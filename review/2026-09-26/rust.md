# Rust / pgrx recipe 专项审查记录

[返回总手册](../../DEBIAN_REVIEW_2026-09-26.md)

审查时间：2026-09-26。范围为 `debbuild/` 中 60 个实际调用 Cargo 的 recipe；`hydra` 仅在 PATH 中出现 `.cargo/bin`，按 C/C++ recipe 处理，不计入本专项。

本次只读取 recipe、Debian 文件、本地权威源码 tarball 与必要官方资料。在 `/tmp` 副本中校验补丁和解析 manifest；没有执行 `make setup`、Cargo 编译、Debian 构建、安装、数据库写入、发布，也没有修改 recipe。下列构建与运行后果均按明确触发条件推导，不能视为现有 DEB 已经损坏或已实际暴露服务的证据。

## 已确认的问题与风险

### RUST-01：PgDog 首次安装后可在重启时以固定管理口令监听所有网卡

- **严重度：P1；置信度：高；状态：静态确认，实际服务运行未验证。**
- 位置：`debbuild/pgdog/debian/pgdog.toml:5`、`:18`；`debbuild/pgdog/debian/users.toml:7`；`debbuild/pgdog/debian/rules:32`、`:33`；`debbuild/pgdog/debian/pgdog.service:11`、`:12`、`:21`。
- 默认配置为 `host = "0.0.0.0"`，管理用户及示例数据库用户密码均为公开固定值 `change-me`。打包仅调用 `dh_installsystemd --no-start`，未指定 `--no-enable`；service 安装节挂入 `multi-user.target`。
- [Debian 官方 dh_installsystemd 手册](https://manpages.debian.org/bookworm/debhelper/dh_installsystemd.1.en.html)明确说明 `--no-start` 不阻止 enable。因而首次安装时不立即启动并不意味着重启时不启动。
- 源码归档 `pgdog-0.1.57.tar.gz` 内 `pgdog/src/main.rs:97`、`:108` 的 `configcheck` 只校验配置加载，没有拒绝模板密码；recipe 自身亦在 `debian/rules:21` 对这些模板调用 `configcheck`。配置顶部“生产使用前编辑”的注释没有形成启动屏障。
- **触发条件/影响：** 用户安装后尚未修改模板就重启，且服务可启动、网络允许连接时，管理接口可能以已知口令对外开放。无需把示例后端数据库能够登录当成管理入口暴露的先决条件。
- **建议：** 默认回环监听；模板凭据未替换前拒绝启动；首装默认不 enable。应按产品意图选择组合，而非仅增加注释。
- **后续验证：** 一次性 systemd 容器/VM 中安装包，检查生成的 postinst、`systemctl is-enabled pgdog`、重启后监听地址和管理认证；修改口令后再验证主动启用流程。本文没有做远程访问或安全攻击验证。

### RUST-02：pg_typescript 的默认源码链固定 x86_64 V8，ARM64 声明与实现冲突

- **严重度：P1；置信度：高；状态：架构不匹配已静态确认，未运行链接器。**
- 位置：`debbuild/pg_typescript/Makefile:14`、`:15`、`:16`、`:23`、`:24`、`:60`；`debbuild/pg_typescript/debian/control.in:11`。
- `V8_ARCHIVE` 固定为 `rusty_v8-149.4.0-simdutf-x86_64-unknown-linux-gnu.a.gz`，且 `check-src` 强制一个固定 SHA256；编译时直接把该文件传入 `RUSTY_V8_ARCHIVE`。`Architecture: any` 却允许 ARM64。
- 已只读检查本地实际归档：首个 ELF 成员 `binding.o` 的 `e_machine=62`，即 x86-64；不是仅凭文件名推断。
- **触发条件/影响：** 默认 ARM64 builder 有该文件时会试图把 x86-64 静态对象链接进 ARM64 `.so`；没有该文件则在 `check-src` 退出。即使覆盖 `RUSTY_V8_ARCHIVE` 为 ARM64 归档，默认校验值仍为 x86_64 校验值，必须额外覆盖校验变量才能通过，默认 recipe 无架构选择逻辑。
- **建议：** 按目标架构选择归档与校验，并核实其共享库链接属性；若现阶段仅支持 amd64，应明确收窄 control 与支持矩阵。
- **后续验证：** 两种原生架构均核验 V8 对象机器类型后分别构建，并安装执行 TypeScript 函数；不能用 macOS/amd64 仿真证明 ARM64 通过。

### RUST-03：8 个安装循环吞掉文件复制与验收失败，pg_typescript 还吞掉部分 PG 编译失败

- **严重度：P1；置信度：高；状态：shell 控制流静态确认，未断言现有包缺文件。**
- 受影响位置如下。

| Recipe | 安装循环起点 | 会被后续成功命令掩盖的步骤 |
|---|---:|---|
| etcd_fdw | `debbuild/etcd_fdw/debian/rules:20` | `.so`/SQL/license 复制（27–30 行），结尾 printf 返回成功 |
| pg_durable | `debbuild/pg_durable/debian/rules:19` | `.so`/control/SQL 复制（25–27 行），结尾 printf 返回成功 |
| pg_graphql | `debbuild/pg_graphql/debian/rules:20` | `.so`/SQL 复制以及 SQL 数量、升级路径断言（26–31 行） |
| pg_trickle | `debbuild/pg_trickle/debian/rules:19` | `.so`、`pg_trickle_dump`、SQL 复制（26–28 行） |
| pg_typescript | `debbuild/pg_typescript/debian/rules:19` | 前面 PG 的失败可被后面 PG 的成功覆盖；末个 PG 的 `.so` 复制失败也可被 SQL 复制成功覆盖 |
| pggraph | `debbuild/pggraph/debian/rules:20` | `.so`/SQL 复制与升级 SQL 数量、文件断言（26–33 行） |
| pglite_fusion | `debbuild/pglite_fusion/debian/rules:20` | `.so`/SQL 复制与升级 SQL 数量、文件断言（26–31 行） |
| pgrdf | `debbuild/pgrdf/debian/rules:19` | `.so`/SQL 复制与 14 个 SQL、12 条升级边断言（25–32 行） |

- 这些 recipe 未设置 `.SHELLFLAGS` 的 `-e`，也未在循环开头 `set -e`；分号连接的命令/循环以最后一条执行命令的退出状态返回。七个以 printf 写 substvars 收尾的循环，即使文件检查失败，也很容易返回 0。
- `debbuild/pg_typescript/Makefile:56`–`:62` 的 Cargo PG16/17/18 循环同样没有 `set -e`。例如 PG16 构建失败、PG17/18 成功时，外层 `building` 仍可继续；安装循环又可能隐藏 PG16 缺失，形成组合风险。
- **影响：** 失败不再可靠阻止后续 `dh_*` 阶段，可能生成缺共享库、缺 SQL、缺升级路径或缺导出工具的包。`dh_shlibdeps` 不等于 payload 完整性检查；没有 ELF 的包也不必然让整套打包失败。
- **建议：** 所有循环采用一致的失败即停语义；验收断言与打包阶段必须保持强依赖；末尾再次核验每个 PG 的必需文件及 dbgsym。
- **后续验证：** 在一次性副本中移除一个中间 PG 的 `.so`、一个升级 SQL、`pg_trickle_dump`，分别确认流程非零退出且没有收集任何新候选包。无需真实编译即可先验证安装循环的失败传播。

### RUST-04：部分包提升了通用架构的 CPU 指令基线，描述与安装过程未体现

- **严重度：P2；置信度：高（指令选项），中高（具体机器上的失败路径）；状态：兼容性风险，未做旧 CPU 运行测试。**
- 位置：`debbuild/pg_typeid/Makefile:51`–`:54`，`debbuild/pg_typeid/debian/control.in:11`–`:17`；`debbuild/pgdog/debian/rules:14`–`:15`，`debbuild/pgdog/debian/control:23`–`:31`。
- `pg_typeid` 在 amd64 上全局启用 AES/SSE2，在 arm64 上全局启用 AES/NEON；本地源码 `typeid-postgres-0.4.1.tar.gz` 的 `src/lib.rs:131`、`:138` 确实调用 `gxhash::GxHasher`。上游 [gxhash 官方说明](https://github.com/ogxd/gxhash#hardware-acceleration)指出需要相应硬件指令且无软件后备实现。
- `pgdog` 对所有 arm64 构建统一启用 `+lse`。这超出了最初 ARMv8-A 处理器普遍可假设的能力；[Rust aarch64 Linux 目标说明](https://doc.rust-lang.org/rustc/platform-support/aarch64-unknown-linux-gnu.html)将一般目标描述为 ARMv8-A。开启 target feature 的语义见 [rustc 官方文档](https://doc.rust-lang.org/rustc/codegen-options/index.html#target-feature)。
- **触发条件/影响：** 在缺 AES 指令的 x86/ARM 机器或未暴露对应指令的虚拟机中执行 TypeID hash 路径，可能发生 SIGILL；PgDog 在缺 LSE 的 ARM 上也存在相同类别的风险。现代 builder 能跑通不能证明目标架构中的旧 CPU 能跑通。
- **建议：** 确认仓库 CPU 支持基线；有意要求扩展指令时写入面向用户的明确要求并采取启动/加载检测；需要通用覆盖时使用软件后备或运行时分派。更换 TypeID 哈希实现前还必须评估已有 hash index 的兼容性，不能只删除 RUSTFLAGS。
- **后续验证：** 在屏蔽对应 CPU feature 的 VM/QEMU 中安装既有包并运行 hash 操作/PgDog 自检，同时反汇编关键路径确认指令要求。

### RUST-05：6 个 recipe 共用固定 /tmp 锁快照文件，独立工作目录也不能安全并发

- **严重度：P2；置信度：高；状态：静态确认的共享状态冲突。**
- 位置：`debbuild/pg_mooncake/Makefile:20`、`debbuild/pg_parquet/Makefile:15`、`debbuild/pg_tokenizer/Makefile:17`、`debbuild/pgvectorscale/Makefile:16`、`debbuild/vchord/Makefile:17`、`debbuild/vchord_bm25/Makefile:17`。
- `LOCK_SNAPSHOT` 使用固定的 `/tmp/pgrx...-<extension>-cargo-locks.before` 及 `.after` 文件，不包含工作目录、用户或任务标識。两个同一 recipe 的独立副本会覆盖/删除彼此的 before/after。
- **触发条件/影响：** 同一容器或主机并发进行两个版本、PG 子集、重试批次时，`cmp` 可能误报失败、读取另一任务快照，或被另一任务删除文件。`.NOTPARALLEL` 只能约束当前 Make 进程，不能解决此共享路径问题。
- **建议：** 将快照放到对应 `BUILD_DIR`，或使用任务唯一目录并在本任务结束时回收。
- **后续验证：** 两份只包含快照阶段的隔离副本同时运行，验证文件名和生命周期完全独立；不需重新构建 Rust 代码。

### RUST-06：pgml 直接重置并修改共享 Cargo git checkout，影响并发与构建来源追踪

- **严重度：P2；置信度：高；状态：静态确认的共享缓存写入风险。**
- 位置：`debbuild/pgml/Makefile:75`–`:96`，尤其 `:80`、`:81`、`:89`、`:90`、`:93`。
- `patch-lightgbm` 查找 `$CARGO_HOME/git/checkouts` 中固定 revision 的 LightGBM checkout，然后 `git checkout --` 重置两个源文件，再在共享 checkout 原地应用补丁。固定 Cargo.lock 哈希只约束依赖身份，无法隔离被改写的源码副本。
- 已看到保护：recipe 核对 git revision、原始/修改后文件 SHA256，并清理 LightGBM 的 Cargo 缓存；这些保护降低误用错误版本的风险，但不提供跨进程隔离。
- **触发条件/影响：** 其他任务/其他扩展共用同一个 Cargo home 和依赖 revision 时，会观察到修改后的缓存源码；同时运行可在另一编译器读取源码时短暂恢复原始文件。若用户在缓存中做了其他临时修补，这两个 `git checkout --` 也会覆盖它们。
- **建议：** 使用 recipe 私有 Cargo home 或将固定依赖作为 recipe 可追踪的 vendor 源码并局部 patch；不要让二进制依赖于共用缓存此前是否被执行过该 target。
- **后续验证：** 记录实际依赖源路径和编译日志；在两份独立构建中使用隔离 cache，确认结果及校验一致。此次没有进入或修改 builder Cargo cache。

## 发布与可重复性证据缺口

### RUST-L01：OIDC Rust validator 的归档没有分发授权证据

- **优先级：发布前高优先级；置信度：高（仓内证据缺失）；不是已发布侵权的判断。**
- 位置：`debbuild/pg_oidc_validator_rust/debian/copyright:7`–`:13`；`debbuild/pg_oidc_validator_rust/Makefile:7`、`:17`。
- copyright 明写 `LicenseRef-Upstream-No-License` 和上游未公布 license grant；本地归档全量文件名扫描没有 LICENSE、COPYING、NOTICE 类文件。该快照 [上游 Cargo.toml](https://raw.githubusercontent.com/UnAfraid/pg_oidc_validator_rust/b65bbbe288f84fab91d58b8304e8a526d1326af5/Cargo.toml)也没有 license 字段。
- 发布前应取得并保存该源码快照适用的授权依据，或明确把它排除出公开分发清单。本次没有审查外部书面授权，也没有证明该包已经进入公共 APT，因此只报告证据缺口。

### RUST-O01：大部分 recipe 只固定 pgrx 与 Cargo.lock，没有固定实际 Rust 编译器

- 代表位置：`debbuild/block_copy_command/Makefile:12`、`:29`–`:44`；`debbuild/pg_idkit/Makefile:13`；`debbuild/pg_durable/Makefile:40`、`:50`；`debbuild/wrappers/Makefile:57`–`:63`。
- 有的使用环境默认工具链，有的强制 `RUSTUP_TOOLCHAIN=stable`；lockfile 保持不变并不意味着不同日期/不同 builder 的 rustc、LLVM、标准库相同。
- 这属于可重复性和环境约束缺口，不足以单独断言当前构建失败。`pg_search=1.97.1`、`pg_trickle=1.98.0`、`pgdog=1.96.1`、`pgml=1.84.0` 提供了更明确的基线；后者还显式检查工具链版本。
- 建议构建记录保存 `rustc -vV`、cargo/cargo-pgrx 版本、镜像 digest 和所有有效 RUSTFLAGS；如要求严格重放则固定工具链。

### RUST-O02：主包/dbgsym 的收集存在，但收集本身不证明 DWARF 覆盖完整

- 60 个实际 Rust recipe 均声明 `CARGO_PROFILE_RELEASE_DEBUG ?= 2`、`CARGO_PROFILE_RELEASE_STRIP ?= none`；均有 `.ddeb` 收集逻辑。未发现这一范围内主动关闭自动 dbgsym 的普通 recipe。
- 这些是正向静态事实。没有逐个解包并读 ELF section 就不能称“所有 dbgsym 已通过”；静态链接的预编译 V8 以及 Rust 内部调用 C/C++ 库的 DWARF 尤其需要逐对象检查。
- `pgml`/`wrappers` 已显式传递发行版 C/C++ flags，`wrappers/debian/rules` 跳过 DWZ 而保留 dh_strip，不能把该 override 当作丢弃 debug 的问题。
- 本专项未做 60 包全矩阵产物验收；已有历史包也不能直接证明当前工作树 recipe 的构建结果。

### RUST-O03：源码来源与内嵌补丁需要形成更清晰的归档身份记录

- 多数旧 recipe 的 `SOURCE_PATCH` 仍保留声明和文件，但 `setup` 注释明确依赖“source archive already includes pgrx update”，不再执行旧补丁；这与当前本地归档内容相符，不是漏补丁构建失败。
- 建议在记录中区分原始上游归档、下游 repack、构建时补丁，保存各归档摘要；否则同名上游下载替换了已修补归档时，recipe 的真实输入变化不明显。
- 本次没有下载并对比 60 份最新上游 release，也没有查询是否有新版本；版本升级不是纯 Review 的必要动作。

## 排除的假阳性与静态通过项

1. **源码锁图：** 60 个主 tarball 均存在。对源内 Cargo manifest、Cargo.lock、control、rust-toolchain 与 recipe PG/PGRX 映射逐项提取；需要在 setup 中补齐锁图/更新 pgrx 的 recipe，按真实 patch 后内容再判定。没有把 pristine 上游 pgrx=0.16/0.17/0.18 与 recipe=0.19.2 的差异直接报错。
2. **补丁适用性：** 在 `/tmp` 仅抽取补丁触及文件，21 个实际 archive patch 使用 GNU patch `--batch --forward --fuzz=0 -p1` 成功；不编译、不运行上游脚本。`pgdog` 首次遗漏第二 vendor tar 导致的检查失败已排除；加入 recipe 真实 vendor 布局后 patch 全部成功，Cargo.lock SHA256 正好等于 rules 内的 `9a9d053c666a80dafac4d7d121a016e671f0e84d7e79e88d00f1d7ffcd3e9336`。`pgml` 的 LightGBM patch 真正目标是 Cargo checkout 而非主归档，未能在主归档中匹配不作为缺陷；未获取/修改全局缓存以验证该补丁。
3. **PG 范围：** 所有 pgrx recipe 运行前均用 `PG_VERSIONS` 更新构建副本的 `debian/pgversions`。`pgvectorscale`、`vchord`、`vchord_bm25`、`pg_parquet`、`pg_tokenizer` 默认 PG18，但可用变量选择其他源码已提供的 PG14–18 feature；不因静态文件列 14–18 而判定错包。源码仍有 PG13/PG19 feature 不等于 recipe 构建它们。
4. **PGML PG 映射：** `cargo pgrx package` 未显式传 `--features` 不是直接错误。所用 [pgrx 0.12.9 package 实现](https://raw.githubusercontent.com/pgcentralfoundation/pgrx/v0.12.9/cargo-pgrx/src/command/package.rs)依据选定 pg_config 调整 feature；recipe 已给 PATH、PG_CONFIG、PGRX_PG_CONFIG_PATH。是否在目标 builder 上完成所有 PG 的 build/load 仍待运行验证。
5. **跨扩展依赖：** 源码 control 中可见的 requires 已与 recipe 对齐：pg_later→pgmq，pg_vectorize→pg_cron/pgmq/vector，pg_search/pgvectorscale/vchord→vector，pg_mooncake→pg_duckdb，pg_eviltransform→postgis。没有把 `vector` SQL 名与 `pgvector` DEB 名的正常映射报错。
6. **OIDC payload：** 该包构建的是 PG18 OAuth validator 模块，不使用 `cargo pgrx package` 生成 SQL extension。`debian/rules` 只安装模块，并非当然漏 control/SQL；应该通过 PostgreSQL OAuth 验证器真实路径验证，不能套 `CREATE EXTENSION` 验收。
7. **文档路径：** 本专项手工安装规则把本包文档放在包私有路径，没有发现直接向共享 `postgresql-doc-*` 路径写 README 的规则。仍应在后续实际 payload 审核时确认源构建系统没有额外路径。
8. **并行阶段：** `all: setup build move` / `build: building packaging` 缺依赖边的问题由主报告统一列项。60 个 Rust recipe 中仅 kafgres 和 pg_mooncake 有 `.NOTPARALLEL`；不要把 `.NOTPARALLEL` 与独立进程共享 /tmp/Cargo cache 的问题混为一项。

## 审查覆盖表

“锁图”是当前本地归档按实际 setup patch 后的静态状态；并不表示已执行 `cargo fetch --locked` 或构建成功。工具链中的“环境默认”亦不表示当前 builder 缺工具链。

| Recipe | 主源码 tarball | PG 默认 | pgrx | 锁图 | 工具链选择 |
|---|---|---|---|---|---|
| `block_copy_command` | `block_copy_command-0.1.5.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `etcd_fdw` | `etcd_fdw-0.0.1.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `jsonschema` | `jsonschema-0.1.9.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `kafgres` | `kafgres-0.1.0.tar.gz` | 16 | 0.16.1 | 已存在 | stable |
| `pg_anon` | `postgresql_anonymizer-3.2.2.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_base58` | `pg_base58-0.0.1.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_bestmatch` | `pg_bestmatch-0.0.2.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_cardano` | `pg_cardano-1.2.0.tar.gz` | 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_command_fw` | `pg_command_fw-0.1.0.tar.gz` | 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_convert` | `convert-0.1.0.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_durable` | `pg_durable-0.2.8.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | stable |
| `pg_enigma` | `pg_enigma-0.5.0.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_eviltransform` | `pg_eviltransform-0.0.5.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | stable（源码） |
| `pg_explain_ui` | `pg_explain_ui-0.0.2.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_graphql` | `pg_graphql-1.6.2.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | stable |
| `pg_idkit` | `pg_idkit-0.4.0.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | stable |
| `pg_jsonschema` | `pg_jsonschema-0.3.4.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_kazsearch` | `pg_kazsearch-2.3.0.tar.gz` | 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_later` | `pg_later-0.4.0.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_mentat` | `pg_mentat-1.6.0.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | stable |
| `pg_mooncake` | `pg_mooncake-0.2.0.tar.gz` | 18 | 0.19.1 | 已存在 | 1.90.0（源码） |
| `pg_oidc_validator_rust` | `pg_oidc_validator_rust-0.1.0.tar.gz` | 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_parquet` | `pg_parquet-0.5.1.tar.gz` | 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_pinyin` | `pg_pinyin-0.0.6.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_polyline` | `pg_polyline-0.0.1.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_render` | `pg_render-0.1.3.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_rrf` | `pg_rrf-0.0.3.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_search` | `pg_search-0.25.9.tar.gz` | 15 16 17 18 | 0.19.2 | 已存在 | 1.97.1 |
| `pg_session_jwt` | `pg_session_jwt-0.5.0.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_smtp_client` | `pg_smtp_client-0.2.1.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_strict` | `pg_strict-1.0.5.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_summarize` | `pg_summarize-0.0.1.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_tiktoken` | `pg_tiktoken-0.0.1+git20260825.99cb61d.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_tokenizer` | `pg_tokenizer.rs-0.1.1.tar.gz` | 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_trickle` | `pg_trickle-0.107.0.tar.gz` | 18 | 0.19.2 | 已存在 | 1.98.0 |
| `pg_turbovec` | `pg_turbovec-2.2.2.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | stable |
| `pg_typeid` | `typeid-postgres-0.4.1.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_typescript` | `pg_typescript-0.1.0.tar.gz` | 16 17 18 | 0.19.1 | 已存在 | 环境默认 |
| `pg_tzf` | `pg-tzf-0.3.1.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pg_vectorize` | `pg_vectorize-0.27.1.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | stable |
| `pg_when` | `pg_when-0.1.10.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pgcontext` | `pgcontext-0.3.0.tar.gz` | 17 18 | 0.19.2 | 已存在 | stable |
| `pgdd` | `pgdd-0.6.1.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pgdog` | `pgdog-0.1.57.tar.gz` | 不适用 | 不适用 | 已存在 | 1.96.1 |
| `pggraph` | `pggraph-1.2.0.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | stable |
| `pglinter` | `pglinter-2.0.0.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pglite_fusion` | `pglite-fusion-0.0.7.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | stable |
| `pgml` | `pgml-2.10.0.tar.gz` | 14 15 16 17 | 0.12.9 | 已存在 | 1.84.0（校验） |
| `pgmqtt` | `pgmqtt-0.5.0.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | stable |
| `pgrdf` | `pgrdf-0.6.36.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | stable |
| `pgs3` | `pgs3-0.1.1.tar.gz` | 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pgsmcrypto` | `pgsmcrypto-0.1.1.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pgvectorscale` | `pgvectorscale-0.9.1.tar.gz` | 18 | 0.19.2 | 已存在 | 环境默认 |
| `pgwasm` | `pgwasm-0.1.0.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `pgx_ulid` | `pgx_ulid-0.2.3.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `plprql` | `plprql-18.0.2.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |
| `timescaledb_toolkit` | `timescaledb-toolkit-1.26.0.tar.gz` | 16 17 18 | 0.19.2 | 已存在 | stable |
| `vchord` | `VectorChord-1.1.1.tar.gz` | 18 | 0.19.2 | 已存在 | 环境默认 |
| `vchord_bm25` | `VectorChord-bm25-0.3.0.tar.gz` | 18 | 0.19.2 | 已存在 | 环境默认 |
| `wrappers` | `wrappers-0.6.3.tar.gz` | 14 15 16 17 18 | 0.19.2 | 已存在 | 环境默认 |

## 后续验收顺序建议

1. 先修复会掩盖失败的循环以及 PgDog 默认启动/凭据组合，再建立最小负向验收；这两类问题不能只靠 happy path 构建说明安全。
2. 明确 pg_typescript 架构范围与 pg_typeid/PgDog CPU 基线，再分配 builder，避免在不可能支持的平台重试。
3. 按授权范围在 ARM64 noble 完成每个 recipe 的 PG 子集代表构建；架构或发行版例外逐项记原因。
4. 对产物逐包核验 Name/Version/Architecture/Depends、SQL 升级边、ELF/debug build-id、完整 DWARF、文档冲突；带服务/预加载/OAuth/外部服务的扩展用真实加载路径验证。
5. 记录源归档哈希、patch 哈希、锁图哈希、实际工具链、镜像 digest 与日志，之后再决定生产矩阵。Review 本身不授权运行生产构建或发布。
