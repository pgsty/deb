# pg_duckdb 1.2.2

当前配方为 PostgreSQL 15–19 构建 pg_duckdb 1.2.2，使用上游固定的 DuckDB 2.0.1。
源码归档为 `pg_duckdb-1.2.2.tar.gz`，SHA-256 为
`87ca6f9e2b2775731319f2ba95c7f4748b9a08cc2fd2c123020b445985d13abb`。
同一平台的五个 PG 主版本可以复用编译好的 DuckDB 共享库。PGXS 模块和 LLVM bitcode 按 PG 主版本构建。

1.2.2 修复了普通数据库角色通过 httpfs 读取 HTTPS 文件时加载系统 CA 证书的问题。
在 Ubuntu 24.04 amd64 的 PG18 上，实测普通角色通过签名的 httpfs 读取了启用证书校验的 HTTPS CSV。
已安装 pg_mooncake 0.3.4 的实例只升级 pg_duckdb 1.2.1 至 1.2.2 后，原有镜像在重启后继续复制新写入。

# pg_duckdb 1.2.1 升级与 PG19 核验

本轮将 pg_duckdb 1.2.0 升至上游正式发布的 **1.2.1**（2026-11-20），
使用该版本实际 gitlink 固定的 **DuckDB 2.0.1**。目标为 PG15–19；PG14、EL8 已移出当前配方目标。
证据只覆盖下表列出的两个代表性平台，未展开四平台生产矩阵。

## 固定输入

| 输入 | 版本或 commit |
| --- | --- |
| pg_duckdb | `451d389a3fe9d179b06172c6a3595d291de7ca76`（v1.2.1） |
| DuckDB gitlink | `8d78114e90a53823803660bf821f6073ac87da8c`（v2.0.1） |
| httpfs CMake 固定输入 | `f71cfdb4bff85b9e15b1f3b842d9aa395aff0167` |
| 私有 curl（仅系统 curl <7.85 时） | 8.23.0；u24 使用系统 libcurl 8.5.0 |

权威归档：`~/pgsty/repo/ext/src/pg_duckdb-1.2.1.tar.gz`，根目录 `pg_duckdb-1.2.1/`。
SHA256：`9d4d6b6eb8100ced1ff82a9e2f641dc3440d2547dd6de2aedeccfdee1af7e3aa`。
它包含固定 DuckDB 源码与 `SOURCE_MANIFEST.json`，不包含 httpfs checkout；
httpfs 仍通过上游 CMake 的固定提交获取，两侧实际 checkout 均已核对。
归档使用 GNU tar 和 `COPYFILE_DISABLE=1`，排除 Git 与 AppleDouble 元数据。

curl 归档 SHA256：`e3de77cfa6367083c776a26647fc9f633b538c06c3baa73d931a252ac8f72b49`。
每次构建先执行 `pig build get pg_duckdb`；本批新归档在公共镜像返回 404 后才按具体文件复制。
未发布源码镜像或二进制包。

## PG 版本证据

| PG | EL9.8 / aarch64（m1） | Ubuntu 24.04.5 / amd64（m3） |
| --- | --- | --- |
| 15 | 构建＋包/debug＋运行＋core LLVM/JIT 通过 | 构建＋包/debug＋运行＋core LLVM/JIT 通过 |
| 16 | 构建＋包/debug＋运行＋core LLVM/JIT 通过 | 构建＋包/debug＋运行＋core LLVM/JIT 通过 |
| 17 | 构建＋包/debug＋运行＋core LLVM/JIT 通过 | 构建＋包/debug＋运行＋core LLVM/JIT 通过 |
| 18 | 构建＋包/debug＋运行＋core LLVM/JIT 通过 | 构建＋包/debug＋运行＋core LLVM/JIT 通过 |
| 19 | 构建＋包/debug＋运行＋core LLVM/JIT 通过 | 构建＋包/debug＋运行＋core LLVM/JIT 通过 |

表内通过必须同时满足：主包成功生成、LLVM bitcode/index 属于主包、
运行依赖无 LLVM/Clang/core llvmjit、debug 包非空且 ELF Build-ID 匹配、
核心与桥接层都有类型/变量 DWARF、隔离实例实际预加载与查询通过、
全部 bitcode/index 可由 core 对应 LLVM 读取且实际 JIT/inlining 查询成功。
上游源码 gate 已包含 PG19；最终支持判定以逐版本 receipt 为准。
PG18/19 模块版本必须报告 `v1.2.1`，SQL 扩展版本为 `1.2.1`，DuckDB 运行版本为 `v2.0.1`。

