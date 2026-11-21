# pg_vectorsearch 0.2.0 验证记录

日期：2026-11-21。`ssh m3`，`pgsty/u24:build` / `pgminor-nr-u24`，Ubuntu 24.04.5 noble，amd64。
已验证 PG：18、19。以下结论仅覆盖该代表平台，其他生产平台仍须逐坐标验收。

## 版本与来源

- 源码：`pg_vectorsearch-0.2.0.tar.gz`。
- 来源：https://github.com/timescale/pg_vectorsearch/releases/download/v0.2.0/pg_vectorsearch-0.2.0.tar.gz
- 归档方式：official upstream tar.gz。
- SHA256：`1e785bef41f4a607acb7538f35b37e786b42c697f56831d51fecc6510cfdc474`。

- 0.1.0 → 0.2.0；上游库名改为 pg_vectorsearch.so，RPM payload与两侧bitcode模块名同步调整；保留上游0.1.0→0.2.0 SQL。
- 上游0.2.0变更PRISM索引格式，已有索引须按上游要求重建；本次没有自创数据迁移或SQL升级脚本。
- 两侧PG18/19的vec32、vec16、distance、prism四项核心回归通过。prism需要源码构建出来的pgvs_test_helpers.so：仅测试时安装，结束后恢复原状态；该测试库不进入正式包。未声称覆盖上游全部测试。
- 全部支持版本创建PRISM索引并执行ANN查询结果数量断言。

## 补丁审查

- 必要性：保留无用 RUNPATH 去除、Clang15 原子函数指针初值与 LLVM15 bitcode IFUNC 兼容修复。
- 最小性：仅重定位既有三份补丁；IFUNC限制仅由LLVM15 bitcode生成步骤启用，保留原生SIMD。
- 充分性与边界：两侧PG18/19构建、debug与4项核心回归通过；LLVM15专用分支本轮未实跑，结论限静态审查和旧补丁语义比较。
- 命名：pg_vectorsearch-0.2.0-{rpath,clang15-atomics,llvm15-ifunc}.patch；两侧字节一致，无offset/fuzz。

## 包验收

- 2 个构建组合全部通过，检查 4 个主包与调试子包。
- 原生 ELF 与对应 debug 文件 build-id 一致，DWARF 非空。
- 每个主包均带匹配的 dbgsym；实际 bitcode/index 完整，没有共享 postgresql-doc-* README 冲突。
- 取源先执行 pig build get；只复制本轮缺失且校验过的具体归档。LLVM 全程启用。
- 构建输入 SHA256 与提交前配方一致；源码和补丁均保留可追溯校验值。

## 证据与复现

本轮原始证据目录：`/Users/vonng/pgsty/artifacts/nonrust-final-bumps-20261121`。

- PG18：`builds/deb-pg_vectorsearch-pg18.json` 与同名 `.qa.json`；运行收据 `runtime/deb-pg18.json`。
- PG19：`builds/deb-pg_vectorsearch-pg19.json` 与同名 `.qa.json`；运行收据 `runtime/deb-pg19.json`。
- 回归复验：`runtime/*-followup.json`；原始差异及上游脚本输出：`runtime/*-regression-evidence.tar.gz`。
- 编排脚本：`run_builds.py`、`run_regresql_final.py`、`run_runtime.py`、`run_runtime_followup.py`。
- 原始首次失败收据保留；最终判定以复验和逐项审查为准，不以整份首次运行收据状态替代扩展结论。

生产矩阵构建、制品入库、签名、同步与公开发布未由此验证记录宣告完成。
