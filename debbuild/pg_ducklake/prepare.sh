#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

VERSION="${VERSION:-1.0.2}"
UPSTREAM_REPO="${UPSTREAM_REPO:-https://github.com/relytcloud/pg_ducklake.git}"
UPSTREAM_COMMIT="${UPSTREAM_COMMIT:-b7da9fc28f4845a7c84c026ca6569d2d289ea303}"
DUCKDB_REPO="${DUCKDB_REPO:-https://github.com/duckdb/duckdb.git}"
DUCKDB_COMMIT="${DUCKDB_COMMIT:-9a64d338f2fa1d3c1d43c016b09c538b529dd397}"
DUCKLAKE_REPO="${DUCKLAKE_REPO:-https://github.com/duckdb/ducklake.git}"
DUCKLAKE_COMMIT="${DUCKLAKE_COMMIT:-93cc490d9b5554f6fd5322dbef23f41d4fa91bb8}"
DUCKDB_POSTGRES_REPO="${DUCKDB_POSTGRES_REPO:-https://github.com/duckdb/duckdb-postgres.git}"
DUCKDB_POSTGRES_COMMIT="${DUCKDB_POSTGRES_COMMIT:-c89234f0b1985f4ee0f52f16e742a1ab2d4ae4f0}"
DATABASE_CONNECTOR_REPO="${DATABASE_CONNECTOR_REPO:-https://github.com/duckdb/database-connector.git}"
DATABASE_CONNECTOR_COMMIT="${DATABASE_CONNECTOR_COMMIT:-746b56c4063f3682f4eb4facdc49408ed1885555}"
POSTGRES_REPO="${POSTGRES_REPO:-https://github.com/postgres/postgres.git}"
POSTGRES_TAG="${POSTGRES_TAG:-REL_15_13}"
POSTGRES_COMMIT="${POSTGRES_COMMIT:-5261b40acb67fdb8ed1e5976ae99599f16864c93}"
VCPKG_COMMIT="${VCPKG_COMMIT:-84bab45d415d22042bd0b9081aea57f362da3f35}"
VCPKG_ROARING_VERSION="${VCPKG_ROARING_VERSION:-4.5.0}"
BUNDLED_CROARING_VERSION="${BUNDLED_CROARING_VERSION:-4.7.1}"

WORK_DIR="${WORK_DIR:-${REPO_ROOT}/tmp/pg_ducklake-src}"
OUT_DIR="${OUT_DIR:-${SCRIPT_DIR}/candidate}"
SOURCE_DIR="${WORK_DIR}/pg_ducklake-${VERSION}"
TARBALL="pg_ducklake-${VERSION}.tar.gz"

if command -v gtar >/dev/null 2>&1; then
    TAR_BIN=gtar
else
    TAR_BIN=tar
fi

clone_commit() {
    local repo="$1"
    local commit="$2"
    local dest="$3"

    git init -q "$dest"
    git -C "$dest" remote add origin "$repo"
    git -C "$dest" -c http.version=HTTP/1.1 fetch --depth 1 origin "$commit"
    git -C "$dest" checkout -q --detach FETCH_HEAD
    test "$(git -C "$dest" rev-parse HEAD)" = "$commit"
}

rm -rf "$SOURCE_DIR"
mkdir -p "$WORK_DIR" "$OUT_DIR"

clone_commit "$UPSTREAM_REPO" "$UPSTREAM_COMMIT" "$SOURCE_DIR"
clone_commit "$DUCKDB_REPO" "$DUCKDB_COMMIT" "$SOURCE_DIR/duckdb"
clone_commit "$DUCKLAKE_REPO" "$DUCKLAKE_COMMIT" \
    "$SOURCE_DIR/pg_ducklake/third_party/ducklake"
clone_commit "$DUCKDB_POSTGRES_REPO" "$DUCKDB_POSTGRES_COMMIT" \
    "$SOURCE_DIR/pg_ducklake/third_party/duckdb-postgres"
clone_commit "$DATABASE_CONNECTOR_REPO" "$DATABASE_CONNECTOR_COMMIT" \
    "$SOURCE_DIR/pg_ducklake/third_party/duckdb-postgres/database-connector"
