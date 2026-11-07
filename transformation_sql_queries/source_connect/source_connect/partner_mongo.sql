{{ config(materialized='view') }}

select * from {{ source('pulsetrack_silver_mongo','partner_profiles_raw') }}