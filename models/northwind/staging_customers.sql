WITH source_data AS (
    SELECT *
    FROM {{ source('northwind', 'customers') }}
)
SELECT 
	customerid AS customer_id
	,companyname AS company_name
	,contactname AS contact_name
    ,address
    ,city
    ,region
    ,country
	,contacttitle AS contact_title
    ,postalcode AS postal_code
    ,phone
    ,fax
FROM source_data