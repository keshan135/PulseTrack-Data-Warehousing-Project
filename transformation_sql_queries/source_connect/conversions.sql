{{ config(materialized='view') }}

select * from {{ source('pulsetrack_silver','conversions_raw') }}