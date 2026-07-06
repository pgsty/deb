PG_MAJOR ?= 18

ifeq ($(PG_MAJOR),18)
PG_VERSION ?= 18.4
IVORY_MAJOR ?= 5
IVORY_VERSION ?= 5.4
else
$(error ivorysql supports PG_MAJOR=18 for now)
endif

PKG_REV ?= 1PIGSTY
PACKAGE ?= ivorysql-$(PG_MAJOR)
TARBALL := ivorysql-$(IVORY_VERSION).tar.gz

SOURCE_DIR ?= ../SOURCES
SOURCE_TARBALL ?= $(SOURCE_DIR)/$(TARBALL)
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
