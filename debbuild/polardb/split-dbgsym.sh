#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 <package-root> <main.deb> <dbgsym.ddeb>" >&2
  exit 2
fi

package_root=$1
main_deb=$2
dbgsym_deb=$3
control_file=${package_root}/DEBIAN/control
dbgsym_root=${package_root}.dbgsym

[[ -d ${package_root} && -f ${control_file} ]] || {
  echo "invalid package root: ${package_root}" >&2
  exit 1
}
[[ ${dbgsym_deb} == *.ddeb ]] || {
  echo "dbgsym output must end in .ddeb: ${dbgsym_deb}" >&2
  exit 1
}
[[ ! -e ${dbgsym_root} ]] || {
  echo "dbgsym staging path already exists: ${dbgsym_root}" >&2
  exit 1
}

for tool in file readelf objcopy strip dpkg-deb; do
  command -v "${tool}" >/dev/null || {
    echo "missing required tool: ${tool}" >&2
    exit 1
  }
done

main_package=$(sed -n 's/^Package:[[:space:]]*//p' "${control_file}" | head -n 1)
version=$(sed -n 's/^Version:[[:space:]]*//p' "${control_file}" | head -n 1)
architecture=$(sed -n 's/^Architecture:[[:space:]]*//p' "${control_file}" | head -n 1)
maintainer=$(sed -n 's/^Maintainer:[[:space:]]*//p' "${control_file}" | head -n 1)

[[ -n ${main_package} && -n ${version} && -n ${architecture} ]] || {
  echo "package control is missing Package, Version, or Architecture" >&2
  exit 1
}
[[ -n ${maintainer} ]] || maintainer='Ruohang Feng <rh@vonng.com>'

mkdir -p "${dbgsym_root}/DEBIAN" "${dbgsym_root}/usr/lib/debug"
debug_count=0
build_ids=()

while IFS= read -r -d '' elf; do
  file -b "${elf}" | grep -Eq '^ELF .* (executable|shared object)' || continue
  readelf --sections --wide "${elf}" | grep -Eq '\.(z?debug_info|z?debug_line)' || continue

  build_id=$(readelf -n "${elf}" 2>/dev/null | sed -n 's/.*Build ID:[[:space:]]*//p' | head -n 1)
  relative_path=${elf#"${package_root}"/}
  if [[ -n ${build_id} ]]; then
    debug_file=${dbgsym_root}/usr/lib/debug/.build-id/${build_id:0:2}/${build_id:2}.debug
    build_ids+=("${build_id}")
  else
    debug_file=${dbgsym_root}/usr/lib/debug/${relative_path}.debug
  fi

  mkdir -p "$(dirname "${debug_file}")"
  objcopy --only-keep-debug "${elf}" "${debug_file}"
  strip --strip-unneeded "${elf}"
  objcopy --remove-section=.gnu_debuglink --add-gnu-debuglink="${debug_file}" "${elf}"
  chmod 0644 "${debug_file}"
  debug_count=$((debug_count + 1))
done < <(find "${package_root}" -type f -print0)

if (( debug_count == 0 )); then
  echo "no ELF files with DWARF found under ${package_root}" >&2
  exit 1
fi

build_id_list=$(printf '%s\n' "${build_ids[@]}" | LC_ALL=C sort -u | paste -sd ' ' -)
{
  printf 'Package: %s-dbgsym\n' "${main_package}"
  printf 'Version: %s\n' "${version}"
  printf 'Architecture: %s\n' "${architecture}"
  printf 'Maintainer: %s\n' "${maintainer}"
  printf 'Depends: %s (= %s)\n' "${main_package}" "${version}"
  printf 'Section: debug\n'
  printf 'Priority: optional\n'
  printf 'Auto-Built-Package: debug-symbols\n'
  [[ -z ${build_id_list} ]] || printf 'Build-Ids: %s\n' "${build_id_list}"
  printf 'Description: debug symbols for %s\n' "${main_package}"
  printf ' This package contains detached debug symbols for %s.\n' "${main_package}"
} >"${dbgsym_root}/DEBIAN/control"

dpkg-deb --build --root-owner-group "${package_root}" "${main_deb}"
dpkg-deb --build --root-owner-group "${dbgsym_root}" "${dbgsym_deb}"
printf 'split %d ELF files into %s\n' "${debug_count}" "${dbgsym_deb}"
