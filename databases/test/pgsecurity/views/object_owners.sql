--
-- Name: object_owners; Type: VIEW; Schema: -; Owner: -
--


CREATE OR REPLACE VIEW object_owners AS
SELECT
  n.nspname AS schema_name,
  c.relname AS object_name,
  cr.rolname AS object_owner,
  sr.rolname AS schema_owner,
  CASE c.relkind
    WHEN 'r' THEN 'Table'
    WHEN 'i' THEN 'Index'
    WHEN 'S' THEN 'Sequence'
    WHEN 't' THEN 'Toast Table'
    WHEN 'v' THEN 'View'
    WHEN 'm' THEN 'Materialised View'
    WHEN 'c' THEN 'Composite Type'
    WHEN 'f' THEN 'Foreign Table'
    WHEN 'p' THEN 'Partitioned Table'
    WHEN 'I' THEN 'Partitioned Index'
  END AS object_type
FROM pg_class AS c
INNER JOIN pg_namespace AS n ON c.relnamespace = n.oid
INNER JOIN pg_roles AS cr ON c.relowner = cr.oid
INNER JOIN pg_roles AS sr ON n.nspowner = sr.oid
WHERE n.nspname NOT IN ('pg_catalog', 'pg_toast', 'information_schema');
