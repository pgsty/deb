# pg_duckdb 1.2.0 打包准备

上游发行说明：https://github.com/duckdb/pg_duckdb/releases/tag/v1.2.0 。
上游将此版本标为 Experimental，明确表示尚不适合生产使用。
本次仅准备配方与源码，未执行构建、安装、运行回归或容器解包验证。
后续在其他批次项目完成后，通过独立会话先做代表性验证，再构建全平台候选包。

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

## 配方边界

两侧使用同一份 `pg_duckdb-1.2.0-source-build.patch`：
以随包 DuckDB 的 `CMakeLists.txt` 代替 Git 子模块 HEAD 作为构建前置，
并保留 PGXS 安装目录先于 `install-duckdb` 的顺序约束。
配方显式设置 `PG_DUCKDB_VERSION=v1.2.0`、`PG_MAX_VER=18`，仅打包 PG14–18。

保留动态 `libduckdb.so`、LLVM、既有调试信息策略、两任务的 DuckDB 内层并行默认值，
以及同一平台内按源码、编译器和 flags 区分的跨 PG 主版本核心缓存。
PGXS 桥接层仍逐 PG 版本重建，不跨系统或架构共享编译缓存。

独立构建会话必须检查新版本的工具链需求、补丁应用、容器解包、payload、
Build-ID/DWARF、PG14–18 加载与查询，以及与 pg_mooncake 的真实 API/ABI 关系。
`duckdb_fdw` 已有自己的静态 DuckDB 输入，不因本次升级自动重建。
本轮没有修改 PGEXT 数据库或发布源码与二进制包。
