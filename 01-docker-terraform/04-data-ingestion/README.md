# NYC Taxi Data Ingestion

Data Engineering Zoomcamp — Module 01: Docker, PostgreSQL and Data Ingestion.

## Overview

This project implements a batch ingestion pipeline that loads NYC Yellow Taxi trip data into PostgreSQL using Python, pandas and SQLAlchemy.

The project includes:

- `notebook.ipynb` — exploratory analysis, schema inspection, ingestion and data validation.
- `ingest_data.py` — reusable, command-line batch ingestion pipeline.
- `pyproject.toml` and `uv.lock` — dependency management with `uv`.

## Tech Stack

- Python 3.13
- pandas
- PostgreSQL 18
- SQLAlchemy and psycopg
- Docker Compose
- uv
- Jupyter Notebook (VS Code)

## Dataset

**NYC Yellow Taxi — January 2021**

Source: [DataTalksClub NYC TLC Dataset](https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz)

- 1,369,765 records
- 18 columns
- CSV compressed with gzip

## Pipeline

1. Read the compressed CSV in batches of 100,000 rows.
2. Apply explicit data types and parse timestamp columns.
3. Connect to PostgreSQL using environment-based credentials.
4. Replace the target table on the first batch and append subsequent batches.
5. Log batch sizes and execution times.

The pipeline uses a full-refresh strategy. It is intended for local development and learning, not production use.

## Running Locally

Start the PostgreSQL service from the `03-postgresql` directory:

```powershell
docker compose up -d
```

From the `04-data-ingestion` directory, install dependencies:

```powershell
uv sync
```

The pipeline reads `POSTGRES_PASSWORD` from the existing `../03-postgresql/.env` file.

Run the ingestion:

```powershell
uv run python ingest_data.py `
    --url "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz" `
    --host 127.0.0.1 `
    --port 5432 `
    --user root `
    --db ny_taxi `
    --table yellow_taxi_data_pipeline
```

**Warning:** Running this command replaces the target table and reloads the entire dataset.

## Validation Results

| Metric | Result |
|---|---:|
| Total records ingested | 1,369,765 |
| Records with pickup dates in January 2021 | 1,369,741 |
| Records with pickup dates before January 2021 | 20 |
| Records with pickup dates after January 2021 | 4 |
| Missing pickup timestamps | 0 |
| Negative trip distances | 0 |

The 24 records with pickup dates outside January are preserved during ingestion. Data-quality filtering is left to downstream transformations.

## Current Limitations

- Full refresh rather than incremental ingestion.
- No primary key or deduplication.
- The target table is replaced before the full load completes.
- No automated data-quality tests.
- Monetary values use floating-point types.

## Next Steps

- Containerize the ingestion pipeline.
- Orchestrate PostgreSQL and ingestion using Docker Compose.
- Introduce automated validation and safer loading strategies.