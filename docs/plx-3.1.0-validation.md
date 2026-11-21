# plx 3.1.0 验证记录

日期：2026-11-21。`ssh m3`，`pgsty/u24:build` / `pgminor-nr-u24`，Ubuntu 24.04.5 noble，amd64。
已验证 PG：15、16、17、18、19。以下结论仅覆盖该代表平台，其他生产平台仍须逐坐标验收。

## 版本与来源

- 源码：`plx-3.1.0.tar.gz`。
- 来源：https://codeload.github.com/commandprompt/plx/tar.gz/refs/tags/v3.1.0
- 归档方式：official upstream tar.gz。
- SHA256：`5a85f9d8be948a7e32bff6f68495a4b597965b45c180f289ba82e22455c937e6`。

- 2.0.1 → 3.1.0；3.1.0 正式 release 发布于 2026-11-21T01:25:31Z，覆盖先前发现的 3.0.0。
- 两侧PG15原始installcheck为26/26；PG19为25/26，plxlua测试唯一差异是 SET standard_conforming_strings = off 新增 ERROR: non-standard string literals are not supported。后续函数输出相同，不改包内源码或预期文件来隐藏差异。
- 两侧PG15/19的make upgradecheck均通过；上游SQL包含2.0.0→3.0.0→3.1.0升级链。全部支持版本的Lua、C#函数结果断言通过。

## 补丁审查

- 必要性：无额外补丁。
- 最小性：仅更新正式版本、来源和 Lua/C# 描述；忠实安装上游 SQL。
- 充分性与边界：两侧 PG15–19 功能冒烟；PG15 回归26/26，PG19回归25/26，唯一预期输出差异已逐行审查；PG15/19升级测试通过。
- 命名：无新增补丁。

## 包验收

- 5 个构建组合全部通过，检查 10 个主包与调试子包。
- 原生 ELF 与对应 debug 文件 build-id 一致，DWARF 非空。
- 每个主包均带匹配的 dbgsym；实际 bitcode/index 完整，没有共享 postgresql-doc-* README 冲突。
- 取源先执行 pig build get；只复制本轮缺失且校验过的具体归档。LLVM 全程启用。
- 构建输入 SHA256 与提交前配方一致；源码和补丁均保留可追溯校验值。

## 证据与复现

本轮原始证据目录：`/Users/vonng/pgsty/artifacts/nonrust-final-bumps-20261121`。

- PG15：`builds/deb-plx-pg15.json` 与同名 `.qa.json`；运行收据 `runtime/deb-pg15.json`。
- PG16：`builds/deb-plx-pg16.json` 与同名 `.qa.json`；运行收据 `runtime/deb-pg16.json`。
- PG17：`builds/deb-plx-pg17.json` 与同名 `.qa.json`；运行收据 `runtime/deb-pg17.json`。
- PG18：`builds/deb-plx-pg18.json` 与同名 `.qa.json`；运行收据 `runtime/deb-pg18.json`。
- PG19：`builds/deb-plx-pg19.json` 与同名 `.qa.json`；运行收据 `runtime/deb-pg19.json`。
- 回归复验：`runtime/*-followup.json`；原始差异及上游脚本输出：`runtime/*-regression-evidence.tar.gz`。
- 编排脚本：`run_builds.py`、`run_regresql_final.py`、`run_runtime.py`、`run_runtime_followup.py`。
- 原始首次失败收据保留；最终判定以复验和逐项审查为准，不以整份首次运行收据状态替代扩展结论。

生产矩阵构建、制品入库、签名、同步与公开发布未由此验证记录宣告完成。
