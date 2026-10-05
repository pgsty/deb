# U26A vcpkg get-vars preparation

Ubuntu 26.04 arm64 builds using vcpkg commit
`cd61e1e26a038e82d6550a3ebbe0fbbfe7da78e3` failed twice while
`z_vcpkg_get_cmake_vars` started its child CMake process:

```text
Current working directory cannot be established.
```

Before building `pg_stat_ch` on U26A, bootstrap or check out that exact vcpkg
commit, then run:

```bash
debbuild/pg_stat_ch/tools/apply-vcpkg-u26a-cwd-fix.sh \
  "$HOME/.cache/pg_stat_ch/vcpkg-cd61e1e26a038e82d6550a3ebbe0fbbfe7da78e3" \
  u26a
```

The helper refuses another platform, commit, or input-file hash. It is kept out
of `debbuild/pg_stat_ch/patches/` because those patches apply to the extension
source, while this patch applies to the task's external vcpkg checkout.

The observed facts are limited to the child CMake cwd failure and the successful
U26A build after using a stable parent working directory with explicit `-B`
output directories. Replacement of a short-lived directory is a working
hypothesis, not a confirmed filesystem root cause. The workaround has not been
validated on U26 amd64 and must not be applied there by inference.
