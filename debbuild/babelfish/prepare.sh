#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

CORE_REPO="${CORE_REPO:-https://github.com/babelfish-for-postgresql/postgresql_modified_for_babelfish.git}"
EXT_REPO="${EXT_REPO:-https://github.com/babelfish-for-postgresql/babelfish_extensions.git}"
PG_MAJOR="${PG_MAJOR:-17}"
CORE_BRANCH="${CORE_BRANCH:-BABEL_5_4_STABLE__PG_17_7}"
EXT_BRANCH="${EXT_BRANCH:-BABEL_5_4_STABLE}"
PG_VERSION="${PG_VERSION:-17.7}"
BBF_VERSION="${BBF_VERSION:-5.4.0}"

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
BUILD_DATE_UTC="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

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

${TAR_BIN} -C "${WORK_DIR}" -czf "${OUT_DIR}/${TARBALL}" "$(basename "${ROOT_DIR}")"

echo "Generated: ${OUT_DIR}/${TARBALL}"
echo "Core commit: ${CORE_COMMIT}"
echo "Ext  commit: ${EXT_COMMIT}"
