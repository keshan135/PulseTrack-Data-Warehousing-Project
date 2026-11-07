{{ config(materialized='view') }}

select * from {{ source('pulsetrack_silver','account_managers_raw') }}