PG_MAJOR ?= 18

ifeq ($(PG_MAJOR),18)
IVORY_MAJOR ?= 5
IVORY_VERSION ?= 5.4
else
$(error ivorysql-contrib supports PG_MAJOR=18 for now)
endif

PKG_REV ?= 2PIGSTY
PACKAGE ?= ivorysql-$(PG_MAJOR)-contrib
TARBALL := $(PACKAGE)-$(IVORY_VERSION)-sources.tar.gz

SOURCE_DIR ?= ../SOURCES
SOURCE_TARBALL ?= $(SOURCE_DIR)/$(TARBALL)
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
