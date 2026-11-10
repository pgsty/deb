# OrioleDB DEB

内核与 OrioleDB 存储引擎合包，版本 `1.10.3-1PGSTY`，安装到 `/usr/oriole-<PG_MAJOR>`。默认构建 PG18，同时支持 PG16、PG17。

| PG | PostgreSQL | Patchset | 内核源码 |
|---|---|---|---|
| 16 | 16.15 | 50 | `postgres-patches16_50.tar.gz` |
| 17 | 17.11 | 23 | `postgres-patches17_23.tar.gz` |
| 18 | 18.6 | 4 | `postgres-patches18_4.tar.gz` |

各版本共同使用 `orioledb-1.10.3.tar.gz`。源码与 RPM 使用同一批归档，branding 补丁也与 RPM 的 `oriolepg-postgresql-branding.patch` 一致。LLVM 默认启用，保留发行版编译标志并由 `dh_strip` 自动生成 dbgsym。

在 builder 中先运行 `pig build get orioledb`。如果索引仍返回旧版本，仅把当前 PG 所需的两个缺失归档复制到 `~/ext/src/`；`~/debbuild/SOURCES` 应指向该目录。然后运行：

```bash
cd ~/debbuild/orioledb
make orioledb-18
```

`orioledb-16`、`orioledb-17` 和 `orioledb-all` 为现有其他目标。

官方 v1.10.3 源码将 `orioledb_version()` 定义为 `OrioleDB 1.10.3`，SQL 版本仍是 `1.10`。配方忠实保留上游函数和 11 个安装 SQL 文件；归档不带 Git 元数据，`orioledb_commit_hash()` 返回 40 个零。包版本和内核 branding 使用 `1.10.3`。

## 2026-10-06 全平台验证

PG16、17、18 在 Debian 12/13、Ubuntu 22.04/24.04/26.04 × amd64/arm64 的 30 个组合全部完成真实构建、安装和运行 QA。LLVM 保持启用，没有源码或 LLVM 绕过。

|平台|实际系统|架构|PG|结果|产物|
|---|---|---|---|---|---:|
|`pgsty/d12:build`|Debian GNU/Linux 12 (bookworm)|x86_64|16, 17, 18|构建、安装、运行、JIT、debug 全部通过|6|
|`pgsty/d12a:build`|Debian GNU/Linux 12 (bookworm)|aarch64|16, 17, 18|构建、安装、运行、JIT、debug 全部通过|6|
|`pgsty/d13:build`|Debian GNU/Linux 13 (trixie)|x86_64|16, 17, 18|构建、安装、运行、JIT、debug 全部通过|6|
|`pgsty/d13a:build`|Debian GNU/Linux 13 (trixie)|aarch64|16, 17, 18|构建、安装、运行、JIT、debug 全部通过|6|
|`pgsty/u22:build`|Ubuntu 22.04.5 LTS|x86_64|16, 17, 18|构建、安装、运行、JIT、debug 全部通过|6|
|`pgsty/u22a:build`|Ubuntu 22.04.5 LTS|aarch64|16, 17, 18|构建、安装、运行、JIT、debug 全部通过|6|
|`pgsty/u24:build`|Ubuntu 24.04.4 LTS|x86_64|16, 17, 18|构建、安装、运行、JIT、debug 全部通过|6|
|`pgsty/u24a:build`|Ubuntu 24.04.4 LTS|aarch64|16, 17, 18|构建、安装、运行、JIT、debug 全部通过|6|
|`pgsty/u26:build`|Ubuntu 26.04 LTS|x86_64|16, 17, 18|构建、安装、运行、JIT、debug 全部通过|6|
|`pgsty/u26a:build`|Ubuntu 26.04 LTS|aarch64|16, 17, 18|构建、安装、运行、JIT、debug 全部通过|6|

主包包含内核、OrioleDB 存储引擎、control/SQL/SO 与实际 bitcode/index。每个主包共 1045–1090 个 bitcode 路径（含 index）；每个 dbgsym 包有 128–131 个调试 ELF。postgres 与 orioledb.so 的 Build ID 与调试 ELF 匹配，且有 DWARF。保留核心 JIT 所需 libLLVM 运行库，不依赖 LLVM/Clang 工具链、系统 PostgreSQL 或 libpq5。

安装后的 bin 程序和共享库 ldd 无缺失依赖；初始化、preload、`CREATE EXTENSION orioledb`、`USING orioledb` 建表、插入、更新和查询通过。实际 SQL 版本 1.10，运行引擎 beta 19，内核分别 16.15、17.11、18.6。每个组合均完成实际 JIT 查询，EXPLAIN JSON 证明生成并执行了 JIT functions。数据库已停止。

60 个主包/dbgsym 已校验 SHA-256 并取回 `apt/bookworm`、`apt/trixie`、`apt/jammy`、`apt/noble`、`apt/resolute`。同名旧 pilot 产物先备份后替换。