## 补丁审查

| 当前补丁 | 必要性 | 最小范围与充分性边界 |
| --- | --- | --- |
| `pg_duckdb-1.2.1-source-archive.patch` | 官方 GitHub tar 无子模块 Git 元数据；并行安装需先创建 PGXS lib 目录 | 仅 Makefile 三个 hunk；使用随包 DuckDB CMakeLists 作为依赖、去掉 git submodule update、增加 order-only 安装依赖；不改运行时代码或依赖 pin |
| `pg_duckdb-1.2.1-private-curl.patch` | EL9 系统 curl 缺少 httpfs 要求的 >=7.85 API | 单独 28 行 helper，仅在旧系统 curl 上构建私有 PIC 静态库；发行版 DWARF/hardening flags 传入，不替换系统库 |

补丁统一使用 `extension-version-purpose.patch` 命名，两仓库逐字一致。
旧 httpfs `unique_ptr` 返回值修复已在新固定提交中直接使用 `std::move(result)`，删除本地重复修复。
EL8 专属 flags/GCC Toolset/OpenSSL3 分支随目标退役删除；未引用的旧 install-order patch 删除，
其必要顺序约束保留于新的 source-archive patch。
当前没有新增 PG19 API 或执行器兼容补丁。

## 构建、缓存与调试信息

m1：`pgsty/el9a:build`，容器 `nrheavy-pg-duckdb-el9a`，上限 6 CPU / 24 GiB，核心编译并行 2。
m3：`pgsty/u24:build`，容器 `nrheavy-pg-duckdb-u24`，上限 12 CPU / 40 GiB，核心编译并行 4。

RPM PG16–19 使用 builder 默认 `w19.zstdio`。按用户授权，仅在尚未启动的 PG15 验证构建追加
`--define '_binary_payload w3.zstdio'`，降低封装压缩耗时；不改 spec、源码、编译 flags 或核心缓存。
PG16 在切换检查时已经启动，因此保持原参数；全部坐标仍执行同样的包/debug/runtime/JIT 验收。

EL9 builder 初始缺 pgdg19 仓库导致 `No match for argument: postgresql19-server`；
在本批独立容器中补充与既有 PGDG mirror 一致的 pgdg19 配置后安装 PG19.0。
EL9 PGXS 的 `LLVM_BINPATH` 指向 LLVM21，而系统默认 clang 已为 22。
配方传入 `CLANG='$(LLVM_BINPATH)/clang'`，保留 PGXS 指定的 llvm-lto，
并声明 EL9 平行 `clang21 llvm21` 构建依赖，使 bitcode 生产者与 PGDG core 一致。
u24 使用 PGXS LLVM19；每个 PG 均检查 core 与 reader 链接同一 libLLVM，
逐个读取包内 bitcode/index，并运行强制开启 JIT/inlining 的 PG 聚合和扩展 C 函数调用。
本批 PG19 新建实例默认 `jit=off`；验收显式 `SET jit=on` 后通过。
该开关调整只在测试会话中生效，原始探测失败与修正后 receipt 均保留。

核心、桥接层和私有 curl 均保留完整发行版 `-g`，移除旧核心 `-g1` 限制。
跨 PG 复用只限同平台同源码、补丁、编译器、依赖及 flags 的 bundled DuckDB 缓存；
桥接对象和 LLVM bitcode 仍逐 PG 编译。
DEB 首轮在完整核心 DWARF 上触发 `dwz: Too many DIEs, not optimizing`；
仅 `libduckdb.so` 排除 DWZ 压缩，桥接层仍使用逐 ELF DWZ，`dh_strip` 正常分离完整 dbgsym。
staged 核心使用确定性 PG 专属 Build-ID，避免共装路径冲突。
RPM 保留 ELF Build-ID，但不生成跨 PG 冲突的全局 Build-ID 符号链接。

## 准确复现命令

在任务专属容器内运行，先确认两份指定源码及本轮 spec/recipe/patch 已就位。
以下示例为 PG19；将版本依次替换为 18、17、16、15 可重建其余坐标。
准确复现本批 RPM PG15 时，还需追加 `--define '_binary_payload w3.zstdio'`；其它坐标使用默认压缩。

