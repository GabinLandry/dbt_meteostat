WITH flights AS (
    SELECT *
    FROM {{ ref('prep_flights') }}
),

airports AS (
    SELECT *
    FROM {{ ref('prep_airports') }}
),
departure_stats AS ( -- every question for 
    SELECT
        origin AS faa, -- compare the dept airports


        COUNT(DISTINCT dest) AS unique_departure_connections,


        COUNT(*) AS planned_departures,


 -- filter all cancelled and        
        
        COUNT(*) FILTER (
            WHERE cancelled = 1
        ) AS cancelled_departures,


        COUNT(*) FILTER (
            WHERE diverted = 1
        ) AS diverted_departures,


        COUNT(*) FILTER (
            WHERE cancelled = 0
              AND diverted = 0
        ) AS occurred_departures


    FROM flights
    GROUP BY origin
),
arrival_stats AS (
    SELECT
        dest AS faa,


        COUNT(DISTINCT origin) AS unique_arrival_connections,


        COUNT(*) AS planned_arrivals,


        COUNT(*) FILTER (
            WHERE cancelled = 1
        ) AS cancelled_arrivals,


        COUNT(*) FILTER (
            WHERE diverted = 1
        ) AS diverted_arrivals,


        COUNT(*) FILTER (
            WHERE cancelled = 0
              AND diverted = 0
        ) AS occurred_arrivals


    FROM flights
    GROUP BY dest
),
airport_stats AS (
    SELECT
        a.faa,
        a.name AS airport_name,
        a.city,
        a.country,


        COALESCE(d.unique_departure_connections, 0)
            AS unique_departure_connections,


        COALESCE(r.unique_arrival_connections, 0)
            AS unique_arrival_connections,


        COALESCE(d.planned_departures, 0)
            + COALESCE(r.planned_arrivals, 0)
            AS planned_flights_total,


        COALESCE(d.cancelled_departures, 0)
            + COALESCE(r.cancelled_arrivals, 0)
            AS cancelled_flights_total,


        COALESCE(d.diverted_departures, 0)
            + COALESCE(r.diverted_arrivals, 0)
            AS diverted_flights_total,


        COALESCE(d.occurred_departures, 0)
            + COALESCE(r.occurred_arrivals, 0)
            AS occurred_flights_total


    FROM airports AS a


    LEFT JOIN departure_stats AS d
        ON a.faa = d.faa


    LEFT JOIN arrival_stats AS r
        ON a.faa = r.faa
)
SELECT *
FROM airport_stats
ORDER BY planned_flights_total DESC