{{ config(materialized='view') }}

select * from {{ source('pulsetrack_silver','partners_raw') }}