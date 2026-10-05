#!/usr/bin/env bash
set -Eeuo pipefail

root=${1:?usage: apply-vcpkg-u26a-cwd-fix.sh VCPKG_ROOT u26a}
platform=${2:?usage: apply-vcpkg-u26a-cwd-fix.sh VCPKG_ROOT u26a}
test "$platform" = u26a

expected_commit=cd61e1e26a038e82d6550a3ebbe0fbbfe7da78e3
original_sha=e2f0cfea5cdd7a7569bad8d9a46c67f6e525e6bf540395d6e59c2827dd6b40ae
patched_sha=eb4b9d04df4363890046bf4cfa0be85e74e7c4c090d01bd15456bf6d2a741ecf
helper="$root/scripts/cmake/vcpkg_configure_cmake.cmake"
patch_file=$(cd "$(dirname "$0")" && pwd)/vcpkg-u26a-cwd-stable-workdir.patch

test "$(git -C "$root" rev-parse HEAD)" = "$expected_commit"
actual=$(sha256sum "$helper" | awk '{print $1}')
case "$actual" in
  "$patched_sha")
    echo "status=ALREADY_APPLIED helper_sha=$actual commit=$expected_commit"
    ;;
  "$original_sha")
    patch -d "$root" -p1 --forward --batch <"$patch_file"
    test "$(sha256sum "$helper" | awk '{print $1}')" = "$patched_sha"
    echo "status=APPLIED base_sha=$original_sha helper_sha=$patched_sha commit=$expected_commit"
    ;;
  *)
    echo "unexpected helper sha: $actual" >&2
    exit 1
    ;;
esac
