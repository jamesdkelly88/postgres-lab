#!/usr/bin/env bash
set -e

if [ -z $1 ]; then echo "Usage: plan.sh <env_file_name>"; exit 1; fi

SCRIPT_DIR="$(dirname "$0")"

declare envFile=$1

export $(grep -v ^# $envFile | xargs)

echo "Database: staging"

AUTOUSER=$PGUSER
AUTOPASSWORD=$PGPASSWORD
PGUSER=$PGADMINUSER
PGPASSWORD=$PGADMINPASSWORD

psql -d postgres \
  --set=ON_ERROR_STOP=1 \
  --set=automation_username="$AUTOUSER" \
  --set=automation_password="$AUTOPASSWORD" \
  --set=db_name="staging" \
  --set=owner_role="staging_owner" \
  -f "$SCRIPT_DIR/setup.sql" 

echo "Database: ${PGDATABASE}"

psql -d postgres \
  --set=automation_username="$AUTOUSER" \
  --set=automation_password="$AUTOPASSWORD" \
  --set=db_name="$PGDATABASE" \
  --set=owner_role="${PGDATABASE}_owner" \
  -f "$SCRIPT_DIR/setup.sql" 