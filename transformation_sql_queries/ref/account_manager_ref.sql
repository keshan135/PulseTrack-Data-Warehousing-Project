{{ config(materialized='table') }}

with source_data as (
    select
        cast(am_id as varchar) as AM_ID,
        trim(am_name) as AM_name,
        trim(team) as Team,
        upper(trim(region)) as Region,
        hire_date as raw_hire_date,
        created_at as raw_created_at,
        updated_at as raw_updated_at
    from {{ ref("account_manager")}} where AM_ID != 'am_id'
),

cleaned_dates as (
    select
        AM_ID,
        AM_name,
        Team,
        Region,

        case
            when raw_hire_date ~ '^[0-9]{10}$' then to_timestamp(raw_hire_date::bigint)
            when raw_hire_date ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' then to_timestamp(raw_hire_date, 'YYYY-MM-DD HH24:MI:SS')
            when raw_hire_date ~ '^\d{4}-\d{2}-\d{2}$' then to_timestamp(raw_hire_date, 'YYYY-MM-DD')::timestamp
            when raw_hire_date ~ '^\d{2}/\d{2}/\d{4}$' then to_timestamp(raw_hire_date, 'MM/DD/YYYY')::timestamp
            when raw_hire_date ~ '^\d{2}-\d{2}-\d{4}$' then to_timestamp(raw_hire_date, 'DD-MM-YYYY')::timestamp
            when raw_hire_date ~ '^[A-Za-z]{3} \d{1,2}, \d{4}$' then to_timestamp(raw_hire_date, 'Mon DD, YYYY')::timestamp
            else NULL
        end as hire_date,

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

    from source_data
)

select
    AM_ID,
    AM_name,
    Team,
    Region,
    hire_date,
    created_at,
    updated_at,
    current_timestamp as silver_updated_at
from cleaned_dates 