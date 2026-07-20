#!/usr/bin/env bash
# Smoke-test an installed ivorysql-18 + ivorysql-18-contrib pair.
set -Eeuo pipefail

PGHOME="${IVORYSQL_ROOT:-/usr/ivory-18}"
PORT="${IVORYSQL_TEST_PORT:-55432}"

fail() {
  printf '[FAIL] %s\n' "$*" >&2
  exit 1
}

dpkg-query -W -f='${Status}\n' ivorysql-18 | grep -qx 'install ok installed'
dpkg-query -W -f='${Status}\n' ivorysql-18-contrib | grep -qx 'install ok installed'
verify_output="$(dpkg --verify ivorysql-18 ivorysql-18-contrib 2>&1 || true)"
# Minimal container images commonly use dpkg path-exclude rules for docs.  Do
# not confuse those intentional omissions with a damaged executable payload.
unexpected_verify="$(printf '%s\n' "${verify_output}" | \
  grep -vE '^missing[[:space:]]+/usr/share/doc/' || true)"
if [[ -n "${unexpected_verify}" ]]; then
  printf '%s\n' "${unexpected_verify}" >&2
  fail 'dpkg payload verification failed'
fi

test "$(dpkg -L ivorysql-18-contrib | grep -c '[.]control$')" -eq 29
test "$(dpkg -L ivorysql-18-contrib | grep -E -c '/lib/postgresql/[^/]+[.]so$')" -eq 31

missing=0
while IFS= read -r module; do
  if ldd "${module}" | grep -q 'not found'; then
    ldd "${module}" >&2
    missing=1
  fi
done < <(find "${PGHOME}/lib/postgresql" -maxdepth 1 -type f -name '*.so' | sort)
test "${missing}" -eq 0

testroot="$(mktemp -d /var/tmp/ivorysql-contrib-test.XXXXXX)"
datadir="${testroot}/data"
logdir="${testroot}/log"
mkdir -p "${datadir}" "${logdir}"
chown -R postgres:postgres "${testroot}"

runuser -u postgres -- "${PGHOME}/bin/initdb" -D "${datadir}" \
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

started=0
stop_server() {
  if [[ "${started}" -eq 1 ]]; then
    runuser -u postgres -- "${PGHOME}/bin/pg_ctl" -D "${datadir}" \
      -m fast -w stop >"${logdir}/stop.log" 2>&1 || true
  fi
}
trap stop_server EXIT

runuser -u postgres -- "${PGHOME}/bin/pg_ctl" -D "${datadir}" \
  -l "${logdir}/postgresql.log" -w start
started=1
PSQL=("${PGHOME}/bin/psql" -h 127.0.0.1 -p "${PORT}" -U postgres \
  -d postgres -X -v ON_ERROR_STOP=1)

"${PSQL[@]}" -c 'CREATE EXTENSION fuzzystrmatch' >/dev/null
extensions=(
  postgis address_standardizer address_standardizer_data_us postgis_raster
  postgis_sfcgal postgis_topology postgis_tiger_geocoder pgrouting age ddlx
  http pgagent pgaudit pg_bigm pg_cron pg_curl pg_hint_plan pg_jieba
  pg_partman pgroonga pgroonga_database pg_show_plans pg_stat_monitor
  pg_textsearch plpgsql_check redis_fdw system_stats vector zhparser
)
for extension in "${extensions[@]}"; do
  "${PSQL[@]}" -c "CREATE EXTENSION \"${extension}\"" \
    >"${logdir}/create-${extension}.log" 2>&1
  printf '[ OK ] CREATE EXTENSION %s\n' "${extension}"
done

count="$("${PSQL[@]}" -Atc \
  "SELECT count(*) FROM pg_extension WHERE extname = ANY (ARRAY['address_standardizer','address_standardizer_data_us','age','ddlx','http','pgagent','pgaudit','pg_bigm','pg_cron','pg_curl','pg_hint_plan','pg_jieba','pg_partman','pgroonga','pgroonga_database','pgrouting','pg_show_plans','pg_stat_monitor','pg_textsearch','plpgsql_check','postgis','postgis_raster','postgis_sfcgal','postgis_tiger_geocoder','postgis_topology','redis_fdw','system_stats','vector','zhparser']);")"
test "${count}" -eq 29

"${PSQL[@]}" -Atc "SELECT postgis_lib_version(), postgis_sfcgal_version();"
"${PSQL[@]}" -Atc 'SELECT pgr_version();'
"${PSQL[@]}" -Atc "SELECT '[1,2,3]'::vector <-> '[3,2,1]'::vector;"
"${PSQL[@]}" -c \
  "CREATE TABLE pgroonga_smoke (id integer, content text); INSERT INTO pgroonga_smoke VALUES (1, 'IvorySQL extension test'), (2, 'unrelated row'); CREATE INDEX pgroonga_smoke_idx ON pgroonga_smoke USING pgroonga (content); SET enable_seqscan = off; SELECT id FROM pgroonga_smoke WHERE content &@ 'IvorySQL';"
"${PSQL[@]}" -Atc \
  "SELECT * FROM pg_create_logical_replication_slot('ivory_wal2json_test', 'wal2json', true);"

printf '[ OK ] installed and created all 29 extensions; representative SQL passed\n'
printf '[INFO] test logs: %s\n' "${testroot}"
