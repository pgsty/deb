# pg_try_cast

官方 [v1.0.0](https://github.com/Mazuco/pg_try_cast/releases/tag/v1.0.0) 的 C/PGXS 配方，
PostgreSQL License，PG16–18。包版本 `1.0.0`，control/SQL 版本 `1.0`，未打上游补丁。

源文件 `pg_try_cast-1.0.0.tar.gz` 来自
<https://github.com/Mazuco/pg_try_cast/archive/refs/tags/v1.0.0.tar.gz>，
SHA-256：`dc901d8d98c4c49c9fb45c0278b95ab7ae088a5b534714750d037067acad9971`。
权威本地归档在 `~/pgsty/repo/ext/src/`。

在 Ubuntu builder 中先运行 `pig build get pg_try_cast`；只有取源失败时才把对应 tarball
复制到 `~/ext/src/`，确认 `~/debbuild/SOURCES` 指向该目录，再执行：

```bash
cd ~/debbuild/pg_try_cast
make
```

2026-10-23 在 `pgsty/u24a:build`（Ubuntu 24.04.5 noble / arm64）完成 PG16、17、18：
3 个主 DEB 和 3 个非空 dbgsym ddeb，包含 LLVM bitcode/index，无共享 README 路径。
安装后每个 PG 的上游 3 项 regression 全通过，覆盖 domain、typmod 和多种类型。
PG17 另验证 hstore 有效/无效输入；`try_cast('###', NULL::regtype)` 按上游限制仍抛 42601。
相同 PG 范围也已通过 Rocky 9.8 aarch64 RPM 构建及上游回归。

需要 soft-error 支持的类型输入函数；不能保证第三方类型的错误都能返回 NULL。
扩展为 trusted，不要求 preload。上述为代表性构建验证，不能据此认定生产成熟度或仓库发布状态。
完整记录见 RPM 仓库 `rpmbuild/SPECS/pg_try_cast.md`；临时证据在
`/Users/vonng/tmp/new-extensions-20261023/cast-synonym/`。
