#include "dumbo_sample.h"

Datum elephant_in(PG_FUNCTION_ARGS)
{
  int *result = palloc0(sizeof(int));
  PG_RETURN_POINTER(result);
}

Datum elephant_out(PG_FUNCTION_ARGS)
{
  char *result = palloc0(sizeof(char));
  PG_RETURN_POINTER(result);
}
