# PGSTY DEB 全仓审查手册

审查日期：2026-09-26。基线：`5304650ec6a3c23522fd001f2d8183452a609073`，加审查开始时已有的工作树改动。

## 1. 结论与优先级

当前仓库有一批可以由静态证据直接确认的问题，涉及构建入口失效、并行阶段竞态、缺运行依赖、包文件冲突、错误未传播、debug 交付缺口和服务默认配置。现有一个批次的产物检查结果较好，但不足以证明全部 368 个 recipe 在十个平台都正确。

**建议先处理以下问题，再扩大生产构建或发布范围。这里仅记录修复方向，没有执行修复。**

| 优先级 | 问题 | 定位与详述 |
| --- | --- | --- |
| P1 | PgDog 固定管理口令、监听所有地址，服务虽然不立即启动却仍会被 enable | `debbuild/pgdog/debian/pgdog.toml:5,18`、`debian/rules:33`；[Rust 专项](review/2026-09-26/rust.md) |
| P1 | pg_typescript 在 Architecture:any 下固定使用 x86_64 rusty_v8 库 | `debbuild/pg_typescript/Makefile:14`、`debian/control.in:11`；[Rust 专项](review/2026-09-26/rust.md) |
| P1 | redis/valkey 整合包与发行版拆包拥有相同路径，却没有表达替换/冲突关系 | [特殊包专项](review/2026-09-26/special.md) |
| P1 | standalone Spock、LOLOR、Snowflake 与 pgedge bundle 重复安装文件，并依赖该 bundle | `debbuild/spock/debian/control:12`、`debian/rules:3`；[特殊包专项](review/2026-09-26/special.md)与[补审 SX01](review/2026-09-26/support.md) |
| P1 | aws_s3 没有声明 PL/Python 与 boto3 运行依赖 | `debbuild/aws_s3/debian/control.in:13`；[PGXS-01](review/2026-09-26/pgxs.md) |
| P1 | 多个 Rust 安装循环会吞掉 cp/test 失败，可能打出缺关键文件的包 | [Rust 专项](review/2026-09-26/rust.md) |
| P2 | RDKit 未启用 dh 的 python3 sequence，已有 override 不会自动执行 | `debbuild/rdkit/debian/rules:53,108`；[特殊包专项](review/2026-09-26/special.md) |
| P1 | 外层 make 并行时，setup/build/move 没有顺序保障 | 本手册 G02 |
| P1（启用云资源时） | Terraform 使用仓库内固定口令、全端口来源规则 | 本手册 G11 |
| P2 | 7 个构建快捷目标被同名目录视为已完成，静默跳过 | 本手册 G01 |
| P2 | 运行依赖遗漏：index_advisor、pglogical_ticker、pgsparql、pg4ml | [PGXS-02～04](review/2026-09-26/pgxs.md) |
| P2 | 11 个 recipe 跳过 dh_installdocs，遗漏 copyright 安装步骤 | [PGXS-05](review/2026-09-26/pgxs.md) |
| P2 | libduckdb 使用无 DWARF 的预编译库并禁用 dbgsym；plv8 默认构建不收集产物 | [特殊包专项](review/2026-09-26/special.md) |
| P2 | 收集可带入历史产物，`.ddeb` 复制失败可返回成功 | 本手册 G03、G04 |
| P2 | 元数据库与若干 recipe/源码版本不一致 | 本手册 G07 |

优先级定义：P1 应在受影响路径再次生产交付前处理；P2 为可触发的正确性/可维护性问题或重要验证缺口；P3 为文档、追溯和改进事项。P1 不表示已证明线上事故。本文没有确认需要立即处理的 P0 事件。其余已确认项和条件风险逐条记录在下文与四份专项报告，包括 DocumentDB 源码闭包/可用性、共享 Cargo 缓存、CPU 基线和许可材料证据。

证据状态分为：**静态确认**（代码到结果的因果链明确）、**现有产物实检**（本机已有 DEB 的只读检查）、**条件风险**（需特定环境/历史状态触发）、**验证缺口**。没有把 grep 命中数量当成失败包数量。

## 2. 阅读导航与交付文件

