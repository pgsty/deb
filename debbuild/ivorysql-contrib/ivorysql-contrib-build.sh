#!/usr/bin/env bash
#==============================================================#
# File      :   ivorysql-contrib-build.sh
# Desc      :   build the official IvorySQL 5 extension gap
# Ctime     :   2026-07-20
# Path      :   debbuild/ivorysql-contrib/ivorysql-contrib-build.sh
#==============================================================#
set -Eeuo pipefail

PGROOT="${IVORYSQL_ROOT:-/usr/ivory-18}"
PG_CONFIG="${PGROOT}/bin/pg_config"
JOBS="${IVORYSQL_BUILD_JOBS:-$(nproc)}"
SOURCE_DIR="${PWD}/sources"
WORK_DIR="${PWD}/work"
STAGE_DIR="${PWD}/stage"
LOG_DIR="${PWD}/logs"
SFCGAL_CONFIG="${PWD}/sfcgal-config-pkgconf"

export PATH="${PGROOT}/bin:${PATH}"
export PG_CONFIG

fail() {
  printf '[FAIL] %s\n' "$*" >&2
  exit 1
}

require_file() {
  [[ -f "$1" ]] || fail "missing file: $1"
}

extract_source() {
  local archive="$1"
  require_file "${SOURCE_DIR}/${archive}"
  tar -xzf "${SOURCE_DIR}/${archive}" -C "${WORK_DIR}"
}

run_step() {
  local name="$1"
  local status
  shift
  printf '[BUILD] %s\n' "${name}"
  set +e
  (set -Eeuo pipefail; set -x; "$@") >"${LOG_DIR}/${name}.log" 2>&1
  status=$?
  set -e
  if [[ "${status}" -ne 0 ]]; then
    tail -100 "${LOG_DIR}/${name}.log" >&2
    fail "${name}; full log: ${LOG_DIR}/${name}.log"
  fi
  printf '[ OK ] %s\n' "${name}"
}

build_pgxs() {
  local directory="$1"
  make -C "${directory}" -j"${JOBS}" PG_CONFIG="${PG_CONFIG}" USE_PGXS=1
  make -C "${directory}" PG_CONFIG="${PG_CONFIG}" USE_PGXS=1 \
    DESTDIR="${STAGE_DIR}" install
}

build_age() {
  build_pgxs "${WORK_DIR}/age-1.7.0-pg18"
}

build_ddlx() {
  build_pgxs "${WORK_DIR}/pgddl-0.31"
}

build_http() {
  build_pgxs "${WORK_DIR}/pgsql-http-1.7.1"
}

build_pgagent() {
  local source="${WORK_DIR}/pgagent-pgagent-4.2.3"
  local build="${source}/build-ivory"
  mkdir -p "${build}"
  (
    cd "${build}"
    cmake \
      -DMAJOR_VERSION=4 \
      -DMINOR_VERSION=2 \
      -DPGAGENT_SOURCE_DIR="${source}" \
      -P "${source}/cmake/MakeExt.cmake"
  )
  install -d "${STAGE_DIR}${PGROOT}/share/postgresql/extension"
  install -m 0644 "${build}/pgagent--4.2.sql" "${build}/pgagent.control" \
    "${STAGE_DIR}${PGROOT}/share/postgresql/extension/"
}

build_pgaudit() {
  build_pgxs "${WORK_DIR}/pgaudit-18.0"
}

build_pg_bigm() {
  build_pgxs "${WORK_DIR}/pg_bigm-1.2-20250903"
}

build_pg_cron() {
  build_pgxs "${WORK_DIR}/pg_cron-1.6.7"
}

build_pg_curl() {
  build_pgxs "${WORK_DIR}/pg_curl-2.4.5"
}

build_pg_hint_plan() {
  build_pgxs "${WORK_DIR}/pg_hint_plan-REL18_1_8_0"
}

build_pg_jieba() {
  local source="${WORK_DIR}/ivy_jieba-d0ffac8"
  local build="${source}/build-ivory"
  cmake -S "${source}" -B "${build}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_INSTALL_PREFIX="${PGROOT}" \
    -DPG_JIEBA_POSTGRESQL_DIR="${PGROOT}" \
    -DPostgreSQL_EXECUTABLE="${PGROOT}/bin/postgres" \
    -DPostgreSQL_INCLUDE_DIR="${PGROOT}/include/postgresql" \
    -DPostgreSQL_TYPE_INCLUDE_DIR="${PGROOT}/include/postgresql/server" \
    -DPostgreSQL_LIBRARY="${PGROOT}/lib/libpq.so" \
    -DPostgreSQL_PG_CONFIG="${PG_CONFIG}"
  cmake --build "${build}" -j"${JOBS}"
  DESTDIR="${STAGE_DIR}" cmake --install "${build}"
}

