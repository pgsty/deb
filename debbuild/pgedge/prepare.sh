#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

read_default() {
  awk -v k="$1" '$1==k {print $3; exit}' "${SCRIPT_DIR}/versions.mk"
}

PG_VERSION="${PG_VERSION:-$(read_default PG_VERSION)}"
SPOCK_VERSION="${SPOCK_VERSION:-$(read_default SPOCK_VERSION)}"
SNOWFLAKE_VERSION="${SNOWFLAKE_VERSION:-$(read_default SNOWFLAKE_VERSION)}"
LOLOR_VERSION="${LOLOR_VERSION:-$(read_default LOLOR_VERSION)}"

SPOCK_REPO="${SPOCK_REPO:-https://github.com/pgEdge/spock.git}"
SNOWFLAKE_REPO="${SNOWFLAKE_REPO:-https://github.com/pgEdge/snowflake.git}"
LOLOR_REPO="${LOLOR_REPO:-https://github.com/pgEdge/lolor.git}"

SPOCK_TAG="${SPOCK_TAG:-v${SPOCK_VERSION}}"
SNOWFLAKE_TAG="${SNOWFLAKE_TAG:-v${SNOWFLAKE_VERSION}}"
LOLOR_TAG="${LOLOR_TAG:-v${LOLOR_VERSION}}"

WORK_DIR="${WORK_DIR:-${REPO_ROOT}/tmp/pgedge-src}"
if [ -z "${OUT_DIR:-}" ]; then
  if [ -d "${HOME}/ext/src" ]; then
    OUT_DIR="${HOME}/ext/src"
  elif [ -d "${HOME}/pgsty/repo/ext/src" ]; then
    OUT_DIR="${HOME}/pgsty/repo/ext/src"
  else
    OUT_DIR="${REPO_ROOT}/src"
  fi
fi

mkdir -p "${WORK_DIR}" "${OUT_DIR}"

PG_TARBALL="postgresql-${PG_VERSION}.tar.gz"
SPOCK_TARBALL="spock-${SPOCK_VERSION}.tar.gz"
SNOWFLAKE_TARBALL="snowflake-${SNOWFLAKE_VERSION}.tar.gz"
LOLOR_TARBALL="lolor-${LOLOR_VERSION}.tar.gz"

if [ ! -s "${OUT_DIR}/${PG_TARBALL}" ]; then
  for src_url in \
    "https://repo.pigsty.io/ext/src/${PG_TARBALL}" \
    "https://repo.pigsty.cc/ext/src/${PG_TARBALL}" \
    "https://ftp.postgresql.org/pub/source/v${PG_VERSION}/${PG_TARBALL}"; do
    if curl --retry 5 --retry-delay 2 --retry-all-errors -fL -o "${OUT_DIR}/${PG_TARBALL}" "${src_url}"; then
      break
    fi
  done
fi

if [ ! -s "${OUT_DIR}/${PG_TARBALL}" ]; then
  echo "failed to download ${PG_TARBALL}" >&2
  exit 1
fi

archive_repo() {
  local repo_url="$1"
  local tag="$2"
  local out_tar="$3"
  local prefix="$4"
  local tmp_tar="${WORK_DIR}/${prefix}.download.tar.gz"
  local repo_path
  local archive_url
  local commit="unknown"

  repo_path="${repo_url#https://github.com/}"
  repo_path="${repo_path%.git}"
  archive_url="https://codeload.github.com/${repo_path}/tar.gz/refs/tags/${tag}"

  if [ ! -s "${out_tar}" ]; then
    curl --retry 5 --retry-delay 2 --retry-all-errors -fL -o "${tmp_tar}" "${archive_url}"
    mv -f "${tmp_tar}" "${out_tar}"
  fi

  echo "${commit}"
}

SPOCK_COMMIT="$(archive_repo "${SPOCK_REPO}" "${SPOCK_TAG}" "${OUT_DIR}/${SPOCK_TARBALL}" "spock-${SPOCK_VERSION}")"
SNOWFLAKE_COMMIT="$(archive_repo "${SNOWFLAKE_REPO}" "${SNOWFLAKE_TAG}" "${OUT_DIR}/${SNOWFLAKE_TARBALL}" "snowflake-${SNOWFLAKE_VERSION}")"
LOLOR_COMMIT="$(archive_repo "${LOLOR_REPO}" "${LOLOR_TAG}" "${OUT_DIR}/${LOLOR_TARBALL}" "lolor-${LOLOR_VERSION}")"

BUILD_DATE_UTC="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
MANIFEST="${OUT_DIR}/pgedge-source-manifest-${PG_VERSION}.txt"

cat > "${MANIFEST}" <<MANIFEST_EOF
generated_at_utc=${BUILD_DATE_UTC}
postgresql_version=${PG_VERSION}
postgresql_tarball=${PG_TARBALL}

spock_repo=${SPOCK_REPO}
spock_tag=${SPOCK_TAG}
spock_version=${SPOCK_VERSION}
spock_tarball=${SPOCK_TARBALL}
spock_commit=${SPOCK_COMMIT}

snowflake_repo=${SNOWFLAKE_REPO}
snowflake_tag=${SNOWFLAKE_TAG}
snowflake_version=${SNOWFLAKE_VERSION}
snowflake_tarball=${SNOWFLAKE_TARBALL}
snowflake_commit=${SNOWFLAKE_COMMIT}

lolor_repo=${LOLOR_REPO}
lolor_tag=${LOLOR_TAG}
lolor_version=${LOLOR_VERSION}
lolor_tarball=${LOLOR_TARBALL}
lolor_commit=${LOLOR_COMMIT}
MANIFEST_EOF

echo "Generated: ${OUT_DIR}/${PG_TARBALL}"
echo "Generated: ${OUT_DIR}/${SPOCK_TARBALL}"
echo "Generated: ${OUT_DIR}/${SNOWFLAKE_TARBALL}"
echo "Generated: ${OUT_DIR}/${LOLOR_TARBALL}"
echo "Generated: ${MANIFEST}"
