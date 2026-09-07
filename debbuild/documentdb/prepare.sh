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
LIBBSON_SOURCE=${LIBBSON_SOURCE:-${HOME}/ext/src/mongo-c-driver-1.28.0.tar.gz}
PCRE2_SOURCE=${PCRE2_SOURCE:-${HOME}/ext/src/pcre2-10.40.tar.gz}
UNCRUSTIFY_SOURCE=${UNCRUSTIFY_SOURCE:-${HOME}/ext/src/uncrustify-uncrustify-0.68.1.tar.gz}
CITUS_TOOLS_SOURCE=${CITUS_TOOLS_SOURCE:-${HOME}/ext/src/citus-tools-e36e4ea4258989bf527744334f6c633bb67e0686.tar.gz}
DOCUMENTDB_BUILD_JOBS=${DOCUMENTDB_BUILD_JOBS:-2}

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

for dependency_source in "$LIBBSON_SOURCE" "$PCRE2_SOURCE" "$UNCRUSTIFY_SOURCE" "$CITUS_TOOLS_SOURCE"; do
  test -s "$dependency_source" || { echo "required offline dependency source missing: $dependency_source" >&2; exit 1; }
done
export LIBBSON_SOURCE PCRE2_SOURCE UNCRUSTIFY_SOURCE CITUS_TOOLS_SOURCE
sed -i 's#curl -s -L https://github.com/mongodb/mongo-c-driver/releases/download/$DRIVER_VERSION/mongo-c-driver-$DRIVER_VERSION.tar.gz -o ./mongo-c-driver-$DRIVER_VERSION.tar.gz#cp "$LIBBSON_SOURCE" ./mongo-c-driver-$DRIVER_VERSION.tar.gz#' install_setup_libbson.sh
sed -i 's#curl -L https://github.com/PCRE2Project/pcre2/releases/download/$PCRE_LIB_WITH_VERSION/$PCRE_LIB_WITH_VERSION.tar.gz -o ./$PCRE_LIB_WITH_VERSION.tar.gz#cp "$PCRE2_SOURCE" ./$PCRE_LIB_WITH_VERSION.tar.gz#' install_setup_pcre2.sh
sed -i 's#curl -L https://github.com/uncrustify/uncrustify/archive/${UNCRUSTIFY_REF}.tar.gz | tar xz#tar -xzf "$UNCRUSTIFY_SOURCE"#' install_citus_indent.sh
sed -i 's#git clone https://github.com/citusdata/tools.git#mkdir tools \&\& tar -xf "$CITUS_TOOLS_SOURCE" -C tools --strip-components=1#' install_citus_indent.sh
sed -i '/git checkout e36e4ea4258989bf527744334f6c633bb67e0686/d' install_citus_indent.sh
sed -i 's#make -sj$(cat /proc/cpuinfo | grep -c "processor")#make -sj"${DOCUMENTDB_BUILD_JOBS}"#g' install_setup_libbson.sh install_setup_pcre2.sh
sed -i 's#make -j5#make -j"${DOCUMENTDB_BUILD_JOBS}"#' install_citus_indent.sh

# Upstream setup helpers otherwise allow a stalled download to block the whole
# platform queue indefinitely. Keep their URLs and payloads unchanged while
# making transport failures bounded and visible to the caller.
find /tmp/install_setup -type f -name '*.sh' -exec \
  sed -i 's/curl -s -L/curl --fail --show-error --location --connect-timeout 15 --max-time 300 --retry 2/g' {} +

# CMake 4 rejects old cmake_minimum_required() policy versions in bundled deps.
sed -i 's/cmake \.\./cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ../' install_citus_indent.sh
sed -i 's/$MAKE_PROGRAM /$MAKE_PROGRAM -DCMAKE_POLICY_VERSION_MINIMUM=3.5 /' install_setup_libbson.sh
sed -i "/^mkdir build$/i\\sed -i 's/f\\\\.i/f.m_i/g' src/enum_flags.h" install_citus_indent.sh

echo "install documentdb dependencies"
export CLEANUP_SETUP=1
export INSTALL_DEPENDENCIES_ROOT=/tmp/install_setup
export MAKE_PROGRAM=cmake
export INTELRDFPMATH_SOURCE DOCUMENTDB_BUILD_JOBS
./install_setup_libbson.sh
./install_setup_pcre2.sh
./install_setup_intel_decimal_math_lib.sh
./install_citus_indent.sh
