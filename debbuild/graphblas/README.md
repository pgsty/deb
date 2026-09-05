# GraphBLAS and LAGraph builds

GraphBLAS 10.5.0 and LAGraph 1.2.2 require CMake 3.23 or newer. Ubuntu
22.04 (Jammy) provides the dpkg-managed CMake 3.22.1, so its system package
cannot satisfy that build dependency.

Do not upgrade or replace Jammy's `/usr/bin/cmake`. The shared
`debbuild/kitware-cmake` helper installs Kitware's official CMake 3.31.12
binary release into a private per-user cache (the builder user is `root`):

```text
/root/.cache/pgsty/cmake-3.31.12/bin/cmake
```

The helper selects the native Linux x86_64 or aarch64 archive and verifies a
fixed upstream SHA-256 before extraction:

```text
0dc2e9a6860f06bf10bd8fadc03e35d9eeb4df46e33763a7e480e987758f385c  cmake-3.31.12-linux-x86_64.tar.gz
83f8fd91d2038a56556e1400390fcfe42f79602940c494f6c6f1cdae7f9e7f40  cmake-3.31.12-linux-aarch64.tar.gz
```

Both archives come from `https://cmake.org/files/v3.31/`. The recipe passes
the private executable explicitly through `CMAKE`; it does not change the
global `PATH`, system alternatives, or dpkg state.

The outer Makefile decides whether the system dependency is usable from the
dpkg-managed `cmake` package version, not from whichever `cmake` happens to be
first on `PATH`. On releases with CMake 3.23 or newer, the recipe runs the
normal complete `dpkg-checkbuilddeps` check and `dpkg-buildpackage` path.

When the dpkg-managed CMake is older than 3.23 (currently Jammy), the helper
first verifies private CMake 3.31.12. The recipe then runs
`dpkg-checkbuilddeps` against every declared build dependency except the
already-satisfied CMake constraint. Only after that succeeds does it invoke
`dpkg-buildpackage -d`, with the private executable passed through `CMAKE`.
This is a narrow exception for an externally supplied build tool, not a general
dependency bypass. New missing dependencies must be fixed rather than added to
the exception.

Jammy provides the required `pkg-config` command through the `pkg-config`
package but has no `pkgconf` binary package candidate. These recipes therefore
declare `pkg-config`, which is also available on newer supported releases.

Build GraphBLAS first, install `libgraphblas10` and `libgraphblas-dev` into the
builder, then build LAGraph. Preserve the automatic dbgsym packages. Validate
the runtime shared libraries, Build ID to dbgsym mapping, `.debug_info`, and a
compiled GraphBLAS/LAGraph smoke program before collection.

The Jammy repair retained Debian revision `-1PGSTY`: there was no earlier
GraphBLAS 10.5.0 or LAGraph 1.2.2 Jammy artifact in `apt/jammy`, and the change
only selects the required external build tool and correct build-dependency
package name; it does not change the binary package names, ABI, install
payload, or build flags. If a published artifact at the same upstream version
needs a packaging or payload replacement, increment the Debian revision before
rebuilding.
