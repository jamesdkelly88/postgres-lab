#!/usr/bin/env bash
set -e

if [ -z $2 ]; then echo "Usage: dump.sh <env_file_name> <comma_separated_schema_list>"; exit 1; fi

SCRIPT_DIR="$(dirname "$0")"

declare envFile=$1
declare schemas=$2

declare SCHEMADIR="${SCRIPT_DIR}/../databases"

export $(grep -v ^# $envFile | xargs)

echo "Database: ${PGDATABASE}"

for s in $(echo $schemas | tr "," "\n");
do
    echo "Schema: ${s}"
    pgschema dump --multi-file --schema $s --file "${SCHEMADIR}/${PGDATABASE}/${s}/${s}.sql"
done