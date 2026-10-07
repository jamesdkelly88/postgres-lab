#!/usr/bin/env bash
set -e

if [ -z $1 ]; then echo "Usage: load.sh <env_file_name>"; exit 1; fi

declare envFile=$1

curl -o /tmp/lego.sql https://raw.githubusercontent.com/neondatabase/postgres-sample-dbs/main/lego.sql

tail -n +219 /tmp/lego.sql | head -n -80 > /tmp/lego_data.sql && rm /tmp/lego.sql

psql -f /tmp/lego_data.sql && rm /tmp/lego_data.sql