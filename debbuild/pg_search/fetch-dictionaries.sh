#!/bin/sh
set -eu

# Pinned by Lindera 6.2.0 (dictionary format 2) in the upstream Cargo.lock.
# Use curl so dictionary downloads honor the builder's proxy settings.
cache=${LINDERA_BUILD_DICTIONARY_CACHE_DIR:-$HOME/.cache/pg_search/lindera}
mkdir -p "$cache"
cache=$(cd "$cache" && pwd)
dictionary_dir="$cache/6.2.0-fmt2"
mkdir -p "$dictionary_dir"

fetch_dictionary() {
    archive="$dictionary_dir/$1"
    digest="$2"
    if [ -f "$archive" ] && printf '%s  %s\n' "$digest" "$archive" | sha256sum -c -; then
        return
    fi
    temporary=$(mktemp "$archive.XXXXXX")
    if ! curl --fail --location --retry 5 --connect-timeout 20 --max-time 600 \
        --output "$temporary" "https://lindera.dev/$1" || \
        ! printf '%s  %s\n' "$digest" "$temporary" | sha256sum -c -; then
        rm -f "$temporary"
        return 1
    fi
    mv "$temporary" "$archive"
}

fetch_dictionary mecab-ipadic-2.7.0-20250920.tar.gz a7ba9f645ffe7094e56ae1c4a81d100df8fbb1e28bbe1792622e9728e162db3d
fetch_dictionary mecab-ko-dic-2.1.1-20180720.tar.gz 702ced21c6167e9d9aebc674ab5ee54af58d4443975f2940d37d0567c020591a
fetch_dictionary CC-CEDICT-MeCab-0.1.0-20200409.tar.gz ed3cf9e3ec8a80647f0ec783dc09dad43b8ccad2e994f5eab6ff13a41d0916c8
