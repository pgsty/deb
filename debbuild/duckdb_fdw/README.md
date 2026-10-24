# duckdb_fdw 独立静态包

使用正式 duckdb_fdw 2.0.2 和 DuckDB 2.0.0 源码，与 RPM 使用相同的固定归档、校验和通用补丁。DuckDB 核心、Parquet、JSON、ICU 及动态加载能力静态嵌入 FDW，不安装 libduckdb.so，不依赖 pg_duckdb。

独立包相关文件：本目录 `Makefile`、`README.md`，`debian/changelog`、`control.in`、`copyright`、`rules`、`pgversions` 和 `patches/series`；以 `duckdb_fdw-2.0.2-static.patch` 替换旧补丁并删除 `debian/shlibs.local`。`debbuild/Makefile` 已有可用入口，无须修改。

同一 PG 主版本使用 `Conflicts: postgresql-PGVERSION-pg-duckdb`。切换软件包时修改 shared_preload_libraries 并重启实例；卸载包不会卸载进程中的旧库。运行时 guard 检测实际加载模块，不根据 control 文件存在与否拒绝。Bsymbolic/fno-gnu-unique 约束自身绑定，但不能保证后来加载的其他 DuckDB 核心不误绑定，因此不承诺同 backend 共存。

FDW 的单向 Conflicts 已能阻止两种安装顺序。pg_duckdb 的 `debian/control`、`control.in` 和 `source/control` 同步维护反向 `Conflicts: postgresql-PGVERSION-duckdb-fdw`，仅修改配方，未重编；反向声明随其下次打包生效，当前 FDW 的保护不依赖该重编。两侧声明均只限制对应 PG 主版本。

保留发行版优化、加固、调试信息、PGXS LLVM bitcode/index 和自动 dbgsym。原生 GCC LTO 因 EL9 上可复现的 INSERT 错误禁用；LLVM 不受影响。只安装上游 control/SQL，不自行补写迁移。

DEB 独有适配：大型静态核心超过 noble `dwz` 的 DIE 数量限制，首次打包在 `dh_dwz` 报 `Too many DIEs, not optimizing`。`debian/rules` 仅对 `duckdb_fdw.so` 跳过可选的 DWARF 去重，继续由 `dh_strip` 保留并拆分完整调试信息，未禁用 dbgsym。其他平台差异不放进通用源码补丁。

在隔离 builder 中先 `pig build get duckdb_fdw`，再请求两个准确归档；失败后只复制缺失文件。源码位于 `~/ext/src`，`~/debbuild/SOURCES` 指向它。运行 `make PG_VERSIONS=18 FDW_MAX_JOBS=12` 可构建代表性 PG18；不指定 PG_VERSIONS 时使用 PG15–18。取源校验已内置 recipe。

## 固定来源