- 本手册：总体结论、跨 recipe 问题、元数据、现有产物证据、后续验收与边界。
- [PGXS / SQL 专项](review/2026-09-26/pgxs.md)：运行依赖、control、copyright、源码缺失、测试盲区及排除项。
- [Rust / pgrx 专项](review/2026-09-26/rust.md)：60 个 Rust recipe，toolchain、pgrx、Cargo.lock、安装循环、CPU 基线和服务配置。
- [特殊内核、支持库与服务包专项](review/2026-09-26/special.md)：Babelfish、Cloudberry、Oriole、OpenHalo、DocumentDB、DuckDB、RDKit、Redis/Valkey 等。
- [支持库、工具与内核扩展补审](review/2026-09-26/support.md)：补齐另外 11 个对象，包含 pgtde 许可映射、LOLOR/Snowflake 冲突、libfq ABI 风险与支持库许可/flags。
- [368 个 recipe 台账](review/2026-09-26/recipes.tsv)：当前 changelog 模板、pgversions、包名模板、源码候选和扫描标记。
- [2,230 个产物台账](review/2026-09-26/artifacts.tsv)：实际读取的 Package/Version/Architecture 与文件位置。
- [126 个主包 payload 抽查](review/2026-09-26/payload-samples.tsv)：读取状态、copyright、共享 README、Apple metadata 检查。
- [5 组 ELF/debug 抽查](review/2026-09-26/elf-debug-samples.tsv)：实际 ELF Machine、build-id 与 DWARF section 结果。
- [台账字段与规则说明](review/2026-09-26/README.md)：区分扫描标记、证据与通过结论。
- [584 条元数据只读快照](review/2026-09-26/metadata-snapshot.tsv)：供后续修复比对；不是数据库更新脚本。

专项报告的路径与 `path:line` 均相对本仓库根目录；`tarball!member:line` 表示本地归档内部证据。行号按本次工作树固定，后续改动后可能移动。

## 3. 范围、方法与限制

### 3.1 实际审查范围

1. 读取 `AGENTS.md`、顶层 Makefile、扩展索引、全部 recipe 的 Makefile/主要 Debian 控制文件，按类别继续审查补丁、维护脚本与特殊流程。
2. 368 个 recipe 纳入台账：静态分类为 244 个 PGXS/loop、60 个 Rust/pgrx、64 个特殊或手工流程。分类只描述扫描入口，不代表互斥的上游语言类型。
3. 共 337 个 `debian/control.in`、336 个 `debian/pgversions`。缺少这两个文件不自动构成问题：支持库、自定义 bundle 和由 Debian source package 提取的流程可合法不用它们。
4. PGXS 专项横向扫描 275 个对象，读取 267 份归档关键文件；复杂包可同时进入特殊专项，不能把各专项数量相加作为总覆盖数。Rust 专项检查 60 个主源码归档的相关 Cargo/control/toolchain 文件。特殊专项初查 30 项，另补查 11 个支持库/工具/内核对象；覆盖并集为 368 个 recipe。源码成员仅按审查需要读取，没有宣称逐行审计所有上游实现。`archive/debbuild/` 的两个历史 recipe 不纳入当前支持矩阵和这 368 项。
5. 在临时副本验证 21 个 Rust 归档补丁能以 `--fuzz=0` 应用；特殊包范围的 35 个 shell/维护脚本通过静态语法检查。二者都不等于构建通过。
6. 通过 `psql data` 的 `BEGIN READ ONLY` 查询 `pgext.extension`，获取 584 条记录。没有写入数据库。
7. 对当前 `apt/` 内全部 2,230 个现有 DEB/DDEB 读取包头，对 126 个主包列出 payload，另检查 5 组代表 ELF/debug；没有执行其中的程序、维护脚本或 SQL。
8. 阅读现有构建文档及部分历史记录作为背景。历史日志不能单独证明当前 HEAD 构建成功；报告不将它们转换为新的矩阵通过结论。
9. 用隔离临时目录验证 GNU make 同名目录目标行为、find 子命令失败的返回值行为；这是工具语义核查，不是 PostgreSQL 扩展构建。
10. 针对 make、debhelper、APT 签名和特定依赖语义查阅官方资料；没有以“最新版本普查”为名逐一查询或升级 368 个上游。

### 3.2 本次明确未执行

未运行 recipe setup/build/clean、pig build get/pkg、Docker build、安装/CREATE EXTENSION、生产矩阵、source/recipe 上传、stash 写入、APT 导入、CDN 同步或 Terraform。未进入 RPM 仓库做同步。没有提交 Git commit。

本次只新增审查文档与台账。开始时已有的下列改动保持原状：

- `debbuild/rdkit/README.md`
- `debbuild/rdkit/debian/changelog`
- `debbuild/rdkit/debian/pgversions`
- 未跟踪的 `debbuild/pg_stat_ch/tools/`

RDKit 的结论针对带上述改动的当前工作树。`pg_stat_ch/tools` 的 U26A workaround 文档说明了外部 vcpkg checkout 的条件修补；它不等于通用 recipe 已集成，也没有被本次执行。

## 4. 跨 recipe 的问题

### G01 — 7 个快捷目标被同名目录遮蔽

**P2 / 静态确认，隔离语义核查已复现。**

