# PostgreSQL with Docker

## Overview

This exercise demonstrates how to run PostgreSQL 18 using Docker and persist database data independently of the container lifecycle.

## Start PostgreSQL

```powershell
docker run -d `
  --name journey-postgres `
  -e POSTGRES_USER=root `
  -e POSTGRES_PASSWORD=root `
  -e POSTGRES_DB=ny_taxi `
  -v journey_postgres_data:/var/lib/postgresql `
  -p 5432:5432 `
  postgres:18
```

The credentials are for local development only.

## Connect to PostgreSQL

Using the PostgreSQL client inside the container:

```powershell
docker exec -it journey-postgres psql -U root -d ny_taxi
```

Alternatively, connect using pgcli:

```powershell
uv run pgcli -h localhost -p 5432 -u root -d ny_taxi
```

## Test Data Persistence

Create a table and insert sample records:

```sql
CREATE TABLE test (
    id INTEGER,
    name VARCHAR(50)
);

INSERT INTO test (id, name)
VALUES
    (1, 'Hello Docker'),
    (2, 'Data Engineering Zoomcamp'),
    (3, 'PostgreSQL Persistence Test');
```

Stop and remove the container:

```powershell
docker stop journey-postgres
docker rm journey-postgres
```

The `docker rm` command is only needed if the container was not created with `--rm`.

Recreate the container using the same named volume and verify that the data remains available:

```sql
SELECT * FROM test ORDER BY id;
```

## Key Concepts

- Docker containers are disposable.
- Named volumes persist data independently of containers.
- Port mapping allows access to PostgreSQL from the host.
- PostgreSQL clients can connect both inside and outside Docker.