```bash
# m1 / nrheavy-pg-duckdb-el9a
# BuildRequires include parallel clang21/llvm21 for PGDG EL9 PGXS.
pig build get pg_duckdb
rpmbuild -ba /root/rpmbuild/SPECS/pg_duckdb.spec \
  --define 'pgmajorversion 19' --define 'duckdb_core_jobs 2' \
  --define '_topdir /root/rpmbuild' \
  --define '_rpmdir /root/nonrust-heavy-20261121/pg_duckdb/artifacts/el9a/rpm' \
  --define '_srcrpmdir /root/nonrust-heavy-20261121/pg_duckdb/artifacts/el9a/srpm'

# m3 / nrheavy-pg-duckdb-u24
pig build get pg_duckdb
cd /root/nonrust-heavy-20261121/pg_duckdb/debbuild/pg_duckdb
make build19 DUCKDB_MAX_JOBS=4 \
  PKG_OUTPUT_DIR=/root/nonrust-heavy-20261121/pg_duckdb/artifacts/u24
```

DEB 的专属 Makefile 按当前 PG 目标直接从 `control.in` 生成 control，
未使用 `pg_buildext updatecontrol`。因此旧镜像中 helper 的默认 PGDG 列表止于 18
不会漏掉本批 PG19；PG19 主包、dbgsym 和安装运行记录均实际存在。
无需为该镜像问题改动 pg_duckdb recipe 或全局 helper。

## 验收与外部证据

日志、输入 SHA、每轮首错、产物清单、复现脚本及结果保存在：
`~/pgsty/artifacts/nonrust-heavy-20261121/pg_duckdb/`。
入口为 `result.json`；每个坐标各有 build 与 verify receipt，原始失败记录不覆盖。

核心 smoke 覆盖 `CREATE EXTENSION`、真实 DuckDB 执行计划、PG 表扫描/聚合、事务回滚、
DuckDB 临时表、JSON、Parquet 导出/导入、httpfs 本机 HTTP 读取，
以及上游提供的 `1.2.0 → 1.2.1` SQL 升级路径。
HTTP 测试只在隔离实例允许加载本批构建的 unsigned httpfs 插件；不代表公共签名插件、
MotherDuck 或外部云认证集成已通过。

本记录对应两个代表性平台，未执行四平台生产构建或发布。
PGEXT 与全量矩阵按最终 verified 坐标更新 `extension` / `universe` 的
`version`、`rpm_ver`、`deb_ver` 与 PG 范围。
`pg_mooncake` Rust 配方冻结，未推断其社区插件与 DuckDB 2.0.1 兼容。
`duckdb_fdw` 的独立静态输入不自动沿用本批结论。

<details>
<summary>历史：1.2.0 批次记录（不作为本轮 1.2.1 验证证据）</summary>

## pg_duckdb 1.2.0 打包与验证

上游发行说明：https://github.com/duckdb/pg_duckdb/releases/tag/v1.2.0 。
上游将此版本标为 Experimental，明确表示尚不适合生产使用。
阶段 B 使用固定源码开展代表性构建、包检查和隔离数据库验收，
三个 PG17 pilot 全部通过后才展开六个 RPM、十个 DEB 平台的 PG14–18 候选矩阵。
实时状态及完整日志保存在仓库外的
`~/pgsty/artifacts/full-matrix-20261103/stage-b-pg-duckdb/`。
配方存在或候选构建完成均不表示已发布，也不改变上游的 Experimental 定位。

### 固定源码

- pg_duckdb：`8756099e267c47f0b86c24de4cf995327f1f4279`（v1.2.0）。
- 内嵌 DuckDB：`d54cbbe3df17e8e5ce68312f483b4155836112aa`（v2.0.0），与主仓库 gitlink 一致。
- 归档：`pg_duckdb-1.2.0.tar.gz`，解包根目录 `pg_duckdb-1.2.0`。
- SHA-256：`c2209ab8ac81b5d9f15be7dbca1a3ce42cded007a301498a8c90c7337952722f`。
- 本地权威归档位置：`~/pgsty/repo/ext/src/pg_duckdb-1.2.0.tar.gz`。

归档以 v1.2.0 的 `git archive` 输出为基础，将官方 DuckDB 2.0.0 源码放入
`third_party/duckdb/`，并附带 `SOURCE_MANIFEST.json`。
使用 GNU tar、`COPYFILE_DISABLE=1`、排序文件名、UID/GID 0 和
`mtime=@1793656920`，排除 `.git`、`.DS_Store`、`._*`。
原始 DuckDB tarball SHA-256 为
`7e89053255046bfb26afbd7f524a2fb84df7dbef496aa911ea35e4a1182fdc00`。

