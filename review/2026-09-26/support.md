# 支持库、工具与内核扩展补充审查

[返回总手册](../../DEBIAN_REVIEW_2026-09-26.md)

此补充覆盖其余 11 个 recipe：pgtde、lolor、snowflake、libfq、pgcopydb、pgsodium-libsodium、python-faker、graphblas、lagraph、onesparse、zlog。编号 SX、SUP、LIB 分别对应三个补查分组。没有运行构建、安装或发布。

## 内核 bundle 与 standalone 扩展

审查日期：2026-09-26。范围为当前工作树、权威 src 中被 recipe 选用的归档、只读元数据快照和现有 apt 产物清单。未构建、安装、启动服务、写数据库或修改 recipe；本补充文件为唯一写入。

### SX01 — LOLOR、Snowflake standalone 与必需的 pgEdge bundle 重复拥有文件

- 严重度：P1；置信度：高；静态确认。是原报告 S01（Spock）的同类扩展，宜合并描述，避免计成三种独立根因。
- 定位：`debbuild/lolor/debian/control:5,10-12`、`debbuild/lolor/debian/rules:3-8`；`debbuild/snowflake/debian/control:5,10-12`、`debbuild/snowflake/debian/rules:3-8`；`debbuild/pgedge/debian/rules:95-109`、`debbuild/pgedge/debian/control:49-57`。
- 事实：两个 standalone 的 Build-Depends/Depends 都要求 `pgedge-18`，PG_CONFIG/PATH 使用 `/usr/pgedge-18/bin`。bundle 又将 `.lolor`、`.snowflake` 的同一 PGXS 安装产物收入自身。双方均未声明处理文件接替的 Replaces/Breaks 等关系。
- 归档证据：当前 `lolor-1.2.2.tar.gz` 的 `Makefile:3-7,15-18` 定义 lolor 模块、扩展和 SQL；当前 `snowflake-2.6.0.tar.gz` 的 `Makefile:3-22,27-30` 定义 snowflake 模块、扩展和 SQL。同一个 PG_CONFIG 会得到相同的 lib/share 安装目录。bundle rules 明列 `/usr/pgedge-18/lib/postgresql/lolor.so`、`snowflake.so`，control/SQL 也来自同一安装规则。
- 触发/影响：按当前 recipe 生成 standalone 后安装到其强制依赖的 bundle 上，会发生重叠文件归属，dpkg 可能因 overwrite 拒绝解包。若强制覆盖，升级/移除时会留下文件归属问题。数据库目前将这两个扩展映射到 bundle，不代表 standalone recipe 已从仓库移除或其手动构建路径不存在。
- 建议验证：先确定 standalone 的产品定位。若保留，重新设计 bundle/扩展文件所有权，再以真实 `.deb` 做安装、升级和卸载测试；若停止使用，明确弃用入口与历史包迁移路径。当前 apt 快照没有这两个 standalone 或 pgedge 包，不能声称现有二进制已复现安装失败。

### SX02 — 两个 standalone copyright 同样只有 SPDX 占位

- 严重度：P2；置信度：高；静态确认。宜纳入原报告 S09。
- 定位：`debbuild/lolor/debian/copyright:1-3`、`debbuild/snowflake/debian/copyright:1-3`。
- 事实：文件仅包含 `SPDX-License-Identifier: PostgreSQL` 和 `PostgreSQL License` 名称，缺少版权主体及完整许可证文本。Snowflake 当前归档 `COPYRIGHT:3-5` 明确含 pgEdge、PostgreSQL Global Development Group 和 University of California 的版权声明，recipe 占位没有反映这些内容。
- 影响：自动安装一个名为 copyright 的文件并不等于许可证记录完整。此处为打包文档缺陷，不据此断言发布已违法。
- 建议验证：按当前实际归档补齐准确声明与许可文本，核对最终包的 `/usr/share/doc/<package>/copyright`；不能只检查文件存在。

