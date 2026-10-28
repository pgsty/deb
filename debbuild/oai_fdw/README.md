# oai_fdw 1.16.0

上游：<https://github.com/jimjonesbr/oai_fdw>，tag `v1.16`。
发行包版本为 1.16.0，SQL/control 版本为 1.16。
归档 `oai_fdw-1.16.0.tar.gz`，SHA-256
`5ef6b4d97f3f3a86586bf0ccaf0f2fbc99eb0adbc1be8b67ba63b98be57ceefb`。
RPM/DEB 使用同一份未修改源码，配方默认 PG14–18。

构建依赖 libcurl、libxml2 的开发包；运行依赖由共享库链接自动生成。
无需 preload。主包安装全部上游 base/upgrade SQL 和 LLVM bitcode/index，
调试信息由自动 dbgsym 包保存，文档安装在扩展自己的目录。

在 Linux builder 中先运行 `pig build get oai_fdw`。
缺源时只补上述归档到 `~/ext/src/`，然后：

```sh
cd ~/debbuild/oai_fdw
make PG_VERSIONS=18
```

2026-10-28 在 Ubuntu 24.04.5 arm64 和 Rocky Linux 9.8 aarch64 / PG18.6
通过构建、安装与全部 5 项默认上游回归，包括 SQL 升级路径。
未运行依赖外部 OAI-PMH 服务、代理或压力测试的可选用例；
其他 PG 版本尚未执行二进制构建或运行验收。
