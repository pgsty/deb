#!/usr/bin/env bash
set -euo pipefail

PARENT_COMMIT=35481dc401864f7cfaf75be7e87d002780b1906f
PARENT_ARCHIVE_SHA256=391dc9ddaa5569a13dafdd9f4127af75c6f84ccacee87d040bcf33593982b438
WHITELIST_COMMIT=fbca6aef6962b20126714eaaa3f55c77f65bb5c3
WHITELIST_ARCHIVE_SHA256=ae7f03e59afe6a769384cd66179fa35892620a2f0832c26ea947b5565963aaa3
SNAPSHOT_VERSION=2.4.6
SOURCE_DATE_EPOCH=1789701776

output_dir=${1:-.}
archive_name="pg_curl-${SNAPSHOT_VERSION}.tar.gz"
root_name="pg_curl-${SNAPSHOT_VERSION}"
work_dir=$(mktemp -d "${TMPDIR:-/tmp}/pg-curl-repack.XXXXXX")
trap 'rm -rf "${work_dir}"' EXIT

if command -v gtar >/dev/null 2>&1; then
    tar_cmd=gtar
elif tar --version 2>/dev/null | grep -q 'GNU tar'; then
    tar_cmd=tar
else
    echo 'GNU tar is required (install gtar on macOS)' >&2
    exit 1
fi

mkdir -p "${output_dir}" "${work_dir}/stage/${root_name}"
curl --fail --location --silent --show-error \
    "https://api.pgxn.org/dist/pg_curl/${SNAPSHOT_VERSION}/pg_curl-${SNAPSHOT_VERSION}.zip" \
    --output "${work_dir}/pg_curl.zip"
curl --fail --location --silent --show-error \
    "https://codeload.github.com/RekGRpth/pg_whitelist/tar.gz/${WHITELIST_COMMIT}" \
    --output "${work_dir}/pg_whitelist.tar.gz"

printf '%s  %s\n' "${PARENT_ARCHIVE_SHA256}" "${work_dir}/pg_curl.zip" | sha256sum -c - >/dev/null
printf '%s  %s\n' "${WHITELIST_ARCHIVE_SHA256}" "${work_dir}/pg_whitelist.tar.gz" | sha256sum -c - >/dev/null

unzip -q "${work_dir}/pg_curl.zip" -d "${work_dir}/stage"
mkdir -p "${work_dir}/stage/${root_name}/pg_whitelist"
"${tar_cmd}" -xzf "${work_dir}/pg_whitelist.tar.gz" --strip-components=1 \
    -C "${work_dir}/stage/${root_name}/pg_whitelist"

printf '%s\n' \
    'Composite-source manifest for the official PGXN pg_curl release.' \
    "pg_curl_commit=${PARENT_COMMIT}" \
    "pg_curl_archive_sha256=${PARENT_ARCHIVE_SHA256}" \
    "pg_whitelist_commit=${WHITELIST_COMMIT}" \
    "pg_whitelist_archive_sha256=${WHITELIST_ARCHIVE_SHA256}" \
    "source_date_epoch=${SOURCE_DATE_EPOCH}" \
    > "${work_dir}/stage/${root_name}/SOURCE-MANIFEST.pgsty"

find "${work_dir}/stage/${root_name}" \
    \( -name '.DS_Store' -o -name '._*' -o -name '.git' \) -print -quit | \
    grep -q . && {
        echo 'unexpected VCS or macOS metadata in composite source' >&2
        exit 1
    }

COPYFILE_DISABLE=1 "${tar_cmd}" \
    --sort=name --no-xattrs --no-acls \
    --mtime="@${SOURCE_DATE_EPOCH}" \
    --owner=0 --group=0 --numeric-owner \
    --format=posix \
    --pax-option=delete=atime,delete=ctime \
    -C "${work_dir}/stage" -cf - "${root_name}" | \
    gzip -n -9 > "${output_dir}/${archive_name}"

sha256sum "${output_dir}/${archive_name}"
