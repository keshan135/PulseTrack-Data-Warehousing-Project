{{ config(materialized='view') }}

select * from {{ source('pulsetrack_silver','advertisers_raw') }}