{{ config(materialized='table') }}

with history as(
    select
        cast(trim(advertiser_id) as varchar) as advertiser_id,
        trim(manager_history ->> 'am_id')as am_id,
        trim(manager_history ->> 'am_name')as am_name,
        trim(manager_history ->> 'from')::date as validate_from,
        trim(manager_history ->> 'to')::date as validate_to

    from {{ ref("advertiser_mongo") }}
    CROSS JOIN LATERAL
        jsonb_array_elements(account_manager_history) AS manager_history
),cleaned as(
    select
        advertiser_id,
        am_id,
        am_name,
        validate_from,
        validate_to
    from history
)

select * from cleaned