# OrioleDB DEB

内核与 OrioleDB 存储引擎合包，版本 `1.10~beta19-1PGSTY`，安装到 `/usr/oriole-<PG_MAJOR>`。默认构建 PG18，保留 PG16、PG17 配方。

| PG | PostgreSQL | Patchset | 内核源码 |
|---|---|---|---|
| 16 | 16.15 | 49 | `postgres-patches16_49.tar.gz` |
| 17 | 17.11 | 22 | `postgres-patches17_22.tar.gz` |
| 18 | 18.6 | 3 | `postgres-patches18_3.tar.gz` |

各版本共同使用 `orioledb-beta19.tar.gz`。源码与 RPM 使用同一批归档，branding 补丁也与 RPM 的 `oriolepg-postgresql-branding.patch` 一致。LLVM 默认启用，保留发行版编译标志并由 `dh_strip` 自动生成 dbgsym。

在 builder 中先运行 `pig build get orioledb`。如果索引仍返回旧版本，仅把当前 PG 所需的两个缺失归档复制到 `~/ext/src/`；`~/debbuild/SOURCES` 应指向该目录。然后运行：

```bash
cd ~/debbuild/orioledb
make orioledb-18
```

`orioledb-16`、`orioledb-17` 和 `orioledb-all` 为现有其他目标。

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
