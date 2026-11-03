# pg_integrity_checksums 2.1.0

上游：<https://github.com/VictorNagibator/pg_integrity_checksums>，tag `v2.1.0`。
归档 `pg_integrity_checksums-2.1.0.tar.gz`，SHA-256
`33b3798123f71eda7fd48238145b650ae1c87139c5f12bec2d6fe59dbaa779c0`。
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
本次没有重新运行完整上游 SQL 回归或可选 TAP，也未导入或发布生产仓库。
