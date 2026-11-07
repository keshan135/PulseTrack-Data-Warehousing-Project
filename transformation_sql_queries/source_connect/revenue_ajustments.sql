{{ config(materialized='view') }}

select * from {{ source('pulsetrack_silver','revenue_adjustments_raw') }}