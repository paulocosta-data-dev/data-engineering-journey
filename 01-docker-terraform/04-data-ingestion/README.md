# NYC Taxi Data Ingestion Pipeline

**Data Engineering Journey | Module 01 — Docker, PostgreSQL & Data Ingestion**

## 1. Overview

This project implements a reproducible batch ingestion pipeline for loading NYC Yellow Taxi trip records into PostgreSQL.

It was developed as part of an independent learning project following the [DataTalksClub Data Engineering Zoomcamp](https://github.com/DataTalksClub/data-engineering-zoomcamp).

The project covers:

- Exploring CSV datasets using pandas and Jupyter Notebook.
- Defining explicit data types and parsing timestamps.
- Loading large datasets into PostgreSQL using batch processing.
- Developing a reusable Python ingestion script.
- Managing database credentials through environment variables.
- Containerizing Python applications with Docker.
- Managing dependencies with `uv` and `uv.lock`.
- Running PostgreSQL and ingestion services with Docker Compose.
- Validating ingestion results and identifying data-quality anomalies.

The same dataset was successfully loaded using standalone Python, Docker and Docker Compose.

## 2. Technology Stack

| Technology | Purpose |
|---|---|
| Python 3.13 | Data ingestion implementation |
| pandas 3.1.0 | CSV processing and batching |
| SQLAlchemy 2.1.6 | Database integration |
| psycopg 3.3.6 | PostgreSQL driver |
| PostgreSQL 18 | Relational database |
| Docker | Containerization |
| Docker Compose | Service coordination |
| uv | Dependency management |
| Jupyter Notebook | Data exploration and validation |
| python-dotenv | Environment variable loading |

## 3. Project Structure

```text
01-docker-terraform/
├── 03-postgresql/
│   ├── compose.yaml
│   ├── .env.example
│   ├── .env                  # Local only — not committed
│   └── README.md
│
└── 04-data-ingestion/
    ├── .dockerignore
    ├── .python-version
    ├── Dockerfile
    ├── Dockerfile.uv
    ├── README.md
    ├── ingest_data.py
    ├── notebook.ipynb
    ├── pyproject.toml
    ├── uv.lock
    └── src/
        └── 04_data_ingestion/
            └── __init__.py
```

## 4. Dataset

**NYC Yellow Taxi Trip Records — January 2021**

Source: [DataTalksClub NYC TLC Data](https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz)

| Metric | Value |
|---|---:|
| Total records | 1,369,765 |
| Columns | 18 |
| Format | Gzip-compressed CSV |
| Primary reporting period | January 2021 |
| CSV read batch size | 100,000 rows |
| PostgreSQL write batch size | 10,000 rows |

The dataset contains trip timestamps, pickup and drop-off location identifiers, passenger counts, distances, payment types, fares and additional charges.

## 5. Architecture

```text
                  NYC Yellow Taxi Dataset
                            |
                            v
                    CSV file (.csv.gz)
                            |
                            v
                    Python + pandas
                            |
                Read 100,000 rows per batch
                Apply explicit data types
                Parse pickup/drop-off dates
                            |
                            v
                   SQLAlchemy + psycopg
                            |
                 Write in batches of 10,000
                            |
                            v
                      PostgreSQL 18
                            |
                            v
                    SQL Data Validation
```

The pipeline implements a **full-refresh strategy**:

1. Read the compressed CSV progressively.
2. Apply predefined column types.
3. Parse pickup and drop-off timestamps.
4. Connect to the target PostgreSQL database.
5. Replace the target table when processing the first batch.
6. Append all remaining batches.
7. Log the number of processed records and batch execution times.
8. Validate the resulting data using SQL.

The target table is configurable through command-line arguments.

## 6. Prerequisites

The following tools are required:

- Docker Desktop with Docker Compose.
- Python 3.13 and `uv` for local Python execution.
- VS Code with Python and Jupyter extensions for notebook exploration.

Docker-based execution does not require Python to be installed on the host machine.

All commands below assume a PowerShell terminal on Windows.

## 7. PostgreSQL Setup

PostgreSQL is managed through the Compose configuration in `../03-postgresql/compose.yaml`.

### 7.1. Environment configuration

Create a `.env` file inside `03-postgresql` using `.env.example` as a reference.

Example:

```dotenv
POSTGRES_USER=root
POSTGRES_PASSWORD=your_local_password
POSTGRES_DB=ny_taxi
```

The `.env` file must remain outside version control.

### 7.2. Start PostgreSQL

From the `04-data-ingestion` directory:

```powershell
docker compose -f ..\03-postgresql\compose.yaml up -d postgres
```

Verify the service:

```powershell
docker compose -f ..\03-postgresql\compose.yaml ps
```

PostgreSQL is available to local applications at:

```text
127.0.0.1:5432
```

### 7.3. Persistent storage

The PostgreSQL service uses an external Docker volume:

```text
journey_postgres_data
```

This volume preserves the database files independently of the PostgreSQL container lifecycle.

The volume must already exist before starting the service. For a new environment, create it with:

```powershell
docker volume create journey_postgres_data
```

Do not delete this volume unless you intentionally want to remove its stored data.

## 8. Local Python Execution

### 8.1. Install dependencies

Open a PowerShell terminal inside `04-data-ingestion`:

```powershell
uv sync
```

Dependencies are resolved from `pyproject.toml` and `uv.lock`.

### 8.2. Run the ingestion pipeline

```powershell
uv run python .\ingest_data.py `
    --url "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz" `
    --host 127.0.0.1 `
    --port 5432 `
    --user root `
    --db ny_taxi `
    --table yellow_taxi_data_pipeline
```

The script loads the database password from the local `../03-postgresql/.env` file.

### 8.3. Command-line arguments

| Argument | Description |
|---|---|
| `--url` | CSV dataset URL |
| `--host` | PostgreSQL hostname |
| `--port` | PostgreSQL port |
| `--user` | Database username |
| `--db` | Database name |
| `--table` | Target table |

The pipeline requires `POSTGRES_PASSWORD` to be available through the environment or the local `.env` file.

**Warning:** The pipeline replaces its target table on every full run. Use a dedicated target table to avoid overwriting unrelated data.

## 9. Jupyter Notebook

The `notebook.ipynb` contains the initial exploratory workflow.

It includes:

1. Library imports and dataset configuration.
2. Initial CSV exploration.
3. Data type inspection.
4. Explicit schema definition.
5. Timestamp parsing.
6. Environment configuration.
7. PostgreSQL connectivity.
8. SQL schema inspection.
9. Chunk-based ingestion.
10. Data-quality validation.
11. Temporal anomaly detection.
12. Comparison with the standalone Python pipeline.

### Running the notebook

Open `notebook.ipynb` in VS Code.

Select the Python kernel from the project's `.venv` environment.

Run the cells sequentially or use **Run All**.

The notebook uses a dedicated PostgreSQL table:

```text
yellow_taxi_data_notebook
```

This keeps the exploratory ingestion separate from the standalone pipeline.

**Warning:** The notebook's ingestion cell replaces its target table. To repeat the full ingestion, initialize the CSV chunk reader again before executing the ingestion loop.

## 10. Docker Containerization

The project contains two Dockerfiles.

| File | Dependency installation | Purpose |
|---|---|---|
| `Dockerfile` | pip | Initial containerization exercise |
| `Dockerfile.uv` | uv with lockfile | Reproducible dependency installation |

The recommended implementation is `Dockerfile.uv`.

### 10.1. Build the image

From `04-data-ingestion`:

```powershell
docker build -f Dockerfile.uv -t journey-taxi-ingestion:uv .
```

The image contains:

- Python 3.13 runtime.
- Production dependencies defined in `uv.lock`.
- The `ingest_data.py` script.

Development dependencies, including Jupyter, are excluded from the production environment.

### 10.2. Docker networking

The PostgreSQL container uses the Docker Compose network:

```text
03-postgresql_default
```

When running Python locally, PostgreSQL is accessed through `127.0.0.1`.

Inside Docker, the ingestion container uses the PostgreSQL service hostname `postgres`.

| Execution environment | PostgreSQL hostname |
|---|---|
| Windows / local Python | `127.0.0.1` |
| Docker container | `postgres` |

### 10.3. Run the Docker ingestion

```powershell
docker run --rm `
    --network 03-postgresql_default `
    --env-file ..\03-postgresql\.env `
    journey-taxi-ingestion:uv `
    --url "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz" `
    --host postgres `
    --port 5432 `
    --user root `
    --db ny_taxi `
    --table yellow_taxi_data_docker
```

The `--env-file` option injects database configuration at runtime.

The credentials are not embedded in the Docker image.

The `--rm` flag removes the ingestion container after execution.

### 10.4. Docker execution results

The initial pip-based Docker image successfully ingested the complete dataset.

| Metric | Result |
|---|---:|
| Records ingested | 1,369,765 |
| Batches processed | 14 |
| CSV read batch size | 100,000 |
| Database write batch size | 10,000 |
| Total execution time | 46.00 seconds |

The uv-based image was successfully built, and its dependency imports and PostgreSQL connectivity were validated separately.

## 11. Docker Compose Integration

The ingestion pipeline is integrated with PostgreSQL through Docker Compose.

Configuration file:

```text
../03-postgresql/compose.yaml
```

### 11.1. Services

| Service | Responsibility |
|---|---|
| `postgres` | PostgreSQL database and persistent storage |
| `ingestion` | Containerized Python batch ingestion |

The PostgreSQL service includes a healthcheck using `pg_isready`.

The ingestion service uses:

```yaml
depends_on:
  postgres:
    condition: service_healthy
```

This prevents ingestion from starting before PostgreSQL passes its healthcheck.

### 11.2. Optional ingestion profile

The ingestion service belongs to the optional Compose profile:

```yaml
profiles:
  - ingestion
```

This avoids automatically reloading the dataset when only the database service is started.

### 11.3. Run ingestion with Docker Compose

From the `04-data-ingestion` directory:

```powershell
docker compose -f ..\03-postgresql\compose.yaml --profile ingestion run --rm --build ingestion
```

This command:

1. Builds the ingestion image if required.
2. Starts or verifies the PostgreSQL service.
3. Waits for PostgreSQL to become healthy.
4. Runs the Python ingestion pipeline.
5. Loads the dataset into `yellow_taxi_data_compose`.
6. Removes the one-off ingestion container after completion.

The command performs a full refresh of the destination table.

### 11.4. Docker Compose execution results

The full ingestion was successfully executed using Docker Compose.

| Metric | Result |
|---|---:|
| Target table | `yellow_taxi_data_compose` |
| Records loaded | 1,369,765 |
| Batches | 14 |
| Total execution time | 64.65 seconds |
| PostgreSQL status | Healthy |
| Reported ingestion errors | 0 |

PostgreSQL was recreated during the tested Compose execution, but its persistent volume was retained.

Subsequent validation confirmed that the previously loaded tables remained accessible with their expected row counts.

### 11.5. Docker Compose vs Docker run

The two approaches execute the same Python ingestion logic.

| Feature | Docker run | Docker Compose |
|---|---|---|
| Containerized ingestion | Yes | Yes |
| Shared PostgreSQL network | Explicit argument | Managed by Compose |
| Environment configuration | `--env-file` | Compose environment |
| PostgreSQL health dependency | Manual verification | `depends_on` with healthcheck |
| Database service management | Separate | Integrated |
| Reusable configuration | Command-line arguments | YAML configuration |

Docker Compose reduces the number of manual steps required to coordinate the services.

## 12. Data Validation

The dataset was ingested through four separate workflows:

1. Initial notebook ingestion into `yellow_taxi_data`.
2. Standalone Python ingestion into `yellow_taxi_data_pipeline`.
3. Docker ingestion into `yellow_taxi_data_docker`.
4. Docker Compose ingestion into `yellow_taxi_data_compose`.

### 12.1. Record count comparison

| PostgreSQL table | Records |
|---|---:|
| `yellow_taxi_data` | 1,369,765 |
| `yellow_taxi_data_pipeline` | 1,369,765 |
| `yellow_taxi_data_docker` | 1,369,765 |
| `yellow_taxi_data_compose` | 1,369,765 |

All four tables contain the expected number of records.

To reproduce the comparison:

```sql
SELECT
    (SELECT COUNT(*) FROM yellow_taxi_data) AS original_rows,
    (SELECT COUNT(*) FROM yellow_taxi_data_pipeline) AS python_rows,
    (SELECT COUNT(*) FROM yellow_taxi_data_docker) AS docker_rows,
    (SELECT COUNT(*) FROM yellow_taxi_data_compose) AS compose_rows;
```

**Note:** Matching row counts establish count consistency, not complete record-by-record equivalence.

### 12.2. Temporal validation

```sql
SELECT
    COUNT(*) FILTER (
        WHERE tpep_pickup_datetime < '2021-01-01'
    ) AS trips_before_january,

    COUNT(*) FILTER (
        WHERE tpep_pickup_datetime >= '2021-02-01'
    ) AS trips_after_january,

    COUNT(*) FILTER (
        WHERE tpep_pickup_datetime >= '2021-01-01'
          AND tpep_pickup_datetime < '2021-02-01'
    ) AS trips_in_january

FROM yellow_taxi_data_pipeline;
```

Observed results:

| Pickup period | Records |
|---|---:|
| Before January 2021 | 20 |
| January 2021 | 1,369,741 |
| After January 2021 | 4 |
| **Total** | **1,369,765** |

The dataset contains 24 records with pickup dates outside the expected month.

These records are intentionally preserved during ingestion.

### 12.3. Additional quality checks

| Check | Observed result |
|---|---:|
| Null pickup timestamps | 0 |
| Negative trip distances | 0 |
| Pickup dates outside January 2021 | 24 |

The observed pickup timestamps range from December 2008 to February 2021.

This demonstrates the importance of validating the actual contents of a source dataset instead of assuming all values match the filename or reporting period.

## 13. Engineering Decisions

### Explicit schema definition

Nullable integers are represented using pandas `Int64`, allowing integer columns to contain missing values.

Pickup and drop-off dates are parsed during ingestion and mapped to PostgreSQL timestamp columns.

### Batch processing

The CSV is read in batches of 100,000 rows to avoid loading the complete dataset into a single DataFrame.

Database writes use smaller batches of 10,000 rows.

### Credentials management

Credentials are stored outside the Python source code.

- Local Python uses `python-dotenv`.
- Docker uses runtime environment variables.
- Docker Compose injects environment variables from its configuration.

The `.env` file is excluded from Git.

### Dependency reproducibility

The `uv.lock` file records the resolved dependency versions.

The uv-based Dockerfile installs locked production dependencies using:

```dockerfile
RUN uv sync --locked --no-dev --no-install-project
```

### Source data preservation

The pipeline loads source data without applying business-specific filtering rules.

Temporal anomalies are retained and identified during validation.

Data-quality rules can be applied in downstream transformation layers.

### Data persistence

PostgreSQL uses an external Docker volume.

Database files remain available when the PostgreSQL container is recreated, provided the volume is retained.

## 14. Known Limitations

This project is a learning implementation rather than a production-ready ingestion platform.

Current limitations include:

- **Full refresh only:** No incremental processing.
- **Non-atomic refresh:** A failure after the first batch may leave a partially loaded table.
- **No uniqueness enforcement:** No primary key or deduplication rule.
- **No automated tests:** Validation is currently performed through SQL queries and notebook checks.
- **Floating-point monetary values:** Amounts are stored as floating-point types instead of exact decimals.
- **No retry mechanism:** Temporary network or database failures are not automatically retried.
- **No record-level reconciliation:** Equal row counts do not guarantee equal data values.
- **Limited observability:** Execution progress is recorded through console output rather than structured logs or metrics.

## 15. Potential Improvements

Future improvements may include:

1. Automated schema and data-quality tests.
2. Staging tables and safer full-refresh strategies.
3. Incremental ingestion and checkpointing.
4. Structured logging and error handling.
5. Retry and recovery mechanisms.
6. Source-to-target reconciliation checks.
7. Workflow orchestration in subsequent Data Engineering Zoomcamp modules.

## 16. References

- [DataTalksClub Data Engineering Zoomcamp](https://github.com/DataTalksClub/data-engineering-zoomcamp)
- [DataTalksClub NYC TLC Dataset](https://github.com/DataTalksClub/nyc-tlc-data)
- [pandas Documentation](https://pandas.pydata.org/docs/)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)
- [psycopg Documentation](https://www.psycopg.org/psycopg3/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [uv Documentation](https://docs.astral.sh/uv/)