-- Testing Composite, Range, Enum Types handling.

CREATE TYPE elephant_composite AS (weight integer, name text);

CREATE TYPE elephant_range AS RANGE (subtype = float8, subtype_diff = float8mi);

CREATE TYPE elephant_enum AS ENUM ('infant', 'child', 'adult');
