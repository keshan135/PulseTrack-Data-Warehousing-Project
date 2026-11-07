{{ config(materialized='table') }}

with offer as(
    select
    cast(trim(offer_id) as varchar) as offer_ID,
    initcap(trim(offer_name)) as offer_Name,
    cast(trim(advertiser_id) as varchar) as advertiser_ID,
    initcap(trim(vertical)) as vertical,
    trim(default_payout) as default_pay_raw,
    upper(payout_type) as payout_type,
    created_at as raw_created_at,
    updated_at as raw_updated_at
    from {{ ref('offers') }} where trim(offer_id)!='offer_id'
),
dates as(
    select
        offer_ID,
        offer_Name,
        advertiser_ID,
        vertical,
        default_pay_raw,
        payout_type,

        case
            when raw_created_at ~ '^[0-9]{10}$' then to_timestamp(raw_created_at::bigint)
            when raw_created_at ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' then to_timestamp(raw_created_at, 'YYYY-MM-DD HH24:MI:SS')
            when raw_created_at ~ '^\d{4}-\d{2}-\d{2}$' then to_timestamp(raw_created_at, 'YYYY-MM-DD')::timestamp
            when raw_created_at ~ '^\d{2}/\d{2}/\d{4}$' then to_timestamp(raw_created_at, 'MM/DD/YYYY')::timestamp
            when raw_created_at ~ '^\d{2}-\d{2}-\d{4}$' then to_timestamp(raw_created_at, 'DD-MM-YYYY')::timestamp
            when raw_created_at ~ '^[A-Za-z]{3} \d{1,2}, \d{4}$' then to_timestamp(raw_created_at, 'Mon DD, YYYY')::timestamp
            else NULL
        end as created_at,

        case
            when raw_updated_at ~ '^[0-9]{10}$' then to_timestamp(raw_updated_at::bigint)
            when raw_updated_at ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' then to_timestamp(raw_updated_at, 'YYYY-MM-DD HH24:MI:SS')
            when raw_updated_at ~ '^\d{4}-\d{2}-\d{2}$' then to_timestamp(raw_updated_at, 'YYYY-MM-DD')::timestamp
            when raw_updated_at ~ '^\d{2}/\d{2}/\d{4}$' then to_timestamp(raw_updated_at, 'MM/DD/YYYY')::timestamp
            when raw_updated_at ~ '^\d{2}-\d{2}-\d{4}$' then to_timestamp(raw_updated_at, 'DD-MM-YYYY')::timestamp
            when raw_updated_at ~ '^[A-Za-z]{3} \d{1,2}, \d{4}$' then to_timestamp(raw_updated_at, 'Mon DD, YYYY')::timestamp
            else NULL
        end as updated_at
    from offer
),currency as(
    select
    offer_ID,
    offer_Name,
    advertiser_ID,
    vertical,
    cast(replace(replace(default_pay_raw,'USD',''),'$','') as numeric(5,2)) as default_payout,
    payout_type,
    created_at,
    updated_at
    from dates
)

select * from currency