日志、payload、运行记录、每个产物的大小和 SHA-256 位于 `/tmp/kfull-20261006/oriole-agens/`：`matrix-summary.json` 是逐平台/PG 总表，`SHA256SUMS` 与 `artifact-manifest.tsv` 是已取回产物清单，`results/<platform>/<extension>-<PG>/` 保存完整证据。源码与配方的构建输入摘要见 `input-manifest.json`。

没有生产 staging、签名、仓库索引重建、源码或二进制发布，没有修改 pgext 或元数据库，没有提交 Git。

## 2026-11-03 v1.10.1 全平台验证

`1.10.1-1PGSTY` 在上述十个平台 × PG18、17、16 的 30 个组合全部完成原生构建、安装和运行验收。amd64 使用 m3，ARM64 使用 m1/m5；每个平台依次构建 PG18 → PG17 → PG16。当前源码配对以官方 `.pgtags` 为准，分别为 `patches18_4`、`patches17_23`、`patches16_50`，保留既有 branding 补丁。

| PG | 内核 | ELF/dbgsym 对数 | bitcode 路径（含 index） | index | extension control |
|---|---|---:|---:|---:|---:|
| 18 | 18.6 | 131 | 1090 | 57 | 53 |
| 17 | 17.11 | 129 | 1056 | 55 | 52 |
| 16 | 16.15 | 128 | 1045 | 57 | 54 |

每个组合均对照实际 staging 树检查完整安装 payload，校验所有原生 ELF 的 Build ID 和 DWARF、安装后的动态链接与私有 libpq 路径、OrioleDB bitcode，以及上游 11 个 SQL 文件。核心 COPYRIGHT 和 OrioleDB README、Apache/PostgreSQL license、PATENTS 均安装到包私有文档目录。未生成或补写上游 SQL 升级文件。

30 个组合均通过 initdb/preload、`CREATE EXTENSION`、pg_trgm/hstore/pgcrypto、PLPython/PLTcl、OrioleDB 表插入更新与 TOAST、并发 BTree 索引、实际 GIN bridge 执行计划、事务与保存点回滚、VACUUM/CHECKPOINT、正常重启和 immediate-stop 崩溃恢复；实际 JIT 查询确认函数生成、inlining 和 optimization。官方归档的 SQL 1.10、beta19 内部版本字符串及全零 commit hash 均按上游原样验证。未验证 S3/外部服务部署。

| 源码 | SHA-256 |
|---|---|
| `orioledb-1.10.1.tar.gz` | `222623457c25e48ecc60e521bb1029da5d24ff3a1a4bba5cf9aab527b3c9d55a` |
| `postgres-patches18_4.tar.gz` | `5c47d7a975aee2cd67e00ce156e050a26e018511ea4b9db3ac97737eefbf2e00` |
| `postgres-patches17_23.tar.gz` | `d2a09b303d1a2ab7a29da387e9ea703c320c49f254dabb36a029d75678375943` |
| `postgres-patches16_50.tar.gz` | `4ffef2b213ea7bd0014f69b67ef11590fe6120f86d10173fd9cd6a7f0b78b1ca` |

30 个主包和 30 个 `.ddeb` 已校验 SHA-256 并收回本仓库 `apt/<codename>/`，容器内数据库已停止。证据目录为 `/Users/vonng/.cache/pgsty-build/20261103-extension-production-003724/deb/`，主要清单为 `09c-orioledb-matrix.json`、`09c-orioledb-artifacts.json`、`09c-sources.json` 和逐组合 QA/log 文件。

本批没有 Git 提交、生产 stash、仓库导入、签名或 CDN 发布。元数据库未写入；SQL 版本仍为 1.10，`deb_ver=1.10.1`、四个新源码文件名和 `mtime` 待外部同步，见 `09c-metadata-pending.json`。

## 2026-11-07 v1.10.2 全平台验证

`1.10.2-1PGSTY` 在十个平台 × PG16/17/18 的 30 个组合全部完成原生构建、主包及 dbgsym 审计、安装和运行验收。amd64 使用 m3 Docker，ARM64 使用本机 Docker。每个平台按 PG18 → PG17 → PG16 构建，LLVM 保持启用。

| 镜像 | 实际系统 | 架构 | PG | 产物 |
|---|---|---|---|---:|
| `pgsty/d12:build` | Debian GNU/Linux 12 (bookworm) | amd64 | 16, 17, 18 | 6 |
| `pgsty/d12a:build` | Debian GNU/Linux 12 (bookworm) | arm64 | 16, 17, 18 | 6 |
| `pgsty/d13:build` | Debian GNU/Linux 13 (trixie) | amd64 | 16, 17, 18 | 6 |
| `pgsty/d13a:build` | Debian GNU/Linux 13 (trixie) | arm64 | 16, 17, 18 | 6 |
| `pgsty/u22:build` | Ubuntu 22.04.5 LTS | amd64 | 16, 17, 18 | 6 |
| `pgsty/u22a:build` | Ubuntu 22.04.5 LTS | arm64 | 16, 17, 18 | 6 |
| `pgsty/u24:build` | Ubuntu 24.04.5 LTS | amd64 | 16, 17, 18 | 6 |
| `pgsty/u24a:build` | Ubuntu 24.04.5 LTS | arm64 | 16, 17, 18 | 6 |
| `pgsty/u26:build` | Ubuntu 26.04.1 LTS | amd64 | 16, 17, 18 | 6 |
| `pgsty/u26a:build` | Ubuntu 26.04.1 LTS | arm64 | 16, 17, 18 | 6 |