build_pg_partman() {
  build_pgxs "${WORK_DIR}/pg_partman-5.4.2"
}

build_pgroonga() {
  local source="${WORK_DIR}/pgroonga-4.0.9"
  # PGroonga 4.0.9 uses Meson and emits shared modules, without PGXS bitcode.
  meson setup "${source}/build-ivory" "${source}" \
    -Dinstall_to_postgresql=true -Dmessage_pack=enabled -Dtest=false \
    -Dxxhash=enabled -Dpg_config="${PG_CONFIG}"
  meson compile -C "${source}/build-ivory" -j"${JOBS}"
  DESTDIR="${STAGE_DIR}" meson install -C "${source}/build-ivory"
}

build_pgrouting() {
  local source="${WORK_DIR}/pgrouting-3.8.0"
  local build="${source}/build-ivory"
  cmake -S "${source}" -B "${build}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DWITH_DOC=OFF -DWITH_ALL_DOC=OFF \
    -DPOSTGRESQL_PG_CONFIG="${PG_CONFIG}" \
    -DPOSTGRESQL_EXECUTABLE="${PGROOT}/bin/postgres" \
    -DPOSTGRESQL_INCLUDE_DIR="${PGROOT}/include/postgresql/server"
  cmake --build "${build}" -j"${JOBS}"
  DESTDIR="${STAGE_DIR}" cmake --install "${build}"
}

build_pg_show_plans() {
  build_pgxs "${WORK_DIR}/pg_show_plans-2.1.8"
}

build_pg_stat_monitor() {
  build_pgxs "${WORK_DIR}/pg_stat_monitor-2.3.2"
}

build_pg_textsearch() {
  build_pgxs "${WORK_DIR}/pg_textsearch-1.2.0"
}

build_plpgsql_check() {
  build_pgxs "${WORK_DIR}/plpgsql_check-2.8.11"
}

build_postgis() {
  local directory="${WORK_DIR}/postgis-3.5.4"
  local sfcgal_config

  # GDAL 3.13 removed MIN from cpl_port.h; use PostgreSQL's equivalent macro.
  sed -i 's/num_bands = MIN(/num_bands = Min(/g' \
    "${directory}/raster/rt_pg/rtpg_geometry.c"

  if command -v sfcgal-config >/dev/null 2>&1; then
    sfcgal_config="$(command -v sfcgal-config)"
  else
    require_file "${SFCGAL_CONFIG}"
    chmod +x "${SFCGAL_CONFIG}"
    sfcgal_config="${SFCGAL_CONFIG}"
  fi

  (
    cd "${directory}"
    ./autogen.sh
    ./configure \
      --prefix="${PGROOT}" \
      --bindir="${PGROOT}/bin" \
      --datadir="${PGROOT}/share/postgresql" \
      --mandir="${PGROOT}/share/man" \
      --with-pgconfig="${PG_CONFIG}" \
      --with-geosconfig="$(command -v geos-config)" \
      --with-gdalconfig="$(command -v gdal-config)" \
      --with-sfcgal="${sfcgal_config}" \
      --with-protobuf
    make -j"${JOBS}"
    make DESTDIR="${STAGE_DIR}" install
  )
}

build_redis_fdw() {
  build_pgxs "${WORK_DIR}/redis_fdw-20a4c07"
}

build_system_stats() {
  build_pgxs "${WORK_DIR}/system_stats-4.0"
}

build_vector() {
  make -C "${WORK_DIR}/pgvector-0.8.7" -j"${JOBS}" \
    PG_CONFIG="${PG_CONFIG}" OPTFLAGS=
  make -C "${WORK_DIR}/pgvector-0.8.7" \
    PG_CONFIG="${PG_CONFIG}" OPTFLAGS= DESTDIR="${STAGE_DIR}" install
}

build_wal2json() {
  build_pgxs "${WORK_DIR}/wal2json-wal2json_2_6"
}

build_zhparser() {
  # Pigsty's Debian scws package follows the distro layout (/usr/include and
  # the multiarch library directory), while upstream zhparser defaults to the
  # historical /usr/local prefix used by the RPM package.
  make -C "${WORK_DIR}/zhparser-2.3" -j"${JOBS}" \
    PG_CONFIG="${PG_CONFIG}" USE_PGXS=1 SCWS_HOME=/usr
  make -C "${WORK_DIR}/zhparser-2.3" \
    PG_CONFIG="${PG_CONFIG}" USE_PGXS=1 SCWS_HOME=/usr \
    DESTDIR="${STAGE_DIR}" install
}

build_pg_bulkload() {
  build_pgxs "${WORK_DIR}/pg_bulkload-VERSION3_1_23"
}

build_pg_profile() {
  build_pgxs "${WORK_DIR}/pg_profile-4.11"
}

