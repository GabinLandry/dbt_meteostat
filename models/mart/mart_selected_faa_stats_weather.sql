WITH flights AS (
    SELECT *
    FROM {{ ref('prep_flights') }}
),

airports AS (
    SELECT *
    FROM {{ ref('prep_airports') }}
),

weather AS (
    SELECT *
    FROM {{ ref('prep_weather_daily') }}
),
departure_stats AS (
    SELECT
        origin AS airport_code,
        flight_date AS date,
        COUNT(DISTINCT dest) AS departure_connections,
        COUNT(*) AS planned_departures,
        COUNT(*) FILTER (
            WHERE cancelled = 1
        ) AS cancelled_departures,
        COUNT(*) FILTER (
            WHERE diverted = 1
        ) AS diverted_departures,
        COUNT(*) FILTER (
            WHERE cancelled = 0
        ) AS actual_departures,
        COUNT(DISTINCT tail_number) FILTER (
            WHERE cancelled = 0
        ) AS unique_airplanes,
        COUNT(DISTINCT airline) FILTER (
            WHERE cancelled = 0
        ) AS unique_airlines
    FROM flights
    GROUP BY
        origin,
        flight_date
),
arrival_stats AS (
    SELECT
        dest AS airport_code,
        flight_date AS date,
        COUNT(DISTINCT origin) AS arrival_connections,
        COUNT(*) AS planned_arrivals,
        COUNT(*) FILTER (
            WHERE cancelled = 1
        ) AS cancelled_arrivals,
        COUNT(*) FILTER (
            WHERE diverted = 1
        ) AS diverted_arrivals,
        COUNT(*) FILTER (
            WHERE cancelled = 0
        ) AS actual_arrivals
    FROM flights
    GROUP BY
        dest,
        flight_date
),
airport_day_stats AS (
    SELECT
        w.airport_code,
        w.date,
        COALESCE(d.departure_connections, 0) AS departure_connections,
        COALESCE(a.arrival_connections, 0) AS arrival_connections,
        COALESCE(d.planned_departures, 0)
            + COALESCE(a.planned_arrivals, 0)
            AS total_planned_flights,
        COALESCE(d.cancelled_departures, 0)
            + COALESCE(a.cancelled_arrivals, 0)
            AS total_cancelled_flights,
        COALESCE(d.diverted_departures, 0)
            + COALESCE(a.diverted_arrivals, 0)
            AS total_diverted_flights,
        COALESCE(d.actual_departures, 0)
            + COALESCE(a.actual_arrivals, 0)
            AS total_actual_flights,
        d.unique_airplanes,
        d.unique_airlines,
        w.min_temp_c,
        w.max_temp_c,
        w.precipitation_mm,
        w.max_snow_mm,
        w.avg_wind_direction,
        w.avg_wind_speed_kmh,
        w.wind_peakgust_kmh
    FROM weather AS w
    LEFT JOIN departure_stats AS d
        ON w.airport_code = d.airport_code
       AND w.date = d.date
    LEFT JOIN arrival_stats AS a
        ON w.airport_code = a.airport_code
       AND w.date = a.date
)
SELECT
    s.airport_code,
    ap.name AS airport_name,
    ap.city,
    ap.country,
    s.date,
    s.departure_connections,
    s.arrival_connections,
    s.total_planned_flights,
    s.total_cancelled_flights,
    s.total_diverted_flights,
    s.total_actual_flights,
    s.unique_airplanes,
    s.unique_airlines,
    s.min_temp_c,
    s.max_temp_c,
    s.precipitation_mm,
    s.max_snow_mm,
    s.avg_wind_direction,
    s.avg_wind_speed_kmh,
    s.wind_peakgust_kmh
FROM airport_day_stats AS s
LEFT JOIN airports AS ap
    ON s.airport_code = ap.faa
ORDER BY
    s.date,
    s.airport_code