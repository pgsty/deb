# Vchord suite 2026-11-04

本批使用 PGSTY 自有分支：vchord 1.2.0、vchord_bm25 1.0.0、pg_tokenizer 1.0.0，
支持 PostgreSQL 14–18。RPM 侧来源和 SHA256 清单见兄弟仓库 `rpm/doc/vchord-suite.md`。
源文件直接下载 GitHub tag 归档到 `~/pgsty/repo/ext/src`，分别命名为
`vchord-1.2.0.tar.gz`、`vchord_bm25-1.0.0.tar.gz`、`pg_tokenizer-1.0.0.tar.gz`。
pg_tokenizer 的 tag 带 `v` 前缀，另外两个 tag 不带。

## 工具链与配方

- cargo-pgrx/pgrx 为 0.19.3，本批使用 Rust 1.99.0；release debug=2、strip=none，保留自动 dbgsym。
- vchord 的 ARM64 SIMD C shim 需要 Clang >= 16。Makefile 显式选取可用的新版本 Clang，并检查 major；`control.in` 列出版本化 compiler/libclang 开发包。
- `LIBCLANG_PATH` 必须是规范化后的路径。Clang 21 的 `-print-file-name=libclang.so` 可能包含 `../..`；直接把这种 dirname 交给 clang-sys 会触发 panic。
- vchord 导出 dpkg build flags，禁用该 C shim 路径的 GCC LTO 标志，仍保留优化与 DWARF。
- 三套配方声明 `libicu-dev`；否则 PostgreSQL 头文件的 `unicode/ucol.h` 会导致 pgrx bindgen 失败。
- vchord 的 workspace 版本 `0.0.0` 不应改写。扩展版本由 control 和分支提供的 SQL 确定；编译前后检查锁文件不变。
- vchord、vchord_bm25 安装分支自带的 release/upgrade SQL。bm25 1.0.0 使用 tsvector 和新索引格式；自带的 0.3.0 升级脚本会拒绝不兼容的原地升级。
- LICENSE 安装到包自己的文档目录，不使用共享 `postgresql-doc-*` 路径。
- Debian 的 dbgsym 包使用 `.deb`，本批 Ubuntu 的 dbgsym 使用 `.ddeb`；按包名与 `.debug` payload 验证并收集两种后缀。

Ubuntu 22.04 默认 Clang 15 不满足 vchord 要求。本批在隔离 builder 中使用 LLVM 官方
`https://apt.llvm.org/jammy/` 的 `llvm-toolchain-jammy-19` 仓库，安装 `clang-19` 和
`libclang-19-dev`。仓库密钥指纹为
`6084F3CF814B57C1CF12EFD515CF4D18AF4F7421`，通过 `signed-by` 限定密钥；保持 APT 签名验证。
其他 Debian/Ubuntu builder 使用已有的 Clang 19，Ubuntu 26.04 使用 Clang 21。

## 构建与验证

网络请求和安装均走宿主机本地 8888 HTTP 代理：Mac Docker 使用
`host.docker.internal:8888`，Linux Docker 使用 host 网络和 `127.0.0.1:8888`。
先运行 `pig build get`，仅补复制缺失的指定归档。

```bash
cd ~/debbuild/vchord
make PG_VERSIONS='14 15 16 17 18'
```

先导平台 `pgsty/u26a:build`（Ubuntu 26.04.1、arm64、PG18）已完成三个主包及三个
dbgsym 的构建、payload 检查、安装、preload 和联动 SQL 验证。RPM 先导 el10a 同时通过。
完整十平台矩阵现已完成：每个平台 15 个主包和 15 个 dbgsym，总计 300 个 DEB/DDEB。
全部 50 个发行版/架构/PG 组合均安装本批三个扩展并通过联动测试；执行计划确认使用
vchord 向量索引与 BM25 索引。包、依赖、debug payload 和取回后的 SHA256 均已核对。