build_pg_readonly() {
  # Install the upstream SQL files unchanged; no packaging-authored upgrade SQL.
  build_pgxs "${WORK_DIR}/pg_readonly-1.0.6"
}

build_pg_repack() {
  local source="${WORK_DIR}/percona-pg_repack-1.5.3"
  local pg_version
  # The upstream Makefile's unescaped awk $2 mishandles IvorySQL's suffix.
  pg_version="$("${PG_CONFIG}" --version | awk '{print $2}')"
  make -C "${source}" -j"${JOBS}" PG_CONFIG="${PG_CONFIG}" USE_PGXS=1 \
    VERSION="${pg_version}"
  make -C "${source}" PG_CONFIG="${PG_CONFIG}" USE_PGXS=1 \
    VERSION="${pg_version}" DESTDIR="${STAGE_DIR}" install
}

build_pgnodemx() {
  build_pgxs "${WORK_DIR}/pgnodemx-1.7"
}

build_pgtt() {
  build_pgxs "${WORK_DIR}/pgtt-4.5"
}

build_set_user() {
  build_pgxs "${WORK_DIR}/percona-pgaudit18_set_user-4.2.0"
}

build_vectorscale() {
  local source="${WORK_DIR}/pgvectorscale-0.9.1"
  local lock_expected=a8d26a2e48dd483bf16187b63bb9f55aac0aaa9e3d670518ffed01be038f1eb0
  export PATH="${HOME}/.cargo/bin:${PATH}"
  [[ "$(cargo pgrx --version)" == 'cargo-pgrx 0.19.2' ]] || \
    fail 'cargo-pgrx 0.19.2 is required; run pig build pgrx -v 0.19.2 first'
  [[ "$(sha256sum "${source}/Cargo.lock" | cut -d ' ' -f1)" == "${lock_expected}" ]] || \
    fail 'unexpected vectorscale Cargo.lock'
  (
    cd "${source}/pgvectorscale"
    export PGRX_HOME="${source}/pgrx-home"
    export CARGO_TARGET_DIR="${source}/target"
    export CARGO_BUILD_JOBS="${IVORYSQL_CARGO_BUILD_JOBS:-${JOBS}}"
    export CARGO_PROFILE_RELEASE_DEBUG=2 CARGO_PROFILE_RELEASE_STRIP=none
    export RUSTFLAGS="${RUSTFLAGS:-} -C link-arg=-Wl,--no-gc-sections"
    if [[ "$(uname -m)" == x86_64 ]]; then
      export RUSTFLAGS="${RUSTFLAGS} -C target-feature=+avx2,+fma"
    fi
    cargo pgrx init --pg18="${PG_CONFIG}" --no-run
    CARGO_NET_GIT_FETCH_WITH_CLI=true cargo fetch --locked
    CARGO_NET_OFFLINE=true CARGO_NET_GIT_FETCH_WITH_CLI=true \
      cargo pgrx package -v --no-default-features --features pg18,build_parallel \
      --pg-config "${PG_CONFIG}"
  )
  [[ "$(sha256sum "${source}/Cargo.lock" | cut -d ' ' -f1)" == "${lock_expected}" ]] || \
    fail 'vectorscale Cargo.lock changed during build'
  local package="${source}/target/release/vectorscale-pg18${PGROOT}"
  install -m 0755 "${package}/lib/postgresql/vectorscale-0.9.1.so" \
    "${STAGE_DIR}${PGROOT}/lib/postgresql/"
  install -m 0644 "${package}/share/postgresql/extension/"* \
    "${STAGE_DIR}${PGROOT}/share/postgresql/extension/"
}

verify_stage() {
  local extension_dir="${STAGE_DIR}${PGROOT}/share/postgresql/extension"
  local module_dir="${STAGE_DIR}${PGROOT}/lib/postgresql"
  local expected_controls="${WORK_DIR}/expected.controls"
  local actual_controls="${WORK_DIR}/actual.controls"
  local expected_modules="${WORK_DIR}/expected.modules"
  local actual_modules="${WORK_DIR}/actual.modules"

  cp "${PWD}/expected-controls.txt" "${expected_controls}"

  cp "${PWD}/expected-modules.txt" "${expected_modules}"

  LC_ALL=C sort -u -o "${expected_controls}" "${expected_controls}"
  LC_ALL=C sort -u -o "${expected_modules}" "${expected_modules}"

  find "${extension_dir}" -maxdepth 1 -type f -name '*.control' \
    -exec basename {} .control \; | LC_ALL=C sort -u >"${actual_controls}"
  find "${module_dir}" -maxdepth 1 -type f -name '*.so' \
    -exec basename {} \; | LC_ALL=C sort -u >"${actual_modules}"
  diff -u "${expected_controls}" "${actual_controls}"
  diff -u "${expected_modules}" "${actual_modules}"

  grep -Eq "^default_version[[:space:]]*=[[:space:]]*'?2[.]8'?" \
    "${extension_dir}/plpgsql_check.control"
  grep -Eq "^default_version[[:space:]]*=[[:space:]]*'?0[.]31'?" \
    "${extension_dir}/ddlx.control"

  while IFS= read -r module; do
    if ldd "${module}" | grep -q 'not found'; then
      ldd "${module}" >&2
      fail "unresolved shared-library dependency in ${module}"
    fi
  done < <(find "${module_dir}" -maxdepth 1 -type f -name '*.so' | sort)

  find "${STAGE_DIR}" -type f -print0 | sort -z | \
    xargs -0 sha256sum | sed "s#  ${STAGE_DIR}/#  #" >"${PWD}/FILES.sha256"
  printf '[ OK ] exact extension gap: 39 controls and 39 modules\n'
}

