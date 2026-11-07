#!/usr/bin/env bash
set -euo pipefail

PARENT_COMMIT=6abdb3dbe81c0e320eebeeb0120cff993d593b31
PGXN_ARCHIVE_SHA256=6e28b6e49409e50b47d49835352c8ae9e6d722573073cffe31336a6728f38ca5
PGXN_SHA1=fcd18d962f4b273b8ea5868f144ebf97f1569769
WHITELIST_COMMIT=9001c0cb09483e0828c2578f8e842cf00268a44e
WHITELIST_ARCHIVE_SHA256=b07e49d409a40b3000119fa8a74c9064266fdb231a1906045e14dda592460595
SNAPSHOT_VERSION=2.5.0
SOURCE_DATE_EPOCH=1793936434

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

mkdir -p "${output_dir}" "${work_dir}/stage/${root_name}" "${work_dir}/pgxn"
curl --fail --location --silent --show-error \
    "https://api.pgxn.org/dist/pg_curl/${SNAPSHOT_VERSION}/pg_curl-${SNAPSHOT_VERSION}.zip" \
    --output "${work_dir}/pg_curl.zip"
curl --fail --location --silent --show-error \
    "https://codeload.github.com/RekGRpth/pg_whitelist/tar.gz/${WHITELIST_COMMIT}" \
    --output "${work_dir}/pg_whitelist.tar.gz"

printf '%s  %s\n' "${PGXN_ARCHIVE_SHA256}" "${work_dir}/pg_curl.zip" | sha256sum -c - >/dev/null
printf '%s  %s\n' "${WHITELIST_ARCHIVE_SHA256}" "${work_dir}/pg_whitelist.tar.gz" | sha256sum -c - >/dev/null

unzip -q "${work_dir}/pg_curl.zip" -d "${work_dir}/pgxn"
pgxn_root=$(find "${work_dir}/pgxn" -mindepth 1 -maxdepth 1 -type d -name 'pg_curl-*' -print -quit)
test -n "${pgxn_root}"
cp -Rp "${pgxn_root}/." "${work_dir}/stage/${root_name}/"
mkdir -p "${work_dir}/stage/${root_name}/pg_whitelist"
"${tar_cmd}" -xzf "${work_dir}/pg_whitelist.tar.gz" --strip-components=1 \
    -C "${work_dir}/stage/${root_name}/pg_whitelist"

printf '%s\n' \
    'Composite-source manifest for the official PGXN pg_curl 2.5.0 release.' \
    "pg_curl_version=${SNAPSHOT_VERSION}" \
    "pg_curl_git_commit=${PARENT_COMMIT}" \
    "pg_curl_pgxn_zip_sha256=${PGXN_ARCHIVE_SHA256}" \
    "pg_curl_pgxn_sha1=${PGXN_SHA1}" \
    "pg_whitelist_git_commit=${WHITELIST_COMMIT}" \
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
