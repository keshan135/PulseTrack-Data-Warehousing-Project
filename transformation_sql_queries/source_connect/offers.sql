{{ config(materialized='view') }}

select * from {{ source('pulsetrack_silver','offers_raw') }}