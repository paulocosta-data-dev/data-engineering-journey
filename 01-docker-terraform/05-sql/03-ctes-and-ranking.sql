
-- ============================================================
-- Data Engineering Journey
-- Module 01 - CTEs and Ranking
-- Dataset: NYC Yellow Taxi, January 2021
-- Database: ny_taxi
-- ============================================================


-- 01. Trips by borough
-- Use a CTE and a window function to calculate percentages.

WITH trips_by_borough AS (
    SELECT
        z."Borough" AS borough,
        COUNT(*) AS total_trips
    FROM yellow_taxi_data_pipeline AS t
    INNER JOIN taxi_zones AS z
        ON t."PULocationID" = z."LocationID"
    WHERE
        t.tpep_pickup_datetime >= '2021-01-01'
        AND t.tpep_pickup_datetime < '2021-02-01'
    GROUP BY z."Borough"
)
SELECT
    borough,
    total_trips,
    ROUND(
        100.0 * total_trips /
        SUM(total_trips) OVER (),
        2
    ) AS percentage_of_total
FROM trips_by_borough
ORDER BY total_trips DESC;


-- 02. Compare ranking functions
-- ROW_NUMBER, RANK and DENSE_RANK for Manhattan pickup zones.

WITH trips_by_zone AS (
    SELECT
        z."Borough" AS borough,
        z."Zone" AS zone,
        COUNT(*) AS total_trips
    FROM yellow_taxi_data_pipeline AS t
    INNER JOIN taxi_zones AS z
        ON t."PULocationID" = z."LocationID"
    WHERE
        t.tpep_pickup_datetime >= '2021-01-01'
        AND t.tpep_pickup_datetime < '2021-02-01'
        AND z."Borough" = 'Manhattan'
    GROUP BY
        z."Borough",
        z."Zone"
)
SELECT
    zone,
    total_trips,
    ROW_NUMBER() OVER (
        PARTITION BY borough
        ORDER BY total_trips DESC
    ) AS row_number,
    RANK() OVER (
        PARTITION BY borough
        ORDER BY total_trips DESC
    ) AS rank,
    DENSE_RANK() OVER (
        PARTITION BY borough
        ORDER BY total_trips DESC
    ) AS dense_rank
FROM trips_by_zone
ORDER BY total_trips DESC
LIMIT 10;


-- 03. Top 3 pickup zones per borough
-- Use two CTEs to aggregate and rank zones independently.

WITH trips_by_zone AS (
    SELECT
        z."Borough" AS borough,
        z."Zone" AS zone,
        COUNT(*) AS total_trips
    FROM yellow_taxi_data_pipeline AS t
    INNER JOIN taxi_zones AS z
        ON t."PULocationID" = z."LocationID"
    WHERE
        t.tpep_pickup_datetime >= '2021-01-01'
        AND t.tpep_pickup_datetime < '2021-02-01'
        AND z."Borough" NOT IN ('Unknown', 'EWR')
    GROUP BY
        z."Borough",
        z."Zone"
),
ranked_zones AS (
    SELECT
        borough,
        zone,
        total_trips,
        ROW_NUMBER() OVER (
            PARTITION BY borough
            ORDER BY total_trips DESC, zone
        ) AS position
    FROM trips_by_zone
)
SELECT
    borough,
    position,
    zone,
    total_trips
FROM ranked_zones
WHERE position <= 3
ORDER BY borough, position;
