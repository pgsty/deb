# pg_integrity_checksums 2.2.0

上游：<https://github.com/VictorNagibator/pg_integrity_checksums>，tag `v2.2.0`。
归档 `pg_integrity_checksums-2.2.0.tar.gz`，SHA-256
`771d85da3dd8c99f99f6498fa38dc1452233f34973da925cccda7b4144aeaaa1`。
RPM/DEB 使用同一份未修改源码，配方默认 PG14–18。

这是原 SQL 扩展 `pg_checksums` 的改名版本，与 PGDG 的离线校验工具无关。
上游保留原 SQL 函数名，因此新旧扩展不能在同一个数据库/schema 共存。
包安装上游 `MIGRATION.md`，不声明取代 PGDG 工具，也不自动迁移数据库。

在 Linux builder 中先运行 `pig build get pg_integrity_checksums`。
缺源时只补上述归档到 `~/ext/src/`，然后：

```sh
cd ~/debbuild/pg_integrity_checksums
make PG_VERSIONS=18
```

历史验证：2.0.0 于 2026-10-28 在 Ubuntu 24.04.5 arm64 和 Rocky Linux 9.8 aarch64 / PG18.6
通过构建、安装与全部 9 项上游 SQL 回归；未运行可选 TAP。
主包含 SO、control、上游 SQL、LLVM bitcode/index；保留自动 dbgsym。
上述历史记录仅覆盖 PG18。

2026-11-03 的 2.1.0 生产构建覆盖 Debian 12/13、Ubuntu 22.04/24.04/26.04，
各自 amd64/arm64 与 PG14–18，共 50 个主包和 50 个自动 dbgsym。
全部通过安装、CREATE EXTENSION、物理/逻辑校验最小功能、LLVM bitcode 和
build-id/DWARF 配对检查；固定样例的逻辑校验值在这 50 个坐标一致。
该批没有重新运行完整上游 SQL 回归或可选 TAP，也未导入或发布生产仓库。

2026-11-10 的 2.2.0 构建再次覆盖上述十平台与 PG14–18，50 个主包和
50 个自动 dbgsym 全部通过 QA 并取回本地 `apt/<codename>/pgxn-20261110/`。
逐组合验证安装、CREATE EXTENSION、FNV32/FNV64 固定向量、bigint 转换、
串并行及行顺序一致性、索引校验、变更检测和上游 2.1.0 → 2.2.0 升级 SQL。
主包 LLVM bitcode/index、自动 dbgsym 的 build-id/DWARF 及取回包的 SHA-256 均通过检查。
同批 RPM 六平台也已通过；完整日志和来源记录位于
`/Users/vonng/pgsty/artifacts/pgxn-build-20261110/`。
这是安装与基本功能 QA，未执行完整上游 SQL 回归或可选 TAP，未导入或发布生产仓库。
