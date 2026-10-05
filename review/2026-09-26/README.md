# 审查台账说明

[总手册](../../DEBIAN_REVIEW_2026-09-26.md)是阅读入口。全部表格记录于 2026-09-26，针对 commit `5304650ec6a3c23522fd001f2d8183452a609073` 与总手册列出的已有工作树改动。

## 表格含义

- `recipes.tsv`：368 个具有顶层 Makefile 的活动 recipe 目录。`changelog_template_version` 是 recipe 中可读取的首条模板值，可能包含占位符，也可能由 setup 重写；不是最终 DEB 版本。`pgversions_file` 是静态文件，不自动等于默认构建 PG 子集。`source_candidates` 来自 Makefile 静态展开、版本 include 补充和少数专用脚本；不是完整 transitive dependency lock。源码缺失只指本地权威目录，不代表公共镜像不存在。
- `artifacts.tsv`：2,230 个本次实际读取控制字段的现有文件。`kind` 按 Package 的 `-dbgsym` 后缀分类，不能由扩展名推断。`header_readable=True` 不等于安装或运行成功。
- `payload-samples.tsv`：126 个不同主包/归一化版本的文件列表抽查，当前均为 noble arm64 批次。`copyright_present=True` 只表示文件存在，不保证许可文本准确、完整或涵盖所有 bundled components。没有冲突候选并不代替与系统包完整求交集。
- `metadata-snapshot.tsv`：`pgext.extension` 584 条只读记录，仅选取本次核对字段。无数据库写入；没有声称所有行都与 recipe 一一映射。一个 recipe 可能提供多个 SQL 扩展，另有 PGDG 或 bundle 记录不对应独立 recipe。
- `elf-debug-samples.tsv`：5 组现有 noble arm64 主/debug ELF 对象的 Machine、build-id 与 `.debug_info` 抽查，不代表该包的全部 ELF 或全矩阵。
- `documentdb-metadata.tsv`：用于 G16 的补充只读字段，记录 available 状态和 DEB 包映射。

## recipes.tsv 扫描标记

| 标记 | 精确含义 | 不能推断的结论 |
| --- | --- | --- |
| `parallel-stage-risk` | all 同时列出 setup/build/move，未匹配 .NOTPARALLEL 或直接 build→setup | 不代表逐条依赖图均完整分析，更不代表 328 次构建已经失败 |
| `dpkg-dependency-bypass` | Makefile 包含 dpkg-buildpackage 的 -d 参数 | 工具链处于 dpkg 之外、私有 CMake 等可能是有效例外 |
| `no-control.in` | 没有本地 debian/control.in | 自定义/支持包可合法使用 control 或提取上游 packaging |
| `no-pgversions` | 没有本地 debian/pgversions | 支持库和特殊内核不一定需要此文件 |
| `source-candidate-missing` | 静态识别的归档在本地 src 目标目录缺失 | 未验证 pig build get 或公共镜像 |

未出现标记不是“全部通过”。专项报告中的动态脚本、SQL 依赖、版权、CPU 基线等问题没有被压缩到这几个规则中。

## 复核方法

本次没有保存临时源码树、构建目录、压缩归档、DEB 副本、数据库凭据或临时执行日志。保留的是面向维护者的审查报告和字段清单。后续若源码/metadata/recipe 有变化，应创建新日期快照，不能将本日期台账默认为最新状态。

根目录手册与专项报告提供来源文件行号、归档成员证据、触发条件、影响和建议验收。复现构建须先获得相应任务范围，并遵守 AGENTS.md 的 builder、取源、debug、stash 与发布规则。
