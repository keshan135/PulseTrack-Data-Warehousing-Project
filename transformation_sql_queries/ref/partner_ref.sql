{{ config(materialized='table') }}

with partner as(
    select
    cast(partner_id as numeric) as partner_ID,
    initcap(trim(partner_name)) as partner_Name,
    initcap(trim(channel)) as channel,
    initcap(trim(media_buyer)) as media_buyer,
    trim(payment_terms) as payment_terms,
    join_date as join_date_raws,
    created_at as raw_created_at,
    updated_at as raw_updated_at
    from {{ ref('partners') }}
),
dates as(
    select
        partner_ID,
        partner_Name,
        channel,
        media_buyer,
        payment_terms,
        case
            when join_date_raws ~ '^[0-9]{10}$' then to_timestamp(join_date_raws::bigint)
            when join_date_raws ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' then to_timestamp(join_date_raws, 'YYYY-MM-DD HH24:MI:SS')
            when join_date_raws ~ '^\d{4}-\d{2}-\d{2}$' then to_timestamp(join_date_raws, 'YYYY-MM-DD')::timestamp
            when join_date_raws ~ '^\d{2}/\d{2}/\d{4}$' then to_timestamp(join_date_raws, 'MM/DD/YYYY')::timestamp
            when join_date_raws ~ '^\d{2}-\d{2}-\d{4}$' then to_timestamp(join_date_raws, 'DD-MM-YYYY')::timestamp
            when join_date_raws ~ '^[A-Za-z]{3} \d{1,2}, \d{4}$' then to_timestamp(join_date_raws, 'Mon DD, YYYY')::timestamp
            else NULL
        end as join_date,
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
    from partner
)

select * from dates