# get documentdb source tarball
# pig build get documentdb

TARBALL=${1-'documentdb-0.110-0.tar.gz'}
SOURCE=${SOURCE:-}

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

echo "install documentdb dependencies"
export CLEANUP_SETUP=1
export INSTALL_DEPENDENCIES_ROOT=/tmp/install_setup
export MAKE_PROGRAM=cmake
./install_setup_libbson.sh
./install_setup_pcre2.sh
./install_setup_intel_decimal_math_lib.sh
./install_citus_indent.sh
