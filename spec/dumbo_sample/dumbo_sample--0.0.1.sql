CREATE FUNCTION foo(integer) RETURNS integer AS $$
BEGIN
  RETURN $1;
END
$$ LANGUAGE 'plpgsql' IMMUTABLE STRICT;