| 项目 | 正式 tag / commit | 归档和 SHA-256 |
|---|---|---|
| [duckdb_fdw](https://github.com/alitrack/duckdb_fdw/releases/tag/v2.0.2) | v2.0.2 / `4c444d19f80eace50bc09fa3ec766e8ca2cf667d` | `duckdb_fdw-2.0.2.tar.gz` / `1ed7935b009211915434fd65083b0562389e3faf1722865f81633d70a0c0fc8b` |
| [DuckDB](https://github.com/duckdb/duckdb/releases/tag/v2.0.0) | v2.0.0 / `d54cbbe3df17e8e5ce68312f483b4155836112aa` | `duckdb-2.0.0.tar.gz` / `7e89053255046bfb26afbd7f524a2fb84df7dbef496aa911ea35e4a1182fdc00` |

两者均已核对正式 release/tag；校验值是官方 tag 归档的本地 SHA-256，不是上游另行签署的声明。最终源码在 `/Users/vonng/pgsty/repo/ext/src/`。GitHub 下载走 `http://127.0.0.1:8888`。没有使用旧 `2.0.1+git20260529.9354241` 快照作为正式版。

删除旧 2.0.1 补丁和 `shlibs.local`；原有 PG API、slot、连接/事务、类型和普通方括号文本适配采用正式上游实现，不复用旧源码修改。新通用补丁仅涉及静态构建、静态扩展注册和运行时 guard；与 RPM 的 `duckdb_fdw-2.0.2-static.patch` 逐字一致。11 个 SQL/升级脚本及 control 原样安装并逐文件比较，不新增迁移。

## 2026-10-24 实际验收

先完成 EL9 RPM 验收，再开始本次 noble 构建。实际环境：Ubuntu **24.04.5 LTS**，arm64/aarch64，PostgreSQL **18.6-1.pgdg24.04+2**，GCC **13.3.0**，CMake **3.28.3**，Clang/LLVM **19.1.1**。镜像 `pgsty/u24a:build` 的 ID 为 `sha256:a4fa63b43bba30fbab4d71d85bcff43a4b9bc95a539e7d6e15af4201c19c7b89`，独立容器为 `duckdb-fdw-20261024-u24a` 和 `duckdb-fdw-20261024-u24a-peer`。

| 验收项 | 结果 |
|---|---|
| 完整包 | `postgresql-18-duckdb-fdw_2.0.2-1PGSTY~noble_arm64.deb` 与自动 dbgsym `.ddeb` 均生成，最终 `dpkg-buildpackage` 退出 0 |
| 调试信息 | dbgsym 内 `.debug` 大小 922,649,408 字节；没有剥除 core DWARF 后伪造空调试包 |
| 文件 | 无通用 libduckdb.so；PGXS bitcode/index 在主包；文档和许可证在本包私有目录 |
| 依赖 | `postgresql-18, libc6 (>= 2.38), libgcc-s1 (>= 3.0), libstdc++6 (>= 13.1)`；无 pg_duckdb、外部 libduckdb、LLVM/Clang 直接依赖 |
| 冲突 | 仅 `postgresql-18-pg-duckdb`，无 Replaces；两种安装顺序均由 dpkg 拒绝，原包保持安装 |
| ELF | 无 libduckdb DT_NEEDED、无强未解析 DuckDB 核心依赖；无 GNU unique 定义；自身导出与动态重定位交集为零；保留 PG magic/init/SQL 导出和 RELRO/NOW |
| 实际引擎 | CREATE EXTENSION 2.0.2，DuckDB v2.0.0；fingerprint 的核心路径就是 duckdb_fdw.so |
| SQL | 扫描、INSERT 回读、ROLLBACK、NULL、decimal、timestamptz、数组、看似数组的普通文本通过 |
| 插件 | 内建 Parquet 与官方 v2.0.0 ARM64 httpfs 加载、回环 HTTP Parquet 读取通过；记录同 backend 实际 ELF 路径 |
| LLVM | 实际 JIT 生成 4 个函数，inlining/optimization 开启，FDW SQL 函数调用和结果通过 |
| pg_duckdb 单独运行 | 复用原有 1.1.1 包，实际核心 v1.4.3；duckdb.query=42 和强制 DuckDB 执行 sum=55 通过，未重编 |
| 残留预加载 | 在一次性 peer 容器替换软件包而不重启，两个全新 backend 的 CREATE/LOAD 明确报错，postmaster 存活；移除预加载并重启后 FDW 正常 |

上游 11 个适用 SQL examples 均通过，可选 pgvector 示例不在本次范围。原样 `make installcheck` **未全绿**：上游 expected 缺少实际 EXPLAIN 的 `CAST("s" AS VARCHAR)`，另有四处空行差异。完整差异已保存；仅规范化这些已知输出差异后，其余 SQL 结果完全一致。没有修改上游 expected 文件。

ELF 仍有 55,543 个导出定义，含核心及第三方符号；本次并未宣称任意加载顺序安全。已覆盖 pg_duckdb 预加载在先、替换软件包后 FDW CREATE/LOAD 在后。未覆盖绕开包管理器手工复制库、FDW 在先再加载 peer 核心等组合，也不支持同一连接临时切换模式。控制文件存在本身不会使运行时 guard 拒绝。

官方测试插件 URL：`https://extensions.duckdb.org/v2.0.0/linux_arm64/httpfs.duckdb_extension.gz`，SHA-256：`f524888fc7d74cc0c6c4a8f7ed5beedac5b12e71cb426503f882c72ce6afbd43`；运行时扩展版本 `77392a7207`。该文件仅用于测试，没有打入包。此插件使用 C++ 初始化入口、携带部分自身实现；不能由单个插件通过推论所有 C++ 插件或完全隐藏核心的变体都兼容。

## 复现与证据

```sh
cd /root/debbuild
pig build get duckdb_fdw
pig build get duckdb_fdw-2.0.2.tar.gz duckdb-2.0.0.tar.gz
# 仅在失败后复制上述确定缺失的归档到 /root/ext/src。
cd duckdb_fdw
FDW_MAX_JOBS=12 DEB_BUILD_OPTIONS=parallel=12 \
  DPKG_DEB_COMPRESSOR_TYPE=zstd DPKG_DEB_COMPRESSOR_LEVEL=6 make PG_VERSIONS=18
```

首次从源码完成全部 core/native/LLVM 构建后，在 dwz 阶段失败；修正后以 `dpkg-buildpackage -b -us -uc -nc` 复用已有源码构建的归档，重新执行 FDW native/LLVM 编译、安装和完整二进制打包。第一次重试还发现 PostgreSQL substvar 没有被手工安装循环填入，最终明确声明 `postgresql-PGVERSION` 依赖。最终日志为 `u24a-final-package.log`，不是前两次失败或中间包。新环境执行上面的正常入口即可包含这两项修正。

noble builder 的 `/etc/dpkg/dpkg.cfg.d/excludes` 默认过滤大部分文档。包内文档和许可证完整；验收中另外使用 `dpkg --path-include='/usr/share/doc/postgresql-18-duckdb-fdw*' -i <主包>` 保留文档并检查 `dpkg -V` 输出为空。这是测试环境设置，没有修改系统全局配置或配方 payload。

全部日志、复现脚本和制品保存在 `/Users/vonng/tmp/duckdb-fdw-20261024/`：

- `REPRODUCE.md`、`work/`：完整安装、SQL/插件、ELF 和双向包冲突命令。脚本仅供隔离容器的一次性集群使用。
- `logs/u24a-final-package.log`、`u24a-package.log`、`u24a-installed-payload.log`、`u24a-elf.log`：最终构建与包检查。
- `logs/u24a-runtime.log`、`u24a-qa-final/`、`u24a-peer-tests.log`、`u24a-peer-qa-final/`：运行和错误组合验证。
- `artifacts/u24a/`：主包、dbgsym、buildinfo、changes；`artifacts/manifest.json` 包含大小与 SHA-256。

主包 SHA-256 为 `4c6aa7550c29bdd7465dd9718aafd87bf9780c689ba46edb6cf3d936a3906d2b`，dbgsym 为 `c7dd5918d3badd842836d37d7c4d327b2c13fc03c4ebf13a73d5ca67b8234c8e`。本次是完整代表性二进制包和运行验收，没有生成 DEB source package，也没有执行十平台矩阵。

## 后续范围

本次仅 PG18 获得完整包和运行验证。在 EL9 对 PG14.24 的后续编译探测发现，正式 2.0.2 使用了 PG14 没有的 `boolVal` / `makeBoolean`，LLVM 编译失败（`logs/el9a-pg14-compile-probe-final.log`）。因此两侧默认入口收敛为 PG15–18，PG14 列为兼容性待办；没有修改已验收 PG18 的编译/链接输入。PG15–17 尚待完整包和运行验证，建议先补 PG17 再 PG15/16；其他发行版/架构分别核对编译器、系统 ABI 和对应官方插件。EL9 RPM 依赖不能作为 EL8 可用性的证据，noble 包也不能直接用于其他 Ubuntu/Debian 版本。无需因此重编 pg_duckdb 或其他无编译输入变化的扩展。

当前状态为代表性完整包和运行验收通过，未推送、导入 APT/YUM、签名或发布。pgext 版本、source 两个归档、移除旧 pg_duckdb 依赖和标注同 PG 安装互斥均列为后续元数据待办，尚未写入数据库。

补充 EL8 情况：另在 Rocky 8.10 ARM64 PG18、GCC 8.5、LLVM 21.1.8 做了 180 秒编译探测。依赖和配置通过，完成 88/2,018 步后按时限中止，未发现真实编译错误，也没有完成包或运行验证；不能宣称 EL8 已支持。详见证据目录 `logs/el8a-probe.log`。
