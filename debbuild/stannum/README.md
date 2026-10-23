# stannum 打包说明

本 recipe 打包上游尚未正式发布的 0.1.0 开发源码，固定提交记录在 changelog 正文。
RPM 版本为 `0.1.0-1PGSTY`，DEB 版本为 `0.1.0-1PGSTY~<codename>`，
PostgreSQL 扩展版本为 `0.1.0`。包版本不附加提交日期或 hash。

- 上游：[TeamSpringbird/stannum](https://github.com/TeamSpringbird/stannum)。
- 源码：`stannum-0.1.0.tar.gz`，直接使用固定提交的官方 tar.gz，无 repack、无源码补丁。
- SHA-256：`9e113b4b6028f2ad748cbd8b97ee2592275a102c1ed79c9e0219061fa0772f9d`。
- License：AGPL-3.0-or-later。
- PostgreSQL：17、18；默认构建两个版本，可用 `make PG_VERSIONS=17` 选择一个版本。
- 工具链：上游 `rust-toolchain.toml` 固定 Rust 1.96.0，cargo-pgrx/pgrx 固定 0.19.1。

源码归档保存在 `~/pgsty/repo/ext/src/`；builder 通过
`~/debbuild/SOURCES -> ~/ext/src` 使用该文件。先在 builder 运行
`pig build get stannum`；如果源码镜像尚无此归档，只复制上述具体 tarball 到
builder 的 `~/ext/src/`，不批量同步源码目录。

```bash
# In the Ubuntu/Debian builder, after installing control.in Build-Depends:
rustup toolchain install 1.96.0 --profile minimal
cargo +1.96.0 install cargo-pgrx --version 0.19.1 --locked
cd ~/debbuild/stannum
make
```

Rust/cargo-pgrx 由 rustup/cargo 提供，普通系统构建依赖仍由
`dpkg-buildpackage` 检查，不跳过依赖校验。recipe 使用 `cargo fetch --locked`，
随后离线打包并检查 `Cargo.lock` 未改变。GitHub 请求遵守仓库代理规则。
主包安装 SO、control 和上游生成的 SQL；Rust release 保留 DWARF，由
`dh_strip` 自动生成 `-dbgsym`。纯 Rust/pgrx 流程不生成 PGXS bitcode/index。
文档只安装到包私有目录。

`tin` 与 `stannum` 的全局 `==>` 运算符冲突，不可在同一数据库同时安装。
正常主库查询可按需加载；可选 `shared_preload_libraries='stannum'` 启用维护
worker，备库索引读取要求主备双方预加载。没有包装层自行实现的升级 SQL。

2026-10-23 已在 `pgsty/el9a:build`（Rocky Linux 9.8/aarch64）和
`pgsty/u24a:build`（Ubuntu 24.04.5 noble/arm64）验证 PG17.11、PG18.6：

- 从生成的 RPM/DEB 安装，检查主包、RPM debuginfo/debugsource、DEB dbgsym。
- `CREATE EXTENSION`、EXPLAIN 实际索引路径、词项/布尔/短语查询、BM25 排名、高亮。
- INSERT/UPDATE/DELETE、ROLLBACK、VACUUM、`verify_index`、REINDEX、重启后查询。
- 可选 preload，以及上游 `extension_upgrade.py` 的 schema/bootstrap 检查和
  `maintenance_workers.py background manual settings`。
- 测试后恢复安装 SQL，并验证库、control、SQL 的 SHA-256 不变。

Ubuntu builder 默认排除文档，验收安装使用
`dpkg --path-include='/usr/share/doc/*' -i ...` 保留完整候选 payload。
本次是上述两个 ARM64 平台的试构建与 QA，不代表其他生产平台或发布完成；
完整崩溃/并发 fuzz、备库恢复和性能测试不在本轮 QA 范围。
