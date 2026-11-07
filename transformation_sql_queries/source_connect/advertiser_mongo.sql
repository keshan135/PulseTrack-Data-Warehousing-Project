{{ config(materialized='view') }}

select * from {{ source('pulsetrack_silver_mongo','advertiser_accounts_raw') }}