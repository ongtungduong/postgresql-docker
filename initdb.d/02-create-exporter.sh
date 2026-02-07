#!/usr/bin/env bash
set -e

psql -v ON_ERROR_STOP=1 --username postgres --dbname postgres <<-EOSQL
	CREATE USER postgres_exporter WITH PASSWORD '${EXPORTER_PASSWORD:-securepassword}';
    GRANT pg_monitor, pg_read_all_stats to postgres_exporter;
	CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
EOSQL
