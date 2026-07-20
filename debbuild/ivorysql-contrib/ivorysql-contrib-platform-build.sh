#!/usr/bin/env bash
# Install build dependencies and build one native Debian/Ubuntu target.
set -Eeuo pipefail

mode="${1:-all}"
recipe_dir="${IVORYSQL_RECIPE_DIR:-$(cd "$(dirname "$0")" && pwd)}"
output_dir="${PKG_OUTPUT_DIR:-${recipe_dir}/out}"
jobs="${IVORYSQL_BUILD_JOBS:-$(nproc)}"

case "${mode}" in
  deps|build|all) ;;
  *)
    printf 'usage: %s [deps|build|all]\n' "$0" >&2
    exit 2
    ;;
esac

install_dependencies() {
  test "${EUID}" -eq 0 || {
    printf 'dependency installation must run as root\n' >&2
    exit 1
  }
  if ! command -v equivs-build >/dev/null 2>&1; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends equivs
  fi
  make -C "${recipe_dir}" setup
  (
    cd "${recipe_dir}"
    DEBIAN_FRONTEND=noninteractive mk-build-deps \
      --install --remove \
      --tool 'apt-get -y -o Debug::pkgProblemResolver=yes --no-install-recommends' \
      build/debian/control
  )
}

build_package() {
  test -d "${recipe_dir}/build/debian" || make -C "${recipe_dir}" setup
  mkdir -p "${output_dir}"
  IVORYSQL_BUILD_JOBS="${jobs}" PKG_OUTPUT_DIR="${output_dir}" \
    make -C "${recipe_dir}" build verify move
}

if [[ "${mode}" == deps || "${mode}" == all ]]; then
  install_dependencies
fi
if [[ "${mode}" == build || "${mode}" == all ]]; then
  build_package
fi
