#!/usr/bin/env bash
set -e

psql -v ON_ERROR_STOP=1 --username postgres --dbname postgres <<-EOSQL
	CREATE USER ${PROJECT_USER:-app} WITH PASSWORD '${PROJECT_PASSWORD:-securepassword}';
    CREATE DATABASE ${PROJECT_USER:-app} WITH OWNER ${PROJECT_USER:-app};
EOSQL
