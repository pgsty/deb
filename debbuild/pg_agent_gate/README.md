# pg_agent_gate 0.4.1

- 上游：<https://github.com/Manuelreyesbravo/pg_agent_gate>，tag `v0.4.1`。
- 源码归档：`pg_agent_gate-0.4.1.tar.gz`。
- SHA-256：`fae0bff41e71f5f6462745477800c334a7cbf043953aaf862de81dd42076ec36`。
- 本配方仅支持 PG18，RPM 与 DEB 使用相同源码和补丁。

上游固定 pgrx 0.19.2，且没有 Cargo.lock。打包补丁将其对齐 builder 的
0.19.3，并提供固定 Cargo.lock；先 locked fetch，再离线打包并核对
lockfile 没有变化。构建显式指定 `--no-default-features --features pg18`，
不启用上游默认的 pg19。保留 Rust release DWARF 与自动 dbgsym。

在 Linux builder 中先 `pig build get pg_agent_gate`。目录尚未更新时，
只将缺失的上述归档放入 builder 的 `~/ext/src/`，再执行：

```sh
pig build pgrx -v 0.19.3 --pg 18
cd ~/debbuild/pg_agent_gate
make PG_VERSIONS=18
```

安装生成的 base SQL 和上游提供的升级 SQL。包不修改服务器配置。
代理角色首次执行 SQL 前需要通过 shared preload 或角色级 session preload
加载扩展；推荐按上游说明配置 `shared_preload_libraries='pg_agent_gate'`。
可选的绑定断言使用 `pg_living_assertions`，没有将其设为强制依赖。

安装验收使用独立临时 PG18 集群运行上游 `tests/approvals.sh`，验证审批前
拒绝执行、授权审批后提交、未授权审批被拒绝，以及审批后仍执行 max_rows 限制。
历史 0.3.0 验证：2026-10-28 在 Rocky Linux 9.8 aarch64 和 Ubuntu 24.04.5 arm64 / PG18.6
通过构建、安装与上述全部 7 项检查；主包与所有调试包的 DWARF/build-id 检查通过。
未运行可选 pg_living_assertions 集成。产物与完整证据位于
`/Users/vonng/tmp/pgxn-packaging-20261028-hassp03o/`。

2026-11-03 的 0.4.1 生产构建覆盖 bookworm、trixie、jammy、noble、resolute
的 amd64/arm64，均仅构建 PG18。十个平台共生成 10 个主包及 10 个自动
`-dbgsym` 包，已检查安装文件、依赖、DWARF/build-id，并在一次性集群中
通过上游 `tests/membership.sh` 和 `tests/approvals.sh`。Rust 使用 1.99.0，
pgrx 使用 0.19.3，patched Cargo.lock SHA-256 为
`ccbe57aff80dc03cee019ef6dd7bb4e5cbccb9dc34c62c6e27b7589c240c8cdd`。
部分 builder 镜像缺少已声明的 `libicu-dev`，构建前需安装；配方在 Rust
编译前执行 `dpkg-checkbuilddeps`。仅收集到本仓库 `apt/`，尚未发布。
