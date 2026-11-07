{{ config(materialized='table') }}

with impression as(
    select
    cast(impression_id as varchar) as impression_ID,
    cast(campaign_id as varchar) as campaign_ID,
    cast(creative_id as varchar) as creative_id,
    partner_id as partner_id_raw,
    impression_time as impression_time_raw,
    initcap(trim(placement_raw)) as placemenet,
    country as country_raw,
    initcap(trim(device)) as device,
    cast(bot_score as numeric(4,3)) as bot_score,
    created_at as raw_created_at,
    updated_at as raw_updated_at
    from {{ ref("impressions") }}
),
dates as(
    select
        impression_ID,
        campaign_ID,
        creative_id,
        partner_id_raw,
        case
            when impression_time_raw ~ '^[0-9]{10}$' then
                to_timestamp(impression_time_raw::bigint)
            when impression_time_raw ~ '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$' then
                impression_time_raw::timestamptz
            when impression_time_raw ~ '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}' then
                to_timestamp(left(replace(impression_time_raw, 'T', ' '), 19), 'YYYY-MM-DD HH24:MI:SS')
            when impression_time_raw ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' then
                to_timestamp(impression_time_raw, 'YYYY-MM-DD HH24:MI:SS')
            when impression_time_raw ~ '^\d{4}-\d{2}-\d{2}$' then
                to_timestamp(impression_time_raw, 'YYYY-MM-DD')::timestamp
            when impression_time_raw ~ '^[A-Za-z]{3} \d{1,2}, \d{4}$' then
                to_timestamp(impression_time_raw, 'Mon DD, YYYY')::timestamp
            else null
        end as impression_time,
        placemenet,
        country_raw,
        device,
        bot_score,
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
    from impression
),replacement as(
    select
        impression_ID,
        campaign_ID,
        creative_id,
        CASE
            WHEN TRIM(partner_id_raw) ~ '^[0-9]{5}_[0-9]+$' THEN SPLIT_PART(TRIM(partner_id_raw), '_', 1)
            WHEN TRIM(partner_id_raw) ~ '^[0-9]{5}$' THEN TRIM(partner_id_raw)
            ELSE NULL
        END AS partner_id,
        impression_time,
        placemenet,
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
        bot_score,
        created_at,
        updated_at
    from dates

),cleaned as(
    select
        impression_ID,
        campaign_ID,
        creative_id,
        CAST(partner_id AS NUMERIC) AS partner_id,
        impression_time,
        placemenet,
        country,
        device,
        bot_score,
        created_at,
        updated_at
    from replacement
)

select * from cleaned