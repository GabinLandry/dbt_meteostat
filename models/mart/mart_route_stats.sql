WITH flights AS (
    SELECT *
    FROM {{ ref('prep_flights') }}
),

airports AS (
    SELECT *
    FROM {{ ref('prep_airports') }}
),
route_stats AS (
    SELECT
        origin AS origin_airport_code,
        dest AS destination_airport_code,
        COUNT(*) AS total_flights_on_route,
        COUNT(DISTINCT tail_number) AS unique_airplanes,
        COUNT(DISTINCT airline) AS unique_airlines,
        AVG(actual_elapsed_time) FILTER (
            WHERE cancelled = 0
        ) AS avg_actual_elapsed_time,
        AVG(arr_delay) FILTER (
            WHERE cancelled = 0
        ) AS avg_arrival_delay,
        MAX(arr_delay) FILTER (
            WHERE cancelled = 0
        ) AS max_arrival_delay,
        MIN(arr_delay) FILTER (
            WHERE cancelled = 0
        ) AS min_arrival_delay,
        COUNT(*) FILTER (
            WHERE cancelled = 1
        ) AS total_cancelled,
        COUNT(*) FILTER (
            WHERE diverted = 1
        ) AS total_diverted
  FROM flights
    GROUP BY
        origin,
        dest
)
SELECT
    r.origin_airport_code,
    o.name AS origin_airport_name,
    o.city AS origin_city,
    o.country AS origin_country,
    r.destination_airport_code,
    d.name AS destination_airport_name,
    d.city AS destination_city,
    d.country AS destination_country,
    r.total_flights_on_route,
    r.unique_airplanes,
    r.unique_airlines,
    r.avg_actual_elapsed_time,
    r.avg_arrival_delay,
    r.max_arrival_delay,
    r.min_arrival_delay,
    r.total_cancelled,
    r.total_diverted
FROM route_stats AS r
LEFT JOIN airports AS o
    ON r.origin_airport_code = o.faa
LEFT JOIN airports AS d
    ON r.destination_airport_code = d.faa
ORDER BY
    r.total_flights_on_route DESC