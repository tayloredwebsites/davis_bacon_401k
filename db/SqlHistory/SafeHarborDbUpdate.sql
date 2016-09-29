-- new safe harbor fields 18-Nov-2010
-- run this immediately after safe harbor migration
-- look into doing this with postgres
--  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
--    in def native_database_types),  add :numeric type

-- Table: employee_packages
ALTER TABLE employee_packages DROP COLUMN safe_harbor_pct;
ALTER TABLE employee_packages ADD COLUMN safe_harbor_pct numeric(5,2);
ALTER TABLE employee_packages ALTER COLUMN safe_harbor_pct SET DEFAULT 0;
