#!/bin/bash

# script to create debbuild.tar.gz and upload to pigsty.cc / pigsty.io

PROG_NAME="$(basename $0)"
BIN_DIR="$(cd $(dirname $0) && pwd)"
HOME_DIR="$(cd ${BIN_DIR}/.. && pwd)"
TMP_DIR="$HOME_DIR/tmp"
DEBBUILD_DIR="$HOME_DIR/debbuild"
TARBALL_NAME="debbuild.tar.gz"

# make tarball
echo "build tmp/debbuild"
rm -rf "${TMP_DIR}/debbuild"
cp -r ${DEBBUILD_DIR} ${TMP_DIR}
cd "${TMP_DIR}"
gtar -zcf debbuild.tar.gz debbuild
RPM_TARBALL="${TMP_DIR}/${TARBALL_NAME}"

# print info
ls -alh "${TARBALL_NAME}"
md5sum  "${TARBALL_NAME}"

# upload to cloud
cp "${TARBALL_NAME}" ~/pgsty/repo/ext/spec/${TARBALL_NAME}
rclone copyto "${TARBALL_NAME}" "cos:/repo-1304744452/ext/spec/${TARBALL_NAME}"
rclone copyto "${TARBALL_NAME}" "cf:/repo/ext/spec/${TARBALL_NAME}"

# you can get it from:
# https://repo.pigsty.cc/ext/spec/debbuild.tar.gz
# https://repo.pigsty.io/ext/spec/debbuild.tar.gz
