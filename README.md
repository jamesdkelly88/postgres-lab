# postgres-lab

A collection of PostgreSQL sample scripts, databases and tool configs for testing.

- `docker` - compose files for running PostgreSQL containerised
- [`pgschema`](#pgschema) - declarative schema migrations
- [`sqlfluff`](#sqlfluff) - linter for checking syntax and style
- [`squawk`](#squawk) - linter for catching breaking or blocking changes
<!-- - [`terraform`](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs) - database configuration as code
- sample databases
- sample queries
- sample pipelines -->

# [pgschema](https://www.pgschema.com/)

[Back to top](#postgres-lab)

## Schema Layout

```
├── database1
|   ├── extensions.sql
│   ├── schema1
|   |   ├── schema1.sql
│   │   └── tables
│   │       ├── first_table.sql
│   │       └── second_table.sql
│   └── schema2
|       ├── schema2.sql 
│       ├── views
│       │   └── view.sql
│       ├── default_privileges
│       │   └── tables.sql
│       └── privileges
│           └── view.sql
├── database2...
└── database3...
```

`extensions.sql` contains the commands to create the required extensions inside the database, as this is not managed by `pgschema`.

`pgschema` creates a `.sql` file for each database object. It also creates a `.sql` file for the schema listing the object files to include. 

These are processed in order and so this file can be edited to handle dependencies. The `\i` directives can be changed to include an entire folder (in alphabetical order) by adding a trailing `/`.

## Prerequisites

- pgschema - installable via Go (`go install github.com/pgplex/pgschema@latest`) or as a standalone binary
- a PostgreSQL client (e.g. `psql` / `pgadmin`) to run the setup scripts
- If using extensions/multiple schemas, a `staging` database with the extensions installed and schemas created (or run the `setup` script)
- `.env` file containing database connection parameters (see below)

## Usage

### Environment variables

```sh
PGHOST=localhost
PGPORT=5432
PGDATABASE=example
PGUSER=bot
PGPASSWORD=secret
PGSSLMODE=require

# for the setup scripts
PGADMINUSER=postgres
PGADMINPASSWORD=secret

# for the staging database
PGSCHEMA_PLAN_HOST=localhost
PGSCHEMA_PLAN_PORT=5432
PGSCHEMA_PLAN_DB=staging
PGSCHEMA_PLAN_USER=postgres
PGSCHEMA_PLAN_PASSWORD=secret
PGSCHEMA_PLAN_SSLMODE=require
```

Use `export $(grep -v ^# $envFile | xargs)` to load an `.env` file (`.env` and [a couple of others](https://www.pgschema.com/cli/dotenv) are loaded automatically by `pgschema`)

### Ignore file

```toml
[type]
patterns = ["exclude", "!include"]
```

#### Types

- tables
- views
- functions
- procedures
- aggregates
- types
- sequences
- indexes
- constraints
- triggers
- privileges
- default_privileges

The one in this repo excludes all permissions but includes everything else.

### Dump

```sh
pgschema dump --multi-file --schema schema --file database/schema/schema.sql --qualify-schema
```

### Plan

**Important** 

- If extensions or cross schema references are used, then an external database should be used, rather than the default embedded instance
- `pgschema` only works on a single schema at a time, so for multiple schemas, a looping process must be used
- The schema must exist in the target database
- Any extensions used must be installed in both the plan and target databases

```sh
pgschema plan --schema schema --file database/schema/schema.sql                                                                               # outputs to console

pgschema plan --file database/schema/schema.sql --schema schema --output-sql output.sql --output-human output.txt --output-json output.json   # outputs to files
```

### Apply

**Important** 

- It is a schema management tool, so it will suggest dropping tables/columns
  - plans must be reviewed for data loss and migrations handled manually

#### Interactive (file)

1. Generates the plan
2. Prints it to the console
3. Asks for approval
4. Applies the changes

```sh
pgschema apply --file database/schema/schema.sql --schema schema 
```

### Interactive (planned)

1. Validates the plan for drift
2. Prints the changes to the console
3. Asks for approval
4. Applies the changes

```sh
pgschema apply --plan output_schema.json --schema schema
```

#### Automated

1. Validates the plan for drift
2. Applies the changes

```sh
pgschema apply --plan output_schema.json --schema schema --auto-approve
```


## Ownership

Best practice is to have a `database_owner` role own the database and objects (unless a `schema_owner` role is required for segregation). 

In order to satisfy this with `pgschema`, perform the following setup (TODO: needs thorough testing on different providers):

```sql

-- ==========================================
-- 1. RUN AS SUPERUSER (Connected to 'postgres' database)
-- ==========================================

-- CREATE DB OWNER ROLE
CREATE ROLE dbname_owner WITH NOLOGIN;
GRANT dbname_owner TO superuser;

-- CREATE DB
CREATE DATABASE dbname WITH OWNER = dbname_owner;

-- CREATE HUMAN ADMIN USER
CREATE USER human WITH ENCRYPTED PASSWORD 'password';
GRANT dbname_owner TO human WITH INHERIT TRUE, SET TRUE;

-- CREATE PGSCHEMA USER THAT AUTOMATICALLY ASSUMES OWNER ROLE
CREATE USER bot WITH ENCRYPTED PASSWORD 'password';
GRANT dbname_owner TO bot WITH INHERIT FALSE, SET TRUE;
ALTER ROLE bot IN DATABASE dbname SET role TO dbname_owner;

-- CREATE APP ROLE
CREATE ROLE dbname_app WITH NOLOGIN;

-- CREATE APP USER
CREATE USER app WITH ENCRYPTED PASSWORD 'password';
GRANT dbname_app TO app;

-- SECURE DATABASE
GRANT CONNECT ON DATABASE dbname TO dbname_owner;
GRANT CONNECT ON DATABASE dbname TO dbname_app;
GRANT CONNECT ON DATABASE dbname TO bot;
REVOKE CONNECT ON DATABASE dbname FROM PUBLIC;

-- ==========================================
-- 2. RUN CONNECTED TO TARGET DATABASE (\c dbname)
-- ==========================================

-- GRANT SPECIFIC PERMISSIONS TO APP ROLE
GRANT USAGE ON SCHEMA schemaname TO dbname_app;
GRANT SELECT ON ALL TABLES IN SCHEMA schemaname TO dbname_app;
ALTER DEFAULT PRIVILEGES FOR ROLE dbname_owner IN SCHEMA schemaname GRANT SELECT ON TABLES TO dbname_app;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA schemaname TO dbname_app;
ALTER DEFAULT PRIVILEGES FOR ROLE dbname_owner IN SCHEMA schemaname GRANT USAGE, SELECT ON SEQUENCES TO dbname_app;

-- CHECK FOR ASSUMED ROLE
SELECT 
  session_user AS authenticated_role,
  current_user AS effective_role,
  current_role AS active_role;  

-- LEAVE ASSUMED ROLE
SET ROLE NONE;
```

# [sqlfluff](https://www.sqlfluff.com/)

[Back to top](#postgres-lab)

SQLFluff is a linter that checks SQL code style. It comes with a default set of rules, which can be altered by creating a `.sqlfluff` file in your current directory.

## Prerequisites

- `python` and `pip` - `sqlfluff` is a Python package

## Usage

### Linting

```sh
sqlfluff lint databases/example --dialect postgres
```

You can specify a `.sql` file or a folder. It will work recursively.

This will output a list of issues found. If `[dialect]` is included in your `.sqlfluff` file this argument can be omitted.

### Fixing

SQLFluff has the ability to fix some issues it finds. Use `fix` instead of `lint` to do this. It will still error if there are issues it cannot resolve.

# [Squawk](https://squawkhq.com/)

Squawk is a linter that checks migrations for damaging/blocking actions. It comes with a default set of [rules](https://squawkhq.com/docs/rules) which can be configured using a `.squawk.toml` file - it will traverse upwards to find this, or you can specify with `--config path/to/.squawk.toml`

## Prerequisites

- For `squawk-cli`: either Node.js and `npm` or Python and `pip`
- For the [extension](https://marketplace.visualstudio.com/items?itemName=sbdchd.squawk): Visual Studio code

## Usage

```sh
squawk pgschema/output_*.sql 
```

The path should be a migration `.sql` file. It accepts wildcards.

<!-- ## TODO: Interesting rules -->