这不是完整离线依赖包：上游 CMake 仍会按固定提交
`77392a72077a85897db2519fae11e2c0da972b8a` 获取 `duckdb/duckdb-httpfs`。
在 builder 中按仓库规则配置 GitHub HTTP 代理，保留实际取源日志。

当系统 `libcurl < 7.85` 时，还需要官方构建输入 `curl-8.23.0.tar.gz`：

- 来源：`https://curl.se/download/curl-8.23.0.tar.gz`。
- SHA-256：`e3de77cfa6367083c776a26647fc9f633b538c06c3baa73d931a252ac8f72b49`。
- 保存在同一权威源码目录；先运行 `pig build get curl-8.23.0.tar.gz`，取不到才复制该文件。

helper 在构建树中生成带 PIC 的私有静态 libcurl，供本轮 httpfs 编译使用，
不会替换系统 libcurl。系统版本足够时继续使用发行版提供的库。

### 配方边界

两侧使用同一份 `pg_duckdb-1.2.0-source-build.patch`：
以随包 DuckDB 的 `CMakeLists.txt` 代替 Git 子模块 HEAD 作为构建前置，
并保留 PGXS 安装目录先于 `install-duckdb` 的顺序约束。
httpfs 继续固定原提交，通过上游 `APPLY_PATCHES` 钩子对派生类 `unique_ptr`
返回值显式使用 `std::move`，解决 GCC 8–11 的 C++17 编译错误。
配方显式设置 `PG_DUCKDB_VERSION=v1.2.0`、`PG_MAX_VER=18` 和完整
`DUCKDB_COMMIT=d54cbbe3df17e8e5ce68312f483b4155836112aa`，仅打包 PG14–18。
PG18 还在 PGXS 读取变量前导出版本定义；验收要求加载模块报告 `v1.2.0`，
不能接受上游 target-specific 变量生效过晚造成的 `unknown`。

保留动态 `libduckdb.so`、LLVM、既有调试信息策略、两任务的 DuckDB 内层并行默认值，
以及同一平台内按源码、补丁、commit、依赖版本、编译器和 flags 区分的跨 PG 主版本核心缓存。
PGXS 桥接层仍逐 PG 版本重建，不跨系统或架构共享编译缓存。
DuckDB 核心保留既有 `-g1` 函数及行号 DWARF，桥接层保留发行版完整 `-g`；
不能把核心调试信息描述为完整变量调试。

DWZ 使用 `--no-dwz-multifile`，保留逐 ELF 优化和正常 dbgsym 分离。
由于不同 PG 包不能共同拥有同一个全局 Build-ID 路径，`dh_strip` 在 staged
核心上写入确定性的 PG 专属 Build-ID；核心缓存本身不变，自动生成的 dbgsym
因此可以同时安装。dbgsym 使用构建器实际生成的 `.deb` 或 `.ddeb` 文件名，
收集时不改名，也不同时保留两种后缀的重复候选。

验收检查主包与 dbgsym 的逐文件归属、Build-ID/DWARF、候选与安装 ELF 的 SHA-256、
PG14–18 预加载、版本、强制执行计划、事务、跨连接读取、非 public 安装、
本地 JSON/Parquet，以及来自同批构建的 httpfs 插件和真实本机 HTTP 读取。
还需验证多个 PG 主版本的主包和全部 dbgsym 同时安装。
隔离测试允许本轮未签名 httpfs 插件，不代表公共插件、MotherDuck 或云认证集成通过。

### 下游兼容边界

`pg_mooncake` Rust 包的 `RegisterDuckdbTableAm` C 接口未变化，未发现需要自动
重编 Rust 包的新编译输入。但其独立 C++ 社区插件与 DuckDB 版本严格匹配：
已有 v1.4.3 插件不能用于 v2.0.0；2026-11-04 检查的双架构 v2.0.0 社区路径均为 404。
因此本批候选不声明与现有 Mooncake 插件兼容；仅重编 Rust 包不能解决该缺口。
需要上游提供匹配插件后再单独验收，不在打包任务内实现其 API 迁移。

`duckdb_fdw` 已有自己的静态 DuckDB 输入，不因本次升级自动重建。
同一 PG 主版本的既有互斥关系保留。

本轮不写 PGEXT 数据库，不进入生产 staging，不发布源码或二进制包。
后续元数据维护须包含新增 curl 源码输入；当前数据库同步仍是外部待办。

</details>
