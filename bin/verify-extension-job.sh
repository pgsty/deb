#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
usage:
  verify-extension-job.sh verify OUTPUT_DIR RECIPE_DIR PACKAGE_TEMPLATE PG_VERSIONS DEBUG_POLICY EXPECTED_ARCH JOB_KIND SINCE_MARKER
  verify-extension-job.sh run    OUTPUT_DIR RECIPE_DIR PACKAGE_TEMPLATE PG_VERSIONS DEBUG_POLICY EXPECTED_ARCH JOB_KIND BUILD_TARGET

PG_VERSIONS is a space-separated non-empty list for JOB_KIND=extension and '-'
for JOB_KIND=support. BUILD_TARGET is '-' for the recipe default target.
EOF
  exit 2
}

die() {
  echo "$*" >&2
  exit 1
}

contains_word() {
  local needle=$1
  shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

normalize_arch() {
  case "$1" in
    x86_64|amd64) echo amd64 ;;
    aarch64|arm64) echo arm64 ;;
    *) die "unsupported expected architecture: $1" ;;
  esac
}

verify_job() {
  local version_placeholder=\$v
  [[ -d "$output_dir" ]] || die "missing output directory: $output_dir"
  [[ -d "$recipe_dir" ]] || die "missing recipe directory: $recipe_dir"
  [[ -f "$since_marker" ]] || die "missing job marker: $since_marker"
  command -v dpkg-deb >/dev/null || die "dpkg-deb is required"
  command -v dpkg-parsechangelog >/dev/null || die "dpkg-parsechangelog is required"
  command -v file >/dev/null || die "file is required"
  command -v readelf >/dev/null || die "readelf is required"

  expected_arch=$(normalize_arch "$expected_arch_input")
  case "$job_kind" in
    extension)
      [[ "$package_template" == *"$version_placeholder"* ]] || die "extension package template must contain literal \$v"
      [[ "$pg_versions" != "-" && -n "$pg_versions" ]] || die "extension PG version list is empty"
      ;;
    support)
      [[ "$package_template" != *"$version_placeholder"* ]] || die "support package template must not contain \$v"
      [[ "$pg_versions" == "-" ]] || die "support PG version list must be '-'"
      ;;
    *) die "unsupported job kind: $job_kind" ;;
  esac

  expected_pgs=()
  declare -A pg_seen=()
  if [[ "$job_kind" == extension ]]; then
    read -r -a expected_pgs <<<"$pg_versions"
    [[ ${#expected_pgs[@]} -gt 0 ]] || die "extension PG version list is empty"
    local pg
    for pg in "${expected_pgs[@]}"; do
      [[ "$pg" =~ ^(14|15|16|17|18)$ ]] || die "unsupported PG major: $pg"
      [[ -z ${pg_seen[$pg]+x} ]] || die "duplicate PG major: $pg"
      pg_seen[$pg]=1
    done
  fi

  packaging_dirs=()
  for candidate in "$recipe_dir/build/debian" "$recipe_dir/build/buildsrc/debian"; do
    [[ -s "$candidate/control" && -s "$candidate/changelog" ]] && packaging_dirs+=("$candidate")
  done
  [[ ${#packaging_dirs[@]} -eq 1 ]] || die "expected exactly one generated Debian packaging directory, found ${#packaging_dirs[@]}"
  control_file="${packaging_dirs[0]}/control"
  changelog_file="${packaging_dirs[0]}/changelog"
  expected_version=$(dpkg-parsechangelog -l"$changelog_file" -SVersion)
  [[ -n "$expected_version" ]] || die "empty expected package version"
  [[ "$expected_version" == *PGSTY* ]] || die "expected version does not contain PGSTY: $expected_version"

  mapfile -t expected_packages < <(
    sed -n -E 's/^Package:[[:space:]]*([^[:space:]]+).*$/\1/p' "$control_file" | sort -u
  )
  [[ ${#expected_packages[@]} -gt 0 ]] || die "generated control declares no binary packages"

  declare -A expected_package_set=()
  local package
  for package in "${expected_packages[@]}"; do
    [[ -n "$package" ]] || die "empty Package field in generated control"
    [[ -z ${expected_package_set[$package]+x} ]] || die "duplicate generated Package: $package"
    expected_package_set[$package]=1
  done

  primary_packages=()
  recipe_name=${recipe_dir##*/}
  custom_root_prefix=
  case "$recipe_name" in
    babelfish*) custom_root_prefix=babelfish ;;
    ivorysql*) custom_root_prefix=ivory ;;
    openhalodb*) custom_root_prefix=halo ;;
    orioledb*) custom_root_prefix=oriole ;;
    pgedge*) custom_root_prefix=pgedge ;;
    pgtde*) custom_root_prefix=pgtde ;;
  esac
  if [[ "$job_kind" == extension ]]; then
    local expected
    for pg in "${expected_pgs[@]}"; do
      expected=${package_template//\$v/$pg}
      [[ -n ${expected_package_set[$expected]+x} ]] || die "generated control does not declare expected package: $expected"
      primary_packages+=("$expected")
    done

    template_regex="^${package_template//\$v/(14|15|16|17|18)}$"
    for package in "${expected_packages[@]}"; do
      if [[ "$package" =~ $template_regex ]]; then
        pg=${BASH_REMATCH[1]}
        [[ -n ${pg_seen[$pg]+x} ]] || die "generated control declares unexpected PG package: $package"
      fi
    done
  else
    [[ -n ${expected_package_set[$package_template]+x} ]] || die "generated control does not declare support package: $package_template"
    primary_packages+=("$package_template")
  fi

  shopt -s nullglob
  artifacts=("$output_dir"/*.deb "$output_dir"/*.ddeb)
  [[ ${#artifacts[@]} -gt 0 ]] || die "no DEB artifacts in $output_dir"

  declare -A artifact_by_package=()
  local artifact version architecture
  for artifact in "${artifacts[@]}"; do
    [[ -f "$artifact" ]] || continue
    package=$(dpkg-deb -f "$artifact" Package 2>/dev/null || true)
    [[ -n "$package" ]] || die "cannot read Package metadata: $artifact"
    [[ -z ${artifact_by_package[$package]+x} ]] || die "duplicate artifact package: $package"
    artifact_by_package[$package]=$artifact
  done

  for package in "${!artifact_by_package[@]}"; do
    if [[ -n ${expected_package_set[$package]+x} ]]; then
      continue
    fi
    if [[ "$package" == *-dbgsym ]]; then
      base_package=${package%-dbgsym}
      [[ -n ${expected_package_set[$base_package]+x} ]] && continue
    fi
    die "unexpected artifact package: $package"
  done

  tmp_root=$(mktemp -d)
  trap 'rm -rf "$tmp_root"' EXIT
  native_packages=0

  for package in "${expected_packages[@]}"; do
    [[ -n ${artifact_by_package[$package]+x} ]] || die "missing declared binary package: $package"
    artifact=${artifact_by_package[$package]}
    [[ "$artifact" -nt "$since_marker" ]] || die "artifact is not newer than job marker: $artifact"
    version=$(dpkg-deb -f "$artifact" Version)
    architecture=$(dpkg-deb -f "$artifact" Architecture)
    [[ "$version" == "$expected_version" ]] || die "version mismatch for $package: got $version expected $expected_version"
    [[ "$architecture" == "$expected_arch" || "$architecture" == all ]] || die "architecture mismatch for $package: got $architecture expected $expected_arch or all"

    package_root="$tmp_root/$package"
    mkdir -p "$package_root"
    dpkg-deb -x "$artifact" "$package_root"
    useful_payload=$(find "$package_root" -type f -size +0c \
      ! -path '*/usr/share/doc/*' ! -path '*/usr/share/man/*' \
      ! -path '*/usr/share/lintian/*' -print -quit 2>/dev/null || true)
    [[ -n "$useful_payload" ]] || die "package has only empty or documentation payload: $package"

    elf_files=()
    while IFS= read -r -d '' candidate; do
      if file -b "$candidate" | grep -q '^ELF '; then
        elf_files+=("$candidate")
      fi
    done < <(find "$package_root" -type f -size +0c -print0)

    is_primary=false
    contains_word "$package" "${primary_packages[@]}" && is_primary=true
    if [[ "$job_kind" == extension && "$is_primary" == true ]]; then
      prefix=${package_template%%"$version_placeholder"*}
      suffix=${package_template#*"$version_placeholder"}
      pg=${package#"$prefix"}
      pg=${pg%"$suffix"}
      control_payload=$(find "$package_root/usr/share/postgresql/$pg/extension" -maxdepth 1 \
        -type f -name '*.control' -size +0c -print -quit 2>/dev/null || true)
      sql_payload=$(find "$package_root/usr/share/postgresql/$pg/extension" -maxdepth 1 \
        -type f -name '*.sql' -size +0c -print -quit 2>/dev/null || true)
      if [[ ${#elf_files[@]} -eq 0 ]]; then
        [[ "$architecture" == all ]] || die "SQL-only primary package is not Architecture: all: $package"
        [[ -n "$control_payload" && -n "$sql_payload" ]] || die "SQL-only package lacks non-empty control/SQL payload for PG$pg: $package"
      elif [[ -n "$custom_root_prefix" ]]; then
        custom_payload=
        for custom_root in "$package_root/usr/${custom_root_prefix}-"*; do
          [[ -d "$custom_root" ]] || continue
          custom_payload=$(find "$custom_root" -type f -size +0c -print -quit 2>/dev/null || true)
          [[ -n "$custom_payload" ]] && break
        done
        [[ -n "$custom_payload" ]] || die "custom-prefix package lacks non-empty /usr/${custom_root_prefix}-* payload: $package"
      else
        native_pg_payload=
        while IFS= read -r -d '' candidate; do
          if file -b "$candidate" | grep -q '^ELF '; then
            native_pg_payload=$candidate
            break
          fi
        done < <(find "$package_root/usr/lib/postgresql/$pg" -type f -size +0c -print0 2>/dev/null)
        [[ -n "$native_pg_payload" ]] || die "native package lacks an ELF under the PostgreSQL $pg library root: $package"
        if [[ -n "$control_payload" || -n "$sql_payload" ]]; then
          [[ -n "$control_payload" && -n "$sql_payload" ]] || die "native extension has incomplete control/SQL payload for PG$pg: $package"
        fi
      fi
    fi

    debug_package="$package-dbgsym"
    if [[ ${#elf_files[@]} -gt 0 ]]; then
      ((native_packages += 1))
      [[ "$debug_policy" != N/A:* ]] || die "native package is marked debug N/A: $package"
      [[ "$architecture" == "$expected_arch" ]] || die "native package has wrong architecture: $package"
      [[ -n ${artifact_by_package[$debug_package]+x} ]] || die "missing dbgsym package: $debug_package"
      debug_artifact=${artifact_by_package[$debug_package]}
      [[ "$debug_artifact" -nt "$since_marker" ]] || die "dbgsym is not newer than job marker: $debug_artifact"
      [[ $(dpkg-deb -f "$debug_artifact" Version) == "$expected_version" ]] || die "dbgsym version mismatch: $debug_package"
      [[ $(dpkg-deb -f "$debug_artifact" Architecture) == "$expected_arch" ]] || die "dbgsym architecture mismatch: $debug_package"
      debug_root="$tmp_root/$debug_package"
      mkdir -p "$debug_root"
      dpkg-deb -x "$debug_artifact" "$debug_root"

      local elf build_id debug_file debug_id section_file note_file
      local -a build_ids debug_ids
      for elf in "${elf_files[@]}"; do
        note_file=$(mktemp "$tmp_root/notes.XXXXXX")
        readelf -n "$elf" >"$note_file"
        mapfile -t build_ids < <(sed -n 's/.*Build ID:[[:space:]]*//p' "$note_file")
        [[ ${#build_ids[@]} -eq 1 ]] || die "expected exactly one Build ID: $elf"
        build_id=${build_ids[0]}
        [[ "$build_id" =~ ^[0-9a-f]{40}$ ]] || die "missing 20-byte SHA1 Build ID: $elf"
        debug_file="$debug_root/usr/lib/debug/.build-id/${build_id:0:2}/${build_id:2}.debug"
        [[ -s "$debug_file" ]] || die "missing Build-ID debug payload: $debug_file"
        note_file=$(mktemp "$tmp_root/debug-notes.XXXXXX")
        readelf -n "$debug_file" >"$note_file"
        mapfile -t debug_ids < <(sed -n 's/.*Build ID:[[:space:]]*//p' "$note_file")
        [[ ${#debug_ids[@]} -eq 1 ]] || die "expected exactly one debug Build ID: $debug_file"
        debug_id=${debug_ids[0]}
        [[ "$debug_id" == "$build_id" ]] || die "main/debug Build ID mismatch: $package"
        section_file=$(mktemp "$tmp_root/sections.XXXXXX")
        readelf -SW "$debug_file" >"$section_file"
        grep -Fq '.debug_info' "$section_file" || die "debug payload lacks .debug_info: $debug_file"
      done
    elif [[ -n ${artifact_by_package[$debug_package]+x} ]]; then
      die "dbgsym exists for package without native ELF: $debug_package"
    fi

    printf 'verified package=%s version=%s arch=%s payload=%s native_elf=%s\n' \
      "$package" "$version" "$architecture" "${useful_payload#"$package_root"}" "${#elf_files[@]}"
  done

  if [[ "$debug_policy" == N/A:* ]]; then
    [[ $native_packages -eq 0 ]] || die "debug N/A job produced native packages"
  else
    [[ $native_packages -gt 0 ]] || die "native debug policy job produced no ELF package"
  fi
}

[[ $# -ge 1 ]] || usage
mode=$1
shift

case "$mode" in
  verify)
    [[ $# -eq 8 ]] || usage
    output_dir=$1
    recipe_dir=$2
    package_template=$3
    pg_versions=$4
    debug_policy=$5
    expected_arch_input=$6
    job_kind=$7
    since_marker=$8
    verify_job
    ;;
  run)
    [[ $# -eq 8 ]] || usage
    output_dir=$1
    recipe_dir=$2
    package_template=$3
    pg_versions=$4
    debug_policy=$5
    expected_arch_input=$6
    job_kind=$7
    build_target=$8
    mkdir -p "$output_dir"
    shopt -s nullglob
    existing=("$output_dir"/*.deb "$output_dir"/*.ddeb)
    [[ ${#existing[@]} -eq 0 ]] || die "run output directory already contains DEB artifacts"
    make -C "$recipe_dir" clean
    since_marker=$(mktemp "$output_dir/.job-start.XXXXXX")
    make_args=("-C" "$recipe_dir" "PKG_OUTPUT_DIR=$output_dir")
    [[ "$pg_versions" == "-" ]] || make_args+=("PG_VERSIONS=$pg_versions")
    if [[ "$build_target" != "-" ]]; then
      IFS=',' read -r -a build_targets <<<"$build_target"
      make_args+=("${build_targets[@]}")
    fi
    make "${make_args[@]}"

    # Legacy recipes commonly leave dpkg-buildpackage outputs beside the
    # recipe even when their move target does not honor PKG_OUTPUT_DIR.  Copy
    # only artifacts created by this invocation into the isolated job output;
    # the verifier below still rejects stale, duplicate, or unexpected files.
    shopt -s nullglob
    built_artifacts=("$recipe_dir"/*.deb "$recipe_dir"/*.ddeb)
    for artifact in "${built_artifacts[@]}"; do
      [[ -f "$artifact" && "$artifact" -nt "$since_marker" ]] || continue
      destination="$output_dir/${artifact##*/}"
      [[ "$artifact" == "$destination" ]] || cp -p "$artifact" "$destination"
    done
    verify_job
    ;;
  *) usage ;;
esac
