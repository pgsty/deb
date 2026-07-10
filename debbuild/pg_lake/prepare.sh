#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

VERSION="${VERSION:-3.4.0}"
UPSTREAM_REPO="${UPSTREAM_REPO:-https://github.com/Snowflake-Labs/pg_lake.git}"
EXPECTED_UPSTREAM_COMMIT="${EXPECTED_UPSTREAM_COMMIT:-9242798331c415358490587670e4b81a9d4eb4e7}"
EXPECTED_AVRO_COMMIT="${EXPECTED_AVRO_COMMIT:-2b11dba4fb28c7bb6ff08b40509a6a71fcaf4c21}"
EXPECTED_DUCKDB_COMMIT="${EXPECTED_DUCKDB_COMMIT:-6ddac802ffa9bcfbcc3f5f0d71de5dff9b0bc250}"
EXPECTED_DUCKDB_POSTGRES_COMMIT="${EXPECTED_DUCKDB_POSTGRES_COMMIT:-b63ef4b1eb007320840b6d1760f3c9b139bb3b49}"
EXPECTED_DUCKDB_HTTPFS_COMMIT="${EXPECTED_DUCKDB_HTTPFS_COMMIT:-13f8a814d41a978c3f19eb1dc76069489652ea6f}"
EXPECTED_DUCKDB_AWS_COMMIT="${EXPECTED_DUCKDB_AWS_COMMIT:-bc15d211f282d1d78fc0d9fda3d09957ba776423}"
EXPECTED_DUCKDB_AZURE_COMMIT="${EXPECTED_DUCKDB_AZURE_COMMIT:-7e1ac3333d946a6bf5b4552722743e03f30a47cd}"
WORK_DIR="${WORK_DIR:-${REPO_ROOT}/tmp/pg_lake-src}"
# This is a maintainer refresh helper.  Write a candidate archive by default;
# promotion and SHA updates are an explicit review step.
OUT_DIR="${OUT_DIR:-${SCRIPT_DIR}/candidate}"
SOURCE_DIR="${WORK_DIR}/pg_lake-${VERSION}"
TARBALL="pg_lake-${VERSION}.tar.gz"

if command -v gtar >/dev/null 2>&1; then
    TAR_BIN=gtar
else
    TAR_BIN=tar
fi

rm -rf "${SOURCE_DIR}"
mkdir -p "${WORK_DIR}" "${OUT_DIR}"

git clone --filter=blob:none --depth 1 --branch "v${VERSION}" \
    "${UPSTREAM_REPO}" "${SOURCE_DIR}"

git -C "${SOURCE_DIR}" submodule update --init --depth 1 --filter=blob:none \
    avro \
    duckdb_pglake/duckdb \
    duckdb_pglake/duckdb-postgres

# Polaris is only needed by the REST-catalog test suite.  Keep the stock
# `make submodules` target from fetching it during a package build.
git -C "${SOURCE_DIR}" config submodule.test_common/rest_catalog/polaris.update none

UPSTREAM_COMMIT="$(git -C "${SOURCE_DIR}" rev-parse HEAD)"
AVRO_COMMIT="$(git -C "${SOURCE_DIR}/avro" rev-parse HEAD)"
DUCKDB_COMMIT="$(git -C "${SOURCE_DIR}/duckdb_pglake/duckdb" rev-parse HEAD)"
DUCKDB_POSTGRES_COMMIT="$(git -C "${SOURCE_DIR}/duckdb_pglake/duckdb-postgres" rev-parse HEAD)"
SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-$(git -C "${SOURCE_DIR}" show -s --format=%ct HEAD)}"
BUILD_DATE_UTC="${BUILD_DATE_UTC:-$(python3 -c 'import datetime, sys; print(datetime.datetime.fromtimestamp(int(sys.argv[1]), datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))' "${SOURCE_DATE_EPOCH}")}"

