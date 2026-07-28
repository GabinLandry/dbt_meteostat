WITH source_data AS (
    SELECT *
    FROM {{ source('northwind_data', 'products') }}
)
SELECT
    customer_id,
    company_name,
    contact_name,
    contact_title,
    address,
    city,
    region,
    postal_code,
    country,
    phone,
    fax
FROM source_data