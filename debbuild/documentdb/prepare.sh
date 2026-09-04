#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo 'usage: prepare.sh documentdb-0.116-0.tar.gz intelrdfpmath-applied-2.0u3-1.tar.gz' >&2
  exit 2
fi

TARBALL=$1
INTEL_TARBALL=$2
EXPECTED_TARBALL=documentdb-0.116-0.tar.gz
EXPECTED_INTEL_TARBALL=intelrdfpmath-applied-2.0u3-1.tar.gz
EXPECTED_INTEL_SIZE=5805822
EXPECTED_INTEL_SHA256=3212a37262ce55c9f0bf16103f6a5df0e4ce9e9eea3c2a7866c39097227e5e56
SOURCE=${SOURCE:-}
INTELRDFPMATH_SOURCE=${INTELRDFPMATH_SOURCE:-}
RECIPE_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

if [[ $TARBALL != "$EXPECTED_TARBALL" || $INTEL_TARBALL != "$EXPECTED_INTEL_TARBALL" ]]; then
  echo "unexpected DocumentDB source inputs: $TARBALL $INTEL_TARBALL" >&2
  exit 2
fi

if [[ -z $SOURCE ]]; then
  for candidate in \
    "${HOME}/debbuild/SOURCES/${TARBALL}" \
    "${HOME}/ext/src/${TARBALL}" \
    "${HOME}/pgext/repo/ext/src/${TARBALL}" \
    "${HOME}/pgsty/repo/ext/src/${TARBALL}"; do
    if [[ -f $candidate && ! -L $candidate ]]; then
      SOURCE=$candidate
      break
    fi
  done
fi

if [[ ! -f $SOURCE || -L $SOURCE ]]; then
  echo "source tarball not found: ${TARBALL}" >&2
  exit 1
fi

if [[ -z $INTELRDFPMATH_SOURCE ]]; then
  for candidate in \
    "${HOME}/debbuild/SOURCES/${INTEL_TARBALL}" \
    "${HOME}/ext/src/${INTEL_TARBALL}" \
    "${HOME}/pgext/repo/ext/src/${INTEL_TARBALL}" \
    "${HOME}/pgsty/repo/ext/src/${INTEL_TARBALL}"; do
    if [[ -f $candidate && ! -L $candidate ]]; then
      INTELRDFPMATH_SOURCE=$candidate
      break
    fi
  done
fi

if [[ ! -f $INTELRDFPMATH_SOURCE || -L $INTELRDFPMATH_SOURCE ]]; then
  echo "source tarball not found: ${INTEL_TARBALL}" >&2
  exit 1
fi
if [[ $(stat -c '%s' "$INTELRDFPMATH_SOURCE") != "$EXPECTED_INTEL_SIZE" ]]; then
  echo "unexpected Intel RDFP Math archive size: $INTELRDFPMATH_SOURCE" >&2
  exit 1
fi
if [[ $(sha256sum "$INTELRDFPMATH_SOURCE" | awk '{print $1}') != "$EXPECTED_INTEL_SHA256" ]]; then
  echo "unexpected Intel RDFP Math archive SHA256: $INTELRDFPMATH_SOURCE" >&2
  exit 1
fi
intel_tar_manifest=$(mktemp)
trap 'rm -f -- "$intel_tar_manifest"' EXIT
tar -tf "$INTELRDFPMATH_SOURCE" > "$intel_tar_manifest"
grep -Fx './LIBRARY/makefile' "$intel_tar_manifest" >/dev/null
grep -Fx './LIBRARY/src/bid_functions.h' "$intel_tar_manifest" >/dev/null

echo "extract documentdb scripts to /tmp/install_setup"
rm -rf /tmp/documentdb /tmp/install_setup; mkdir -p /tmp/documentdb;
tar -xf "${SOURCE}" -C /tmp/documentdb --strip-component=1
cp -r /tmp/documentdb/scripts /tmp/install_setup
cd /tmp/install_setup
patch --batch --fuzz=0 -p0 < "$RECIPE_DIR/documentdb-intelrdfpmath-offline.patch"

# CMake 4 rejects old cmake_minimum_required() policy versions in bundled deps.
sed -i 's/cmake \.\./cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ../' install_citus_indent.sh
sed -i 's/$MAKE_PROGRAM /$MAKE_PROGRAM -DCMAKE_POLICY_VERSION_MINIMUM=3.5 /' install_setup_libbson.sh
sed -i "/^mkdir build$/i\\sed -i 's/f\\\\.i/f.m_i/g' src/enum_flags.h" install_citus_indent.sh

echo "install documentdb dependencies"
export CLEANUP_SETUP=1
export INSTALL_DEPENDENCIES_ROOT=/tmp/install_setup
export MAKE_PROGRAM=cmake
export INTELRDFPMATH_SOURCE
./install_setup_libbson.sh
./install_setup_pcre2.sh
./install_setup_intel_decimal_math_lib.sh
./install_citus_indent.sh
