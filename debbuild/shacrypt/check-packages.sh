#!/bin/sh
# Validate the built archives before collecting them, including split DWARF.
set -eu
build_dir=${1:-build}
version=$(dpkg-parsechangelog -l"$build_dir/debian/changelog" -SVersion)
arch=$(dpkg --print-architecture)
versions=$(cd "$build_dir" && pg_buildext supported-versions)
test -n "$versions"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT HUP INT TERM

for pg in $versions; do
    package=postgresql-$pg-shacrypt
    deb=${package}_${version}_${arch}.deb
    debug=${package}-dbgsym_${version}_${arch}.ddeb
    # Debian uses .deb for automatic debug packages; Ubuntu uses .ddeb.
    if [ ! -f "$debug" ]; then
        debug=${package}-dbgsym_${version}_${arch}.deb
    fi
    test -s "$deb"
    test -s "$debug"
    test "$(dpkg-deb -f "$deb" Package)" = "$package"
    test "$(dpkg-deb -f "$debug" Package)" = "$package-dbgsym"
    for archive in "$deb" "$debug"; do
        test "$(dpkg-deb -f "$archive" Version)" = "$version"
        test "$(dpkg-deb -f "$archive" Architecture)" = "$arch"
    done
    root=$scratch/$pg
    mkdir -p "$root/main" "$root/debug"
    dpkg-deb -x "$deb" "$root/main"
    dpkg-deb -x "$debug" "$root/debug"
    lib=$root/main/usr/lib/postgresql/$pg/lib/shacrypt.so
    ext=$root/main/usr/share/postgresql/$pg/extension
    test -s "$lib"
    test -s "$ext/shacrypt.control"
    test -s "$ext/shacrypt--1.1.sql"
    test ! -d "$root/main/usr/share/doc/postgresql-doc-$pg"
    build_id=$(readelf -n "$lib" | sed -n 's/.*Build ID: //p')
    test -n "$build_id"
    prefix=$(printf '%s' "$build_id" | cut -c1-2)
    suffix=$(printf '%s' "$build_id" | cut -c3-)
    dwarf=$root/debug/usr/lib/debug/.build-id/$prefix/$suffix.debug
    test -s "$dwarf"
    readelf -S "$dwarf" > "$root/sections"
    grep -q '\.debug_info' "$root/sections"
    printf 'PASS %s %s %s payload and matching dbgsym\n' "$package" "$version" "$arch"
done