每个组合均核对完整安装树、所有原生 ELF 的架构/Build ID/DWARF、私有 libpq 与动态链接、上游 control 和 11 个 OrioleDB SQL 文件、许可证及 PATENTS。PG16/17/18 分别有 128/129/131 对 ELF/dbgsym，bitcode 路径为 1045/1056/1090 个，其中 index 为 57/55/57 个。主包包含实际 OrioleDB bitcode 与内核 JIT provider；保留核心 JIT 所需 libLLVM 运行库，无 LLVM/Clang 工具链、系统 PostgreSQL 或 libpq5 运行依赖，无独立 llvmjit 包或共享 PostgreSQL README 冲突。

30 个组合均通过 initdb/preload、`CREATE EXTENSION`、pg_trgm/hstore/pgcrypto、PLPython/PLTcl、OrioleDB 插入更新与 TOAST、并发 BTree 索引构建、实际 GIN bridge 执行计划、事务/保存点回滚、VACUUM/CHECKPOINT、正常重启持久化和 immediate-stop 崩溃恢复。实际 JIT 查询均生成函数并启用 inlining/optimization。运行时为 `OrioleDB 1.10.2`，SQL 版本为 `1.10`，归档构建的 commit hash 保持上游全零行为。未覆盖 S3/外部服务场景或上游完整测试套件。

OrioleDB 新源码 `orioledb-1.10.2.tar.gz` 的 SHA-256 为 `78f1ea1da694ae147d40ab11497eabd8382b6c68a0cf3e11f5310e1707f03633`，三个 PostgreSQL patchset 归档及校验值与上次一致。

30 个主包和 30 个 dbgsym 包已校验 SHA-256 并取回 `apt/bookworm/`、`apt/trixie/`、`apt/jammy/`、`apt/noble/`、`apt/resolute/`；每个目录 12 个本批产物。Debian 的 dbgsym 后缀为 `.deb`，Ubuntu 为 `.ddeb`。测试数据库已停止。

完整证据位于 `/Users/vonng/.cache/pgsty-build/orioledb-deb-1.10.2-20261107/`，包括 `matrix-summary.json`、`artifact-manifest.json`、`artifact-manifest.tsv`、`SHA256SUMS`、`input-manifest.json` 和逐平台/PG 的 `evidence/`。

本地 `data.pgext.extension` 与 `pgext/db/extension.csv` 已同步本批事实：`rpm_ver=1.10.2`、`deb_ver=1.10.2`、新源码文件名和 `mtime=2026-11-07`；保留 SQL `version=1.10`。未进入生产 stash，未导入 APT 仓库、发布源码或同步 CDN，未提交 Git。

## 2026-11-09 v1.10.3 全平台验证

`1.10.3-1PGSTY` 在 Debian 12/13、Ubuntu 22.04/24.04/26.04 × amd64/arm64 × PG16/17/18 的 30 个组合全部完成原生构建、安装和运行验收。RPM 同批完成六个 EL 平台的 18 个组合。源码配对保持 patchset 50/23/4，SQL 版本为 1.10，运行版本为 OrioleDB 1.10.3；LLVM 始终启用，无新增平台补丁。

全部 DEB 组合通过完整 payload、Build ID/DWARF、私有 libpq 与动态链接、83 个 OrioleDB bitcode 对象及 index、11 个 SQL 文件和许可证审计。安装测试覆盖扩展加载、contrib/PL、读写/TOAST、BTree/GIN、事务回滚、JIT、正常重启及崩溃恢复；本次修复对应的上游 `rll_lock_past_retained` isolation 测试三种执行顺序全部通过。没有运行完整上游测试套件或外部 S3 测试。

30 个主包与 30 个 dbgsym 已校验摘要并收回 `apt/<codename>/`。源码 SHA-256 为 `bcc07133da30b3c2f1051ac1f7ac17c9ecbb8c37c97ed127a13f597016885b7f`。详细证据位于 `/Users/vonng/pgsty/artifacts/orioledb-1.10.3-20261109/`，包括矩阵、产物摘要及逐平台/PG 的日志和 QA 数据。

未进入生产 stash，未导入或同步 APT 仓库，未发布源码，未修改 PGEXT/元数据库，未提交 Git。候选版本和 source 更新事实保存在证据目录的 `metadata-pending.json`。
