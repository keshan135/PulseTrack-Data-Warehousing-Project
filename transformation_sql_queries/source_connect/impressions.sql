{{ config(materialized='view') }}

select * from {{ source('pulsetrack_silver','impressions_raw') }}