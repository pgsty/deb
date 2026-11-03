# PostgreSQL Anonymizer 3.3.2

源码归档为 `postgresql_anonymizer-3.3.2.tar.gz`，SHA-256：
`cfeb2d3dd4db981d58a7f5062665a8e52b7225cf45dabbccd435110f8f6f43da`。
本配方支持 PostgreSQL 14–18，使用上游 pgrx 0.19.3。

归档中的 Cargo.toml 已为 3.3.2，但根 Cargo.lock 条目仍为 3.3.1。
`patches/pg-anon-3.3.2-lock-version.patch` 仅修正该根版本，未调整依赖版本；
应用后的锁文件 SHA-256 为
`2a30c53c32de09d29aed744677dab082396ff6c91c27664fbe32d3b1117b0e42`。
构建先执行 `cargo fetch --locked`，再离线打包，前后核对锁文件校验值。

在 builder 中先执行 `pig build get pg_anon`；缺少本版本归档时，仅复制上述
具体文件到 `~/ext/src/`。安装 `debian/control.in` 声明的构建依赖，以及
cargo-pgrx 0.19.3 后执行 `make`。配方在 Rust 编译之前检查 dpkg 构建依赖，
保留 release DWARF，由 debhelper 自动拆分 `-dbgsym`。

`anon.init()` 从 `extension/anon/` 直接读取默认 CSV。打包时保留全部 24 个
上游 CSV 的相对路径，并将 `en_US/fake/` 下的默认数据另外复制到该根目录；
仅保留 locale 子目录会使默认初始化缺少数据。静态脱敏测试应由普通表所有者
执行，遵守上游默认的 `anon.nosuperuser` 限制。

2026-11-03 已在 bookworm、trixie、jammy、noble、resolute 的原生 amd64/arm64
builder 中完成 PG14–18 全矩阵：50 个主包、50 个 dbgsym 包。每个包均核对
文件与依赖、CSV 原始字节、DWARF/build-id；每个 PG 组合均通过安装、预加载、
CREATE EXTENSION、anon.init()、假数据查询和普通表所有者静态脱敏检查。
产物仅收集到本仓库 `apt/`，尚未导入或发布。
