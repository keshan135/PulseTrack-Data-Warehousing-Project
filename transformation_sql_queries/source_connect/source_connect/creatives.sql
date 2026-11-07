{{ config(materialized='view') }}

select * from {{ source('pulsetrack_silver','creatives_raw') }}