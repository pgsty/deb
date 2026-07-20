#!/usr/bin/env bash
# Create the official 5.4 extension set, then start the same data directory
# with Pigsty's split kernel + contrib packages and exercise upgrade paths.
set -Eeuo pipefail

OFFICIAL_ROOT="${OFFICIAL_IVORYSQL_ROOT:-/usr/ivory-5}"
SPLIT_ROOT="${SPLIT_IVORYSQL_ROOT:-/usr/ivory-18}"
PORT="${IVORYSQL_PARITY_PORT:-55433}"

for binary in \
  "${OFFICIAL_ROOT}/bin/initdb" "${OFFICIAL_ROOT}/bin/pg_ctl" \
  "${SPLIT_ROOT}/bin/pg_ctl" "${SPLIT_ROOT}/bin/psql"; do
  test -x "${binary}"
done

testroot="$(mktemp -d /var/tmp/ivorysql-official-parity.XXXXXX)"
datadir="${testroot}/data"
logdir="${testroot}/log"
mkdir -p "${datadir}" "${logdir}"
chown -R postgres:postgres "${testroot}"

started=0
server_root=''
stop_server() {
  if [[ "${started}" -eq 1 ]]; then
    runuser -u postgres -- "${server_root}/bin/pg_ctl" -D "${datadir}" \
      -m fast -w stop >"${logdir}/stop.log" 2>&1 || true
    started=0
  fi
}
trap stop_server EXIT

start_server() {
  server_root="$1"
  runuser -u postgres -- "${server_root}/bin/pg_ctl" -D "${datadir}" \
    -l "${logdir}/postgresql.log" -w start
  started=1
}

psql_with() {
  local root="$1"
  shift
  "${root}/bin/psql" -h 127.0.0.1 -p "${PORT}" -U postgres \
    -d postgres -X -v ON_ERROR_STOP=1 "$@"
}

runuser -u postgres -- "${OFFICIAL_ROOT}/bin/initdb" -D "${datadir}" \
  --no-locale --encoding=UTF8 --auth-local=trust --auth-host=trust \
  >"${logdir}/initdb.log" 2>&1
{
  printf "listen_addresses = '127.0.0.1'\n"
  printf 'port = %s\n' "${PORT}"
  printf "shared_preload_libraries = 'pgaudit,pg_cron,pg_hint_plan,pg_jieba,pg_show_plans,pg_stat_monitor,pg_textsearch'\n"
  printf "cron.database_name = 'postgres'\n"
  printf "wal_level = logical\n"
  printf "max_replication_slots = 10\n"
} >>"${datadir}/postgresql.conf"

start_server "${OFFICIAL_ROOT}"
psql_with "${OFFICIAL_ROOT}" -c 'CREATE EXTENSION fuzzystrmatch' >/dev/null

extensions=(
  postgis address_standardizer address_standardizer_data_us postgis_raster
  postgis_sfcgal postgis_topology postgis_tiger_geocoder pgrouting age ddlx
  http pgagent pgaudit pg_bigm pg_cron pg_curl pg_hint_plan pg_jieba
  pg_partman pgroonga pgroonga_database pg_show_plans pg_stat_monitor
  pg_textsearch plpgsql_check redis_fdw system_stats vector zhparser
)
for extension in "${extensions[@]}"; do
  psql_with "${OFFICIAL_ROOT}" -c "CREATE EXTENSION \"${extension}\"" \
    >"${logdir}/official-create-${extension}.log" 2>&1
done

official_count="$(psql_with "${OFFICIAL_ROOT}" -Atc \
  "SELECT count(*) FROM pg_extension WHERE extname = ANY (ARRAY['address_standardizer','address_standardizer_data_us','age','ddlx','http','pgagent','pgaudit','pg_bigm','pg_cron','pg_curl','pg_hint_plan','pg_jieba','pg_partman','pgroonga','pgroonga_database','pgrouting','pg_show_plans','pg_stat_monitor','pg_textsearch','plpgsql_check','postgis','postgis_raster','postgis_sfcgal','postgis_tiger_geocoder','postgis_topology','redis_fdw','system_stats','vector','zhparser']);")"
