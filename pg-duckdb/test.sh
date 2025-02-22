#!/bin/bash

OS_VENDOR=""
OS_VERSION=""
OS_PACKAGE=""
OS_MANAGER=""
OS_CODENAME=""
ARCH=$(uname -m)


function check_package_manager(){
    # get package / manager: rpm|deb and dnf|yum|apt|apt-get|zypper
    if command -v dpkg >/dev/null 2>&1; then
        OS_PACKAGE="deb"
        if command -v apt >/dev/null 2>&1; then
            OS_MANAGER="apt"
        elif command -v apt-get >/dev/null 2>&1; then
            OS_MANAGER="apt-get"
        else
            echo "fail to determine os package manager for deb"
            exit 4
        fi
    elif command -v rpm >/dev/null 2>&1; then
        OS_PACKAGE="rpm"
        if command -v dnf >/dev/null 2>&1; then
            OS_MANAGER="dnf"
        elif command -v yum >/dev/null 2>&1; then
            OS_MANAGER="yum"
        elif command -v zypper >/dev/null 2>&1; then
            OS_MANAGER="zypper"
        else
            echo "fail to determine os package manager for rpm"
            exit 4
        fi
    else
        echo "fail to determine os package type"
        exit 3
    fi
    echo "package = ${OS_PACKAGE},${OS_MANAGER}"
}



function test_duckdb_deb {
    version=${1-'17'}
    export v=${version}
    echo "========================================"
    echo "Testing PostgreSQL $v"
    dpkg -i /tmp/deb/postgresql-$v-pg-duckdb*.deb

    echo "========================================"
    rm -rf /tmp/data
    sudo -u postgres /usr/lib/postgresql/$v/bin/pg_ctl -D /tmp/data init
    echo "shared_preload_libraries = 'pg_duckdb'" | sudo -u postgres tee /tmp/data/postgresql.auto.conf
    sudo -u postgres /usr/lib/postgresql/$v/bin/pg_ctl -D /tmp/data start
    echo "========================================"

    sudo -u postgres /usr/lib/postgresql/$v/bin/pg_ctl -D /tmp/data stop
    dpkg -r postgresql-$v-pg-duckdb
}

function uninstall_duckdb_deb(){
    version=${1-'17'}
    export v=${version}
    rm -rf /usr/lib/postgresql/$v/lib/libduckdb.so
    rm -rf /usr/lib/postgresql/$v/lib/pg_duckdb.so
    rm -rf /usr/lib/postgresql/$v/lib/pg_duckdb.control
    rm -rf /usr/lib/postgresql/$v/lib/pg_duckdb*.sql
    rm -rf /usr/lib/postgresql/$v/lib/bitcode/pg_duckdb
}

function test_duckdb_rpm {
    version=${1-'17'}
    export v=${version}
    RPM_DIR=/tmp/rpm/x86_64
    if [ "$ARCH" == "aarch64" ]; then
        RPM_DIR=/tmp/rpm/aarch64
    fi
    echo "========================================"
    echo "Testing PostgreSQL $v"
    rpm -ivh ${RPM_DIR}/pg_duckdb_$v*.rpm
    echo "========================================"
    rm -rf /tmp/data
    sudo -u postgres /usr/pgsql-$v/bin/pg_ctl -D /tmp/data init > /dev/null 2>&1
    echo "shared_preload_libraries = 'pg_duckdb'" | sudo -u postgres tee /tmp/data/postgresql.auto.conf
    sudo -u postgres /usr/pgsql-$v/bin/pg_ctl -D /tmp/data start
    echo "========================================"
    sudo -u postgres /usr/pgsql-$v/bin/pg_ctl -D /tmp/data stop > /dev/null 2>&1
    yum remove -y pg_duckdb_$v*
}

function uninstall_duckdb_rpm(){
    version=${1-'17'}
    export v=${version}
    rm -rf /usr/pgsql-$v/lib/libduckdb.so
    rm -rf /usr/pgsql-$v/lib/pg_duckdb.so
    rm -rf /usr/pgsql-$v/lib/pg_duckdb.control
    rm -rf /usr/pgsql-$v/lib/pg_duckdb*.sql
    rm -rf /usr/pgsql-$v/lib/bitcode/pg_duckdb
}


check_package_manager

VERSION=${1-'17'}

if [ "$OS_PACKAGE" == "deb" ]; then
    test_duckdb_deb $VERSION
    uninstall_duckdb_deb $VERSION
elif [ "$OS_PACKAGE" == "rpm" ]; then
    test_duckdb_rpm $VERSION
    uninstall_duckdb_rpm $VERSION
fi

