# hdr_histogram 1.0.0

PGXS C 扩展，支持 PostgreSQL 14–18。包版本为 `1.0.0`，上游 SQL/control
版本为 `1.0`；包含 HdrHistogram_c 0.11.10，依赖 zlib，无需 preload。

## 源码

- 上游：<https://github.com/vovcke/pg_hdr_histogram>
- 正式资产：<https://github.com/vovcke/pg_hdr_histogram/releases/download/v1.0.0/hdr_histogram-1.0.0.tar.gz>
- 权威归档：`~/pgsty/repo/ext/src/hdr_histogram-1.0.0.tar.gz`
- SHA256：`835c50c059ca18da397e66121701dce9148ae96de6815fdbe343bdf47796eb00`
- 归档根目录：`hdr_histogram-1.0.0`；无需重打包或源码补丁。
- 许可证：MIT（扩展）和 CC0-1.0（内嵌 HdrHistogram_c）。

## 构建

在 builder 的 `~/debbuild` 内先执行 `pig build get hdr_histogram`；若镜像尚无
归档，仅将上述文件复制到 `~/ext/src/`，保持 `SOURCES -> ~/ext/src`。
然后运行 `cd hdr_histogram && make`，主包和自动 dbgsym 输出到 `~/ext/pkg/`。
默认覆盖 `debian/pgversions` 的 PG14–18，必须有相应 server-dev 和 zlib1g-dev。

2026-10-23 验证：`pgsty/u24a:build`（Ubuntu 24.04.5 noble arm64）以及对应
RPM `pgsty/el9a:build`（Rocky 9.8 aarch64）均通过 PG14–18 构建、安装、
`CREATE EXTENSION` 和上游 `make installcheck`。DEB 各 PG 有主包与非空 dbgsym，
无共享 PostgreSQL README 路径冲突；RPM 各 PG 有主包、debuginfo 和 debugsource，
启用 LLVM 的 bitcode/index 在主包。此记录是指定平台试包结论，不代表生产发布。

## 运行边界

额外测试通过文本及 binary COPY roundtrip、不同范围/精度的合并、实际两个
worker 的并行 hdr_add/hdr_merge，并核对与串行聚合的序列化结果相同。

- `strict` 拒绝参数不同的直方图。
- 默认 `lossless` 要求当前累加器覆盖输入；窄范围先出现会拒绝，宽范围先出现可接收。
- `left` 会静默丢弃超出累加器范围的样本，本轮测试确认两个输入仅保留一个。
- `union` 保留全部样本，并采用最宽范围和最高精度。

本轮未验证独立 Java/Python 实现的格式互通、长期负载或生产安全成熟度。
完整日志和试包见 `/Users/vonng/tmp/new-extensions-20261023/histogram/report.md`。
