{{ config(materialized='view') }}

select * from {{ source('staging', 'green_tripdata_external') }}
limit 10