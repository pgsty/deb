import json
from pathlib import Path

root = Path.cwd()
module = 'pg_vectorsearch-' + (root / 'VERSION').read_text().strip()
targets = json.loads((root / 'builddir/meson-info/intro-targets.json').read_text())
selected = [target for target in targets if target['name'] in ('vs_pg', module)]
assert len(selected) == 2, 'expected the PostgreSQL core library and extension'
sources = sorted({
    str(Path(source).resolve().relative_to(root))
    for target in selected
    for group in target['target_sources']
    for source in group.get('sources', [])
    if source.endswith('.c')
})
assert sources and all(source.startswith('src/') for source in sources)
objects = ' '.join(str(Path(source).with_suffix('.o')) for source in sources)
makefile = '''MODULE_big = {module}
OBJS = {objects}
PG_CPPFLAGS = -I$(CURDIR)/src -I$(CURDIR)/src/pg -I$(CURDIR)/builddir -DVS_DISABLE_IFUNC
PG_CPPFLAGS += -std=gnu11 -ffp-contract=fast -fassociative-math -fno-signed-zeros -fno-trapping-math
PG_CPPFLAGS += $(shell pkg-config --cflags openblas)
PG_CONFIG ?= pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
# LLVM 15 cannot thin-link x86 target_clones IFUNC summaries.
# Keep all modules and native SIMD; only JIT bitcode uses the generic clones.
ifeq ($(shell $(CLANG) -dumpversion | cut -d. -f1),15)
BITCODE_CFLAGS += -DVS_DISABLE_TARGET_CLONES
endif
.PHONY: bitcode install-bitcode
ifeq ($(with_llvm),yes)
bitcode: $(OBJS:.o=.bc)
install-bitcode: bitcode
\t$(call install_llvm_module,$(MODULE_big),$(OBJS))
else
bitcode install-bitcode:
endif
'''
(root / 'Makefile.llvm').write_text(makefile.format(module=module, objects=objects))
