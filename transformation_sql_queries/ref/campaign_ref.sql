{{ config(materialized='table') }}


with campaign as(
    select
    cast(trim(campaign_id) as varchar) as campaign_ID,
    initcap(trim(campaign_name)) as campaign_Name,
    upper(trim(offer_id)) as offer_ID,
    cast(trim(advertiser_id) as varchar)as advertiser_ID,
    upper(price_type) as price_type,
    start_date as start_date_raw,
    end_date as end_date_raw,
    created_at as raw_created_at,
    updated_at as raw_updated_at
    from {{ref("campaigns")}} where trim(campaign_id)!='campaign_id'
),
dates as(
    select
    campaign_ID,
    campaign_Name,
    offer_ID,
    advertiser_ID,
    price_type,
    case
            when start_date_raw ~ '^[0-9]{10}$' then to_timestamp(start_date_raw::bigint)
            when start_date_raw ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' then to_timestamp(start_date_raw, 'YYYY-MM-DD HH24:MI:SS')
            when start_date_raw ~ '^\d{4}-\d{2}-\d{2}$' then to_timestamp(start_date_raw, 'YYYY-MM-DD')::timestamp
            when start_date_raw ~ '^\d{2}/\d{2}/\d{4}$' then to_timestamp(start_date_raw, 'MM/DD/YYYY')::timestamp
            when start_date_raw ~ '^\d{2}-\d{2}-\d{4}$' then to_timestamp(start_date_raw, 'DD-MM-YYYY')::timestamp
            when start_date_raw ~ '^[A-Za-z]{3} \d{1,2}, \d{4}$' then to_timestamp(start_date_raw, 'Mon DD, YYYY')::timestamp
            else NULL
        end as start_date,
    case
            when end_date_raw ~ '^[0-9]{10}$' then to_timestamp(end_date_raw::bigint)
            when end_date_raw ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' then to_timestamp(end_date_raw, 'YYYY-MM-DD HH24:MI:SS')
            when end_date_raw ~ '^\d{4}-\d{2}-\d{2}$' then to_timestamp(end_date_raw, 'YYYY-MM-DD')::timestamp
            when end_date_raw ~ '^\d{2}/\d{2}/\d{4}$' then to_timestamp(end_date_raw, 'MM/DD/YYYY')::timestamp
            when end_date_raw ~ '^\d{2}-\d{2}-\d{4}$' then to_timestamp(end_date_raw, 'DD-MM-YYYY')::timestamp
            when end_date_raw ~ '^[A-Za-z]{3} \d{1,2}, \d{4}$' then to_timestamp(end_date_raw, 'Mon DD, YYYY')::timestamp
            else NULL
        end as end_date,
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
    from campaign
)

select * from dates