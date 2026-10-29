
-- ============================================================
-- Data Engineering Journey
-- Module 01 - SQL Joins
-- Dataset: NYC Yellow Taxi, January 2021
-- Database: ny_taxi
--
-- Tables:
--   yellow_taxi_data_pipeline - Trip records
--   taxi_zones                - Taxi zone lookup
-- ============================================================


-- 01. Top 10 pickup zones
-- INNER JOIN: match trips with their pickup zone names.

SELECT
    z."Borough" AS borough,
    z."Zone" AS pickup_zone,
    COUNT(*) AS total_trips,
    ROUND(AVG(t.trip_distance)::numeric, 2) AS avg_distance,
    ROUND(AVG(t.total_amount)::numeric, 2) AS avg_amount
FROM yellow_taxi_data_pipeline AS t
INNER JOIN taxi_zones AS z
    ON t."PULocationID" = z."LocationID"
GROUP BY
    z."Borough",
    z."Zone"
ORDER BY total_trips DESC
LIMIT 10;


-- 02. Validate pickup zone relationships
-- LEFT JOIN retains all trips, including unmatched records.

SELECT
    COUNT(*) AS total_trips,
    COUNT(z."LocationID") AS matched_trips,
    COUNT(*) - COUNT(z."LocationID") AS unmatched_trips
FROM yellow_taxi_data_pipeline AS t
LEFT JOIN taxi_zones AS z
    ON t."PULocationID" = z."LocationID";


-- 03. Pickup and dropoff zone names
-- Role-playing dimension: taxi_zones is joined twice.

SELECT
    t.tpep_pickup_datetime,
    pickup."Borough" AS pickup_borough,
    pickup."Zone" AS pickup_zone,
    dropoff."Borough" AS dropoff_borough,
    dropoff."Zone" AS dropoff_zone,
    t.trip_distance,
    t.total_amount
FROM yellow_taxi_data_pipeline AS t
LEFT JOIN taxi_zones AS pickup
    ON t."PULocationID" = pickup."LocationID"
LEFT JOIN taxi_zones AS dropoff
    ON t."DOLocationID" = dropoff."LocationID"
ORDER BY t.tpep_pickup_datetime
LIMIT 10;


-- 04. Validate pickup and dropoff relationships
-- Check referential integrity for both location identifiers.

SELECT
    COUNT(*) AS total_trips,
    COUNT(*) FILTER (
        WHERE pickup."LocationID" IS NULL
    ) AS unmatched_pickups,
    COUNT(*) FILTER (
        WHERE dropoff."LocationID" IS NULL
    ) AS unmatched_dropoffs,
    COUNT(*) FILTER (
        WHERE pickup."LocationID" IS NOT NULL
          AND dropoff."LocationID" IS NOT NULL
    ) AS fully_matched_trips
FROM yellow_taxi_data_pipeline AS t
LEFT JOIN taxi_zones AS pickup
    ON t."PULocationID" = pickup."LocationID"
LEFT JOIN taxi_zones AS dropoff
    ON t."DOLocationID" = dropoff."LocationID";


-- 05. Top 10 pickup-to-dropoff borough combinations
-- Aggregate trips between boroughs during January 2021.

SELECT
    pickup."Borough" AS pickup_borough,
    dropoff."Borough" AS dropoff_borough,
    COUNT(*) AS total_trips,
    ROUND(AVG(t.trip_distance)::numeric, 2) AS avg_distance,
    ROUND(AVG(t.total_amount)::numeric, 2) AS avg_amount
FROM yellow_taxi_data_pipeline AS t
INNER JOIN taxi_zones AS pickup
    ON t."PULocationID" = pickup."LocationID"
INNER JOIN taxi_zones AS dropoff
    ON t."DOLocationID" = dropoff."LocationID"
WHERE
    t.tpep_pickup_datetime >= '2021-01-01'
    AND t.tpep_pickup_datetime < '2021-02-01'
GROUP BY
    pickup."Borough",
    dropoff."Borough"
ORDER BY total_trips DESC
LIMIT 10;
