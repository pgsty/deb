# pg_integrity_checksums 2.0.0

上游：<https://github.com/VictorNagibator/pg_integrity_checksums>，tag `v2.0.0`。
归档 `pg_integrity_checksums-2.0.0.tar.gz`，SHA-256
`73297f1433538c31a2edc8953c0a024f401d3718121286fe683601a960bf8f13`。
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

2026-10-28 在 Ubuntu 24.04.5 arm64 和 Rocky Linux 9.8 aarch64 / PG18.6
通过构建、安装与全部 9 项上游 SQL 回归；未运行可选 TAP。
主包含 SO、control、上游 SQL、LLVM bitcode/index；保留自动 dbgsym。
其他 PG 版本尚未执行二进制构建或运行验收。
