# pg_synonym

官方 [v1.0.0](https://github.com/Mazuco/pg_synonym/releases/tag/v1.0.0) 的 C/PGXS 配方，
PostgreSQL License，PG15–18。包版本 `1.0.0`，control/SQL 版本 `1.0`，未打上游补丁。

源文件 `pg_synonym-1.0.0.tar.gz` 来自
<https://github.com/Mazuco/pg_synonym/archive/refs/tags/v1.0.0.tar.gz>，
SHA-256：`8d410728828d8b0d8dca1c40d525b3fbdd3f1c31f5a287c1dc415a53973f815e`。
权威本地归档在 `~/pgsty/repo/ext/src/`。

在 Ubuntu builder 中先运行 `pig build get pg_synonym`；只有取源失败时才把对应 tarball
复制到 `~/ext/src/`，确认 `~/debbuild/SOURCES` 指向该目录，再执行：

```bash
cd ~/debbuild/pg_synonym
make
```

2026-10-23 在 `pgsty/u24a:build`（Ubuntu 24.04.5 noble / arm64）完成 PG15、16、17、18：
4 个主 DEB 和 4 个非空 dbgsym ddeb，包含 LLVM bitcode/index，无共享 README 路径。
安装后每个 PG 的上游 5 项 regression 全通过，覆盖 DDL/DML、late binding、权限和 RLS。
PG17 另验证 DDL 回滚、pg_dump/pg_restore，以及恢复后的别名查询和 DDL 继续同步。
相同 PG 范围也已通过 Rocky 9.8 aarch64 RPM 构建及相同运行检查。

扩展使用 event trigger，必须由超级用户安装；不要求 preload。
别名为 security-invoker view，重建会重置手工 GRANT；不要手工改名或修改别名视图属性。
上述为代表性构建验证，不能据此认定生产成熟度或仓库发布状态。
完整记录见 RPM 仓库 `rpmbuild/SPECS/pg_synonym.md`；临时证据在
`/Users/vonng/tmp/new-extensions-20261023/cast-synonym/`。
