# pg_mooncake 0.3.0

打包来源已切换到 [PGSTY fork](https://github.com/pgsty/pg_mooncake/tree/v0.3.0)。
`v0.3.0` 指向 `1a9cbfd65be9a6486d020120acb49ef0c6800d68`。

## 固定构建输入

| 组件 | 版本 / 提交 |
| --- | --- |
| pg_mooncake | 0.3.0 |
| Rust / cargo-pgrx | 1.99.0 / 0.19.3 |
| pg_duckdb | 1.2.0 / `8756099e267c47f0b86c24de4cf995327f1f4279` |
| DuckDB | 2.0.0 / `d54cbbe3df17e8e5ce68312f483b4155836112aa` |
| moonlink | v0.0.1 / `b298ef7444890e3c8af5544e350232518bcfd8e5` |
| duckdb_mooncake | v0.0.2 / `49765a369ad88986916ce53c969ed2ce4ba66fac` |

源码归档为 `~/pgsty/repo/ext/src/pg_mooncake-0.3.0.tar.gz`，75,089 字节，SHA-256：

```text
319e37de5c366842bbc88ebd3f3e0b150871bb0e35b1ba05df48affeeca5b71d
```

这是指定兼容性测试线程交付的轻量包：包含 pg_mooncake 自身源码、`fetch-deps.sh`
和 `BUILD.md`。`fetch-deps.sh` 拉取固定提交的子模块；Cargo 使用 `--locked`，
CMake 拉取上游锁定的 Corrosion、nanoarrow 和 CRoaring。构建需要联网，不能运行
`cargo update`。主项目、Moonlink 和 FFI 的三个锁文件在构建前后均检查不变。
GitHub 请求通过宿主机 `http://127.0.0.1:8888`，Mac Docker 容器使用
`http://host.docker.internal:8888`。

两个必要的原生文件均随主包安装：`pg_mooncake.so` 和
`share/extension/pg_mooncake/v2.0.0/<duckdb-platform>/mooncake.duckdb_extension`。
后者不使用原社区仓库中的旧插件。包必须与 pg_duckdb 1.2.0 配套；SQL 本身也会
拒绝其他版本。旧的 0.2.0 pgrx 补丁已移除。

Rust release 使用 `CARGO_PROFILE_RELEASE_DEBUG=2`、
`CARGO_PROFILE_RELEASE_STRIP=none`；C/C++ 使用发行版构建 flags。
两个 ELF 都参与正常的 debug 拆分。DuckDB 插件末尾的 534 字节 metadata/signature
会被 ELF strip 移除，配方在拆分后从原始构建文件恢复，并验证一致。

多 PG 调试包必须能够共装。RPM 在 debugedit 的 Build-ID seed 中加入 PG 包名；
DEB 为安装暂存区的 DuckDB 插件生成包含 PG 主版本的 Build-ID，并禁用跨文件
DWZ 合并。两个方案均保留完整 DWARF、自动 debug 子包和原始构建文件。

pg_mooncake 和 duckdb_mooncake 的许可证为 MIT；随包链接的 Moonlink 为 BUSL-1.1，
对应许可证文件及其中的 pg_mooncake 链接/分发例外一并保留。
此包没有 PGXS LLVM bitcode 或独立 llvmjit 子包。

## 运行配置与联合验证

初始化一次性 PostgreSQL 18 实例，使用同平台 pg_duckdb 1.2.0 包和本次生成的
pg_mooncake 包。配置：

```ini
shared_preload_libraries = 'pg_duckdb,pg_mooncake'
wal_level = logical
duckdb.allow_community_extensions = true
duckdb.allow_unsigned_extensions = true
# RPM:
mooncake.extension_repository = '/usr/pgsql-18/share/extension/pg_mooncake'
# DEB 使用 /usr/share/postgresql/18/extension/pg_mooncake
```

使用源码中的 `tests/pg_regress`、`tests/version_guard.py`、`tests/integration.py`。
回归覆盖 setup、sanity、partitioned_table；版本检查拒绝 1.1.3 与 1.3.0 并接受
1.2.0；集成测试覆盖初始复制、INSERT/UPDATE/DELETE、聚合、过滤、JOIN、预备语句、
回滚、快照、compaction、无关 WAL、空表和分区表。重启后继续检查复制与清理，
并核对实际加载的 DuckDB v2.0.0 / Mooncake v0.0.2。

仅验证全新数据库和本地存储。0.2.0 到 0.3.0 的 SQL 升级脚本未由上游提供，
打包不补写；S3、崩溃恢复和压力测试不在本次验证范围。

另有一个已记录的查询边界：u24a / PG14 在 PL/pgSQL `DO` 中动态执行
`EXPLAIN` 时，pg_duckdb 报 `Duckdb_ExplainCustomScan_Cpp` 内部错误，
`DataChunk::GetValue(1, 0)` 访问越界。普通独立 SQL 的 `EXPLAIN` 通过，
其他平台上的同类动态调用未逐一验证。首轮失败日志保存在
`apt/noble/pg-mooncake-0.3.0-matrix-20261105/arm64/validation/runtime/pg14-first-attempt/`。
因此联合功能通过不表示所有 PL/pgSQL 调用路径均已验证。

## DEB 构建入口

在 `pgsty/u24a:build` 中运行：

```bash
cd ~/debbuild
pig build get pg_mooncake-0.3.0.tar.gz
# 只有取源失败时，从本地权威目录复制这一个归档到容器 ~/ext/src。
cd pg_mooncake
RUSTUP_TOOLCHAIN=stable make PG_VERSIONS=18 JOBS=4
```

使用 stable 前应确认 `rustc --version` 为 1.99.0，`cargo pgrx --version` 为
0.19.3。工具链由 builder 的 rustup 提供；系统依赖由 `debian/control.in` 声明，
正常使用 `dpkg-checkbuilddeps` 和 `dpkg-buildpackage` 检查依赖。Jammy
系统 CMake 过旧时，调用既有 `kitware-cmake` 安装私有 CMake 3.31.12，
仅在构建子进程的 PATH 中使用它；此时显式检查除 CMake 外的完整依赖列表，
再对 dpkg-buildpackage 使用 `-d`。ICU 开发头文件由 `libicu-dev` 明确提供。
`PG_VERSIONS` 可指定 PG14–18 子集，默认 PG18；同一构建树的各阶段串行执行。

检查主 `.deb` 和自动生成的 `-dbgsym` 包（依发行版为 `.deb` 或 `.ddeb`），确认两个 ELF 的 build-id/debuglink
与非空 DWARF。payload 不安装共享 `postgresql-doc-*` README；实际执行联合测试
才能确认 DuckDB footer 在 debhelper 处理后仍有效。

## 2026-11-05 PG18 代表性验证

环境：`pgsty/u24a:build` / Ubuntu 24.04.5 noble / arm64 / PostgreSQL 18.6。构建使用 Rust 1.99.0、cargo-pgrx 0.19.3。
主 `.deb` 和 `-dbgsym .ddeb` 共 2 个包。

| 检查 | 结果 |
| --- | --- |
| 源码 SHA-256、固定依赖与三个 Cargo.lock | 通过；锁文件未改变 |
| 系统构建依赖、版本检查、完整编译与打包 | 通过 |
| 主包、debug payload 与 build-id 对应 | 通过；两个 ELF 均已拆分，DWARF 非空 |
| DuckDB 534 字节 footer | 与编译产物一致；安装包实际加载成功 |
| 全新实例安装与 SQL 回归 | 3/3 通过 |
| pg_duckdb 版本检查 | 3/3 通过 |
| 联合集成检查 | 11/11 通过 |
| 重启后继续复制与清理 | 2/2 通过 |
| 最终状态 | Moonlink 表注册 0，复制槽 0；无 panic / segmentation fault |

运行版本为 pg_mooncake 0.3.0、pg_duckdb 1.2.0、DuckDB v2.0.0，实际加载的
Mooncake 插件为 v0.0.2。主包没有 LLVM/Clang/core-llvmjit 运行依赖，也没有独立
扩展 llvmjit 包。打包器的 DWZ/插件未解析符号提示未影响上述 DWARF 与实际加载检查。

产物已拉回 `apt/noble/pg-mooncake-0.3.0-20261105/arm64/`。该目录的 `SHA256SUMS` 与 builder 产物逐项匹配，
`validation/` 保存构建、payload、集成、服务日志及可复现检查脚本。
源码归档已进入本地权威目录；本地 `data.pgext.extension`、`pgext.universe`、
`pgext.doc` 的相关 URL 元数据和 `db/extension.csv`、`db/universe.csv` 已同步。
已发布包矩阵保留原有事实。

以上为最初的 PG18 代表性验证。后续完整矩阵的产物和验证结果单独记录；
本批产物为本地候选包，未进入生产 staging，也未签名、重建或发布仓库。

## 2026-11-05 完整矩阵交付

本批仅使用 m0、m4、m5，未连接或使用正在运行性能测试的 m1。
RPM 六个平台与 DEB 十个平台均完成 PG14–18，共 80 个组合；
190 个二进制包（90 RPM、100 DEB/dbgsym）及 30 个 SRPM 已取回本地。
实际运行 PostgreSQL 版本为 14.24、15.19、16.15、17.11、18.6。

下表均为原生架构 Docker builder 的实际结果；每行覆盖五个 PG 主版本。

| 镜像 | 实际系统 | 包架构 | 宿主 | 二进制包 | SRPM |
| --- | --- | --- | --- | ---: | ---: |
| `pgsty/d12:build` | Debian GNU/Linux 12 (bookworm) | amd64 | m4 | 10 | 0 |
| `pgsty/d13:build` | Debian GNU/Linux 13 (trixie) | amd64 | m4 | 10 | 0 |
| `pgsty/u22:build` | Ubuntu 22.04.5 LTS | amd64 | m0 | 10 | 0 |
| `pgsty/u24:build` | Ubuntu 24.04.5 LTS | amd64 | m4 | 10 | 0 |
| `pgsty/u26:build` | Ubuntu 26.04.1 LTS | amd64 | m4 | 10 | 0 |
| `pgsty/d12a:build` | Debian GNU/Linux 12 (bookworm) | arm64 | m5 | 10 | 0 |
| `pgsty/d13a:build` | Debian GNU/Linux 13 (trixie) | arm64 | m5 | 10 | 0 |
| `pgsty/u22a:build` | Ubuntu 22.04.5 LTS | arm64 | m5 | 10 | 0 |
| `pgsty/u24a:build` | Ubuntu 24.04.5 LTS | arm64 | m5 | 10 | 0 |
| `pgsty/u26a:build` | Ubuntu 26.04.1 LTS | arm64 | m5 | 10 | 0 |

每个组合包含主包与自动 dbgsym 包，后缀依发行版为 `.deb` 或 `.ddeb`。
产物位于 `apt/<codename>/pg-mooncake-0.3.0-matrix-20261105/<arch>/`；
代号为 bookworm、trixie、jammy、noble、resolute。

u24/u24a 在通用的 PG 专属插件 Build-ID 修复加入配方前完成构建，
这两组原始候选包已通过五个 PG 主包与 dbgsym 共装检查。
本批有上述配方差异，不能视为所有平台均由最后一版配方重新构建。

全部 80 个组合均安装本次 pg_mooncake 包与同平台 pg_duckdb 1.2.0 包，
并验证主包/debug 包共装、SQL/control、两个 ELF 的架构与 Build-ID/debuglink、
非空 DWARF、DuckDB 插件 534 字节 footer，以及主包无 LLVM/Clang 运行依赖。
RPM 复用 `pg-duckdb-1.2.0-20261104` 批次，DEB 复用
`pg-duckdb-1.2.0-v13-20261104` 批次。

矩阵运行检查覆盖 1,000 行初始复制、INSERT/UPDATE/DELETE、事务回滚、
预备查询、快照、full compaction、源表与镜像表完整结果比较、独立 EXPLAIN
中的 DuckDB 执行路径、PostgreSQL 重启后继续复制，以及删除后的注册/复制槽清理。
80/80 组合均有 `PASS` 与 `EXPLAIN-PASS`，实际服务日志无 panic、
segmentation fault 或异常信号退出。此矩阵为主要功能 smoke；前述 el9a/u24a
PG18 的上游回归 3/3、版本守卫 3/3、集成 11/11 与重启 2/2 是另一次深入验证。
PL/pgSQL 动态 EXPLAIN 的已知问题及未覆盖的 S3/崩溃压力/SQL 升级边界仍适用。

每个产物目录的 `SHA256SUMS` 已与取回的包逐项核对；`validation/` 保留
payload、安装、运行日志与复查脚本。RPM 的 `source/SHA256SUMS` 另记录 SRPM。
全量交付清单为 RPM 仓库中的
`tmp/pg-mooncake-0.3.0-matrix-20261105/matrix-delivery.json`。
构建产物均为本地候选包，未进入生产 staging/stash，未签名或发布。

## 2026-11-05 本地入库与目录同步

后续入库验收已将上述 30 个主 RPM、50 个主 DEB 加入本地正式仓库索引，
110 个 debug 包独立归档。签名、索引及客户端下载验收通过，回执见
`~/pgsty/repo/reports/daily-package-final-20261105.md`。
本地 `pgext.extension`、`pgext.universe`、双语 changelog 及其 CSV
已补齐完整矩阵与已知限制；CDN 与源码镜像尚未同步。
