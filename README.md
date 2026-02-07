# PostgreSQL Docker

A PostgreSQL setup for development purpose, using Docker Compose, featuring automatic performance tuning, Prometheus metrics exporter, and secure credential generation.

## Quick Start

### 1. Generate environment file

```bash
./generate-env.sh <project_user>
```

This creates a `.env` file with:

- Random 32-character passwords for the project user, `postgres` superuser, and exporter user
- An available `POSTGRES_PORT` (starting from 5432, incremented if occupied)
- A corresponding `EXPORTER_PORT` (prefixed with `1`, e.g. `15432`)

### 2. Start the services

```bash
docker compose up -d
```

### 3. Connect

```bash
# As the project user
psql -h localhost -p <POSTGRES_PORT> -U <project_user> -d <project_user>

# As superuser
psql -h localhost -p <POSTGRES_PORT> -U postgres -d postgres
```

## Configuration

All settings are controlled via environment variables in `.env`. See `.env.example` for defaults:

| Variable | Default | Description |
|---|---|---|
| `PROJECT_USER` | `app` | Application database user & database name |
| `PROJECT_PASSWORD` | `securepassword` | Password for the project user |
| `POSTGRES_PASSWORD` | `securepassword` | Password for the `postgres` superuser |
| `EXPORTER_PASSWORD` | `securepassword` | Password for the `postgres_exporter` user |
| `POSTGRES_PORT` | `5432` | Host port mapped to PostgreSQL |
| `EXPORTER_PORT` | `15432` | Host port mapped to the Prometheus exporter |

## Init Scripts

Scripts in `initdb.d/` run automatically on **first container initialization** (in alphabetical order):

| Script | Purpose |
|---|---|
| `01-tune-system.sh` | Applies PostgreSQL performance tuning via `ALTER SYSTEM SET` |
| `02-create-exporter.sh` | Creates `postgres_exporter` user with monitoring grants and enables `pg_stat_statements` |
| `03-create-project.sh` | Creates the project user and database |

### Performance Tuning (01-tune-system.sh)

Tuned for a system with **8 GB RAM** and **4 CPUs**:

- `shared_buffers` = 2 GB
- `effective_cache_size` = 6 GB
- `maintenance_work_mem` = 512 MB
- `max_connections` = 500
- `max_worker_processes` = 4
- `max_parallel_workers` = 4
- WAL: `min_wal_size` = 2 GB, `max_wal_size` = 8 GB
- SSD-optimized: `random_page_cost` = 1.1, `effective_io_concurrency` = 200

## Prometheus Metrics

The exporter exposes metrics at `http://localhost:<EXPORTER_PORT>/metrics` and includes:

- Standard PostgreSQL metrics
- `pg_stat_statements` query statistics
- Auto-discovered databases

## Data Persistence

PostgreSQL data is stored in `./data/` on the host, which is git-ignored. To reset the database completely, stop the containers and remove the directory:

```bash
docker compose down
rm -rf ./data
```

## License

Unlicensed — personal project.
