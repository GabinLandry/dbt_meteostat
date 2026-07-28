WITH source_data AS (
    SELECT *
    FROM {{ source('northwind_data', 'categories') }}
)
SELECT 
	category_id
	,category_name
	,description
	,picture
FROM source_data