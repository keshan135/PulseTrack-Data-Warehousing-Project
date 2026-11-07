{{ config(materialized='view') }}

select * from {{ source('pulsetrack_silver','conversion_touchpoints_raw') }}