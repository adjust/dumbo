#http://blog.pgxn.org/post/4783001135/extension-makefiles pg makefiles
EXTENSION = dumbo_sample
PG_CONFIG ?= pg_config
DATA = $(wildcard *--*.sql)

MODULE_big = dumbo_sample
OBJS = src/dumbo_sample.o

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
