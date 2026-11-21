# pg_tre 4.6.5 验证记录

日期：2026-11-21。`ssh m3`，`pgsty/u24:build` / `pgminor-nr-u24`，Ubuntu 24.04.5 noble，amd64。
已验证 PG：17、18、19。以下结论仅覆盖该代表平台，其他生产平台仍须逐坐标验收。

## 版本与来源

- 源码：`pg_tre-4.6.5.tar.gz`。
- 来源：https://api.pgxn.org/dist/pg_tre/4.6.5/pg_tre-4.6.5.zip
- 归档方式：PGXN zip normalized using GNU tar。
- SHA256：`71c484a37d067d217710edb088bb934aa907900ba83403605885aefdd70b236a`。

- 4.6.4 → 4.6.5，正式目标为 PG17–19。
- PG19 的常规 PGXS quiet installcheck 与上游预期文件输出模式不同，初跑 2/63 原样匹配；改用源码自带 scripts/run-regress.sh 后两侧各 68/68 通过。所有 expected 文件哈希在测试前后保持不变。
- 全部支持版本建立 TRE 索引并断言正则查询结果。

## 补丁审查

- 必要性：上游仍为 vendored TRE 与 Lime 硬编码编译参数，需传递发行版优化、加固和 -g 参数。
- 最小性：仅两处构建参数替换，按 4.6.5 上下文重定位；不改 TRE 算法。
- 充分性与边界：两个代表平台的全部目标 PG 均通过构建、DWARF 和 payload 检查，PG19 上游测试 68/68。
- 命名：pg_tre-4.6.5-build-flags.patch；删除被替代的 pg-tre-4.6.2-build-flags.patch。

## 包验收

- 3 个构建组合全部通过，检查 6 个主包与调试子包。
- 原生 ELF 与对应 debug 文件 build-id 一致，DWARF 非空。
- 每个主包均带匹配的 dbgsym；实际 bitcode/index 完整，没有共享 postgresql-doc-* README 冲突。
- 取源先执行 pig build get；只复制本轮缺失且校验过的具体归档。LLVM 全程启用。
- 构建输入 SHA256 与提交前配方一致；源码和补丁均保留可追溯校验值。

## 证据与复现

本轮原始证据目录：`/Users/vonng/pgsty/artifacts/nonrust-final-bumps-20261121`。

- PG17：`builds/deb-pg_tre-pg17.json` 与同名 `.qa.json`；运行收据 `runtime/deb-pg17.json`。
- PG18：`builds/deb-pg_tre-pg18.json` 与同名 `.qa.json`；运行收据 `runtime/deb-pg18.json`。
- PG19：`builds/deb-pg_tre-pg19.json` 与同名 `.qa.json`；运行收据 `runtime/deb-pg19.json`。
- 回归复验：`runtime/*-followup.json`；原始差异及上游脚本输出：`runtime/*-regression-evidence.tar.gz`。
- 编排脚本：`run_builds.py`、`run_regresql_final.py`、`run_runtime.py`、`run_runtime_followup.py`。
- 原始首次失败收据保留；最终判定以复验和逐项审查为准，不以整份首次运行收据状态替代扩展结论。

生产矩阵构建、制品入库、签名、同步与公开发布未由此验证记录宣告完成。
