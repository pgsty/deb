# pg_duckdb 1.2.0 打包与验证

上游发行说明：https://github.com/duckdb/pg_duckdb/releases/tag/v1.2.0 。
上游将此版本标为 Experimental，明确表示尚不适合生产使用。
阶段 B 使用固定源码开展代表性构建、包检查和隔离数据库验收，
三个 PG17 pilot 全部通过后才展开六个 RPM、十个 DEB 平台的 PG14–18 候选矩阵。
实时状态及完整日志保存在仓库外的
`~/pgsty/artifacts/full-matrix-20261103/stage-b-pg-duckdb/`。
配方存在或候选构建完成均不表示已发布，也不改变上游的 Experimental 定位。

## 固定源码

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

## 配方边界

两侧使用同一份 `pg_duckdb-1.2.0-source-build.patch`：
以随包 DuckDB 的 `CMakeLists.txt` 代替 Git 子模块 HEAD 作为构建前置，
并保留 PGXS 安装目录先于 `install-duckdb` 的顺序约束。
httpfs 继续固定原提交，通过上游 `APPLY_PATCHES` 钩子对派生类 `unique_ptr`
返回值显式使用 `std::move`，解决 GCC 8–11 的 C++17 编译错误。
配方显式设置 `PG_DUCKDB_VERSION=v1.2.0`、`PG_MAX_VER=18` 和完整
`DUCKDB_COMMIT=d54cbbe3df17e8e5ce68312f483b4155836112aa`，仅打包 PG14–18。

保留动态 `libduckdb.so`、LLVM、既有调试信息策略、两任务的 DuckDB 内层并行默认值，
以及同一平台内按源码、补丁、commit、依赖版本、编译器和 flags 区分的跨 PG 主版本核心缓存。
PGXS 桥接层仍逐 PG 版本重建，不跨系统或架构共享编译缓存。
DuckDB 核心保留既有 `-g1` 函数及行号 DWARF，桥接层保留发行版完整 `-g`；
不能把核心调试信息描述为完整变量调试。

验收检查主包与 dbgsym 的逐文件归属、Build-ID/DWARF、候选与安装 ELF 的 SHA-256、
PG14–18 预加载、版本、强制执行计划、事务、跨连接读取、非 public 安装、
本地 JSON/Parquet，以及来自同批构建的 httpfs 插件和真实本机 HTTP 读取。
还需验证多个 PG 主版本的主包和全部 dbgsym 同时安装。
隔离测试允许本轮未签名 httpfs 插件，不代表公共插件、MotherDuck 或云认证集成通过。

## 下游兼容边界

`pg_mooncake` Rust 包的 `RegisterDuckdbTableAm` C 接口未变化，未发现需要自动
重编 Rust 包的新编译输入。但其独立 C++ 社区插件与 DuckDB 版本严格匹配：
已有 v1.4.3 插件不能用于 v2.0.0；2026-11-04 检查的双架构 v2.0.0 社区路径均为 404。
因此本批候选不声明与现有 Mooncake 插件兼容；仅重编 Rust 包不能解决该缺口。
需要上游提供匹配插件后再单独验收，不在打包任务内实现其 API 迁移。

`duckdb_fdw` 已有自己的静态 DuckDB 输入，不因本次升级自动重建。
同一 PG 主版本的既有互斥关系保留。

本轮不写 PGEXT 数据库，不进入生产 staging，不发布源码或二进制包。
后续元数据维护须包含新增 curl 源码输入；当前数据库同步仍是外部待办。
