{{ config(materialized='table') }}

with advertiser as(
    select
    cast(trim(advertiser_id) as varchar) as advertiser_ID,
    cast(trim(account_manager_id)as varchar) as AM_ID,
    initcap(trim(advertiser_name)) as advertiser_Name,
    lower(trim(vertical)) as vertical,
    upper(trim(status)) as status,
    upper(trim(billing_country)) as billing_country,
    signup_date as signup_date_raw,
    created_at as created_at_raw,
    updated_at as updated_at_raw
    from {{ ref("advertisers")}}
    where lower(trim(advertiser_id)) != 'advertiser_id'
),
dates as(
    select
    advertiser_ID,
    AM_ID,
    advertiser_Name,
    vertical,
    status,
    billing_country,
    case
            when signup_date_raw ~ '^[0-9]{10}$' then to_timestamp(signup_date_raw::bigint)
            when signup_date_raw ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' then to_timestamp(signup_date_raw, 'YYYY-MM-DD HH24:MI:SS')
            when signup_date_raw ~ '^\d{4}-\d{2}-\d{2}$' then to_timestamp(signup_date_raw, 'YYYY-MM-DD')::timestamp
            when signup_date_raw ~ '^\d{2}/\d{2}/\d{4}$' then to_timestamp(signup_date_raw, 'MM/DD/YYYY')::timestamp
            when signup_date_raw ~ '^\d{2}-\d{2}-\d{4}$' then to_timestamp(signup_date_raw, 'DD-MM-YYYY')::timestamp
            when signup_date_raw ~ '^[A-Za-z]{3} \d{1,2}, \d{4}$' then to_timestamp(signup_date_raw, 'Mon DD, YYYY')::timestamp
            else NULL
        end as signup_date,
    case
            when created_at_raw ~ '^[0-9]{10}$' then to_timestamp(created_at_raw::bigint)
            when created_at_raw ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' then to_timestamp(created_at_raw, 'YYYY-MM-DD HH24:MI:SS')
            when created_at_raw ~ '^\d{4}-\d{2}-\d{2}$' then to_timestamp(created_at_raw, 'YYYY-MM-DD')::timestamp
            when created_at_raw~ '^\d{2}/\d{2}/\d{4}$' then to_timestamp(created_at_raw, 'MM/DD/YYYY')::timestamp
            when created_at_raw ~ '^\d{2}-\d{2}-\d{4}$' then to_timestamp(created_at_raw, 'DD-MM-YYYY')::timestamp
            when created_at_raw ~ '^[A-Za-z]{3} \d{1,2}, \d{4}$' then to_timestamp(created_at_raw, 'Mon DD, YYYY')::timestamp
            else NULL
        end as created_at,
    case
            when updated_at_raw ~ '^[0-9]{10}$' then to_timestamp(updated_at_raw::bigint)
            when updated_at_raw ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' then to_timestamp(updated_at_raw, 'YYYY-MM-DD HH24:MI:SS')
            when updated_at_raw ~ '^\d{4}-\d{2}-\d{2}$' then to_timestamp(updated_at_raw, 'YYYY-MM-DD')::timestamp
            when updated_at_raw~ '^\d{2}/\d{2}/\d{4}$' then to_timestamp(updated_at_raw, 'MM/DD/YYYY')::timestamp
            when updated_at_raw ~ '^\d{2}-\d{2}-\d{4}$' then to_timestamp(updated_at_raw, 'DD-MM-YYYY')::timestamp
            when updated_at_raw ~ '^[A-Za-z]{3} \d{1,2}, \d{4}$' then to_timestamp(updated_at_raw, 'Mon DD, YYYY')::timestamp
            else NULL
        end as updated_at
    from advertiser

)
select * from dates