test "${UPSTREAM_COMMIT}" = "${EXPECTED_UPSTREAM_COMMIT}"
test "${AVRO_COMMIT}" = "${EXPECTED_AVRO_COMMIT}"
test "${DUCKDB_COMMIT}" = "${EXPECTED_DUCKDB_COMMIT}"
test "${DUCKDB_POSTGRES_COMMIT}" = "${EXPECTED_DUCKDB_POSTGRES_COMMIT}"
grep -q "GIT_TAG ${EXPECTED_DUCKDB_HTTPFS_COMMIT}" "${SOURCE_DIR}/duckdb_pglake/extension_config.cmake"
grep -q "GIT_TAG ${EXPECTED_DUCKDB_AWS_COMMIT}" "${SOURCE_DIR}/duckdb_pglake/extension_config.cmake"
grep -q "GIT_TAG ${EXPECTED_DUCKDB_AZURE_COMMIT}" "${SOURCE_DIR}/duckdb_pglake/extension_config.cmake"

find "${SOURCE_DIR}" -name .DS_Store -delete
test -z "$(git -C "${SOURCE_DIR}" status --porcelain --untracked-files=all --ignore-submodules=dirty)"
for repo in \
    "${SOURCE_DIR}/avro" \
    "${SOURCE_DIR}/duckdb_pglake/duckdb" \
    "${SOURCE_DIR}/duckdb_pglake/duckdb-postgres"; do
    test -z "$(git -C "${repo}" status --porcelain --untracked-files=all --ignore-submodules=dirty)"
done

cat > "${SOURCE_DIR}/SOURCE_MANIFEST" <<EOF
name=pg_lake
version=${VERSION}
build_date_utc=${BUILD_DATE_UTC}
upstream_repo=${UPSTREAM_REPO}
upstream_tag=v${VERSION}
upstream_commit=${UPSTREAM_COMMIT}
avro_commit=${AVRO_COMMIT}
duckdb_commit=${DUCKDB_COMMIT}
duckdb_postgres_commit=${DUCKDB_POSTGRES_COMMIT}
duckdb_httpfs_commit=${EXPECTED_DUCKDB_HTTPFS_COMMIT}
duckdb_aws_commit=${EXPECTED_DUCKDB_AWS_COMMIT}
duckdb_azure_commit=${EXPECTED_DUCKDB_AZURE_COMMIT}
polaris_included=false
EOF

test "$(git -C "${SOURCE_DIR}" status --porcelain --untracked-files=all --ignore-submodules=dirty)" = "?? SOURCE_MANIFEST"
if ! "${TAR_BIN}" --version 2>/dev/null | grep -q 'GNU tar'; then
    echo "GNU tar is required for a normalized source archive" >&2
    exit 1
fi

# Reflogs contain clone-time timestamps but are not needed by the build-time
# commit, status, checkout, or apply checks.
find "${SOURCE_DIR}/.git" -type d -name logs -prune -exec rm -rf {} +

COPYFILE_DISABLE=1 GZIP=-n "${TAR_BIN}" \
    --sort=name \
    --mtime="@${SOURCE_DATE_EPOCH}" \
    --owner=0 --group=0 --numeric-owner \
    --pax-option=delete=atime,delete=ctime \
    -C "${WORK_DIR}" -czf "${OUT_DIR}/${TARBALL}" \
    "$(basename "${SOURCE_DIR}")"

echo "Generated: ${OUT_DIR}/${TARBALL}"
if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "${OUT_DIR}/${TARBALL}"
else
    shasum -a 256 "${OUT_DIR}/${TARBALL}"
fi
cat "${SOURCE_DIR}/SOURCE_MANIFEST"
cat <<EOF
This is a candidate maintainer snapshot; it does not replace the authoritative
Source0 automatically.  After review, copy it into the shared source store and
update SOURCE_SHA256 in the DEB Makefile plus source_sha256 in the RPM spec.
EOF
