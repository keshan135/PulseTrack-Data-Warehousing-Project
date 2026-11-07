{{ config(materialized='table') }}

with advertiser as(
    select
        cast(trim(advertiser_id) as varchar) as advertiser_id,
        trim(legal_name) as legal_name_raw,
        trim(display_name)as display_name,
        trim(vertical)as vertical,
        trim(status) as status,
        upper(trim(billing ->> 'country')) as billing_country,
        upper(trim(billing ->> 'currency')) as billing_currency,
        "createdAt" as created_at,
        "updatedAt" as updated_at

    from {{ ref("advertiser_mongo") }}


)
,cleaned as (
    select
        advertiser_id,
        TRIM(
            REGEXP_REPLACE(
            legal_name_raw,
            ',?\s*LLC$',
            '',
            'i'
            )
        ) AS legal_name,
        display_name,
        vertical,
        status,
        billing_country,
        billing_currency,
        created_at,
        updated_at
    from advertiser
)
select * from cleaned