test "${official_count}" -eq 29

psql_with "${OFFICIAL_ROOT}" -c \
  "CREATE TABLE parity_vector (id integer PRIMARY KEY, embedding vector(3)); INSERT INTO parity_vector VALUES (1, '[1,2,3]'); CREATE TABLE parity_pgroonga (id integer, content text); INSERT INTO parity_pgroonga VALUES (1, 'official IvorySQL data'), (2, 'unrelated'); CREATE INDEX parity_pgroonga_idx ON parity_pgroonga USING pgroonga (content);" \
  >"${logdir}/official-data.log"
psql_with "${OFFICIAL_ROOT}" -Atc \
  "SELECT * FROM pg_create_logical_replication_slot('official_wal2json', 'wal2json');" \
  >"${logdir}/official-slot.log"
printf '[ OK ] official package created all 29 extensions\n'

stop_server
start_server "${SPLIT_ROOT}"

upgrades=(pg_partman pg_textsearch redis_fdw system_stats vector)
for extension in "${upgrades[@]}"; do
  psql_with "${SPLIT_ROOT}" -c "ALTER EXTENSION \"${extension}\" UPDATE" \
    >"${logdir}/upgrade-${extension}.log" 2>&1
  printf '[ OK ] ALTER EXTENSION %s UPDATE\n' "${extension}"
done

versions="$(psql_with "${SPLIT_ROOT}" -Atc \
  "SELECT string_agg(extname || '=' || extversion, ',' ORDER BY extname) FROM pg_extension WHERE extname IN ('pg_partman','pg_textsearch','plpgsql_check','redis_fdw','system_stats','vector');")"
for expected in \
  'pg_partman=5.4.1' 'pg_textsearch=1.2.0' 'plpgsql_check=2.8' \
  'redis_fdw=2.0' 'system_stats=4.0' 'vector=0.8.4'; do
  [[ ",${versions}," == *",${expected},"* ]]
done

split_count="$(psql_with "${SPLIT_ROOT}" -Atc \
  "SELECT count(*) FROM pg_extension WHERE extname = ANY (ARRAY['address_standardizer','address_standardizer_data_us','age','ddlx','http','pgagent','pgaudit','pg_bigm','pg_cron','pg_curl','pg_hint_plan','pg_jieba','pg_partman','pgroonga','pgroonga_database','pgrouting','pg_show_plans','pg_stat_monitor','pg_textsearch','plpgsql_check','postgis','postgis_raster','postgis_sfcgal','postgis_tiger_geocoder','postgis_topology','redis_fdw','system_stats','vector','zhparser']);")"
test "${split_count}" -eq 29

psql_with "${SPLIT_ROOT}" -Atc \
  "SELECT postgis_lib_version(), postgis_sfcgal_version(), pgr_version(); SELECT embedding <-> '[3,2,1]'::vector FROM parity_vector WHERE id = 1; SET enable_seqscan = off; SELECT id FROM parity_pgroonga WHERE content &@ 'IvorySQL';" \
  >"${logdir}/split-queries.log"
psql_with "${SPLIT_ROOT}" -c \
  "CREATE TABLE parity_wal (id integer, payload text); INSERT INTO parity_wal VALUES (1, 'split package');" \
  >/dev/null
wal_changes="$(psql_with "${SPLIT_ROOT}" -Atc \
  "SELECT count(*) FROM pg_logical_slot_get_changes('official_wal2json', NULL, NULL);")"
test "${wal_changes}" -gt 0

printf '[ OK ] official data directory started with split packages\n'
printf '[ OK ] versions: %s\n' "${versions}"
printf '[ OK ] official wal2json slot decoded %s changes with split package\n' \
  "${wal_changes}"
printf '[INFO] parity logs: %s\n' "${testroot}"
