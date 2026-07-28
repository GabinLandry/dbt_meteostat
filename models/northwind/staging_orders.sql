WITH source_data AS (
    SELECT *
    FROM {{ source('northwind_data', 'orders') }}
)
SELECT
    order_id
    ,customer_id
    ,employee_id
    ,order_date::DATE AS order_date
    ,required_date::DATE AS required_date
    ,shipped_date::DATE AS shipped_date
    ,ship_via
	,freight
	,ship_name
	,ship_address
    ,ship_city
	,ship_region
	,ship_postal_code
    ,ship_country
FROM source_data