{{ config(materialized='view') }}

select * from {{ source('pulsetrack_silver','campaigns_raw') }}