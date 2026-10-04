-- Create the owner role if it doesn't exist.
SELECT format(
  'CREATE ROLE %I NOLOGIN',
  :'owner_role'
)
WHERE NOT EXISTS (
  SELECT 1
  FROM pg_roles
  WHERE rolname = :'owner_role'
)
\gexec

-- Allow the current user to SET ROLE to the owner role.
GRANT :"owner_role" TO CURRENT_USER WITH INHERIT TRUE, SET TRUE;

-- Create the automation user if it doesn't exist.
SELECT format(
  'CREATE ROLE %I LOGIN ENCRYPTED PASSWORD %L',
  :'automation_username',
  :'automation_password'
)
WHERE NOT EXISTS (
  SELECT 1
  FROM pg_roles
  WHERE rolname = :'automation_username'
)
\gexec

-- Give the automation user membership of the owner role.
GRANT :"owner_role" TO :"automation_username" WITH INHERIT FALSE, SET TRUE;

-- Create the database if it doesn't exist.
SELECT format(
  'CREATE DATABASE %I OWNER %I',
  :'db_name',
  :'owner_role'
)
WHERE NOT EXISTS (
  SELECT 1
  FROM pg_database
  WHERE datname = :'db_name'
)
\gexec

-- Make the automation user automatically assuming the owner role role when connecting to the database
ALTER ROLE :"automation_username" IN DATABASE :"db_name" SET ROLE TO :"owner_role";