main() {
  [[ -x "${PG_CONFIG}" ]] || fail "IvorySQL pg_config not found: ${PG_CONFIG}"
  [[ "$("${PG_CONFIG}" --version)" == *'PostgreSQL 18.'* ]] || \
    fail "expected PostgreSQL 18 pg_config: $("${PG_CONFIG}" --version)"
  [[ -d "${SOURCE_DIR}" ]] || fail "source directory not found: ${SOURCE_DIR}"
  [[ ! -e "${WORK_DIR}" && ! -e "${STAGE_DIR}" && ! -e "${LOG_DIR}" ]] || \
    fail 'work, stage, or logs already exists; run debian/rules clean first'
  mkdir -p "${WORK_DIR}" "${STAGE_DIR}" "${LOG_DIR}"
  sha256sum -c SOURCES.sha256

  local archives=(
    age-1.7.0-pg18.tar.gz
    pgddl-0.31.tar.gz
    pgsql-http-1.7.1.tar.gz
    pgagent-4.2.3.tar.gz
    pgaudit-18.0.tar.gz
    pg_bigm-1.2-20250903.tar.gz
    pg_cron-1.6.7.tar.gz
    pg_curl-2.4.5.tar.gz
    pg_hint_plan-REL18_1_8_0.tar.gz
    ivy_jieba-d0ffac8.tar.gz
    pg_partman-5.4.2.tar.gz
    pgroonga-4.0.9.tar.gz
    pgrouting-3.8.0.tar.gz
    pg_show_plans-2.1.8.tar.gz
    pg_stat_monitor-2.3.2.tar.gz
    pg_textsearch-1.2.0.tar.gz
    plpgsql_check-2.8.11.tar.gz
    postgis-3.5.4.tar.gz
    redis_fdw-20a4c07.tar.gz
    system_stats-4.0.tar.gz
    pgvector-0.8.7.tar.gz
    wal2json-2.6.tar.gz
    zhparser-2.3.tar.gz
    pg_bulkload-VERSION3_1_23.tar.gz
    pg_profile-4.11.tar.gz
    pg_readonly-1.0.6.tar.gz
    percona-pg_repack-1.5.3.tar.gz
    pgnodemx-1.7.tar.gz
    pgtt-4.5.tar.gz
    percona-pgaudit18_set_user-4.2.0.tar.gz
    pgvectorscale-0.9.1.tar.gz
  )
  local archive
  for archive in "${archives[@]}"; do
    extract_source "${archive}"
  done

  run_step pg_bulkload build_pg_bulkload
  run_step pg_profile build_pg_profile
  run_step pg_readonly build_pg_readonly
  run_step pg_repack build_pg_repack
  run_step pgnodemx build_pgnodemx
  run_step pgtt build_pgtt
  run_step set_user build_set_user
  run_step postgis build_postgis
  run_step pgrouting build_pgrouting
  run_step pgroonga build_pgroonga
  run_step age build_age
  run_step ddlx build_ddlx
  run_step http build_http
  run_step pgagent build_pgagent
  run_step pgaudit build_pgaudit
  run_step pg_bigm build_pg_bigm
  run_step pg_cron build_pg_cron
  run_step pg_curl build_pg_curl
  run_step pg_hint_plan build_pg_hint_plan
  run_step pg_jieba build_pg_jieba
  run_step pg_partman build_pg_partman
  run_step pg_show_plans build_pg_show_plans
  run_step pg_stat_monitor build_pg_stat_monitor
  run_step pg_textsearch build_pg_textsearch
  run_step plpgsql_check build_plpgsql_check
  run_step redis_fdw build_redis_fdw
  run_step system_stats build_system_stats
  run_step vector build_vector
  run_step wal2json build_wal2json
  run_step zhparser build_zhparser
  run_step vectorscale build_vectorscale
  verify_stage
}

main "$@"
