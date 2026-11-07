{{ config(materialized='view') }}

select * from {{ source('pulsetrack_silver','clicks_raw') }}