### SX03 — pgtde 的 DEP-5 通配段放在末尾，覆盖前面的第三方许可证映射

- 严重度：P2；置信度：高；静态确认。
- 定位：`debbuild/pgtde/debian/copyright:5-40,42-46`。
- 事实：前面分别为 vendored libkmip、PostGIS、pg_gather、wal2json、pg_repack 等定义 Apache/BSD/GPL 许可段；后面又用 `Files: *` 把所有文件设为 PostgreSQL 许可。该文件主动声明 DEP-5 格式，而该格式规定最后一个匹配的 Files 段生效，通配符也匹配斜线与前导点，因此 `.postgis-src/*`、`.pg_gather-src/*` 等前面的特定段在机器解析结果中全部被覆盖。[Debian copyright-format 1.0 §6.9](https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/#files-field)
- 影响：生成的机器可读许可清单错误地将 GPL/Apache/BSD 的第三方组件归到 PostgreSQL；人类仍可看到前面段落，不能据此说源码中完全没有第三方声明。
- 建议验证：把通用段放到具体覆盖段之前，并用 DEP-5 解析器抽查 `.postgis-src/...`、`.pg_gather-src/gather.sql`、`.pg_tde-src/subprojects/libkmip/...` 的最终匹配结果；同步核对实际二进制 copyright，而不只依赖 lintian 是否提示。

### 已核对且不应误报的事实

#### pgtde

- `versions.mk:1-16` 明确只支持 PG18，当前核心 18.6 / Percona release 1 / pg_tde 2.2.2；`debian/control`、rules、postinst、copyright、changelog、patch series 与唯一补丁、source/format、两个 lintian-overrides 均已读取。
- `sources.sha256` 的 12 项（10 个 tarball + 两个 helper）全部存在于本机权威 `src`，实际 SHA256 全部吻合。10 个归档根目录均符合 Makefile:25-43 的解包/改名规则；扫描未发现 `.git/`、`.DS_Store`、AppleDouble 成员。
- 元数据库 `pg_tde.version=2.2.2`、`deb_ver=18.6`、`deb_pg={18}` 及 12 项 source 名称与当前 recipe 一致。`PG_VERSION` 与 `PGTDE_VERSION` 属于不同组件，不应直接比较为版本漂移。
- `debian/changelog` 为模板，setup:49-57 会替换各版本占位并追加发行版代号。存在重复模板版本条目，但不能以占位符本身判为无效最终版本。
- 主包与 contrib 分别使用 `.pgtde-stage`、`.pgtde-contrib-stage`；主包装内核/pg_tde，contrib 装 PostgreSQL contrib 与附加扩展。`pgtde-18-contrib` 精确依赖主包 `${binary:Version}` 与同一源码构建的关系一致，不是独立组件的错误版本锁定。
- rules:14-15 已显式传入 CFLAGS/LDFLAGS 的 dpkg-buildflags；当前没有 noautodbgsym/nostrip。Makefile:64-65 采集主包、contrib 及 `.deb`/`.ddeb` 格式的 dbgsym；仍受主报告公共阶段并行/历史产物 glob/find-exec 退出码问题影响。
- `.pgtde-pg-config` 和 `.pgtde-sfcgal-config` 是构建 helper，不是替换最终系统 pg_config。前者区分 stage/hybrid/final 路径以处理 DESTDIR；后者用 pkg-config 兼容 SFCGAL。两个 helper 与 postinst 的 `bash -n` 静态语法检查通过。
- rules:119-130 有意把六个 TDE-aware 程序置于 canonical pg_* 名，并把 pg_tde_* 保留为指向 canonical 名的链接；与 control:65-66 的描述一致，不应当成误删上游程序。后续仍需真实备份/恢复/升级路径验收。
- rules:132-177 有 RPATH 白名单检查与关键 extension/control/payload 存在性断言。pg_repack 补丁引用的原文上下文存在于当前 1.5.3 归档中，意图是保留被 repack 表的访问方法；`3.0 (quilt)` 的补丁不能因 setup 没显式 patch 命令就判为未应用。
- `dh_auto_test` 被关闭（rules:188-189）。目前没有本次构建、安装及 TDE/runtime 测试证据；该缺口应涵盖加密表、密钥轮转、备份/恢复、repack 对加密 AM 的保持，而不能用打包路径检查替代。

#### lolor / snowflake

- 两个 recipe 的 Makefile 与完整 debian 目录全部读取；没有自己的 versions.mk 或 patch，版本来自 `../pgedge/versions.mk`。当前分别选用 1.2.2 与 2.6.0 归档，二者均存在且根目录正确。
- snowflake changelog 模板仍写 2.4，但 setup:15 将其替换为 `SNOWFLAKE_VERSION=2.6.0`，因此最终版本不是 2.4；不新增此项误报。
- 上游 Makefile 把 `PG_CONFIG=pg_config` 设为普通变量，会覆盖 export 的同名环境变量；recipe 同时把 `/usr/pgedge-18/bin` 放在 PATH 首位，故默认仍选择同一内核，不据此认定它选错系统 PG。
- 两者无共享 PostgreSQL-doc README 安装规则；没有自动 dbgsym 禁用选项。测试均关闭（各 rules:10-11），需后续安装后验证 LOLOR preload/大对象复制及 Snowflake 建扩展/ID 生成功能。

### 主手册补充复核

G15 与 G16 的修订结论与代码/快照一致：prepare.sh:18-21,88-90 强制要求四份额外离线归档；documentdb/Makefile:21 和 changelog:11 明确排除 distributed，不能把其数据库记录简单 bump 成 0.117。未发现新误报。

本补充把特殊对象逐包读取覆盖从 30 项扩展到 33 项。没有新增 builder 构建或动态安装结论。


## 支持库与客户端工具

### 范围

完整读取 `libfq`、`pgcopydb`、`pgsodium-libsodium`、`python-faker` 的 Makefile、全部 debian 文件、脚本和许可证；这四个 recipe 均无本地 patch 文件。额外交叉读取 pgsodium 对私有库的消费规则与 patch。读取对应本地归档关键构建、许可证及安装文件；四份源码均存在，归档条目未发现 AppleDouble、.DS_Store 或 __pycache__。未执行构建、安装、发布或修改 recipe。

| recipe | 源码归档 | 版本 | 包型 | 已读源条目数 |
| --- | --- | --- | --- | --- |
| libfq | libfq-0.6.2.tar.gz | 0.6.2 | 原生共享库/开发文件合包 | 54 |
| pgcopydb | pgcopydb-0.18.tar.gz | 0.18 | 原生客户端工具 | 653 |
| pgsodium-libsodium | libsodium-1.0.22.tar.gz | 1.0.22 | 私有 PIC 静态开发库 | 814 |
| python-faker | faker_40.37.0.orig.tar.gz | 40.37.0 | 架构无关 Python 运行库 | 1605 |

“源条目数”是已枚举归档范围，不代表逐字审阅所有上游源码。

### 新增确认问题

#### SUP-01 — libfq 的 copyright 文件只有许可证名称，无实际版权与条款

- 严重度：P2；置信度：高。
- 位置：`debbuild/libfq/debian/copyright:1`、3。
- 证据：完整文件只有 `SPDX-License-Identifier: PostgreSQL`、空行、`PostgreSQL License`。未列任何版权作者或许可证条款。源码 `libfq-0.6.2.tar.gz!libfq-0.6.2/src/libfq.c:5` 为 Ian Barwick 2013–2023 版权，7 为 PostgreSQL Licence；相关移植代码的版权也应核实。
- 影响：dh_installdocs 虽会安装 copyright，但该文件本身内容不完整，不能把“路径存在”当成版权信息完整。
- 依据：[Debian Policy 12.5](https://www.debian.org/doc/debian-policy/ch-docs.html#copyright-information)要求包内 copyright 包含适用版权与分发条款，短 SPDX 标记不足以替代完整信息。
- 后续验证：以归档内各代码来源核对作者和许可证范围，再对 DEB copyright 实际内容检查。这里不对法律责任作额外推断。

### 条件性风险与验证缺口

#### SUP-R01 — libfq 的 release 库名变更缺少 DEB ABI 迁移保护

- 严重度：P2；置信度：高（库名机制与包结构），中（现有旧消费包是否仍在用户环境）。
- 位置：`debbuild/libfq/debian/control:10`、13；`debbuild/libfq/debian/rules:7`；`debbuild/libfq/Makefile:3`。
- 证据：0.6.1 与 0.6.2 两份本地上游归档的 `Makefile.am:16` 分别为 `libfq_la_LDFLAGS = -release 0.6.1 ...` / `-release 0.6.2 ...`。GNU Libtool 的 [-release 说明](https://www.gnu.org/s/libtool/manual/html_node/Release-numbers.html)明确该选项把 release 写入实际库名并破坏跨 release 的二进制可替换性。DEB 始终只有同名 `Package: libfq`，没有按 ABI 拆分，也没有旧消费方的 Breaks 或兼容库安装逻辑。
- 触发：用户保留针对 0.6.1 链接的 firebird_fdw 或其他程序，仅升级 libfq 至 0.6.2；若旧包依赖是最低版本而非精确 ABI，APT 仍可认为依赖满足，但旧 NEEDED 指向的 release 库不再存在。
- 边界：本次没有读取已发布旧 firebird_fdw ELF/Depends，因此记录为具体升级风险，不能宣称已发生生产故障。全套消费方同时重建升级也不能保证用户不会部分升级。
- 后续验证：在旧 DEB 中提取 `readelf -d` NEEDED 和 Depends，对新 libfq payload 做差分；验证“旧消费方+新库”的升级顺序。按真实结果选择 ABI 包名、兼容库保留或准确版本关系/Breaks，不能盲目给新库建旧名软链接。

#### SUP-R02 — pgcopydb 手动 make 路径需证明 Debian buildflags 全程传入

- 严重度：P3；置信度：高（规则缺显式配置），未确认 debug 丢失。
- 位置：`debbuild/pgcopydb/debian/rules:5`、7、18。
- 证据：override 中直接执行上游 make，recipe 未按 AGENTS.md 手工构建约定设置 `DPKG_EXPORT_BUILDFLAGS`/包含 buildflags.mk。上游 `pgcopydb-0.18.tar.gz!pgcopydb-0.18/src/bin/pgcopydb/Makefile:45` 显式 `-g`，50 使用 `pg_config --cflags`，80–90 添加安全参数和环境 CFLAGS；链接 129 使用 LDFLAGS。因上游和 debhelper 本身也可能导出足够 flags，不能报“肯定没有 DWARF”。
- 后续验证：读取实际编译日志中的 CFLAGS/CPPFLAGS/LDFLAGS 和 debhelper 所用版本行为；确认主体与 bundled SQLite 都有 DWARF、路径映射及预期硬化，并确认自动 dbgsym 非空。若等价传递已经被证明，可把例外写清楚。

#### SUP-R03 — pgcopydb 的 clean 不清 bundled SQLite 对象，直接重复 dpkg-buildpackage 有陈旧对象风险

- 严重度：P3；置信度：高（clean 漏项），正常全新 setup 不受影响。
- 位置：`debbuild/pgcopydb/debian/rules:10`、11；`debbuild/pgcopydb/debian/clean:1`。
- 证据：上游 `src/bin/pgcopydb/Makefile:166` 的 clean 删除主目录 OBJS（包括指向 sqlite3.o 的软链接），没有进入 `src/bin/lib/sqlite` 清理真实 sqlite3.o。主 Makefile:131 为该对象提供无源码 prerequisites 的转发规则；只有对象不存在时才执行子 make。`debian/clean` 也仅删除 debian/home。
- 触发：在同一个构建副本中改 flags、工具链或 bundled SQLite 源后直接再跑 dpkg-buildpackage；它的 clean 未清此对象，可能复用旧对象。`debbuild/pgcopydb/Makefile:13` 的完整 setup 会清整个 build，所以默认全流程重建不受影响。
- 后续验证：用未来授权的 builder 改编译选项重跑包构建，检查 sqlite3.o 是否重编译；确保 source clean 和增量路径均可解释。

### 未发现独立缺陷，但需要保留的验证边界

#### libfq

- 主包 Architecture:any、shlibs/misc Depends、Firebird 构建依赖合理；dh_auto_install 会调用上游 make install，其 Automake install 依赖会完成必要构建，不能仅因 override_dh_auto_build 为空便认定包未编译。
- `rules:9` 删除 .la；没有禁止自动 dbgsym。尚未检查真实 shared library SONAME、shlibs、开发头文件 payload 和 debug 内容。
- `debian/postinst:5` 手工 ldconfig 与 dh_makeshlibs 自动触发可能重复，但幂等，不单独计作重要故障。
- 上游 configure.ac:4 仍写 0.6.1，而 release 库名已为 0.6.2，属于上游版本元信息不一致；需记录，但目前没有证据它改写了 Debian 版本或破坏构建。

#### pgcopydb

- Build-Depends 包含工具实际使用的 PostgreSQL 开发库、GC、ncurses、Sphinx 等；主包有 postgresql-client/shlibs/misc 依赖；安装路径固定 /usr/bin，manpage 随包。
- `debian/rules:15` 保留真实 clone smoke test，`debian/tests/copydb:7` 用 pg_virtualenv 创建临时实例，校验迁移表数据 579；这比空测试模板覆盖更好。但仅一张小表，不覆盖逻辑追赶、大对象、权限、不同 PG 版本迁移。
- 顶层 Makefile 快捷目标 .PHONY 问题已属于主审查 G01，本补充不重复计数。

#### pgsodium-libsodium

- 未发现新的确定独立缺陷。Architecture:any 与 PIC 静态库相符；只安装到 /usr/include/pgsodium-libsodium 和 /usr/lib/pgsodium-libsodium，未覆盖系统 libsodium ABI。
- `rules:19`、21 以 LC_ALL=C 枚举/去重全局已定义符号；25 重写 archive；33–39 验证定义均加前缀且不存在原私有未定义引用。消费侧 `debbuild/pgsodium/patches/pgsodium-3.1.11.patch:39` 开始采用对应私有 include/lib 路径与宏重定义头。
- `rules:56` 仅把静态 archive 排除 dh_strip，以保留 DWARF 给最终 pgsodium.so 的自动 dbgsym，是有原因的静态开发包流程，不应要求制造独立空 .ddeb，也不能等同普通共享模块禁用 dbgsym。
- 测试运行的是重写前上游库；将来仍应在两种架构检查重写后的 archive 链接、nm 未定义引用、pgsodium 与 pg_vault 同时加载、最终 DWARF；本次没有执行这些动态验证。
- 头文件目录整体复制会带 version.h.in 模板，但未见二进制冲突或运行故障，未作为独立问题。

#### python-faker

- 未发现新的确定独立缺陷。源码 setup.py:70 仅 Windows 条件需要 tzdata；75 要求 Python>=3.10，与 jammy/bookworm Python 基线及 README.source 意图吻合；不存在仍必须依赖 python-dateutil 的证据。
- Architecture:all 合理，dh-python/pybuild/`${python3:Depends}` 标准路径，移除 /usr/bin/faker 以仅交付运行库，包含实际 import/provider autopkgtest。
- Makefile 已使用 all→move→build→setup 依赖链与 clean-artifacts；相较宽泛并行 sibling template 更稳妥。允许仅 bookworm/jammy 是明确 backport 约束，不应误报缺其余六个平台。
- `override_dh_auto_test` 为空，但另有 `debian/tests/smoke`；普通 dpkg-buildpackage 不自动执行 autopkgtest，不能仅凭构建成功声称该 smoke 已运行。

### 已有共性风险引用

libfq、pgcopydb、pgsodium-libsodium 的 `all: setup build move` 无阶段依赖，及收集宽 glob，沿用主报告的构建竞态/旧产物混入结论，不额外增加重复发现。三者相关位置分别是 Makefile:1 与 19、1 与 26、1 与 23。python-faker 已避免这两个模板问题。


## 图计算支持库与日志库

日期：2026-09-26。只读审查四个 recipe 的 Makefile、全部 Debian 文件及相关本地源码构建规则；补丁仅在 `/tmp` 抽取副本中检查。未构建、安装、写库或修改 recipe。

### LIB-01：三个 copyright 文件只有许可短名，缺完整声明；GraphBLAS 还遗漏嵌入依赖的不同许可

**P2 / 静态确认 / 置信度高。**

位置：`debbuild/graphblas/debian/copyright:5`–`:7`、`debbuild/lagraph/debian/copyright:5`–`:7`、`debbuild/onesparse/debian/copyright:5`–`:7`；安装规则关联 `graphblas/debian/libgraphblas10.install:1`、`lagraph/debian/liblagraph1.install:1`、`onesparse/debian/rules:15`–`:16`。

这三个文件均只有 7 行：Files/Copyright 后为 `License: Apache-2.0` 或 `License: BSD-2-Clause`，没有许可正文、后续独立 License stanza，亦未指向 `/usr/share/common-licenses/Apache-2.0`。它们声明使用 DEP-5 格式；[Debian copyright 格式说明](https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/#license-field)区分许可短名与对应的完整许可条款，不能只把短名当成整个声明。

GraphBLAS 更具体：本地 `graphblas-10.5.0.tar.gz!LICENSE:2`–`:3` 明说第三方代码例外；`:61` 为 LZ4 BSD-2-Clause，`:132` 为 ZSTD BSD-3-Clause，`:168` 为 xxHash BSD-2-Clause；source 中也包含这些目录。现有 `Files: * / License: Apache-2.0` 未反映这些区别。应按实际编入/分发范围保留版权人与许可。GraphBLAS/LAGraph 的 `.install` 只列库/头/CMake/pkg-config 文件，没有显式收集上游 LICENSE；OneSparse 仅显式安装 README。`dh_installdocs` 的默认文档行为不能凭空补全 `debian/copyright`，参见[官方手册](https://manpages.debian.org/bookworm/debhelper/dh_installdocs.1.en.html)。

影响：后续二进制交付的许可说明和来源追踪不完整；这里没有逐包验证这四类现有产物，也没有判断外部是否另行附带授权文件，更不据此断言已发生违规发布。

建议：补完整 license stanza 或适用的 common-licenses 引用；GraphBLAS 根据内嵌代码列 Files/版权/许可，并安装必要的上游 notices。验收时读取每个 runtime/dev 包的 `/usr/share/doc/<pkg>/copyright` 及相关 LICENSE/NOTICE，不能只检查 copyright 文件“存在”。

### LIB-02：zlog 上游不消费 CPPFLAGS，发行版部分 hardening flags 没有进入编译命令

**P3 / 静态确认的 flags 传播缺口 / 置信度高。**

位置：`debbuild/zlog/debian/rules:4`–`:5`、`:10`–`:11`；本地源码 `zlog-1.2.18.tar.gz!src/Makefile:66`、`:193`–`:194`。

rules 正确导出 dpkg buildflags，但上游 `REAL_CFLAGS` 只包含 OPTIMIZATION、CFLAGS、WARNINGS、DEBUG，`.c.o` 命令亦仅传 REAL_CFLAGS，没有 CPPFLAGS。因此发行版放在 CPPFLAGS 中的预处理选项（例如 `_FORTIFY_SOURCE`）不会因为“已经 export”就自动生效。

这不是 dbgsym 缺失：CFLAGS 与上游 DEBUG 都保留 `-g`，LDFLAGS 也进入链接命令。影响仅为被遗漏的 CPPFLAGS 及其保护/配置语义。

建议：局部修正上游编译规则或显式传入合并后的 flags，避免覆盖上游必要的 PIC、pthread、警告选项。后续以真实 gcc 命令核验 `_FORTIFY_SOURCE`、优化、`-g` 与 linker flags 同时存在；本次未构建，未检查二进制是否包含 fortified libc 调用。

### 四个 recipe 的覆盖与静态结论

| Recipe | 版本及包范围 | 依赖与构建 | debug/payload 静态结果 | 平台/PG 边界 |
|---|---|---|---|---|
| graphblas | 10.5.0；libgraphblas10、libgraphblas-dev | cmake>=3.23、debhelper-compat13、pkg-config；系统工具链属于常规 build-essential 假设，不因未显式列 gcc 就报错 | 导出 dpkg flags、保留优化/-g；shared ON/static OFF；multiarch 库、单一 GraphBLAS.h、CMake、.pc 分包；未禁用 dbgsym | 不属于 PG 扩展；无 PG loop；arm64 加 `-fno-tree-vectorize`规避已记 GCC ICE；没有仅 amd64 源码/二进制硬编码 |
| lagraph | 1.2.2；liblagraph1、liblagraphx1、liblagraph-dev | cmake>=3.23、libgraphblas-dev>=10.5.0、debhelper、pkg-config；dev包精确依赖两 runtime 包相同 binary:Version | 导出 dpkg flags；shared ON/static OFF；两个 SONAME 库、两个头、统一 LAGraph CMake 目录与 .pc 拆分合理；未禁用 dbgsym | 不属于 PG 扩展；依赖先装 GraphBLAS；CPU/OpenMP 与实际共享库依赖需通过目标产物确认 |
| onesparse | DEB 1.0.0；仅 postgresql-18-onesparse | PG18 server-dev、pkgconf、GraphBLAS/LAGraph dev；补丁改用发行版 pkg-config 路径，未发现继续指向 /usr/local 的安装需求 | PGXS install 标准 .so/control/SQL；README 由 dh_installdocs 安装到私有路径；上游 Makefile 没有 `DOCS=README`；未禁用 dbgsym | 只支持本 recipe 明确固定的 PG18；没有 pgversions/control.in 并非缺陷；支持库最小实际 API版本尚需验证 |
| zlog | 1.2.18；zlog 主包包括 header/static/shared | debhelper、gcc、make；runtime shlibs/misc；Provides/Conflicts/Replaces 明确处理 libzlog1/libzlog-dev 的合包替代 | dpkg flags 已导出、debug不关闭；明确安装 .so.1.2、.so.1/.so 链、.a/.h；verify 核对主包/调试包name-version-arch与非空debug文件 | .NOTPARALLEL；白名单五代号×两架构并要求与真实builder匹配；不是 PG扩展，无PG版本维度 |

四个主源码归档当前均存在于 `src` 指向的权威目录。未执行 `pig build get`；不能据本地文件存在断言所有 builder 都能取到。

#### 已排除的假阳性

- **GraphBLAS/LAGraph 的 `-d` 例外：** 已完整读取 `docs/kitware-cmake.md`。两者 Makefile:23–37 先检查 dpkg 管理的 CMake 版本；系统满足时正常完整依赖检查，不满足时调用固定 Kitware 3.31.12、校验可执行版本，并以 `dpkg-checkbuilddeps -d` 检查除 CMake 外完整 Build-Depends。分别与 control:5 一致，不报“无条件跳过依赖检查”。此处传的是 dpkg-checkbuilddeps 的依赖字符串参数，不与 dpkg-buildpackage 的跳过检查选项混淆。
- **Release 不等于没有 DWARF：** GraphBLAS/LAGraph rules 都导出 DPKG flags，并 include buildflags.mk；本地 CMake 规则追加 Release flags，没有看到把 -g 清掉的相关规则。需要 ELF 验证才能关闭调试符号任务，但不能仅凭 `CMAKE_BUILD_TYPE=Release` 报 dbgsym 缺失。
- **OneSparse tag 与 SQL 版本差异：** `debian/changelog:3`–`:6` 已明确上游 release tag 为 1.0.0、control 内 default_version 为 0.1.0；实际本地 control 与说明相符。两者不是必然需要机械改为同一字符串。
- **OneSparse 手工 patch 与 quilt：** 当前 setup 手工应用 `debian/patches/onesparse-1.0.0.patch`，series 也列同一补丁，属于需要留意的混合维护方式；但不能直接认定 dpkg-source 必然再次应用并失败。本次核读本机 dpkg 1.23.11 的 `Dpkg::Source::Package::V3::Quilt::check_patches_applied`，它先 dry-run 检查可应用性再决定自动 apply。目标发行版 dpkg 的生命周期尚未复验。该 patch 在 `/tmp` 中对当前源 Makefile 使用 GNU patch `--fuzz=0` 成功。
- **GraphBLAS JIT 与 compiler 依赖：** recipe 选择 compact+JIT，源配置记录 JIT compiler 与 flags；OneSparse 源 `src/guc.c:7` 默认 JIT OFF。因此不直接将 runtime control 未依赖 gcc 判为所有常规功能都会失败。用户显式开启 JIT 时，应检查 compiler、系统 headers、缓存写权限和运行 uid，并记录该可选功能的前置条件。
- **测试关闭：** 四个 recipe 均关闭或未集成自动运行测试，这本身不能证明二进制错误；但必须保留为运行验收缺口。

### 仍需关闭的验证缺口

1. GraphBLAS/LAGraph 的文档记录了 2026-09-05 Jammy 双架构与 Noble ARM64 的构建/smoke；本次未重新执行，不把历史记录写成当前工作树“构建通过”。该记录亦不等于五系统十平台全矩阵通过。
2. 当前 `apt/` 没有检出这四类名称的可审查产物；未对其进行实际 Package/SONAME/DT_NEEDED/RPATH、ELF Machine、build-id、DWARF、安装冲突验收。
3. GraphBLAS/LAGraph 库运行依赖依赖 dh_shlibdeps 生成，需在只装声明依赖的空白环境运行最小 C 程序并通过 pkg-config/CMake 两种 consumer 路径链接；不能只在充满 dev 包的 builder 测试。
4. OneSparse 应在 PG18 初始化库后 CREATE EXTENSION，并覆盖矩阵/向量与调用 LAGraph 的操作；若承诺 JIT，则另外测试开启 JIT 的角色权限及缓存路径，不把默认关闭 JIT 的成功当成 JIT 已验证。
5. zlog 自带 verify 检查包头和 debug 文件存在，但不核验 main/debug build-id 配对或 `.debug_info` 内容（`Makefile:55`–`:60`）；应补独立 ELF 验收。它的精确文件名/版本/架构收集比宽泛 glob 明确，但不能仅用“文件存在”证明是刚刚这一轮生成。
6. graphblas、lagraph、onesparse 的 `all: setup build move` 和宽泛 move glob 沿用主报告 G02/G03/G04 的问题；zlog 有 `.NOTPARALLEL`、精确文件名和 move→verify，不能把前三者的共性标签批量套到 zlog。
