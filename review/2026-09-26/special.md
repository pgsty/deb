# 特殊内核、复杂扩展与服务包专项 Review

[返回总手册](../../DEBIAN_REVIEW_2026-09-26.md)

审查日期：2026-09-26。只读审查当前工作树；没有修改 recipe、没有构建/安装/发布、没有写数据库、没有进入 RPM 仓库。RDKit 的三个未提交文件与 `pg_stat_ch/tools/` 未跟踪目录均保留。以下是静态证据，不能替代目标 builder 验证。

严重度：P1 = 可直接阻断安装或使重要构建错误失察；P2 = 实质性打包、可复现性或维护问题；P3 = 文档及操作易错点。每项区分代码可确认事实与尚待产物/运行验证的影响。

## 确认问题

### S01 / P1 / 高置信度：独立 Spock 包与它所依赖的 pgEdge 内核 bundle 重复拥有同一文件

补查确认 LOLOR、Snowflake standalone 也有同一根因，见[补审 SX01](support.md)。

- 定位：`debbuild/spock/debian/control:10`、`:12`；`debbuild/spock/debian/rules:3`；`debbuild/pgedge/debian/rules:95`；`debbuild/pgedge/debian/install:1`。
- 事实：独立包名为 `pgedge-18-spock`，必须依赖 `pgedge-18`，其 `PG_CONFIG` 固定为 `/usr/pgedge-18/bin/pg_config`；pgEdge bundle 自身又完整执行 `.spock` 的 `install` 并收集 `/usr/pgedge-18/*`。两侧 control 没有文件替换/迁移关系。
- 补强：实际读取 `src/spock-5.0.11.tar.gz` 中 `spock-5.0.11/Makefile:7-16,130-133`，安装对象包括 `spock.so`、`spock_output.so`、扩展 SQL/control 和 `spockctrl`，不是只含元数据的兼容包。
- 触发与影响：用户安装 `pgedge-18-spock` 时，依赖会同时装入包含同一 Spock 文件的 `pgedge-18`；dpkg 文件所有权冲突。此 recipe 仍存在即构成可触发路径，不以顶层是否设快捷 target 为前提。
- 建议验证：分别读取两包 `dpkg-deb -c/-I` 求 payload 交集，在一次性环境安装两者。修复时需明确独立包是过渡包、彻底停用，还是从 bundle 中拆出；简单强制覆盖会留下卸载行为问题。

### S02 / P1 / 高置信度：Redis、Valkey 整合包没有表达与发行版拆包的文件迁移关系