| 镜像 | 实际系统 | 架构 | 构建主机 | 包数量 |
|---|---|---|---|---:|
| `pgsty/d12:build` | Debian 12 / bookworm | amd64 | m0 → m3 | 30 |
| `pgsty/d12a:build` | Debian 12 / bookworm | arm64 | m1 | 30 |
| `pgsty/d13:build` | Debian 13 / trixie | amd64 | m3 | 30 |
| `pgsty/d13a:build` | Debian 13 / trixie | arm64 | m5 | 30 |
| `pgsty/u22:build` | Ubuntu 22.04.5 / jammy | amd64 | m0 → m3 | 30 |
| `pgsty/u22a:build` | Ubuntu 22.04.5 / jammy | arm64 | m1 | 30 |
| `pgsty/u24:build` | Ubuntu 24.04.5 / noble | amd64 | m3 | 30 |
| `pgsty/u24a:build` | Ubuntu 24.04.5 / noble | arm64 | m5 | 30 |
| `pgsty/u26:build` | Ubuntu 26.04.1 / resolute | amd64 | m3 | 30 |
| `pgsty/u26a:build` | Ubuntu 26.04.1 / resolute | arm64 | m5 | 30 |

m0 同时编译三个扩展后，将已生成的缓存与构建目录转到 m3 继续剩余目标；两个平台
最终在 m3 完成打包与安装验收。对应系统镜像、源码与配方保持一致。

任务证据位于 `~/.cache/pgext/vchord-suite-20261104/`。构建产物取回到
`apt/<codename>/vcs1104/<architecture>/`；该目录只是本地收集目录，未导入或发布 APT 仓库。
联合验收回执为 `~/.cache/pgext/vchord-suite-20261104/receipt.json`：RPM/DEB 共
16 平台、240 个扩展坐标、570 个二进制包、80 个隔离 PostgreSQL 测试集群。
本任务未修改 `pgext` 元数据库；bm25/tokenizer 的版本和源码字段仍需在授权后同步。

## vchord 1.2.0-2PGSTY 重构建：2026-11-05

本批仅重构建 vchord，与同日 RPM 任务使用完全相同的源码及包修订号。
`debian/changelog` 从 `1.2.0-1PGSTY` 增为 `1.2.0-2PGSTY`，构建副本追加真实系统代号，
最终版本为 `1.2.0-2PGSTY~bookworm/trixie/jammy/noble/resolute`。
Makefile 记录了重发 tag 的提交和源码校验值，没有引入下游补丁。

- 上游：`pgsty/vchord` 的 `1.2.0` tag，提交 `6ea6a3be3b2ec5521f2575055d3c77a0b9771f95`。
- 源码：`~/pgsty/repo/ext/src/vchord-1.2.0.tar.gz`。
- SHA256：`caf1a482b62e8eba507c881f3acda3365393fc4d1648ad5ca9d4dd51d47a96a0`。
- Cargo.lock SHA256：`8d2e52210bcb7daca5643af4ef8ebe703b86451a8bd6a8fddf3c939464ccbb84`，构建前后均核对。

RPM 任务已重新下载并逐一比对归档内 288 个文件与上述提交；DEB 复用这份已核验归档。
它与上一批归档内容相同，因此本次是包修订重构建，没有新的上游源码变更。
供应来源保持 PGSTY，不重建其他扩展。只读核对 `pgext.extension` 后确认
`version/rpm_ver/deb_ver` 均为 `1.2.0`、`source` 为 `vchord-1.2.0.tar.gz`，无需改写这些字段。

十平台全部完成 PG14–18 构建、逐包验证、安装和运行测试：

| 镜像 | 实际系统 | 架构 | 构建主机 | 主包 + dbgsym |
|---|---|---|---|---:|
| `pgsty/d12:build` | Debian 12 / bookworm | amd64 | m0、m4 | 5 + 5 |
| `pgsty/d12a:build` | Debian 12 / bookworm | arm64 | m1 | 5 + 5 |
| `pgsty/d13:build` | Debian 13 / trixie | amd64 | m4 | 5 + 5 |
| `pgsty/d13a:build` | Debian 13 / trixie | arm64 | m5 | 5 + 5 |
| `pgsty/u22:build` | Ubuntu 22.04.5 / jammy | amd64 | m0、m4 | 5 + 5 |
| `pgsty/u22a:build` | Ubuntu 22.04.5 / jammy | arm64 | m1 | 5 + 5 |
| `pgsty/u24:build` | Ubuntu 24.04.5 / noble | amd64 | m4 | 5 + 5 |
| `pgsty/u24a:build` | Ubuntu 24.04.5 / noble | arm64 | m5 | 5 + 5 |
| `pgsty/u26:build` | Ubuntu 26.04.1 / resolute | amd64 | m4 | 5 + 5 |
| `pgsty/u26a:build` | Ubuntu 26.04.1 / resolute | arm64 | m5 | 5 + 5 |

