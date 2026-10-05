# PGXS / SQL recipe 静态审查记录（2026-09-26）

[返回总手册](../../DEBIAN_REVIEW_2026-09-26.md)

## 范围与方法

只读检查，未运行构建、安装、数据库写入、发布。扫描 275 个具有 `debian/control.in`、可识别 `TARBALL` 且不含 Rust/pgrx 标记的 recipe；部分复杂扩展仅做横向元数据扫描，专门实现由其他审查分支负责。用 Python tarfile 在内存中读取本地源码归档的 Makefile/GNUmakefile/control/SQL/README，未解包覆盖仓库。检查的维度包括 PG 列表、包名映射、Architecture、源码依赖、文档安装、版权文件、编译链接参数、构建阶段和收集逻辑。

缺源、动态变量和大于 100 MB 的归档不计作已完整读取源码。全矩阵构建与安装没有在本次 Review 中执行；本报告的高置信是指静态因果链明确，不代表已经重现运行故障。所有路径相对仓库根目录；归档内部位置写成 `归档!文件:行`。

## 已确认的问题

### PGXS-01 — aws_s3 缺少 PL/Python 和 boto3 运行依赖

- 严重度：P1；置信度：高。
- 位置：`debbuild/aws_s3/debian/control.in:13`；`debbuild/aws_s3/debian/rules:15`。
- 证据：Depends 仅有 `${postgresql:Depends}, ${misc:Depends}`；`aws_s3-0.0.1.tar.gz!aws_s3-0.0.1/aws_s3--0.0.1.sql:22`、36 等直接声明 `LANGUAGE plpython3u`，67、180 导入 `boto3`。源码 README:9 要求 boto3，38 要求先建 plpython3u。
- 触发与影响：在只有 PostgreSQL 的干净机器安装此 DEB，APT 不会安装对应 `postgresql-plpython3-<major>` / `python3-boto3`。创建扩展会因语言不可用失败；即使手工安装语言，S3 导入导出调用仍可因缺 boto3 失败。
- 处置方向：补齐准确的 DEB 运行依赖；另核实是否在 control 中声明 `requires = 'plpython3u'`，或清楚记录上游要求的 bootstrap 顺序。
- 后续验证：最小 PostgreSQL 镜像仅安装该 DEB 的依赖闭包，执行语言 bootstrap / CREATE EXTENSION，再用本地 mock S3 覆盖一次实际导入导出。
- 外部依据：[上游安装说明](https://github.com/chimpler/postgres-aws-s3)。

### PGXS-02 — index_advisor / pglogical_ticker 缺必需扩展包依赖

- 严重度：P2；置信度：高。
- 位置：`debbuild/index_advisor/debian/control.in:13`；`debbuild/pglogical_ticker/debian/control.in:13`。
- 证据：`index_advisor-0.2.0.tar.gz!index_advisor-0.2.0/index_advisor.control:5` 声明 `requires = hypopg`；`pglogical_ticker-1.4.1.tar.gz!pglogical_ticker-1.4.1/pglogical_ticker.control:6` 声明 `requires = 'pglogical'`。recipe 未补对应 `postgresql-PGVERSION-hypopg` / `postgresql-PGVERSION-pglogical`。
- 触发与影响：APT 成功安装主包后，干净实例的 CREATE EXTENSION ... CASCADE 无法找到必需扩展 control 文件；默认 builder 已装大量扩展会掩盖问题。
- 不误判依据：`${postgresql:Depends}` 并不会推断 extension requires。`pg_buildext` 的 substvars() 只构造 PostgreSQL 服务端与适用的 JIT ABI 依赖；见[工具源码](https://raw.githubusercontent.com/credativ/postgresql-common/master/pg_buildext)。
- 后续验证：各 PG 版本在最小安装环境检查 apt 依赖闭包、CREATE EXTENSION CASCADE；ticker 还需 pglogical 的正确 preload 配置。

### PGXS-03 — pgsparql 缺实际使用的 Perl 模块

- 严重度：P2；置信度：高。
- 位置：`debbuild/pgsparql/debian/control.in:13`。
- 证据：Depends 仅包含 PostgreSQL、plperl 与 misc；`pgsparql-1.0.tar.gz!pgsparql-1.0/sparql--1.0.sql:74` 使用 `LWP::Simple`，75 使用 `URI::Escape`，76 使用 `JSON`，103 使用 `Try::Tiny`，且多处重复。这些模块并非 PL/Perl 包本身承诺提供的全部模块。
- 触发与影响：最小依赖安装环境中扩展函数编译或调用会出现 Can't locate ... in @INC。需要核对 `libwww-perl`、`libjson-perl`，以及经直接或传递依赖得到的 `liburi-perl`、`libtry-tiny-perl`；仍支持安装历史 0.3 SQL 时还需检查 `DateTime`。
- 后续验证：五个系统核对实际模块包名及传递依赖，最小实例 CREATE EXTENSION sparql CASCADE，并实际执行 HTTP/JSON 路径。
- 包依赖核对来源：[Debian PL/Perl 包](https://packages.debian.org/bookworm/postgresql-plperl-15)、[libwww-perl](https://packages.debian.org/bookworm/libwww-perl)。

### PGXS-04 — pg4ml 缺 numpy 运行依赖，GPU 可选依赖也未表达

- 严重度：P2；置信度：高（numpy），中（GPU 功能交付约定）。
- 位置：`debbuild/pg4ml/debian/control.in:13`；`debbuild/pg4ml/debian/rules:13`。
- 证据：Depends 有 plpython3，无 numpy。源码 `pg4ml-2.0.tar.gz!pg4ml-2.0/sql/03_function/03_matrix/03_prod_trans_turn_mirror/sm_sc.fv_opr_transpose_nd_py.sql:11` 为 `from numpy import array`；多个数学/池化函数使用 numpy。`.../sm_sc.fv_opr_prod_mx_py_cupy.sql:10` 使用 `import cupy as cp`。上游通过 gen_sql_files.sh 合成扩展 SQL，recipe 未裁掉这些函数。
- 触发与影响：DEB 与 CREATE EXTENSION 成功不代表数值函数可用；最小 PL/Python 环境调用这些函数缺模块失败。
- 处置方向：numpy 应进入依赖闭包。CuPy/CUDA 不宜无条件硬绑到所有 CPU 平台，需明确可选能力与启用说明，并测试 CPU 基础函数。
- 后续验证：干净实例执行至少一个 numpy-backed 函数；GPU 功能另列专用环境验证。

### PGXS-05 — 11 个空 dh_installdocs override 丢弃 Debian copyright 安装

- 严重度：P2；置信度：高（打包流程），产物实检待补。
- 机制：空 `override_dh_installdocs:` 跳过整个 dh_installdocs 步骤，连 `debian/copyright` 安装也一起关闭。多数 recipe 只使用 PGXS 安装 SQL/SO，没有补装包私有 copyright。Debian 官方明确该文件由 dh_installdocs 安装到所有包：[dh_installdocs 手册](https://manpages.debian.org/testing/debhelper/dh_installdocs.1.en.html)。
- 确切位置：

| recipe | 位置 |
| --- | --- |
| data_historization | `debbuild/data_historization/debian/rules:15` |
| ddl_historization | `debbuild/ddl_historization/debian/rules:12` |
| decoder_raw | `debbuild/decoder_raw/debian/rules:15` |
| mysqlcompat | `debbuild/mysqlcompat/debian/rules:15` |
| pg_duration | `debbuild/pg_duration/debian/rules:15` |
| pg_plan_filter | `debbuild/pg_plan_filter/debian/rules:16` |
| pg_schedoc | `debbuild/pg_schedoc/debian/rules:13` |
| pg_xxhash | `debbuild/pg_xxhash/debian/rules:15` |
| pgroonga | `debbuild/pgroonga/debian/rules:31` |
| pgsentinel | `debbuild/pgsentinel/debian/rules:17` |
| temporal_tables | `debbuild/temporal_tables/debian/rules:17` |

- 影响：主包可能有 changelog 却没有 `/usr/share/doc/<package>/copyright`；这是明确的 Debian 包元数据缺失，不能用“无需 README”解释关闭整个步骤。
- 边界：mysqlcompat 本地源码缺失；pgroonga 是 Meson 特例，应在实际产物确认上游是否另装相当文件。其余已读对应 PGXS install 机制，未见补装 Debian copyright。
- 后续验证：逐包检查现有或未来 DEB 的完整 file list 与 lintian 结果；保留 dh_installdocs 默认 copyright 行为，再独立处理可选 README。

### PGXS-06 — timestamp9 使用 CMake 但 Build-Depends 未声明

- 严重度：P2；置信度：高（声明缺失），中（具体精简 builder 是否已经间接安装）。
- 位置：`debbuild/timestamp9/debian/control.in:5`；`debbuild/timestamp9/debian/rules:4`、15。
- 证据：Build-Depends 只有 debhelper-compat 与 postgresql-all，rules 强制 `--buildsystem=cmake`，configure 实际需要 cmake。
- 影响：依赖检查不能验证该工具，预装完整工具链的 builder 可通过，而依据源码包 Build-Depends 配置的精简环境可在配置阶段失败。
- 后续验证：确认目标发行版依赖闭包，使用仅按 Build-Depends 安装工具的 builder；无需因此宣称现有生产构建失败。

### PGXS-07 — aws_s3 Homepage 与真实源码上游不符

- 严重度：P3；置信度：高。
- 位置：`debbuild/aws_s3/debian/control.in:8`。
- 证据：现指 `https://github.com/arkhipov/aws-s3`，本次公开读取返回 404；源码 README:16 的 git clone 指向 `chimpler/postgres-aws-s3`，与已读源码及[可用官方仓库](https://github.com/chimpler/postgres-aws-s3)匹配。
- 影响：用户与维护者无法由 DEB 元信息追踪实际上游；建议同时核对元数据库 source_url/homepage 类字段，但 Review 不修改。

## 横向风险与验证缺口

### PGXS-R01 — 收集时可能混入旧版本、旧 PG、旧系统代号的产物

- 严重度：P2；置信度：高（代表 recipe）；横向规则匹配 251 项，不等同逐项已证实。
- 代表位置：`debbuild/pg_profile/Makefile:8` 仅删除 build，`debbuild/pg_profile/Makefile:25` 将当前目录全部 `*.deb` 及 `*.ddeb` 复制输出。
- 触发：同一 recipe 目录先构建完整 PG 集合，再缩小 PG 范围；或升级版本/复用挂载目录切换代号。旧产物未清理，成功构建后新旧文件一起进入 ext/pkg。
- 影响：收集清单与本次目标不一致，后续 broad pull/stash 可误包含旧包；并非证明已导入了错误包。
- 后续验证：检查采集是否依据本轮 `.changes` 精确列文件；让产物清理与构建依赖有顺序，单独保留显式增量构建路径。父审查已覆盖全仓阶段竞态，本项不重复计数。

### PGXS-R02 — 144 个 setup 在 recipe 真源位置生成 control

- 严重度：P3；置信度：高。
- 代表位置：`debbuild/pg_profile/Makefile:10`、`debbuild/index_advisor/Makefile:9`。
- 行为：setup 已解压 build 后，仍先在原 recipe 工作目录运行 pg_buildext updatecontrol，然后 cp debian 到 build；build 中又更新一次。
- 影响：以不同 builder 的 supported-versions 操作只读 recipe checkout/共享 recipe，会写入原始 debian/control 或因不可写失败；同一 recipe 被并发复用时可能互相覆盖。最终构建副本更新并不消除这种源目录污染。
- 后续验证：把 recipe 以只读挂载方式进行 setup 的静态命令验证；明确 generated control 的所有权与是否应该受版本控制。

### PGXS-R03 — 4 份字面声明的本地权威源码归档缺失

- 严重度：P2（可重现性缺口）；置信度：高（仅本机缺失）。
- 位置均为对应 `Makefile:3`：`debbuild/mysqlcompat/Makefile` → mysqlcompat-0.0.7.tar.gz；`debbuild/pg_mon/Makefile` → pg_mon-1.0.tar.gz；`debbuild/pg_timeit/Makefile` → pg-timeit-1.0.tar.gz；`debbuild/postgresql_anonymizer/Makefile` → postgresql_anonymizer-1.3.2.tar.gz。
- 边界：未运行 pig build get，故不能宣称公共镜像也缺失；其中有历史 recipe，父审查应结合顶层 target/元数据判断当前是否活跃。
- 后续验证：用户授权构建时先 pig build get，仅复制明确缺失归档；若退役应在支持清单明确状态。

### PGXS-R04 — 原生模块缺 shlibs substitution，值得补一轮依赖检查

- 严重度：P3；置信度：高（字段缺失），未认定所有包必然不能运行。
- 受影响原生 recipe：pg_duration、pg_plan_filter、pg_relusage、pg_tle、pg_uint128、pg_xxhash、pgl_ddl_deploy、safeupdate，其 control.in 的 Depends 没有 `${shlibs:Depends}`。
- 这些模块多依赖已被 PostgreSQL 拉入的 libc，不能简单等同“必然缺动态库”。pg_xxhash 虽 Build-Depends 写 libxxhash-dev，但源码自带 xxhash.o，未链接 libxxhash.so，故不报 libxxhash 运行依赖必缺。
- 后续验证：以每个 ELF 的 NEEDED 与 dh_shlibdeps 输出确定实际所需依赖，再完善模板。

### PGXS-R05 — 广泛关闭自动测试，构建成功不覆盖运行能力

- 多数常规 recipe 的 override_dh_auto_test 为空，安装流程只会编译与复制，没有自动 CREATE EXTENSION 或实际语言运行时函数检查。
- 这不是所有扩展都必须开启上游 regression 的结论（有些依赖外部服务或 preload），但上述缺运行依赖是具体盲区。
- 后续建议：将最小安装依赖闭包、CREATE EXTENSION、至少一个核心函数与升级路径作为独立验收；preload/外部服务单列，而不是把 builder 自带依赖当成包的依赖。

## 已排除的典型误报

- `Architecture: all` 扫描未发现确定的原生 ELF 被错报为 all；external_file/pg_dbms_lock/pg_utl_smtp 的 MODULES 为空，属于纯 SQL。
- 不含 `${postgresql:Depends}` 不自动构成 bug：多个手工 SQL recipe 直接声明 `postgresql-PGVERSION`，语义仍成立。
- qdgc 的 qdgc_postgis bridge 是可选组件，Depends 不强制 PostGIS 而 Suggests 声明符合当前拆分意图。
- pgsqlmock 源码 requires 写 pgTap，但 recipe 已通过 patches 修为 pgtap，不应报大小写问题。
- pgcalendar 与 external_file 的上游 DOCS 有 README，但 rules 手工只复制扩展文件、dh_installdocs 放包私有目录，不走上游 DOCS install。
- temporal_tables 的 override_dh_install 删除路径确实值得日后简化，但 `Makefile:13` 已在源码 GNUmakefile 注释 DOCS，因此不能认定当前产物仍带共享 README。
- pgvector 上游默认 `-march=native`，当前 rules:15 显式 `OPTFLAGS=` 已关闭；pg_uint128 中该参数只是注释。
- pg_biscuit 的 `-lroaring` 是 WITH_ROARING 可选路径；ulak 的 NATS 也是未启用路径，不能据此直接报 lib 缺依赖。
- 历史 changelog 的 PIGSTY 后缀不按新规则强制改写；目前活跃 pgversions 扫描没有新增 PG13/PG19 的证据。

## 后续验收建议

先补运行依赖闭包与 copyright，再确认 timestamp9 的最小 build dependencies；随后整治产物收集、recipe 源目录生成污染与测试覆盖。每次真正修复需在明确的 Debian/Ubuntu builder 验证。默认代表环境为 pgsty/u24a:build、noble、arm64；至少覆盖一个真实 PG，依赖类修复优先覆盖 PG14–18 的各 package 名称；没有 ELF 的 SQL 包不要求空 dbgsym。

## 附表：275 recipe 覆盖清单与共性筛选位置

归档读取统计：已读归档关键文件 267；本地缺失 4；仅recipe扫描（归档>100MB） 4。

“根目录 control”指 setup 中无 cd 的 updatecontrol 确切位置。“宽 glob”列只是 251 个候选，不自动证明每个 recipe 都无其他产物清理路径；需依次完整核查。所有源码仅检查选定关键文件，不等于全量上游代码审计。

| recipe | PG 范围 | 源码覆盖 | 根目录 control | 宽 glob 候选 |
| --- | --- | --- | --- | --- |
| acdat | 14,15,16,17,18 | 已读归档关键文件 | — | — |
| age | 17,18 | 已读归档关键文件 | — | Makefile:53 |
| aggs_for_arrays | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| aggs_for_vecs | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| argm | 14,15,16,17,18 | 已读归档关键文件 | — | — |
| aws_s3 | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| cat_tools | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| chkpass | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| citus | 16,17,18 | 已读归档关键文件 | Makefile:12 | Makefile:46 |
| column_encrypt | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| count_distinct | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| cron_utils | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| cryptint | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| data_historization | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| datasketches | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:40 |
| db_migrator | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| dbt2 | 14,15,16,17,18 | 已读归档关键文件 | — | — |
| ddl_historization | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:33 |
| ddsketch | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| decoder_raw | 14,15,16,17,18 | 已读归档关键文件 | Makefile:10 | Makefile:22 |
| documentdb | 15,16,17,18 | 已读归档关键文件 | Makefile:22 | Makefile:58 |
| duckdb_fdw | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:38 |
| emaj | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| external_file | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| faker | 14,15,16,17,18 | 已读归档关键文件 | — | — |
| fbsql | 16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| firebird_fdw | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| floatfile | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| floatvec | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| fsm_core | 15,16,17,18 | 已读归档关键文件 | — | Makefile:27 |
| geoip | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:27 |
| hashtypes | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| hdfs_fdw | 14,15,16,17,18 | 已读归档关键文件 | — | — |
| hunspell | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:27 |
| hydra | 14,15,16 | 已读归档关键文件 | Makefile:12 | — |
| imgsmlr | 14,15,16,17,18 | 已读归档关键文件 | Makefile:10 | Makefile:22 |
| index_advisor | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| jdbc_fdw | 14,15,16,17,18 | 已读归档关键文件 | — | — |
| jev | 14,15,16,17 | 已读归档关键文件 | — | Makefile:28 |
| kafka_fdw | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| log_fdw | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| logerrors | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| logical_ddl | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:25 |
| login_hook | 14,15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:28 |
| lower_quantile | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| macavity | 16,17,18 | 已读归档关键文件 | — | Makefile:28 |
| md5hash | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| mobilitydb | 18 | 已读归档关键文件 | — | — |
| mongo_fdw | 14,15,16,17,18 | 已读归档关键文件 | Makefile:15 | Makefile:27 |
| multicorn | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:29 |
| mysqlcompat | 14,15,16,17,18 | 本地缺失 | Makefile:9 | Makefile:21 |
| nominatim_fdw | 14,15,16,17,18 | 已读归档关键文件 | Makefile:11 | Makefile:23 |
| odbc_fdw | 14,15,16,17,18 | 已读归档关键文件 | — | — |
| omnigres | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:110 |
| omnisketch | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| online_advisor | 14,15,16,17,18 | 已读归档关键文件 | — | — |
| pagevis | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| parray_gin | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| passwordcheck_cracklib | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:27 |
| passwordpolicy | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| pdu | 14,15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:26 |
| permuteseq | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg4ml | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:22 |
| pg_accumulator | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:33 |
| pg_acl | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_ai_query | 14,15,16,17,18 | 仅recipe扫描（归档>100MB） | Makefile:9 | Makefile:21 |
| pg_arraymath | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_ash | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:27 |
| pg_auditor | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:28 |
| pg_auth_mon | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:27 |
| pg_background | 14,15,16,17,18 | 已读归档关键文件 | Makefile:17 | Makefile:29 |
| pg_base36 | 14,15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:28 |
| pg_base62 | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_bigm | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_bikram_sambat | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:23 |
| pg_biscuit | 16,17,18 | 已读归档关键文件 | — | Makefile:46 |
| pg_bulkload | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_byteamagic | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| pg_bzip | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_cheat_funcs | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_circuit | 16,17,18 | 已读归档关键文件 | — | Makefile:29 |
| pg_cjk_parser | 14,15,16,17,18 | 已读归档关键文件 | — | — |
| pg_clickhouse | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:32 |
| pg_column_tetris | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| pg_cooldown | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_country | 14,15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:28 |
| pg_crash | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:33 |
| pg_curl | 14,15,16,17,18 | 已读归档关键文件 | — | — |
| pg_currency | 14,15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:28 |
| pg_datasentinel | 15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_dbms_errlog | 14,15,16,17,18 | 已读归档关键文件 | — | — |
| pg_dbms_job | 14,15,16,17,18 | 已读归档关键文件 | — | — |
| pg_dbms_lock | 14,15,16,17,18 | 已读归档关键文件 | — | — |
| pg_dbms_metadata | 14,15,16,17,18 | 已读归档关键文件 | — | — |
| pg_ddlx | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_describe | 17,18 | 已读归档关键文件 | — | Makefile:24 |
| pg_disorder | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| pg_dispatch | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:23 |
| pg_drop_events | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_duckdb | 14,15,16,17,18 | 仅recipe扫描（归档>100MB） | — | Makefile:27 |
| pg_ducklake | 14,15,16,17,18 | 仅recipe扫描（归档>100MB） | — | Makefile:50 |
| pg_duration | 17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_ecdsa | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_emailaddr | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_envvar | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_extra_time | 14,15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:28 |
| pg_fact_loader | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:18 |
| pg_failover_slots | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| pg_financial | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_fio | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_fkpart | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_flight_recorder | 15,16,17,18 | 已读归档关键文件 | — | — |
| pg_fsql | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:33 |
| pg_fts | 17,18 | 已读归档关键文件 | — | Makefile:24 |
| pg_geohash | 14,15,16,17,18 | 已读归档关键文件 | Makefile:12 | Makefile:24 |
| pg_grammar_guard | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:28 |
| pg_gzip | 14,15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:28 |
| pg_hashids | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_hashlib | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_html5_email_address | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_http | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:27 |
| pg_incremental | 16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| pg_isok | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| pg_ivm | 14,15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:28 |
| pg_jieba | 14,15,16,17,18 | 已读归档关键文件 | — | — |
| pg_jobmon | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_kpart | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| pg_liquid | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:32 |
| pg_living_assertions | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:28 |
| pg_local_cache | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:30 |
| pg_math | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_meta | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_mockable | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| pg_mon | 14,15,16 | 本地缺失 | Makefile:9 | Makefile:21 |
| pg_net | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:43 |
| pg_noset | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_oidc_validator | 18 | 已读归档关键文件 | — | Makefile:33 |
| pg_orca | 18 | 已读归档关键文件 | — | Makefile:24 |
| pg_orphaned | 14,15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:28 |
| pg_partman | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_pathcheck | 17,18 | 已读归档关键文件 | — | Makefile:23 |
| pg_permissions | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:27 |
| pg_plan_filter | 14,15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:28 |
| pg_policy | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:29 |
| pg_profile | 14,15,16,17,18 | 已读归档关键文件 | Makefile:10 | Makefile:25 |
| pg_projection | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| pg_protobuf | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_qos | 15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:28 |
| pg_query_rewrite | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| pg_random | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_readme | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_readonly | 14,15,16,17,18 | 已读归档关键文件 | Makefile:19 | Makefile:38 |
| pg_redis_pubsub | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_regresql | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:32 |
| pg_relation_sql | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:26 |
| pg_relusage | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_retry | 17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_rewrite | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_roaringbitmap | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_roast | 14,15,16,17,18 | 已读归档关键文件 | — | — |
| pg_savior | 14,15,16,17,18 | 已读归档关键文件 | Makefile:13 | Makefile:25 |
| pg_schedoc | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:40 |
| pg_slug_gen | 15,16,17,18 | 已读归档关键文件 | — | Makefile:23 |
| pg_sorted_heap | 16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| pg_sqlog | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:28 |
| pg_stat_backtrace | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| pg_stat_ch | 16,17,18 | 已读归档关键文件 | — | Makefile:48 |
| pg_stat_monitor | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_statement_rollback | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:39 |
| pg_statviz | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:26 |
| pg_stl | 16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| pg_store_plans | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_task | 14,15,16,17,18 | 已读归档关键文件 | Makefile:22 | Makefile:38 |
| pg_text_semver | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| pg_textsearch | 17,18 | 已读归档关键文件 | — | Makefile:27 |
| pg_tiktoken_c | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:37 |
| pg_timeit | 14,15,16,17,18 | 本地缺失 | Makefile:9 | Makefile:21 |
| pg_timeseries | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:27 |
| pg_tle | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_tracing | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_track_optimizer | 17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_ttl_index | 15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_uint128 | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_upless | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_uri | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_utl_smtp | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_uuid_v8 | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:34 |
| pg_uuidv7 | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_variables | 14,15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:33 |
| pg_vault | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_vault_tde | 17,18 | 已读归档关键文件 | — | Makefile:24 |
| pg_weighted_statistics | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_xenophile | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_xxhash | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pg_zstd | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pgactive | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:66 |
| pgbouncer_fdw | 14,15,16,17,18 | 已读归档关键文件 | — | — |
| pgcalendar | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:33 |
| pgclone | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| pgcollection | 14,15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:28 |
| pgcozy | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pgcryptokey | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pgdisablelogerror | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| pgelog | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:23 |
| pgfincore | 14,15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:28 |
| pghydro | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:76 |
| pgjq | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pgjwt | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pgl_ddl_deploy | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:26 |
| pglock | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:33 |
| pglogical_ticker | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:27 |
| pgmb | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pgmemento | 14,15,16,17,18 | 已读归档关键文件 | — | — |
| pgmeminfo | 14,15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:28 |
| pgmnemo | 17,18 | 已读归档关键文件 | — | Makefile:25 |
| pgmonitor | 14,15,16,17,18 | 已读归档关键文件 | — | — |
| pgmp | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| pgmq | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:29 |
| pgnodemx | 14,15,16,17,18 | 已读归档关键文件 | Makefile:19 | Makefile:31 |
| pgpdf | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pgproto | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:26 |
| pgqr | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pgroonga | 14,15,16,17,18 | 已读归档关键文件 | Makefile:13 | Makefile:28 |
| pgsentinel | 14,15,16,17,18 | 已读归档关键文件 | Makefile:18 | Makefile:30 |
| pgsodium | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:38 |
| pgsparql | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pgspider_ext | 15,16,17,18 | 已读归档关键文件 | Makefile:10 | Makefile:23 |
| pgsql_tweaks | 14,15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:29 |
| pgsqlmock | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:33 |
| pgtt | 14,15,16,17,18 | 已读归档关键文件 | Makefile:18 | Makefile:31 |
| pguint | 14,15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:28 |
| pgunit | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pgvector | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| pgxicor | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| pgzint | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:32 |
| pljs | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| plpgsql_check | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| plpgsql_wrap | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| plproxy | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| plruby | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:35 |
| plv8 | 14,15,16,17,18 | 仅recipe扫描（归档>100MB） | — | — |
| plx | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| plxslt | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| postbis | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:33 |
| postgresbson | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:33 |
| postgresql_anonymizer | 14,15,16,17,18 | 本地缺失 | Makefile:9 | Makefile:21 |
| provsql | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:25 |
| psql_bm25s | 17,18 | 已读归档关键文件 | — | Makefile:24 |
| q3c | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| qdgc | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| quantile | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| rdf_fdw | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:35 |
| re2 | 16,17,18 | 已读归档关键文件 | — | Makefile:24 |
| redis_fdw | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:20 |
| safeupdate | 14,15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:28 |
| sequential_uuids | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| session_variable | 14,15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:28 |
| shacrypt | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| smlar | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| spat | 17 | 已读归档关键文件 | Makefile:18 | Makefile:37 |
| sqlite_fdw | 14,15,16,17,18 | 已读归档关键文件 | Makefile:10 | Makefile:24 |
| sslutils | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:33 |
| storage_engine | 15,16,17,18 | 已读归档关键文件 | — | Makefile:41 |
| supautils | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:27 |
| system_stats | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| table_version | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| temporal_tables | 14,15,16,17,18 | 已读归档关键文件 | Makefile:11 | Makefile:24 |
| timescaledb | 16,17,18 | 已读归档关键文件 | — | — |
| timestamp9 | 14,15,16,17,18 | 已读归档关键文件 | Makefile:10 | Makefile:22 |
| topn | 14,15,16,17,18 | 已读归档关键文件 | Makefile:16 | Makefile:28 |
| ulak | 14,15,16,17,18 | 已读归档关键文件 | — | Makefile:33 |
| url_encode | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| vasco | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |
| wal2mongo | 14,15,16,17,18 | 已读归档关键文件 | Makefile:10 | Makefile:23 |
| zhparser | 14,15,16,17,18 | 已读归档关键文件 | Makefile:9 | Makefile:21 |

## 补充静态核对

- 在可读取且小于 15 MB 的非 Rust 归档中，扫描 C/C++ 源码的 PostgreSQL 版本 `#error` 边界，未发现与当前 recipe pgversions 明确矛盾的门槛。宏组合、未声明 API 变化及运行语义仍需 builder 验证。
- 在同一批归档非 test/example/doc/model/benchmark 的 SQL 中，扫描 PL/Python、PL/Perl、PL/R、PL/V8 语言声明并比对 DEB 语言包依赖，唯一未声明相应语言包的确定命中是 aws_s3；这不覆盖 SQL 中动态生成的语言或脚本运行时第三方模块。
- 标准 Architecture 与 pg_buildext loop 包名映射扫描未见确定错位；无需为了统一模板把全部手工安装 recipe 重写。