clone_commit "$POSTGRES_REPO" "$POSTGRES_COMMIT" \
    "$SOURCE_DIR/pg_ducklake/third_party/duckdb-postgres/postgres"

test "$(git -C "$SOURCE_DIR" rev-parse HEAD)" = "$UPSTREAM_COMMIT"
test "$(git -C "$SOURCE_DIR/duckdb" rev-parse HEAD)" = "$DUCKDB_COMMIT"
test "$(git -C "$SOURCE_DIR/pg_ducklake/third_party/ducklake" rev-parse HEAD)" = "$DUCKLAKE_COMMIT"
test "$(git -C "$SOURCE_DIR/pg_ducklake/third_party/duckdb-postgres" rev-parse HEAD)" = "$DUCKDB_POSTGRES_COMMIT"
test "$(git -C "$SOURCE_DIR/pg_ducklake/third_party/duckdb-postgres/database-connector" rev-parse HEAD)" = "$DATABASE_CONNECTOR_COMMIT"
test "$(git -C "$SOURCE_DIR/pg_ducklake/third_party/duckdb-postgres/postgres" rev-parse HEAD)" = "$POSTGRES_COMMIT"
grep -q "GIT_TAG ${DUCKDB_POSTGRES_COMMIT}" \
    "$SOURCE_DIR/pg_ducklake/pg_ducklake_extensions.cmake"

SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-$(git -C "$SOURCE_DIR" show -s --format=%ct HEAD)}"
BUILD_DATE_UTC="$(python3 -c 'import datetime, sys; print(datetime.datetime.fromtimestamp(int(sys.argv[1]), datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))' "$SOURCE_DATE_EPOCH")"

cat > "$SOURCE_DIR/SOURCE_MANIFEST" <<EOF
name=pg_ducklake
version=${VERSION}
build_date_utc=${BUILD_DATE_UTC}
upstream_repo=${UPSTREAM_REPO}
upstream_tag=v${VERSION}
upstream_commit=${UPSTREAM_COMMIT}
duckdb_repo=${DUCKDB_REPO}
duckdb_commit=${DUCKDB_COMMIT}
ducklake_repo=${DUCKLAKE_REPO}
ducklake_commit=${DUCKLAKE_COMMIT}
duckdb_postgres_repo=${DUCKDB_POSTGRES_REPO}
duckdb_postgres_commit=${DUCKDB_POSTGRES_COMMIT}
database_connector_repo=${DATABASE_CONNECTOR_REPO}
database_connector_commit=${DATABASE_CONNECTOR_COMMIT}
postgres_repo=${POSTGRES_REPO}
postgres_tag=${POSTGRES_TAG}
postgres_commit=${POSTGRES_COMMIT}
vcpkg_commit=${VCPKG_COMMIT}
vcpkg_roaring_version=${VCPKG_ROARING_VERSION}
bundled_croaring_version=${BUNDLED_CROARING_VERSION}
ducklake_nested_ci_submodules_included=false
duckdb_postgres_ci_submodules_included=false
EOF

find "$SOURCE_DIR" -name .DS_Store -delete
if ! "$TAR_BIN" --version 2>/dev/null | grep -q 'GNU tar'; then
    echo "GNU tar is required for a normalized source archive" >&2
    exit 1
fi

COPYFILE_DISABLE=1 GZIP=-n "$TAR_BIN" \
    --sort=name \
    --mtime="@${SOURCE_DATE_EPOCH}" \
    --owner=0 --group=0 --numeric-owner \
    --pax-option=delete=atime,delete=ctime \
    --exclude='*/.git' --exclude='*/.git/*' \
    --exclude='*/.DS_Store' --exclude='*/._*' \
    -C "$WORK_DIR" -czf "$OUT_DIR/$TARBALL" \
    "$(basename "$SOURCE_DIR")"

echo "Generated: $OUT_DIR/$TARBALL"
if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$OUT_DIR/$TARBALL"
else
    shasum -a 256 "$OUT_DIR/$TARBALL"
fi
cat "$SOURCE_DIR/SOURCE_MANIFEST"
cat <<EOF
This is a candidate maintainer snapshot. Review it before copying it to the
authoritative source store and updating DEB/RPM SHA256 constants.
CRoaring remains a separately checksummed source archive.
EOF
