WITH source_data AS (
    SELECT *
    FROM {{ source('northwind_data', 'products') }}
)
SELECT
    product_id,
    product_name,
    supplier_id,
    category_id,
    quantity_per_unit,
    unit_price::NUMERIC AS unit_price,
    units_in_stock::INTEGER AS units_in_stock,
    units_on_order::INTEGER AS units_on_order,
    reorder_level::INTEGER AS reorder_level,
    discontinued
FROM source_data