
-- ============================================================
-- Data Engineering Journey
-- Module 01 - SQL Fundamentals
-- Dataset: NYC Yellow Taxi, January 2021
-- Database: ny_taxi
-- ============================================================


-- 01. Dataset overview
-- Count trips, distinct pickup/dropoff locations, and average distance.

SELECT
    COUNT(*) AS total_trips,
    COUNT(DISTINCT "PULocationID") AS pickup_locations,
    COUNT(DISTINCT "DOLocationID") AS dropoff_locations,
    ROUND(AVG(trip_distance)::numeric, 2) AS avg_trip_distance
FROM yellow_taxi_data_pipeline;


-- 02. Top 10 pickup locations
-- Aggregate trips and averages by pickup location.

SELECT
    "PULocationID" AS pickup_location,
    COUNT(*) AS total_trips,
    ROUND(AVG(trip_distance)::numeric, 2) AS avg_distance,
    ROUND(AVG(total_amount)::numeric, 2) AS avg_amount
FROM yellow_taxi_data_pipeline
GROUP BY "PULocationID"
ORDER BY total_trips DESC
LIMIT 10;


-- 03. WHERE vs HAVING
-- Filter individual trips before aggregation (WHERE).
-- Filter aggregated location groups afterwards (HAVING).

SELECT
    "PULocationID" AS pickup_location,
    COUNT(*) AS total_trips,
    ROUND(AVG(trip_distance)::numeric, 2) AS avg_distance
FROM yellow_taxi_data_pipeline
WHERE
    tpep_pickup_datetime >= '2021-01-01'
    AND tpep_pickup_datetime < '2021-02-01'
    AND trip_distance > 0
GROUP BY "PULocationID"
HAVING COUNT(*) >= 1000
ORDER BY avg_distance DESC
LIMIT 10;


-- 04. Data quality: pickup timestamp range and invalid distances

SELECT
    COUNT(*) AS total_trips,
    MIN(tpep_pickup_datetime) AS first_pickup,
    MAX(tpep_pickup_datetime) AS last_pickup,
    COUNT(*) FILTER (
        WHERE tpep_pickup_datetime IS NULL
    ) AS null_pickup_dates,
    COUNT(*) FILTER (
        WHERE trip_distance < 0
    ) AS negative_distances
FROM yellow_taxi_data_pipeline;


-- 05. Data quality: trips outside January 2021

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