位置：[debbuild/Makefile:1063](debbuild/Makefile#L1063)、[debbuild/Makefile:1224](debbuild/Makefile#L1224)，以及该文件从 1199 行开始的 `.PHONY` 列表。

受影响：`pgcopydb`、`pg_circuit`、`macavity`、`pg_living_assertions`、`pg_grammar_guard`、`jev`、`kafgres`。这些目标没有前置依赖、未声明 phony，而仓库存在同名目录。`make -C debbuild <name>` 可以返回 0 并提示 up to date，完全不运行子目录 make。

验证方法：将索引 Makefile 复制到临时目录，建立七个空同名目录，执行 `make -n`；七个目标全部返回 up to date，无子 recipe 执行。原始 recipe 未运行。`pgedge` 虽也未列入 `.PHONY`，但依赖 phony 的 `pgedge-18`，故从静默跳过清单排除。

影响仅针对该快捷入口；直接进入扩展目录执行 make 走的是另一条路径，不能据此宣称所有 pig 子命令都无效。GNU make 的[phony 目标规则](https://www.gnu.org/s/make/manual/html_node/Phony-Targets.html)说明了这一行为。

修复验收：补齐目标声明后，在不运行编译的隔离入口检查中确认七个目标确实分发到对应子目录。

### G02 — 阶段作为并列 prerequisites，外层并行 make 会竞态

**P1 / 代表实例静态确认；横向清单为候选范围。**

位置：[debbuild/pg_http/Makefile:1](debbuild/pg_http/Makefile#L1)、`:12`、`:21`、`:26`；[debbuild/pg_typescript/Makefile:44](debbuild/pg_typescript/Makefile#L44)；[debbuild/orioledb/Makefile:93](debbuild/orioledb/Makefile#L93)。

`all: setup build move` 只表达 all 依赖三个目标，不表达三者顺序。`make -j` 或继承 `MAKEFLAGS=-j...` 时，setup 的 rm -rf、build 的读取和 move 的收集可能同时执行。Rust 的 `build: building packaging` 存在第二层同类问题；`$(MAKE) clean setup build move` 的多目标调用也不自动保证串行。

扫描得到 328 个“all 同时列 setup/build/move，未见 .NOTPARALLEL 或直接 build→setup”的候选，完整名单见 recipes.tsv 的 `parallel-stage-risk`。这不是精确的全仓失败计数：部分特殊流程有间接依赖，仍需检查 move 是否独立；另有不符合该匹配形状的风险，如 plv8 的 pre/setup/build 和 Oriole 多目标调用。

明确的正例是 [debbuild/pg_jieba/Makefile:1](debbuild/pg_jieba/Makefile#L1) 的 `all→move→build→setup` 链；新一批 recipe 的 `.NOTPARALLEL:` 也可以序列化外层阶段。编译器内部并行与外层打包阶段并行应分别控制。

修复验收：后续在目标 builder 用受控 `make -j` 检查阶段日志、产物新鲜度和 PG 范围；本次没有构建。GNU make [并行与依赖语义](https://www.gnu.org/software/make/manual/make.html)是本结论依据。

### G03 — 宽泛收集会把历史包当成本轮产物

**P2 / 静态确认，是否已进入生产未核查。**

位置：[debbuild/pg_profile/Makefile:8](debbuild/pg_profile/Makefile#L8)、`:25`；[debbuild/pg_http/Makefile:13](debbuild/pg_http/Makefile#L13)、`:27`。

setup 只清 build，dpkg 生成的包位于 recipe 顶层；move 用 `cp *.deb` 和 `find *.ddeb`。升级版本、缩小 PG 集合或复用目录切换发行版时，旧版本、旧 PG、旧代号的文件会被一并复制。PGXS 子集中 251 个符合类似模式；见专项附表，不能将其全部当成已受污染。

当前 verifier 的 run 模式会先 clean 且要求输出目录无包，有一定防护，但普通快捷目标没有强制经过该入口。建议每轮使用独立输出目录，按本轮 `.changes` / 精确 manifest 收集并核对目标版本，而不是仅依赖扩展名 glob。不能通过全局清空用户已有产物来解决。

### G04 — find -exec 复制 DDEB 失败不能可靠中止收集

**P2 / 静态确认，隔离返回值核查已完成。**

位置：[debbuild/pg_http/Makefile:27](debbuild/pg_http/Makefile#L27)；[debbuild/pg_circuit/Makefile:30](debbuild/pg_circuit/Makefile#L30)；类似模板分布广泛。

`find ... -exec cp {} DEST/ \;` 将 cp 的失败当作该表达式为假，并不因此必然使 find 返回非零。主 `.deb` 已成功复制后若发生容量/权限等错误，后续 `.ddeb` 复制失败可被 make 当成成功。用临时占位文件和 `find ... -exec false \;` 核查，退出码为 0。

建议显式遍历并传播复制错误，最后按主包/调试包名称、版本、架构和 build-id 验收；`set -e` 包在这个 find 外面本身不能解决。未认定当前 apt 产物缺 debug，当前快照配对结果见第 6 节。

### G05 — 增量 rsync 不删除废弃 patch，远端 recipe 可偏离真源

**P2 / 条件风险，文件同步语义静态确认。**

位置：[Makefile:137](Makefile#L137)、`:152`；[debbuild/pg_stat_ch/Makefile:12](debbuild/pg_stat_ch/Makefile#L12)、`:21`；[debbuild/ddl_historization/Makefile:7](debbuild/ddl_historization/Makefile#L7)。

spec* 使用不带删除策略的 `rsync -az debbuild/ ...`。本地删除或改名 patch 后，远端旧文件继续存在；16 个 recipe 用 wildcard 枚举 patches，旧补丁仍可能被应用，导致失败或非预期源码。当前没有读取远端 builder 的文件状态，故不声称远端已经污染。

建议新批次使用可追踪的干净 recipe 快照，或只对明确归属于 recipe 的文件集合做受控同步与校验；不能直接对含 SOURCES/build/输出的整个远端目录盲目加 `--delete`。

### G06 — pg_buildext 在 recipe 真源中生成 control

**P3 / 静态确认。**

位置：[debbuild/pg_profile/Makefile:10](debbuild/pg_profile/Makefile#L10)、[debbuild/pgvector/Makefile:9](debbuild/pgvector/Makefile#L9)。PGXS 子集有 144 个类似调用。

setup 在原 recipe 目录运行 updatecontrol，再复制 debian 到 build，build 中又更新一次。它会修改 recipe 的 control 或导致只读 checkout 失败，且内容受 builder 的 PG 可用版本影响。最终 build 副本再更新并不能消除源目录写入。建议生成步骤只作用于构建副本，并核对为何需要重复调用。

### G07 — recipe、源码与元数据库出现版本漂移

**P2 / 本地只读快照确认；没有写数据库。**

| 元数据 name | 当前 recipe / source | 数据库当前值 | 需要核对的字段 |
| --- | --- | --- | --- |
| `anon` | `pg_anon/Makefile:7`：3.2.2 / postgresql_anonymizer-3.2.2.tar.gz | version、deb_ver 3.1.3；source 仍 3.1.3 | version、deb_ver、source、mtime |
| `pg_turbovec` | `Makefile:9`：2.2.2 | version、deb_ver、source 2.0.0 | version、deb_ver、source、mtime |
| `pgmqtt` | `Makefile:8`：0.5.0 | version、deb_ver、source 0.4.2 | version、deb_ver、source、mtime |
| `vectorscale` | `pgvectorscale/Makefile:8`：0.9.1 | version、deb_ver、source 0.9.0 | version、deb_ver、source、mtime；PG 范围另核实 |
| `documentdb_distributed` | `documentdb/Makefile:21` 明确排除，现有 PG18 包也无该 payload | state=available，deb_ver 0.116，仍指向 documentdb DEB、PG15–18 | 可用性/包映射需要纠正，详见 G16；不能简单 bump 成 0.117 |
| `orioledb` | `Makefile:8`～30：1.9 beta17；新 16_48/17_21/18_2 patchsets | version、deb_ver 1.8；source 为 beta16 与旧 patchsets | 上游/SQL/DEB 版本表示及 source、mtime |
| `age` | `Makefile:5,7`：PG18→1.8.0，PG17→1.7.0 | version 1.8.0、deb_ver 1.7.0、deb_pg 仅 17；source 已列两份 | 区分每 PG 的版本；deb_pg 与版本展示语义，不能简单将所有 PG 改为 1.8.0 |

这些 tarball 均存在于本地权威源目录。元数据不一致可使按扩展名取源与当前 recipe 需求错位，也会误导版本和覆盖展示。当前 apt 批次没有覆盖上述多数对象，不能借现有包头断言它们均已构建发布。

待办应依据后续构建/实际 payload 更新，不能只用 changelog 机械写库；`rpm_ver` 不在本次修改范围。`lolor/spock/snowflake` 的元数据映射可能指 pgedge bundle 版本，已从简单版本不等清单排除；epoch、模板占位符也已排除。

### G08 — 4 个旧 recipe 的本地权威源码缺失

**P2 / 可重现性缺口，仅本地已证。**

四个位置均为对应 Makefile 第 3 行：mysqlcompat→`mysqlcompat-0.0.7.tar.gz`；pg_mon→`pg_mon-1.0.tar.gz`；pg_timeit→`pg-timeit-1.0.tar.gz`；postgresql_anonymizer→`postgresql_anonymizer-1.3.2.tar.gz`。详见 PGXS-R03。

没有运行 pig build get，公共镜像是否可取尚不知。后续先确认是否保留这些历史 recipe，再按取源规范补齐准确归档；不应改用任意“相近版本”或同步整个 src。

### G09 — 验证脚本有明确的覆盖缺口，且未进入普通构建必经路径

**P2 / 验证缺口。**

位置：[bin/verify-extension-job.sh:82](bin/verify-extension-job.sh#L82)、`:159`、`:190`、`:236`；[debbuild/pg_http/Makefile:21](debbuild/pg_http/Makefile#L21)。

现有脚本的优点：核对 declared packages、版本、Architecture 字段、非空 payload、新鲜度、main/debug build-id 与 `.debug_info`。这些检查应保留。

仍未覆盖：

- 不检查共享 `postgresql-doc-*/extension/README*` 冲突路径。
- 以生成 changelog 为版本真值，但未独立要求其代号等于真实 builder 代号；同样错误的 changelog 与 DEB 可一起通过。
- Architecture 只比较控制字段；`file` 仅判断 ELF，未比较 ELF Machine 与期望架构。
- 不验证运行依赖闭包、RPATH/RUNPATH、动态库可解析性、安装冲突、CREATE EXTENSION 或升级路径。
- 将生成的 `debian/control` 视为包清单；对原生扩展，当 control 和 SQL 两者都缺失时也允许通过，以兼容无 DDL 模块，因此不能证明应当有 DDL 的扩展交付完整。
- 仓库普通 Makefile recipe 没有强制调用此脚本。不能把脚本存在视为所有产物都经过它。

这不是要求所有检查塞进一个 shell 脚本；建议区分包结构检查、依赖闭包检查和运行 smoke，记录每层结果。

### G10 — pgversions 检查器可对空文件或错误内容返回成功

**P3 / 静态确认。**

位置：[bin/check_pgversions.sh:27](bin/check_pgversions.sh#L27)、`:38`、`:44`。

脚本只检查末尾换行；空文件只警告、不增加 error_count，任意带换行的文本也通过。最后却输出 “All ... pgversions files are valid”。它从当前目录递归查找，可能混入 archive/build；从错误位置执行也可检查 0 个文件并成功。

建议把脚本的承诺改为真实检查范围，或补版本格式、非空、去重、支持范围及作用目录检查。当前活跃 pgversions 中没有发现明确的 PG13/PG19 行，故不把本工具缺口当成仓库已引入这些支持。

### G11 — Terraform 的固定口令与宽网络规则

**P1（用户以后启用此模板时）/ 静态确认配置风险，未验证云端状态。**

位置：[tf/terraform.tf:145](tf/terraform.tf#L145)、`:148`、`:165`，其余九实例同样；`tf/spec/full.tf:145,148,165`；`tf/spec/meta.tf:142,145,160`；[tf/ssh:13](tf/ssh#L13)、`:38`。

模板把固定登录口令存入仓库，并设置来自 0.0.0.0/0 的全部 TCP ingress；实例配置公网带宽与公网 IP 输出。SSH 引导又用该固定口令并关闭首次主机身份确认。若按模板创建可达且允许密码认证的 builder，访问控制依赖公开默认值；builder 上的源码、构建工具和凭据面临实际暴露风险。

建议采用受控 SSH key、明确来源范围、按需开放端口与主机身份核验。这里没有读取云账号运行状态，也没有创建/销毁/修改任何资源。报告不声称现有主机正在暴露。

### G12 — tf/ssh 在 Terraform 输出失败时仍先截断 SSH 配置

**P2 / 静态确认。**

位置：[tf/ssh:17](tf/ssh#L17)、`:20`、`:22`。

脚本没有 fail-fast，terraform output 失败或返回非法 JSON 后仍执行 `> ~/.ssh/pigsty_config`。jq 失败可能只导致循环为空，最后缺少成功条件；原有配置被清空，而调用者可能得到成功退出码。

建议先完成输出与 IP/schema 验证，生成临时配置，全部成功后原子替换；保留失败时原配置。无需真实云资源即可在隔离 HOME/命令桩中验证，但本次未执行该脚本。

### G13 — 版本降序是否影响 APT 升级，需要发布历史证据

**P2 / 条件风险，不能据 changelog 直接认定已破坏升级。**

位置：[debbuild/pg_typescript/debian/changelog:1](debbuild/pg_typescript/debian/changelog#L1)、`:8`；[debbuild/age/Makefile:44](debbuild/age/Makefile#L44)。

pg_typescript 当前 `0.1.0-1PGSTY`，历史项为 `0.1.0-2PIGSTY`；AGE PG17 setup 也将旧 revision 改写为 1PGSTY。若较高历史 revision 的二进制已公开发布，当前版本可能不是 APT 的升级候选。若旧二进制尚未发布，按仓库规则保持 1PGSTY 可以是正确选择。

后续必须先取得对应代号、架构、PG 的已发布版本记录，再用 dpkg --compare-versions 和 apt-cache policy 判断。不要因构建成功、提交或上传源码就自动递增，也不要批量重写历史。

### G14 — 文档有过期支持范围、不可执行示例和签名语义歧义

**P3 / 静态确认与现有产物实检。**

- [README.md:3](README.md#L3) 仍宣传 PG13–18；仓库默认范围已为 14–18。
- [README.md:14](README.md#L14) 的 pig 安装示例使用 0.9.1，与顶层 Makefile:14 的 v1.8.0 不一致；不能据此断言远端当前最新版本，但文档入口需要统一并验证。
- `docs/extension-smoke-plan.md:33` 起引用 `bin/run-extension-smoke-round.sh`，当前 bin 目录没有该文件。该文档也使用旧 u12/u13 builder 命名，且未覆盖当前十平台。它是计划，不是可直接运行的完整工具。
- [README.md:42](README.md#L42) 写“所有 Deb 包均签名”。当前 2,230 个本地 DEB/DDEB 的 ar 成员都没有 `_gpg*` 嵌入签名；APT 通常验证签名的 Release/InRelease 及其哈希链，不能混同为每个 DEB 的嵌入签名。未检查外部 detached signature 或生产仓库，因此不能据此称 APT 未签名。依据：[apt-secure](https://manpages.debian.org/testing/apt/apt-secure.8.en.html)。
- `.gitignore:19` 的 docs/ 规则使现有长期构建文档不被 Git 跟踪（当前 `git ls-files docs` 为 0）。这不构成构建失败，但克隆仓库不能获得这些验证记录和例外说明；应明确它们是本地资料还是需要版本化的维护手册。

### G15 — DocumentDB 离线源码闭包没有进入预检和元数据清单

**P2 / 静态确认，缺少额外源码时会在 pre 中止。**

位置：[debbuild/documentdb/Makefile:8](debbuild/documentdb/Makefile#L8)、`:13`；[debbuild/documentdb/prepare.sh:18](debbuild/documentdb/prepare.sh#L18)、`:88`。

Makefile 的 check-src 只检查 documentdb 与 Intel 两份归档，`pgext.extension.source` 也只列这两份；但 prepare.sh 无条件要求额外四份文件：

- `mongo-c-driver-1.28.0.tar.gz`
- `pcre2-10.40.tar.gz`
- `uncrustify-uncrustify-0.68.1.tar.gz`
- `citus-tools-e36e4ea4258989bf527744334f6c633bb67e0686.tar.gz`

因此，只按 source 字段或顶层 check-src 准备的空 builder 可以通过第一层预检，却在 prepare:88–90 失败。四份文件当前都存在于本机 src；问题不是本机丢源，而是取源清单与强制消费输入不完整。未实际运行 pig 命令，不能推断其所有远端配置都没有这些额外输入。

建议把这四份输入的准确文件名、来源和摘要纳入 recipe 预检/元数据/操作文档，并保持按需取源。后续从空源码目录按正式清单准备，再在 builder 验证完整 pre；不要依赖旧 builder 恰好有缓存。

### G16 — DocumentDB distributed 已排除，却仍在元数据库声明可用

**P2 / recipe、数据库与现有 payload 三方交叉确认。**

位置：[debbuild/documentdb/Makefile:21](debbuild/documentdb/Makefile#L21)、[debian/changelog:11](debbuild/documentdb/debian/changelog#L11)；数据库行 `pgext.extension.name='documentdb_distributed'`。

recipe 明确删除 internal/pg_documentdb_distributed 构建项，changelog 也解释 OSS 包不包含它。现有 noble arm64 `postgresql-18-documentdb_0.117-1PGSTY~noble_arm64.deb` 只有 documentdb、documentdb_core、documentdb_extended_rum 三个 control，没有 distributed 路径。

但只读查询返回 distributed 的 state=available、deb_repo=PIGSTY、deb_pkg=`postgresql-$v-documentdb`、deb_pg={18,17,16,15}。依此记录安装当前 documentdb 包，无法取得 advertised distributed 扩展。

建议核对该扩展在各仓库的真实交付方式，再纠正 DEB 可用性、PG 范围、包映射与说明。不能仅将 version/deb_ver/source bump 到 0.117，也不能未经授权改变 RPM 一侧状态。当前 payload 实证范围为 noble arm64 PG18；其他 PG 的排除依据为通用 recipe。

## 5. 已排除的误报与正常例外

这些结论用于避免后续修复时破坏现有设计。

| 表面现象 | 审查结果 |
| --- | --- |
| 大量 `dpkg-buildpackage -d` | 60 个 Makefile 命中，但 Rust 工具链可能位于 dpkg 管理之外；GraphBLAS/LAGraph 的私有 CMake 路径有固定版本与剩余依赖检查。不能将每个 -d 当成同等缺陷。仍需逐包验证真实依赖。 |
| Rust 主 Cargo.toml 的 pgrx 版本似乎不一致 | 多个 recipe 有有效源补丁；应审查补丁后的图，不能仅比未打补丁的 tarball。 |
| 某些 Rust 默认仅编 PG18，而 pgversions 列 14–18 | 相关 setup 会按 PG_VERSIONS 重写构建副本，默认缩小代表构建与声明可支持集合并不必然冲突。 |
| `polarstore` 出现 `-march=native` | 命中的是删除上游参数的 sed，不是启用。pgvector 也用 OPTFLAGS= 关闭上游 native 优化。 |
| 纯 SQL 无 dbgsym | 正常；不能制造空 debug 包。 |
| dbgsym 文件扩展名为 `.deb` | 正常，判断应依据 Package 名和 payload，而非仅以 `.ddeb` 后缀计数。 |
| 两架构出现相同 Architecture:all 包 | 当前 145 组重复包 SHA-256 完全相同，是同一跨架构包的双份收集，不是架构标错。 |
| 每个 PG 版本少于 14–18 全集 | 可为上游真实限制，不能仅凭缺一版本报 bug。当前没有新 PG13/PG19 的明确 pgversions 行。 |
| `src` 绝对软链接、Mac 上无 debbuild/SOURCES | src 正确指向权威目录；标准 SOURCES 是 builder 布局，不能以编辑机缺此链接认定 builder 有问题。 |
| CLAUDE.md | 当前正确相对链接到 AGENTS.md。 |
| U26 没有顶层 spec26/pull26 | 仓库已明确使用 Docker/U26 流程，不是漏修。 |
| 历史 PIGSTY 后缀 | 保留历史符合规则；不应大范围改名或自动改变 revision。 |
| ivorysql-contrib 5.4 搭配 ivorysql 5.6 | 当前关系约束按 5.x 系列表达，未确认必然不兼容；需要运行验证而非凭小版本不同判错。 |

## 6. 当前已有产物的只读检查

### 6.1 包头与配对

本次读取的都是已存在于 `apt/<codename>/extension-20260919/{amd64,arm64}/` 的批次产物；没有把旧日志或文件存在等同于当前 recipe 重构建成功。

| 检查项 | 结果 |
| --- | --- |
| 文件总数 | 2,230：1,648 `.deb` + 582 `.ddeb` |
| Package 字段分类 | 1,260 个主包 + 970 个 `-dbgsym` 包 |
| Architecture 字段 | amd64 970、arm64 970、all 290（包含 main/debug 总和） |
| 每个当前发行版 | bookworm/trixie/jammy/noble/resolute 各 446 文件 |
| 包头读取 | 2,230/2,230 成功 |
| 文件所在代号与 Version 后缀 | 未发现不一致 |
| 非 all 主包与 dbgsym 按包名/版本/架构配对 | 未发现缺配对或孤立 debug |
| 相同 Package/Version/Architecture 重复 | 145 组，全部为两架构目录中的 all 包，SHA-256 全相同 |
| 嵌入式 `_gpg*` ar 签名成员 | 0/2,230；不代表 APT Release 签名状态 |

### 6.2 Payload 样本

选择 noble arm64 批次的 126 个主包，覆盖当前批次每个不同主包名/归一化版本；不等于覆盖所有 recipe。

- 126/126 `dpkg-deb -c` 成功。
- 样本均存在至少一个包文档 copyright 文件。
- 未发现共享 `postgresql-doc-<major>/extension/README*` 路径。
- 未发现样本文件名中的 `._*` 或 `.DS_Store`。

边界：这里检查的是文件列表，没有对全部 ELF 逐一比 Machine、DT_NEEDED、build-id 或 DWARF；没有最小依赖安装或 SQL smoke。上述 11 个 copyright 问题对象不在本批次抽查范围内，因此两者不矛盾。Rust/服务包的风险与特殊包冲突也不能被这批样本的正常结果排除。

### 6.3 五组代表性 ELF/debug 实检

另只读提取 noble arm64 已有包中的以下对象，直接解析 ELF header、GNU build-id note 与 section table：

| 主包 | 核查对象 | 结果 |
| --- | --- | --- |
| postgresql-18-pg-search | pg_search.so | main/debug 均 AArch64，build-id 相同，debug 含 `.debug_info` |
| postgresql-18-pgrdf | pgrdf.so | 同上 |
| postgresql-18-documentdb | pg_documentdb.so | 同上 |
| ivorysql-18 | /usr/ivory-18/bin/postgres | 同上 |
| postgresql-18-pg-circuit | pg_circuit.so | 同上 |

准确包路径与 build-id 保存在 elf-debug-samples.tsv。5/5 样本符合上述检查；没有检查每个包中的全部 ELF，也没有逐函数验证源行完整性。尤其不能据 pgrdf 当前成功样本排除“缺文件时安装循环仍成功”的负向路径问题。

## 7. 后续修复与验证手册

以下是后续任务的执行建议，**本次没有执行**。保持先修复、代表构建、必要矩阵、收集、stash、导入、CDN、公共验证的状态分离。

### 7.1 按语义拆分修复

1. 入口与编排：先处理 G01/G02，确保调度确实执行，阶段正确串行；按构建族迁移，避免一次修改数百模板。
2. 包交付：处理 Redis/Valkey 与 Spock 文件归属、Rust 安装错误传播、RDKit Python sequence、aws_s3 与其他运行依赖、copyright。
3. 架构与调试：处理 pg_typescript ARM64 分支、libduckdb 源码/debug 交付策略、Rust CPU 基线；不要只改 Architecture 字段掩盖二进制问题。
4. 收集与追溯：本轮 manifest、复制错误传播、builder recipe 快照一致性；保留已有产物并明确其来源。
5. 元数据：以已核实版本、源归档、目标 PG 和实际 DEB 校正 G07；不顺手改 rpm_ver。
6. 文档与历史：补齐支持声明、可执行 smoke 入口、发布版本历史与验证记录归档。

每个扩展/组件应形成独立语义变更。此手册记录的是问题，不构成自动发布或批量提交的授权。

### 7.2 每个问题关闭所需的证据

| 类别 | 最低关闭证据 |
| --- | --- |
| Make 入口/阶段 | 隔离语义核查；目标 builder 的顺序日志与明确 PG/版本输出；并行条件下无阶段竞态 |
| Build-Depends | 仅按声明依赖配置的 builder 可完成配置/编译，例外工具版本可验证 |
| Depends/语言运行时 | 最小依赖安装环境中的 CREATE EXTENSION + 至少一个实际函数调用，不能用富依赖 builder 代替 |
| 文件冲突 | 支持共存的包须无路径冲突；互斥替换的包须安全升级/迁移、保留配置并正确卸载旧包；路径所有权清楚 |
| Rust 安装失败传播 | 故意缺一个中间 PG 产物时必须非零退出，不得输出文档空包；成功时 control/SQL/SO 逐项匹配 |
| dbgsym | 主 ELF 与 debug ELF build-id 对应；debug payload 有 `.debug_info`；收集无漏文件 |
| CPU / 架构 | 对目标 ELF 读取 Machine 和指令基线，在最低支持 CPU 上执行相关路径 |
| 服务默认值 | 全新安装、重启、升级均不会意外启用公开默认口令；配置检查失败必须阻止服务启动 |
| 源码/补丁 | 源归档 filename/hash、补丁版本和应用结果可追踪；Linux 解包无 Apple metadata |
| 元数据库 | 只在事实验证后更新；附变更前后字段与 artifact/source 对照 |
| 版本单调性 | 发布历史、dpkg 比较、apt policy，证明确实升级到候选版本 |

### 7.3 代表环境与矩阵记录模板

默认后续代表构建为 `pgsty/u24a:build` / noble / arm64。先确认镜像存在，再在 builder `pig build get <准确扩展名或 tarball>`；只有确实缺源时复制对应文件。扩展若不支持 noble，使用其真实支持的 ARM64 平台并记录依据。amd64 正式验证优先使用原生 x86_64 资源。十平台全量生产构建需另行明确要求。

每轮至少记录以下字段：

```text
recipe commit/worktree hash | source filename + sha256 | patches
builder/image identity | codename | architecture | CPU baseline
PG major(s) | command | first real error | build log location
main package(s) | debug package(s) | Version | Depends
payload / ELF / debug check | install | preload/bootstrap | CREATE EXTENSION | smoke
collected apt path | stash state | import state | CDN state | public download state
```

服务型扩展需要外部 ClickHouse、HTTP、S3 等真实或可控 mock 路径；内核 bundle 需要自己的 pg_config、安装前缀、initdb、启动及内建扩展 smoke；不能套普通 `CREATE EXTENSION` 单步结论。

## 8. 最终状态

| 状态 | 本次结果 |
| --- | --- |
| 静态审查 | 已完成本手册描述的全仓覆盖与专项检查；发现未解决问题，不能记为“全部通过” |
| 现有包只读审查 | 已完成包头/配对、有限 payload 与 5 组 ELF/debug 抽查，范围见第 6 节 |
| 当前 recipe 代表性 builder 构建 | 本次未执行 |
| 当前 recipe 指定生产矩阵 | 本次未执行 |
| 本次新产物拉回 apt | 无新构建产物 |
| 生产 stash / APT 导入 / CDN / 公共验证 | 本次均未执行 |
| 元数据库 | 仅只读快照；待更新字段已记录 |
| 代码修复 | 未执行；保留用户原有改动 |

本手册是后续修复的记录入口。关闭条目时应追加真实验证事实，保留原始触发条件和证据，不用“构建退出 0”代替安装、运行或发布验收。
