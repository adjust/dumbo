-- Testing Base Types handling.
CREATE TYPE elephant_base;

CREATE FUNCTION elephant_in(cstring) RETURNS elephant_base AS
'$libdir/dumbo_sample' LANGUAGE C IMMUTABLE;

CREATE FUNCTION elephant_out(elephant_base) RETURNS cstring AS
'$libdir/dumbo_sample' LANGUAGE C IMMUTABLE;

CREATE TYPE elephant_base (
  INPUT  = elephant_in,
  OUTPUT = elephant_out
);
