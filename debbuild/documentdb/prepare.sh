# get documentdb source tarball
# pig build get documentdb

echo "extract documentdb scripts to /tmp/install_setup"
rm -rf /tmp/documentdb /tmp/install_setup; mkdir -p /tmp/documentdb;
tar -xf ~/ext/src/$1 -C /tmp/documentdb --strip-component=1
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
