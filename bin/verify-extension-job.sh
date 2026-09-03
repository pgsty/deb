#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: $0 OUTPUT_DIR PACKAGE_TEMPLATE PG_VERSIONS DEBUG_POLICY SINCE_MARKER" >&2
  echo 'example: verify-extension-job.sh ./pkg "postgresql-$v-pgml" "14 15 16 17" required:non-empty-dbgsym ./job.start' >&2
  exit 2
}

[[ $# -eq 5 ]] || usage

output_dir=$1
package_template=$2
pg_versions=$3
debug_policy=$4
since_marker=$5

[[ -d "$output_dir" ]] || { echo "missing output directory: $output_dir" >&2; exit 1; }
[[ -f "$since_marker" ]] || { echo "missing job marker: $since_marker" >&2; exit 1; }
command -v dpkg-deb >/dev/null || { echo "dpkg-deb is required" >&2; exit 1; }

case "$package_template" in
  *'$v'*) ;;
  *) echo "package template must contain literal \$v: $package_template" >&2; exit 1 ;;
esac

case " $pg_versions " in
  *' 13 '*|*' 19 '*) echo "PG13 and PG19 are forbidden: $pg_versions" >&2; exit 1 ;;
esac

tmp_root=$(mktemp -d)
trap 'rm -rf "$tmp_root"' EXIT

shopt -s nullglob
artifacts=("$output_dir"/*.deb "$output_dir"/*.ddeb)
[[ ${#artifacts[@]} -gt 0 ]] || { echo "no DEB artifacts in $output_dir" >&2; exit 1; }

for pg in $pg_versions; do
  [[ "$pg" =~ ^(14|15|16|17|18)$ ]] || { echo "unsupported PG major: $pg" >&2; exit 1; }
  expected=${package_template//\$v/$pg}
  main_matches=()
  debug_matches=()

  for artifact in "${artifacts[@]}"; do
    [[ -f "$artifact" ]] || continue
    package=$(dpkg-deb -f "$artifact" Package 2>/dev/null || true)
    case "$package" in
      "$expected") main_matches+=("$artifact") ;;
      "$expected-dbgsym") debug_matches+=("$artifact") ;;
    esac
  done

  [[ ${#main_matches[@]} -eq 1 ]] || {
    echo "expected exactly one fresh $expected main package, found ${#main_matches[@]}" >&2
    exit 1
  }

  main=${main_matches[0]}
  [[ "$main" -nt "$since_marker" ]] || {
    echo "main package is not newer than job marker: $main" >&2
    exit 1
  }

  version=$(dpkg-deb -f "$main" Version)
  architecture=$(dpkg-deb -f "$main" Architecture)
  [[ -n "$version" && -n "$architecture" ]] || {
    echo "missing Version/Architecture metadata: $main" >&2
    exit 1
  }

  main_root="$tmp_root/main-$pg"
  mkdir -p "$main_root"
  dpkg-deb -x "$main" "$main_root"
  payload=$(find "$main_root/usr/lib/postgresql/$pg" "$main_root/usr/share/postgresql/$pg" \
    -type f -size +0c -print -quit 2>/dev/null || true)
  [[ -n "$payload" ]] || {
    echo "missing non-empty PostgreSQL $pg payload in $main" >&2
    exit 1
  }

  if [[ "$debug_policy" != N/A:* ]]; then
    [[ ${#debug_matches[@]} -eq 1 ]] || {
      echo "expected exactly one $expected-dbgsym package, found ${#debug_matches[@]}" >&2
      exit 1
    }
    debug=${debug_matches[0]}
    [[ "$debug" -nt "$since_marker" ]] || {
      echo "debug package is not newer than job marker: $debug" >&2
      exit 1
    }
    [[ $(dpkg-deb -f "$debug" Version) == "$version" ]] || {
      echo "main/debug version mismatch for $expected" >&2
      exit 1
    }
    [[ $(dpkg-deb -f "$debug" Architecture) == "$architecture" ]] || {
      echo "main/debug architecture mismatch for $expected" >&2
      exit 1
    }

    debug_root="$tmp_root/debug-$pg"
    mkdir -p "$debug_root"
    dpkg-deb -x "$debug" "$debug_root"
    debug_payload=$(find "$debug_root" -type f -size +0c -print -quit 2>/dev/null || true)
    [[ -n "$debug_payload" ]] || {
      echo "empty debug payload in $debug" >&2
      exit 1
    }
  fi

  printf 'verified pg=%s package=%s version=%s arch=%s payload=%s\n' \
    "$pg" "$expected" "$version" "$architecture" "${payload#$main_root}"
done
