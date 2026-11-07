{{ config(materialized='table') }}

with clicks as(
    select
    cast(click_id as varchar) as click_ID,
    cast(impression_id as varchar) as impression_ID,
    cast(campaign_id as varchar) as campaign_ID,
    cast(creative_id as varchar) as creative_id,
    partner_id as partner_id_raw,
    click_time as click_time_raw,
    trim(ip) as ip,
    trim(user_agent) as user_agent,
    trim(country) as country_raw,
    initcap(trim(device)) as device,
    is_unique as is_unique,
    trim(referrer_raw) as referrer,
    created_at as raw_created_at,
    updated_at as raw_updated_at
    from {{ ref("clicks") }} where trim(click_id) != 'click_id'
),
dates as(
    select
        click_ID,
        impression_ID,
        campaign_ID,
        creative_id,
        partner_id_raw,
        case
            when click_time_raw ~ '^[0-9]{10}$' then
                to_timestamp(click_time_raw::bigint)
            when click_time_raw ~ '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$' then
                click_time_raw::timestamptz
            when click_time_raw ~ '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}' then
                to_timestamp(left(replace(click_time_raw, 'T', ' '), 19), 'YYYY-MM-DD HH24:MI:SS')
            when click_time_raw ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' then
                to_timestamp(click_time_raw, 'YYYY-MM-DD HH24:MI:SS')
            when click_time_raw ~ '^\d{4}-\d{2}-\d{2}$' then
                to_timestamp(click_time_raw, 'YYYY-MM-DD')::timestamp
            when click_time_raw ~ '^[A-Za-z]{3} \d{1,2}, \d{4}$' then
                to_timestamp(click_time_raw, 'Mon DD, YYYY')::timestamp
            else null
        end as click_time,
        ip,
        user_agent,
        country_raw,
        device,
        is_unique,
        referrer,
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
    from clicks
),replacement as(
    select
        click_ID,
        impression_ID,
        campaign_ID,
        creative_id,
        CASE
            WHEN TRIM(partner_id_raw) ~ '^[0-9]{5}_[0-9]+$' THEN SPLIT_PART(TRIM(partner_id_raw), '_', 1)
            WHEN TRIM(partner_id_raw) ~ '^[0-9]{5}$' THEN TRIM(partner_id_raw)
            ELSE NULL
        END AS partner_id,
        click_time,
        ip,
        user_agent,
        case
            when country_raw='US' then replace(country_raw,'US','USA')
            when country_raw='United States' then replace(country_raw,'United States','USA')
            when country_raw='USA' then replace(country_raw,'USA','USA')
            when country_raw='AU' then replace(country_raw,'AU','AU')
            when country_raw='Australia' then replace(country_raw,'Australia','AU')
            when country_raw='U.S.' then replace(country_raw,'U.S.','USA')
            when country_raw='Canada' then replace(country_raw,'Canada','CA')
            when country_raw='us' then replace(country_raw,'us','USA')
            when country_raw='UK' then replace(country_raw,'UK','UK')
            when country_raw='GB' then replace(country_raw,'GB','GB')
            when country_raw='CA' then replace(country_raw,'CA','CA')
            else null
        end as country,
        device,
        case
            when is_unique='1' then 'TRUE'
            when is_unique='true' then 'TRUE'
            when is_unique='Y' then 'TRUE'
            when is_unique='0' then 'FALSE'
            when is_unique='false' then 'FALSE'
            when is_unique='N' then 'FALSE'
            else null
        end as is_unique,
        referrer,
        created_at,
        updated_at
    from dates

),cleaned as(
    select
        click_ID,
        impression_ID,
        campaign_ID,
        creative_id,
        cast(partner_id as numeric)as partner_id,
        click_time,
        ip,
        user_agent,
        country,
        device,
        cast(is_unique as boolean) as is_unique,
        referrer,
        created_at,
        updated_at
    from replacement
)

select * from cleaned