- 定位：`debbuild/redis/debian/control:18`、`debbuild/redis/debian/redis.install:1`、`:4-6`；`debbuild/valkey/debian/control:18`、`debbuild/valkey/debian/valkey.install:1`、`:4-6`。
- 事实：本仓库单包同时安装 server、CLI、benchmark、配置及检查工具，但 control 没有对发行版 `redis-server`/`redis-tools`/`redis-sentinel`、`valkey-server`/`valkey-tools`/`valkey-sentinel` 的 `Breaks`/`Conflicts`/`Replaces` 或适当过渡包关系。
- 补强：Debian 官方 filelist 明确 `redis-server` 和 `valkey-server` 已拥有相同 `/usr/bin/*-server` 与 `/etc/*/*.conf`；Ubuntu Noble 的 `redis-tools` 拥有相同 `/usr/bin/redis-cli`、benchmark、check 工具和补全文件。参考：[Redis server](https://packages.debian.org/trixie/amd64/redis-server/filelist)、[Valkey server](https://packages.debian.org/trixie/amd64/valkey-server/filelist)、[Redis tools](https://packages.ubuntu.com/noble/all/redis-tools/filelist)。
- 触发与影响：已有发行版 Redis/Valkey 的机器切换到本仓库包，或安装依赖发行版 tools 包的软件时，可能直接出现 dpkg 覆盖错误。Redis epoch 已提高为 `6:`，并不会解决不同二进制包名之间的文件归属。
- 建议验证：从发行版 server/tools/sentinel 已安装状态执行模拟升级及一次性真实升级，检查包解析、配置保留、服务单元切换、旧包删除与回滚。应先设计迁移策略，再设置对应关系字段。

### S03 / P2 / 高置信度：RDKit 定义了 Python 打包 override，却未启用对应 debhelper sequence

- 定位：`debbuild/rdkit/debian/rules:52-53`、`:108-110`；`debbuild/rdkit/debian/control.in:8`、`:29-37`。
- 事实：`dh $@ --buildsystem=cmake` 未包含 `--with python3`，Build-Depends 仅有 `dh-python`、没有 `dh-sequence-python3`。因此 `override_dh_python3` 并不会仅因存在而被调度，其内部的 `dh_numpy3` 也不会运行。
- 补强：对应本地源码三件套的 `rdkit_202603.6-1PGSTY~resolute.debian.tar.xz` 中原始 `debian/rules:49` 有 `dh $@ --with python3 --buildsystem=cmake`，本仓库替换版丢失该参数。[dh_python3 官方文档](https://manpages.debian.org/unstable/dh-python/dh_python3.1.en.html)要求启用 addon 或显式调用。
- 触发与影响：Resolute 完整 RDKit suite 构建时 `${python3:Depends}` 及 NumPy ABI 依赖不能按预期生成；可能仅留下无版本的手工 `python3-numpy` 依赖，Python 扩展安装/升级 ABI 保护与字节编译维护脚本缺失。不能由当前无运行错误推出正确。
- 建议验证：在 builder 对生成树执行只读 `dh binary --no-act` 查看 sequence，再检查 `python3-rdkit` 的 Depends、维护脚本、substvars 和 Python/NumPy import。用户刚增加的 PG18 不应在 review 中回滚；问题位于既有 rules。

### S04 / P2 / 高置信度：PLV8 默认构建入口不收集主包和 dbgsym

- 定位：`debbuild/plv8/Makefile:1`、`:40-45`；`debbuild/Makefile:417-418`。
- 事实：`all: pre setup build` 没有 `move`；顶层 `plv8` 仅执行 `cd plv8 && make`。实际构建树为 `$(HOME)/plv8`，dpkg 产物写到其父目录；只有独立 `move` 会复制到 `$(PKG_OUTPUT_DIR)`。
- 触发与影响：标准顶层 `make plv8` 即使成功也不会让下游统一收集流程在 `~/ext/pkg` 找到本次 `.deb/.ddeb`，还可能误以为旧输出是新产物。
- 建议验证：检查默认目标依赖图与对应调用者；修复后在空输出目录跑代表性构建，确认五个 PG 版本主包和 dbgsym 全部收集。`docs/plv8.md` 手动调用 `make setup build move` 并不能弥补标准入口缺失。

### S05 / P2 / 高置信度：libduckdb 明确关闭 dbgsym，实际输入 ELF 也没有 DWARF

- 定位：`debbuild/libduckdb/debian/rules:9-10`、`:14-15`；`debbuild/libduckdb/Makefile:3-9`、`:31-32`。
- 事实：recipe 使用预编译 `libduckdb.so`，调用 `dh_strip --no-automatic-dbgsym`，且 move 只复制 `*.deb`。这与仓库原生 payload 必须有可用 dbgsym 的要求不一致。
- 补强：只读解析本地 `libduckdb-1.5.5-amd64.tar.gz` 和 `libduckdb-1.5.5-arm64.tar.gz` 的 ELF section table，两份都有 `.symtab`，但没有任何 `.debug*`/`.zdebug*` section；不是仅仅未执行 dh_strip 的问题。
- 触发与影响：所有使用这两份归档的构建均无法得到完整源级调试信息。删除禁用 flag 也无法凭空补出 DWARF。
- 建议验证：先确定可追溯、同一构建的 debug 输入或采用带 DWARF 的源码构建，再检查 `.so` 与 debug ELF 的 build-id、DWARF 和 GDB 源行。当前未发现本批 apt 中对应产物，不能声称已有线上包检查完成。

### S06 / P2 / 高置信度：pgEdge 的补丁、构建和安装循环会吞掉前面成员的失败

- 定位：`debbuild/pgedge/Makefile:27-35`；`debbuild/pgedge/debian/rules:64-70`、`:95-109`。
- 事实：这些多命令 shell 循环没有 `set -e`、`&&` 链或明确 `|| exit`。非最后一份 patch 失败后可继续；Spock/LOLOR 的 make 失败后可继续到 Snowflake，整个 shell 返回最后命令的成功状态。最后的 patchelf 循环也没有逐文件失败保护。
- 触发与影响：补丁漂移、某扩展编译/安装失败或 ELF 修补失败时，流水线可能继续。`debian/install` 的宽通配符不能证明预期 Spock/LOLOR payload 齐全，存在部分内容缺失但主包成功的路径。
- 建议验证：通过隔离的命令桩令第一项失败、后两项成功，确认整体必须非零；构建后独立核对必需模块/control/CLI 清单。此处无需真实构建即可确认 shell 返回值缺陷，本次没有注入故障或改文件。

### S07 / P2 / 高置信度：pg_duckdb 的 Build-Depends 没有覆盖必用的 CMake/Ninja

- 定位：`debbuild/pg_duckdb/debian/control:5`、`debbuild/pg_duckdb/debian/control.in:5`；`debbuild/pg_duckdb/debian/rules:57-59`。
- 事实：声明仅含 debhelper、PG server dev、ICU、curl dev；源码默认 `DUCKDB_GEN ?= ninja`，随后调用 DuckDB CMake。实际读取源码归档 `pg_duckdb-1.1.1/Makefile:13-14` 和 `third_party/duckdb/Makefile:341-343` 确认。
- 触发与影响：仅按 control 安装 Build-Depends 的干净 Debian/Ubuntu builder 可以通过 dpkg-checkbuilddeps，却在 CMake/Ninja 缺失时失败；肥 builder 掩盖此问题。
- 建议验证：用只含声明依赖的临时 builder，确认配置依赖闭合，并检查补齐后的 `dpkg-checkbuilddeps`。这不是说当前现成 builder 必然失败。

### S08 / P2 / 高置信度：PolarDB 绕开 debhelper 构建时未导入 dpkg 构建 flags

- 定位：`debbuild/polardb/Makefile:124-127`；`debbuild/polardb/polardb-17.11.1.0.patch:37-39`。
- 事实：该 recipe 直接跑上游 `build-deb.sh`/`build.sh`，没有 `DPKG_EXPORT_BUILDFLAGS` 或 `dpkg-buildflags` 等价导入。上游 `build.sh:166,213-218,249-251` 默认保留 `-g` 与优化参数，但 release 分支仅加 `-O2`，stack protector 只在 debug 分支添加，LDFLAGS 只明确 RUNPATH/build-id。
- 影响：DWARF 已由上游 `-g` 提供，**不应误报为没有 dbgsym**；真实缺口是 Debian/Ubuntu 的 hardening、reproducibility、发行版编译策略没有被 recipe 稳定继承，成功拆出调试包也不能证明这些 flags 正确。
- 建议验证：审阅实际编译/链接命令和 `pg_config --cflags/--ldflags`，比较 `dpkg-buildflags`，检查 stack protector、RELRO、FORTIFY 与源路径映射。flags 变化可能影响特殊内核，应独立构建验证。

### S09 / P2 / 高置信度：若干大型包的 copyright 文件仍是占位信息

- 定位：`debbuild/babelfish/debian/copyright:1-4`；`debbuild/spock/debian/copyright:1-3`；`debbuild/cloudberry/debian/copyright:11-22`；`debbuild/cloudberry-backup/debian/copyright:11-22`；`debbuild/cloudberry-backup/debian/rules:24-30`。
- 事实：Babelfish/Spock 只有 SPDX 标签与 `PostgreSQL License` 名称，缺少实际 PostgreSQL 许可文本和版权声明；Cloudberry 系文件只放 Apache 的短头部，没有完整条款或 `/usr/share/common-licenses/Apache-2.0` 引用。Cloudberry backup 的安装清单只装六个二进制，没有声明安装上游 NOTICE。
- 补强：本地 backup 2.2.0 源码确实有 NOTICE，包含 VMware 与 ASF attribution。是否通过其它上游默认安装路径偶然带入 Cloudberry 主包仍应以实际产物核实；backup 的自定义安装路径则很明确。
- 影响：包随附许可与归属材料不完整，不能把 SPDX 标识视为许可全文。依据：[Debian Policy 12.5](https://www.debian.org/doc/debian-policy/ch-docs.html#copyright-information)、[Apache License 2.0 §4](https://www.apache.org/licenses/LICENSE-2.0)。这是打包材料审查，不对整个发行行为作法律定性。
- 建议验证：从最终 DEB 抽取 copyright、LICENSE、NOTICE，按每个 bundled component 核对。源码包里存在 LICENSE 并不等于二进制包已附带。

### S10 / P2 / 高置信度：pg_duckdb 的共享源码归档包含完整 Git 元数据片段

- 定位：`debbuild/pg_duckdb/Makefile:8-9,18-20`；对应 `src/pg_duckdb-1.1.1.tar.gz`。
- 事实：实际归档内计数 215 个 `/.git/` 成员，包含 `ORIG_HEAD`、`config`、对象目录等。此 recipe 原样解包，既无规范化说明也无隔离处理，违反当前源码归档排除 `.git` 的约定。
- 同时核实：上游顶层 Makefile 的 DuckDB build target 依赖 `.git/modules/third_party/duckdb/HEAD`；因此不能直接删除目录后假定构建仍能工作。
- 影响：归档携带不必要且易变化的本地 Git 状态，可追溯来源与规范化规则难以统一，也可能让构建行为受本地仓库配置影响。没有读取或披露 git config 中的内容，本次未断言存在凭证泄露。
- 建议验证：维护者准备规范化候选归档时先用 pinned commit/version/manifest 替代必要的 Git 查询和依赖，再在 Linux builder 做零 Git 元数据构建。源码文件变更要协调元数据库与潜在 RPM 使用者，本次不实施。

### S11 / P3 / 高置信度：DocumentDB 专项文档已与当前 recipe 和离线依赖机制脱节

- 定位：`docs/documentdb.md:6-13,24-32,52-57`；对照 `debbuild/documentdb/Makefile:3-6`、`debbuild/documentdb/prepare.sh:11-21,88-98`。
- 事实：文档仍要求 `documentdb-0.114-0.tar.gz`，当前 recipe 固定 `.117-0`；文档称不要添加 download/cache patch、重试网络下载，而当前 prepare 已要求四个额外离线 tarball，并校验 Intel 输入。
- 触发与影响：照长期文档准备 builder 会缺新版源码和依赖；文档只拷贝一个 tarball 的命令也不足以满足当前 pre 流程。
- 建议验证：以干净 builder 的“取源→pre→指定 PG 构建”逐项核对文档清单。保留历史说明时明确版本和日期，当前操作段落应跟 recipe 同步。

## 风险与缺失验证，未升级为已发生故障

### R01 / P2 / 中高置信度：Cloudberry backup 的工具链最低版本没有在 control 中表达

- 定位：`debbuild/cloudberry-backup/debian/control:7`；`debbuild/cloudberry-backup/debian/rules:6-9,19-22`。
- 实际源码 `go.mod:3` 要求 Go 1.25.0，control 只要求无版本 `golang-go`。rules 优先 `/usr/local/go/bin` 并设置 `GOTOOLCHAIN=auto`，说明依赖 builder 外置 Go 或在线自动下载。
- 风险：Bookworm/Jammy 等系统原生 Go 可能无法自行使用新版自动工具链机制；或者构建依赖网络及未固定的工具链选择。需要记录最低 bootstrap Go、实际工具链和离线策略。当前没有据此声称现有 builder 构建失败。

### R02 / P2 / 中置信度：DocumentDB pre 全局安装依赖，污染/并发隔离需要明确

- 定位：`debbuild/documentdb/prepare.sh:23-25,81-85,111-119`；`docs/documentdb.md:49-55`。
- 上游 helper 默认把 libbson/PCRE2 等输入直接安装到 `/usr`；prepare 默认复用 `/tmp/documentdb` 与 `/tmp/install_setup` 且先删除。文档明确这是既有设计，因此不把“非 dpkg 安装”本身判作偶发 bug。
- 验证空缺：干净 builder 上依赖是否完整、二次运行幂等、同主机并发 recipe 是否互相删除、对后续其它扩展的 pkg-config/lib 搜索是否产生影响；最终 libbson/pcre2 是静态链接还是带入非托管运行时库，需查 ELF NEEDED 和安装 smoke。

### R03 / P2 / 中置信度：Cloudberry PXF 对核心包使用完全相等的二进制版本

- 定位：`debbuild/cloudberry-pxf/debian/control:25`；`debbuild/cloudberry-pxf/debian/changelog:1-4`；`debbuild/cloudberry/debian/changelog:1`。
- 当前首条版本均为 `2.1.0-1PGSTY`，不能认定当前不可安装。风险是核心安全重建只递增 revision 时 PXF 被强制锁在旧版；PXF changelog 中还遗留 `2.1.0-2PIGSTY` 的文字。
- 建议在生产升级方案中明确二者是否需要严格 ABI lockstep；若需要就同步构建和导入，如果不需要，应使用经过验证的兼容范围。不要在未验证 ABI 时任意放宽。

### R04 / P2 / 中置信度：已有 smoke 脚本与被关闭的上游测试之间没有可见强制门槛

- 定位：`debbuild/babelfish/debian/rules:162-169`、`debbuild/pgedge/debian/rules:114-121`、`debbuild/ivorysql/debian/rules:99-106`、`debbuild/pg_lake/debian/rules:47-49`、`debbuild/ivorysql-contrib/ivorysql-contrib-smoke.sh:1`。
- 内核 bundle、服务型扩展有合理的环境约束，`override_dh_auto_test: :` 不单独视为错误。但编译成功不能证明 auth、bootstrap、协议、复制、在线升级路径可用。
- 最小后续验收：Babelfish TDS/PG 双协议与 bootstrap；pgEdge 双节点复制+冲突处理；OrioleDB `shared_preload_libraries`+建表重启；OpenHalo PG/MySQL 双协议；Cloudberry initdb/单机集群与 Python 管理命令；PXF `PXF_BASE` 独立目录与 gpadmin 启动；pg_lake `pgduck_server`、spatial 首次下载与对象存储；IvorySQL contrib 在当前 5.6 内核上加载 29 controls/31 modules。

### R05 / P2 / 中置信度：DuckDB 的最低 runtime 依赖不是跨版本 ABI 保证

- 定位：`debbuild/duckdb_fdw/debian/control.in:5,13`、`debbuild/duckdb_fdw/debian/shlibs.local:1`；`debbuild/pg_mooncake/debian/control.in:13`。
- FDW 以 pg_duckdb 1.1.1 内置 DuckDB 1.4.3 的 headers 构建，并接受未来任意 `pg_duckdb >=1.1.1`。FDW 补丁声称改用 C API，因此不能仅凭最低版本依赖认定 ABI 已坏。Mooncake 还依赖 pg_duckdb 行为/符号，需与 Rust 专项审查衔接。
- 后续升级 pg_duckdb 时必须测同进程加载、ELF 符号解析、FDW 查询和 Mooncake 建表/写入/查询，不应只各自 CREATE EXTENSION。当前未实际验证新旧库混装失败。

## 已排除的疑点

- `polarstore/debian/rules:11` 的 `-march=native` 是删除操作；已核对实际源码 CMakeLists.txt，该匹配存在，不是包在启用 native 指令集。
- PolarStore 当前只提供 `.a` 与 header，`dh_strip -Xlibpfsd.a` 保留静态 DWARF供最终链接；不能把“SDK 没有独立 dbgsym”直接套成普通共享 ELF 包错误。
- OrioleDB `Makefile:62-78` 会按 PG16/17/18 重建 changelog，当前首条 beta17 与变量一致；旧历史条目不构成当前源码版本漂移。数据库若仍为 beta16，应作为独立元数据问题处理。
- IvorySQL-contrib 自身 5.4 与 IvorySQL 内核 5.6 不等于冲突；显式依赖范围是 5.x，是否兼容要按 ABI 和 smoke 结果判断。本次不主张强制等版本。
- SCWS 虽覆写空 `dh_auto_build`，实际源码 Automake 的 `install-am: all-am` 与 `install-libLTLIBRARIES: $(lib_LTLIBRARIES)` 会在安装阶段完成构建；不能仅凭空 build override 判为空包。
- Cloudberry PXF Gradle distribution checksum 确实存在于实际源码 properties，补丁与 sed 替换能命中；wrapper 也有附带校验文件，不报“sed 没添加校验”。
- pg_duckdb、duckdb_fdw、zhparser、PLV8 的实际顶层 Makefile 未找到 `DOCS = README*`；没有把这些包误报为共享 PostgreSQL README 冲突。
- Redis/Valkey 已经有卸载时停止服务的 prerm；不要重复报告“删除包后服务永远不停止”。升级后服务是否按运维策略手工重启是另一项验证。

## 覆盖与证据限制

读取关键 Makefile、control/control.in、rules、pgversions、安装/维护脚本并按疑点核对源码/补丁：`babelfish`、`cloudberry`、`cloudberry-backup`、`cloudberry-pxf`、`orioledb`、`openhalodb`、`polardb`、`polarstore`、`ivorysql`、`ivorysql-contrib`、`agensgraph`、`documentdb`、`omnigres`、`pg_lake`、`pg_duckdb`、`libduckdb`、`duckdb_fdw`、`pg_mooncake`、`pgroonga`、`pgedge`、`spock`、`plv8`、`rdkit`、`inchi`、`haproxy`、`redis`、`valkey`、`scws`、`zhparser`、`antlr4_runtime413`，共 30 项。没有独立 `groonga` 或 `duckdb` recipe，分别检查相应外部依赖和 `libduckdb`。

静态 `bash -n` 检查上述范围 35 个 shell/维护脚本全部通过；仅说明语法可解析，不说明命令可用、行为正确或构建成功。各 recipe 的并行阶段依赖、宽通配符收集旧产物、缺失源码预检等跨仓共性由主报告统一记录，避免重复计数。

本批 `apt/` 元数据快照未找到 Spock、Redis/Valkey、Cloudberry、libduckdb、RDKit 等对应当前产物；上面这些项主要以当前 recipe 与本地权威源码为证据。没有为了补证执行构建、安装、数据库写入或生产操作。
