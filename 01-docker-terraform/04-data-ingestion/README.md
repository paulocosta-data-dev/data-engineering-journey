# NYC Taxi Data Ingestion Pipeline

**Data Engineering Journey — Module 01: Docker, PostgreSQL & Data Ingestion**

## 1. Overview

This project implements a batch ingestion pipeline to load NYC Yellow Taxi trip data into PostgreSQL using Python, pandas and SQLAlchemy.

The implementation follows the concepts introduced in the [DataTalksClub Data Engineering Zoomcamp](https://github.com/DataTalksClub/data-engineering-zoomcamp), with an independent project structure.

The pipeline supports:

- Exploratory data analysis using Jupyter Notebook.
- Explicit data types and timestamp parsing.
- Batch ingestion into PostgreSQL.
- Configurable ingestion through command-line arguments.
- Environment-based database credentials.
- Local execution with Python and `uv`.
- Containerized execution with Docker.
- Reproducible dependency installation using `uv.lock`.
- Data validation using SQL.

## 2. Technology Stack

| Technology | Purpose |
|---|---|
| Python 3.13 | Pipeline implementation |
| pandas 3.1.0 | CSV processing and batch ingestion |
| SQLAlchemy 2.1.6 | Database connectivity and SQL operations |
| psycopg 3.3.6 | PostgreSQL driver |
| PostgreSQL 18 | Data storage |
| Docker | Containerization |
| Docker Compose | PostgreSQL service management |
| uv | Python dependency management |
| Jupyter Notebook | Data exploration and validation |
| python-dotenv | Environment configuration |

## 3. Project Structure

```text
01-docker-terraform/
├── 03-postgresql/
│   ├── compose.yaml
│   ├── .env.example
│   └── .env                  # Local only, not committed
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

Source: [DataTalksClub NYC TLC Data](