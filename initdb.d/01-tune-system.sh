#!/usr/bin/env bash
set -e

# Default tuning parameters for a system with 8GB RAM, 4 CPUs

psql -v ON_ERROR_STOP=1 --username postgres --dbname postgres <<-EOSQL
	ALTER SYSTEM SET shared_preload_libraries = 'pg_stat_statements';

	ALTER SYSTEM SET max_connections = '500';
	ALTER SYSTEM SET shared_buffers = '2GB';
	ALTER SYSTEM SET effective_cache_size = '6GB';
	ALTER SYSTEM SET maintenance_work_mem = '512MB';
	ALTER SYSTEM SET checkpoint_completion_target = '0.9';
	ALTER SYSTEM SET wal_buffers = '16MB';
	ALTER SYSTEM SET default_statistics_target = '100';
	ALTER SYSTEM SET random_page_cost = '1.1';
	ALTER SYSTEM SET effective_io_concurrency = '200';
	ALTER SYSTEM SET work_mem = '4161kB';
	ALTER SYSTEM SET huge_pages = 'off';
	ALTER SYSTEM SET min_wal_size = '2GB';
	ALTER SYSTEM SET max_wal_size = '8GB';
	ALTER SYSTEM SET max_worker_processes = '4';
	ALTER SYSTEM SET max_parallel_workers_per_gather = '2';
	ALTER SYSTEM SET max_parallel_workers = '4';
	ALTER SYSTEM SET max_parallel_maintenance_workers = '2';
EOSQL
