PG_MAJOR ?= 18

ifeq ($(PG_MAJOR),18)
PG_VERSION ?= 18.4
else ifeq ($(PG_MAJOR),17)
PG_VERSION ?= 17.10
else ifeq ($(PG_MAJOR),16)
PG_VERSION ?= 16.14
else ifeq ($(PG_MAJOR),15)
PG_VERSION ?= 15.18
else
$(error pgedge supports PG_MAJOR=15, 16, 17, or 18)
endif

SPOCK_VERSION ?= 5.0.10
SNOWFLAKE_VERSION ?= 2.5.0
LOLOR_VERSION ?= 1.2.2

PKG_REV ?= 1PIGSTY

SOURCE_DIR ?= ../SOURCES
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
