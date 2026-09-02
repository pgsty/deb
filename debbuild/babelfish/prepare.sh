#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

CORE_REPO="${CORE_REPO:-https://github.com/babelfish-for-postgresql/postgresql_modified_for_babelfish.git}"
EXT_REPO="${EXT_REPO:-https://github.com/babelfish-for-postgresql/babelfish_extensions.git}"
PG_MAJOR="${PG_MAJOR:-17}"
CORE_BRANCH="${CORE_BRANCH:-BABEL_5_7_STABLE__PG_17_11}"
EXT_BRANCH="${EXT_BRANCH:-BABEL_5_7_STABLE}"
PG_VERSION="${PG_VERSION:-17.10}"
BBF_VERSION="${BBF_VERSION:-5.7.0}"

case "${PG_MAJOR}:${PG_VERSION}:${BBF_VERSION}" in
  17:17.10:5.7.0)
    DEFAULT_CORE_COMMIT=aeb4cba9fc9df661a38e1c6b322e6a3965bd7de6
    DEFAULT_EXT_COMMIT=caebb7f5cd6a61fd0bd9969a3b39a3fb972daf14
    ;;
  18:18.4:6.2.0)
    DEFAULT_CORE_COMMIT=a7ed74e5b8aa868f1b25cc5930eac9f737393640
    DEFAULT_EXT_COMMIT=c1194a14f4c9be163c9cc1cc4a1d5598adee5ea3
    ;;
  *)
    DEFAULT_CORE_COMMIT=
    DEFAULT_EXT_COMMIT=
    ;;
esac
EXPECTED_CORE_COMMIT="${EXPECTED_CORE_COMMIT:-${DEFAULT_CORE_COMMIT}}"
EXPECTED_EXT_COMMIT="${EXPECTED_EXT_COMMIT:-${DEFAULT_EXT_COMMIT}}"

WORK_DIR="${WORK_DIR:-${REPO_ROOT}/tmp/babelfish-src}"
OUT_DIR="${OUT_DIR:-${REPO_ROOT}/src}"
TARBALL="babelfish-${PG_MAJOR}-${PG_VERSION}-${BBF_VERSION}.tar.gz"
ROOT_DIR="${WORK_DIR}/babelfish-${PG_MAJOR}-${PG_VERSION}-${BBF_VERSION}"

if command -v gtar >/dev/null 2>&1; then
  TAR_BIN=gtar
else
  TAR_BIN=tar
fi

mkdir -p "${WORK_DIR}" "${OUT_DIR}"
rm -rf "${WORK_DIR}/core" "${WORK_DIR}/ext" "${ROOT_DIR}"

git clone --depth 1 --branch "${CORE_BRANCH}" "${CORE_REPO}" "${WORK_DIR}/core"
git clone --depth 1 --branch "${EXT_BRANCH}" "${EXT_REPO}" "${WORK_DIR}/ext"

mkdir -p "${ROOT_DIR}/postgresql_modified_for_babelfish"
mkdir -p "${ROOT_DIR}/babelfish_extensions"

git -C "${WORK_DIR}/core" archive --format=tar HEAD | ${TAR_BIN} -xf - -C "${ROOT_DIR}/postgresql_modified_for_babelfish"
git -C "${WORK_DIR}/ext" archive --format=tar HEAD | ${TAR_BIN} -xf - -C "${ROOT_DIR}/babelfish_extensions"

CORE_COMMIT="$(git -C "${WORK_DIR}/core" rev-parse HEAD)"
EXT_COMMIT="$(git -C "${WORK_DIR}/ext" rev-parse HEAD)"
ACTUAL_PG_VERSION="$(sed -n 's/^AC_INIT(\[PostgreSQL\], \[\([^]]*\)\].*/\1/p' "${WORK_DIR}/core/configure.ac" | head -1)"
SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-$(git -C "${WORK_DIR}/ext" show -s --format=%ct HEAD)}"
BUILD_DATE_UTC="$(python3 -c 'import datetime, sys; print(datetime.datetime.fromtimestamp(int(sys.argv[1]), datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))' "${SOURCE_DATE_EPOCH}")"

if [[ "${ACTUAL_PG_VERSION}" != "${PG_VERSION}" ]]; then
  echo "source declares PostgreSQL ${ACTUAL_PG_VERSION}, not requested ${PG_VERSION}" >&2
  exit 1
fi
if [[ -n "${EXPECTED_CORE_COMMIT}" ]]; then
  test "${CORE_COMMIT}" = "${EXPECTED_CORE_COMMIT}"
fi
if [[ -n "${EXPECTED_EXT_COMMIT}" ]]; then
  test "${EXT_COMMIT}" = "${EXPECTED_EXT_COMMIT}"
fi

cat > "${ROOT_DIR}/SOURCE_MANIFEST" <<EOF
name=babelfish
pg_major=${PG_MAJOR}
pg_version=${PG_VERSION}
babelfish_version=${BBF_VERSION}
build_date_utc=${BUILD_DATE_UTC}
core_repo=${CORE_REPO}
core_branch=${CORE_BRANCH}
core_commit=${CORE_COMMIT}
ext_repo=${EXT_REPO}
ext_branch=${EXT_BRANCH}
ext_commit=${EXT_COMMIT}
EOF

if ! "${TAR_BIN}" --version 2>/dev/null | grep -q 'GNU tar'; then
  echo "GNU tar is required for normalized Babelfish bundles" >&2
  exit 1
fi

COPYFILE_DISABLE=1 GZIP=-n "${TAR_BIN}" \
  --sort=name \
  --mtime="@${SOURCE_DATE_EPOCH}" \
  --owner=0 --group=0 --numeric-owner \
  --pax-option=delete=atime,delete=ctime \
  --exclude='*/.git' --exclude='*/.git/*' \
  --exclude='*/.DS_Store' --exclude='*/._*' \
  -C "${WORK_DIR}" -czf "${OUT_DIR}/${TARBALL}" "$(basename "${ROOT_DIR}")"

echo "Generated: ${OUT_DIR}/${TARBALL}"
echo "Core commit: ${CORE_COMMIT}"
echo "Ext  commit: ${EXT_COMMIT}"
if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "${OUT_DIR}/${TARBALL}"
else
  shasum -a 256 "${OUT_DIR}/${TARBALL}"
fi
