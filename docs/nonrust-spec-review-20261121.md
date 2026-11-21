# 非 Rust DEB 配方与补丁审查 — 2026-11-21

DEB 侧已完成 **305 个扩展/源码单元提交**，另有 1 个公共构建编排提交；文档独立提交。每个扩展的 recipe、适用补丁及本扩展 target 在同一提交。

完整逐项审查、必要性/充分性/最小性判断与两仓库逐扩展提交表见 [共享审查报告](/Users/vonng/pgsty/rpm/doc/nonrust-spec-review-20261121.md)。[交互式 HTML](/Users/vonng/pgsty/artifacts/nonrust-pg19-20261121/review-commits/nonrust-spec-review-20261121.html) 提供补丁筛选、提交搜索与构建证据。

本侧主要修正：mongo_fdw 保持 legacy Extended JSON 语义，ulak 收窄为必要的 hiredis 兼容，pgactive 补全运行时 PG security minor 下限；撤出 pg_datasentinel、pg_failover_slots、pg_variables 未通过功能验收的 PG19 候选，继续保留 pg_variables composite datum 安全修复与原支持范围。归档 307 个本轮生成 control，保留 control.in 真源及已有跟踪 control。

305 个配方的 Makefile/control 静态解析通过。m3 上 Ubuntu 24.04.5 noble / amd64 / `pgsty/u24:build` 完成 8 次新构建及 payload/dbgsym 检查：mongo_fdw PG18/19、pg_datasentinel PG18、pg_failover_slots PG18、pg_variables PG18、ulak PG19、pgactive PG18/19。后者实际 Depends 包含 `postgresql-18 (>= 18.7)`、`postgresql-19 (>= 19.0)`。

旧有功能失败与未测路径保留；本轮构建结果不代表整个 PG15–19 或十平台矩阵完成。Rust 冻结，大型/内核组件后置。PGEXT 先前授权更新有独立回执，本轮未再次修改。未执行生产 stash、APT 导入、签名、CDN 发布或 push。

用户两份旧 pg_uint128 1.2.0 大补丁保留未提交；新的 1.3.0 配方不引用它们。
