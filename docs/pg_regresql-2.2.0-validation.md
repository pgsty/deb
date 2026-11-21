# pg_regresql 2.2.0 验证记录

日期：2026-11-21。`ssh m3`，`pgsty/u24:build` / `pgminor-nr-u24`，Ubuntu 24.04.5 noble，amd64。
已验证 PG：15、16、17、18。以下结论仅覆盖该代表平台，其他生产平台仍须逐坐标验收。

## 版本与来源

- 源码：`pg_regresql-2.2.0.tar.gz`。
- 来源：https://api.pgxn.org/dist/pg_regresql/2.2.0/pg_regresql-2.2.0.zip
- 归档方式：PGXN zip normalized using GNU tar。
- SHA256：`8b15ec17c30e02ae454da341267b610b9afa05a2e4121ec0f30ab7460cb1d987`。

- 2.1.0 → 2.2.0；包/release为2.2.0，control default_version为2.2，保留上游区别。
- 新增restore目录包含PostgreSQL许可的stats回移源码；RPM License为BSD-2-Clause AND PostgreSQL，LICENSE和restore/README.md随包；DEB使用分文件DEP5许可声明。
- 全部支持版本LOAD、修改catalog stats后校验EXPLAIN的Plan Rows；PG16/17额外断言extended stats restore写入catalog。未声称完成所有上游回归。
- PG19仅在builder副本绕过配方guard探测；两侧首个真实错误均为 pg_regresql.c:31:8: error: unknown type name get_relation_info_hook_type。源码依赖PG19移除的planner hook，暂不实施复杂行为迁移；正式配方与目标均为PG15–18。

## 补丁审查

- 必要性：删除 pg_regresql-2.0.0.patch；上游 Makefile 已包含 .DEFAULT_GOAL := all。
- 最小性：不添加PG19伪兼容层；仅补许可证、LLVM工具路径和15–18目标。
- 充分性与边界：两侧PG15–18构建及stats/planner冒烟通过；PG16/17 extended stats restore通过。PG19缺get_relation_info_hook_type，复杂迁移暂缓。
- 命名：没有新增补丁，删除失效的旧默认目标补丁。

## 包验收

- 4 个构建组合全部通过，检查 8 个主包与调试子包。
- 原生 ELF 与对应 debug 文件 build-id 一致，DWARF 非空。
- 每个主包均带匹配的 dbgsym；实际 bitcode/index 完整，没有共享 postgresql-doc-* README 冲突。
- 取源先执行 pig build get；只复制本轮缺失且校验过的具体归档。LLVM 全程启用。
- 构建输入 SHA256 与提交前配方一致；源码和补丁均保留可追溯校验值。

## 证据与复现

本轮原始证据目录：`/Users/vonng/pgsty/artifacts/nonrust-final-bumps-20261121`。

- PG15：`builds/deb-pg_regresql-pg15.json` 与同名 `.qa.json`；运行收据 `runtime/deb-pg15.json`。
- PG16：`builds/deb-pg_regresql-pg16.json` 与同名 `.qa.json`；运行收据 `runtime/deb-pg16.json`。
- PG17：`builds/deb-pg_regresql-pg17.json` 与同名 `.qa.json`；运行收据 `runtime/deb-pg17.json`。
- PG18：`builds/deb-pg_regresql-pg18.json` 与同名 `.qa.json`；运行收据 `runtime/deb-pg18.json`。
- 回归复验：`runtime/*-followup.json`；原始差异及上游脚本输出：`runtime/*-regression-evidence.tar.gz`。
- 编排脚本：`run_builds.py`、`run_regresql_final.py`、`run_runtime.py`、`run_runtime_followup.py`。
- 原始首次失败收据保留；最终判定以复验和逐项审查为准，不以整份首次运行收据状态替代扩展结论。

生产矩阵构建、制品入库、签名、同步与公开发布未由此验证记录宣告完成。
