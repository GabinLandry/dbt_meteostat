WITH weather AS (
    SELECT *
    FROM {{ ref('prep_weather_daily') }}
),
weekly_weather AS (
    SELECT
        airport_code,
        station_id,
        date_trunc('week', date) AS week_start,
        EXTRACT(YEAR FROM date) AS year,
        cw,
        AVG(avg_temp_c) AS avg_temp_c,
        MIN(min_temp_c) AS min_temp_c,
        MAX(max_temp_c) AS max_temp_c,
        SUM(precipitation_mm) AS precipitation_mm,
        SUM(max_snow_mm) AS snow_mm,
        MODE() WITHIN GROUP (
            ORDER BY avg_wind_direction
        ) AS prevailing_wind_direction,
        AVG(avg_wind_speed_kmh) AS avg_wind_speed_kmh,
        MAX(wind_peakgust_kmh) AS wind_peakgust_kmh,
        SUM(sun_minutes) AS sun_minutes,
        MODE() WITHIN GROUP (
            ORDER BY season
        ) AS season,
        MODE() WITHIN GROUP (
            ORDER BY month_name
        ) AS month_name
    FROM weather
    GROUP BY
        airport_code,
        station_id,
        date_trunc('week', date),
        EXTRACT(YEAR FROM date),
        cw
)
SELECT *
FROM weekly_weather
ORDER BY
    airport_code,
    week_start