# SQL Analytics — NYC Yellow Taxi

**Data Engineering Journey | Module 01 — SQL Fundamentals**

## Overview

This project contains SQL exercises developed using PostgreSQL 18 and the NYC Yellow Taxi January 2021 dataset.

The exercises cover SQL fundamentals, relational joins, data validation, Common Table Expressions (CTEs), ranking functions, and time-series analytics.

All queries were executed and validated against the `ny_taxi` PostgreSQL database.

## Project Structure

```text
05-sql/
├── README.md
├── 01-basic-queries.sql
├── 02-joins.sql
├── 03-ctes-and-ranking.sql
└── 04-window-functions.sql
```

## Dataset and Tables

| Table | Description | Records |
|---|---|---:|
| `yellow_taxi_data_pipeline` | NYC Yellow Taxi trips, January 2021 | 1,369,765 |
| `taxi_zones` | NYC Taxi Zone Lookup | 265 |

The source data was loaded into PostgreSQL using the ingestion pipeline developed in `../04-data-ingestion`.

The `taxi_zones` table provides descriptive attributes for pickup and drop-off location identifiers.

## SQL Exercises

### 1. Basic Queries

File: `01-basic-queries.sql`

Topics:

- `COUNT`, `COUNT(DISTINCT)` and `AVG`
- `GROUP BY` and `ORDER BY`
- `WHERE` versus `HAVING`
- Data type conversion
- Data-quality checks
- Temporal filtering

### 2. Joins

File: `02-joins.sql`

Topics:

- `INNER JOIN`
- `LEFT JOIN`
- Referential integrity
- Joining the same dimension multiple times
- Pickup-to-drop-off borough analysis

### 3. CTEs and Ranking

File: `03-ctes-and-ranking.sql`

Topics:

- Common Table Expressions (`WITH`)
- Multiple CTEs
- `ROW_NUMBER()`
- `RANK()`
- `DENSE_RANK()`
- `PARTITION BY`
- Top-N analysis by borough

### 4. Window Functions

File: `04-window-functions.sql`

Topics:

- `LAG()`
- Seven-day rolling averages
- Day-over-Day (DoD) changes
- Week-over-Week (WoW) changes
- Window frames
- Combining multiple analytical metrics

## Key Findings

### Dataset validation

| Metric | Result |
|---|---:|
| Total trips | 1,369,765 |
| Trips with pickup dates in January 2021 | 1,369,741 |
| Trips before January 2021 | 20 |
| Trips after January 2021 | 4 |
| Missing pickup timestamps | 0 |
| Negative trip distances | 0 |

### Referential integrity

| Metric | Result |
|---|---:|
| Trips with matched pickup locations | 1,369,765 |
| Trips with matched drop-off locations | 1,369,765 |
| Unmatched pickup locations | 0 |
| Unmatched drop-off locations | 0 |

### Borough distribution

Manhattan accounted for **89.83%** of January 2021 trips by pickup location.

### Top pickup zones

| Borough | Top pickup zone | Trips |
|---|---|---:|
| Manhattan | Upper East Side North | 74,397 |
| Queens | JFK Airport | 32,370 |
| Brooklyn | East New York | 1,652 |
| Bronx | Mott Haven/Port Morris | 922 |
| Staten Island | Charleston/Tottenville | 135 |

### Time-series analysis

| Metric | Result |
|---|---|
| Highest daily volume | January 28 — 56,444 trips |
| Largest Day-over-Day increase | January 4 — +69.08% |
| Largest Day-over-Day decrease | January 30 — −28.15% |
| Seven-day rolling average on January 31 | 47,051.14 trips |

Daily volumes showed a recurring weekday/weekend pattern. Week-over-Week comparisons helped distinguish this pattern from changes between consecutive days.

## Running the Queries

### Prerequisites

- PostgreSQL running through Docker Compose.
- The `ny_taxi` database populated with the trip and zone tables.
- A PostgreSQL client such as `pgcli`.

### Connect to PostgreSQL

From `../02-python-pipelines`:

```powershell
uv run pgcli -h 127.0.0.1 -p 5432 -u root -d ny_taxi
```

Enter the password configured in `../03-postgresql/.env`.

### Execute SQL

Open the `.sql` files in VS Code and execute individual queries using a PostgreSQL client.

Alternatively, from inside `pgcli`, execute a file using an absolute path with the `\i` command.

All queries in this directory are read-only.

## Engineering Considerations

- Explicit date filtering ensures that out-of-period source records do not affect January-specific analysis.
- Referential-integrity checks verify location mappings before joining tables.
- Window functions allow comparisons across dates without collapsing daily results.
- `LAG(7)` assumes a continuous daily series; missing calendar days require additional handling.
- Monetary averages use floating-point source values and should not be treated as exact financial calculations.
- Matching row counts and valid location identifiers do not establish complete source-to-target data equivalence.

## References

- [DataTalksClub Data Engineering Zoomcamp](https://github.com/DataTalksClub/data-engineering-zoomcamp)
- [NYC TLC Dataset](https://github.com/DataTalksClub/nyc-tlc-data)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [PostgreSQL Window Functions](https://www.postgresql.org/docs/current/tutorial-window.html)