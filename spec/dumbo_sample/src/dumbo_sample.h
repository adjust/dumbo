#ifndef _DUMBO_SAMPLE_H
#define _DUMBO_SAMPLE_H

#include "postgres.h"
#include "fmgr.h"

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

PG_FUNCTION_INFO_V1(elephant_in);
PG_FUNCTION_INFO_V1(elephant_out);

Datum elephant_in(PG_FUNCTION_ARGS);
Datum elephant_out(PG_FUNCTION_ARGS);

#endif
