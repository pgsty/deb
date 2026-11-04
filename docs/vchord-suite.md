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
