# get documentdb source tarball
# pig build get documentdb

TARBALL=${1-'documentdb-0.114-0.tar.gz'}
SOURCE=${SOURCE:-}
WRAPPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "${SOURCE}" ]; then
  for candidate in \
    "${HOME}/debbuild/SOURCES/${TARBALL}" \
    "${HOME}/ext/src/${TARBALL}" \
    "${HOME}/pgext/repo/ext/src/${TARBALL}" \
    "${HOME}/pgsty/repo/ext/src/${TARBALL}"; do
    if [ -f "${candidate}" ]; then
      SOURCE="${candidate}"
      break
    fi
  done
fi

if [ ! -f "${SOURCE}" ]; then
  echo "source tarball not found: ${TARBALL}" >&2
  exit 1
fi

echo "extract documentdb scripts to /tmp/install_setup"
rm -rf /tmp/documentdb /tmp/install_setup; mkdir -p /tmp/documentdb;
tar -xf "${SOURCE}" -C /tmp/documentdb --strip-component=1
cp -r /tmp/documentdb/scripts /tmp/install_setup
cd /tmp/install_setup
patch -p0 --forward -f < "${WRAPPER_DIR}/documentdb-intelrdfpmath.patch"
patch -p0 --forward -f < "${WRAPPER_DIR}/documentdb-libbson-cache.patch"
patch -p0 --forward -f < "${WRAPPER_DIR}/documentdb-citus-tools-cache.patch"
patch -p0 --forward -f < "${WRAPPER_DIR}/documentdb-source-cache.patch"

LIBBSON_VERSION="$(bash -c '. ./setup_versions.sh; GetLibbsonVersion')"
LIBBSON_ARCHIVE="mongo-c-driver-${LIBBSON_VERSION}.tar.gz"
PCRE2_VERSION="$(bash -c '. ./setup_versions.sh; GetPcre2Version')"
UNCRUSTIFY_REF="$(bash -c '. ./setup_versions.sh; GetUncrustifyVersion')"
CITUS_TOOLS_REF="e36e4ea4258989bf527744334f6c633bb67e0686"

for archive in \
  "${LIBBSON_ARCHIVE}" \
  "pcre2-${PCRE2_VERSION}.tar.gz" \
  "${UNCRUSTIFY_REF}.tar.gz" \
  "citus-tools-${CITUS_TOOLS_REF}.tar.gz"; do
  for candidate in \
    "${HOME}/debbuild/SOURCES/${archive}" \
    "${HOME}/ext/src/${archive}" \
    "${HOME}/pgext/repo/ext/src/${archive}" \
    "${HOME}/pgsty/repo/ext/src/${archive}"; do
    if [ -f "${candidate}" ] && tar -tzf "${candidate}" >/dev/null 2>&1; then
      echo "use cached dependency source: ${candidate}"
      cp -f "${candidate}" "/tmp/install_setup/${archive}"
      break
    fi
  done
done

# CMake 4 rejects old cmake_minimum_required() policy versions in bundled deps.
sed -i 's/cmake \.\./cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ../' install_citus_indent.sh
sed -i 's/$MAKE_PROGRAM /$MAKE_PROGRAM -DCMAKE_POLICY_VERSION_MINIMUM=3.5 /' install_setup_libbson.sh
sed -i "/^mkdir build$/i\\sed -i 's/f\\\\.i/f.m_i/g' src/enum_flags.h" install_citus_indent.sh

echo "install documentdb dependencies"
export CLEANUP_SETUP=1
export INSTALL_DEPENDENCIES_ROOT=/tmp/install_setup
export MAKE_PROGRAM=cmake
./install_setup_libbson.sh
./install_setup_pcre2.sh
./install_setup_intel_decimal_math_lib.sh
./install_citus_indent.sh
