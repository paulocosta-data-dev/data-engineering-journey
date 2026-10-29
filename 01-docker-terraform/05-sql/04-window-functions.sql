
-- ============================================================
-- Data Engineering Journey
-- Module 01 - Window Functions and Time Series
-- Dataset: NYC Yellow Taxi, January 2021
-- Database: ny_taxi
-- ============================================================


-- 01. Daily trips and 7-day rolling average
-- The first six days use a partial window.

WITH daily_trips AS (
    SELECT
        tpep_pickup_datetime::date AS trip_date,
        COUNT(*) AS total_trips
    FROM yellow_taxi_data_pipeline
    WHERE
        tpep_pickup_datetime >= '2021-01-01'
        AND tpep_pickup_datetime < '2021-02-01'
    GROUP BY tpep_pickup_datetime::date
)
SELECT
    trip_date,
    total_trips,
    ROUND(
        AVG(total_trips) OVER (
            ORDER BY trip_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS rolling_avg_7d
FROM daily_trips
ORDER BY trip_date;


-- 02. Day-over-Day (DoD) change
-- Compare each day's trip count with the previous day.

WITH daily_trips AS (
    SELECT
        tpep_pickup_datetime::date AS trip_date,
        COUNT(*) AS total_trips
    FROM yellow_taxi_data_pipeline
    WHERE
        tpep_pickup_datetime >= '2021-01-01'
        AND tpep_pickup_datetime < '2021-02-01'
    GROUP BY tpep_pickup_datetime::date
),
daily_comparison AS (
    SELECT
        trip_date,
        total_trips,
        LAG(total_trips) OVER (
            ORDER BY trip_date
        ) AS previous_day_trips
    FROM daily_trips
)
SELECT
    trip_date,
    total_trips,
    previous_day_trips,
    total_trips - previous_day_trips AS daily_change,
    ROUND(
        100.0 * (total_trips - previous_day_trips)
        / NULLIF(previous_day_trips, 0),
        2
    ) AS daily_change_pct
FROM daily_comparison
ORDER BY trip_date;


-- 03. Week-over-Week (WoW) change
-- Compare each day with the same weekday in the previous week.
-- LAG(7) assumes the daily series has no missing dates.

WITH daily_trips AS (
    SELECT
        tpep_pickup_datetime::date AS trip_date,
        COUNT(*) AS total_trips
    FROM yellow_taxi_data_pipeline
    WHERE
        tpep_pickup_datetime >= '2021-01-01'
        AND tpep_pickup_datetime < '2021-02-01'
    GROUP BY tpep_pickup_datetime::date
),
weekly_comparison AS (
    SELECT
        trip_date,
        total_trips,
        LAG(total_trips, 7) OVER (
            ORDER BY trip_date
        ) AS previous_week_trips
    FROM daily_trips
)
SELECT
    trip_date,
    TO_CHAR(trip_date, 'Dy') AS day_of_week,
    total_trips,
    previous_week_trips,
    ROUND(
        100.0 * (total_trips - previous_week_trips)
        / NULLIF(previous_week_trips, 0),
        2
    ) AS weekly_change_pct
FROM weekly_comparison
WHERE previous_week_trips IS NOT NULL
ORDER BY trip_date;


-- 04. Combined daily analytics
-- Calculate DoD, WoW and rolling average in a single query.

WITH daily_trips AS (
    SELECT
        tpep_pickup_datetime::date AS trip_date,
        COUNT(*) AS total_trips
    FROM yellow_taxi_data_pipeline
    WHERE
        tpep_pickup_datetime >= '2021-01-01'
        AND tpep_pickup_datetime < '2021-02-01'
    GROUP BY tpep_pickup_datetime::date
),
daily_metrics AS (
    SELECT
        trip_date,
        total_trips,
        LAG(total_trips, 1) OVER (
            ORDER BY trip_date
        ) AS previous_day,
        LAG(total_trips, 7) OVER (
            ORDER BY trip_date
        ) AS previous_week,
        AVG(total_trips) OVER (
            ORDER BY trip_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS rolling_avg_7d
    FROM daily_trips
)
SELECT
    trip_date,
    total_trips,
    ROUND(
        100.0 * (total_trips - previous_day)
        / NULLIF(previous_day, 0),
        2
    ) AS dod_pct,
    ROUND(
        100.0 * (total_trips - previous_week)
        / NULLIF(previous_week, 0),
        2
    ) AS wow_pct,
    ROUND(rolling_avg_7d, 2) AS rolling_avg_7d
FROM daily_metrics
ORDER BY trip_date;