m0 分别构建 Debian 12、Jammy 的 PG17，其余 PG 在 m4 构建；各自安装测试后统一收集。
其余平台单 builder 覆盖全部五个 PG。m4 缺少的 Jammy builder 镜像从 m0 复制，
具体镜像 ID 和每个 PG 的来源保存在回执中。五个 ARM64 平台复用空闲 builder，
使用单独的 recipe、构建及输出目录；各平台均重新编译，没有复用上一批二进制产物。

工具链从实际编译进程读取并保存：Rust 1.99.0、cargo-pgrx 0.19.3；
Debian 12/13 和 Jammy 使用 Clang 19.1.7，Noble 使用 Clang 19.1.1，Resolute 使用 Clang 21.1.8。
Jammy 的 Clang 19 来自 LLVM 官方签名仓库。`CC/CXX` 明确指向版本化 Clang，
`LIBCLANG_PATH` 已规范化；C/C++ 保留 `-g` 且不带 GCC LTO 参数，Rust release 使用 debug=2、strip=none。
除由 rustup 提供的 Cargo 外，声明的系统构建依赖已通过 `dpkg-checkbuilddeps` 检查。

每个 builder 均先执行 `pig build get vchord`，并检查目标归档 SHA256。
取源元数据仍指向旧归档时，只补入当前缺失的 `vchord-1.2.0.tar.gz`。
PGDG 和 Jammy LLVM 仓库使用已核验指纹的密钥和 `signed-by`；GitHub 请求沿用本机 8888 代理策略。

验收结果：

- 静态检查、真实源码解包、`pg_buildext updatecontrol` 和 50 个系统/架构/PG 组合的实际构建全部通过；包含默认代表平台 `pgsty/u24a:build`。
- 100 个包：50 个主包、50 个自动 dbgsym。Debian 的 dbgsym 后缀为 `.deb`，Ubuntu 为 `.ddeb`，两者均已收集。
- 逐包核对版本、架构、运行依赖及文件列表；主包含 SO、control 和 17 份 SQL，control/SQL 与上游逐字节一致。
- SO 与 dbgsym 的 Build ID、GNU debuglink 文件名和 CRC 匹配，dbgsym 包含非空 DWARF。
- 主包没有 LLVM/Clang/core-llvmjit 运行依赖，没有共享 `postgresql-doc-*` 文档冲突路径或 PGXS bitcode/index。
- 全部 50 个独立数据库环境通过 preload、CREATE EXTENSION、版本检查、vchordrq/vchordg 索引查询与执行计划检查、halfvec 查询、事务回滚、UPDATE/DELETE、VACUUM、REINDEX 和 pg_dump/pg_restore 验证。
- 100 个包共 1,283,939,034 字节，已取回 `apt/<codename>/vcr1105/<architecture>/`，与 builder SHA256 逐一匹配。每个平台目录含 `SHA256SUMS`。

完整证据位于 `~/.cache/pgext/vchord-deb-reissue-20261105/`：`receipt.json`、
`packages.json`、`SHA256SUMS`、配方和源码校验值、实际工具链、镜像 ID、构建日志、
运行日志，以及 `.changes` / `.buildinfo` 和生成的 control/changelog/pgversions。
七个本次新建的 builder 已停止并保留缓存；五个复用 builder 已恢复原 CPU/内存限制和运行状态。

本批已完成静态检查、代表性构建、十平台生产矩阵及本地取回验收。
未进入生产 `stash/`，未运行 reprepro、生成生产 APT 元数据或同步 CDN，未发布源码镜像。
本次未改动 RPM 产物或 pgext 数据库。源码与此前相同，先前记录的 vchordg/halfvec 排序问题不因本次重构建而改变。

## 2026-11-05 本地入库与目录同步

后续入库验收已将本批 50 个主 DEB 导入五个系统的正式 APT 索引，
50 个 dbgsym 独立归档；RPM 同修订的 30 个主包也已入库。
签名、索引与客户端下载验收通过，回执见
`~/pgsty/repo/reports/daily-package-final-20261105.md`。
本地 PGEXT 目录与双语 changelog 已记录 `1.2.0-2PGSTY` 重构建，
扩展版本字段仍为 `1.2.0`。CDN 与源码镜像尚未同步。
