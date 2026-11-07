{{ config(materialized='table') }}

with revenue_ajust as(
    select
        cast(trim(adjustment_id) as varchar)as adjustment_id,
        cast(trim(conversion_id) as varchar)as conversion_id,
        delta_amount as delta_amount_raw,
        initcap(trim(reason)) as reason,
        adjusted_at as adjusted_at_raw,
        created_at as raw_created_at,
        updated_at as raw_updated_at
    from {{ ref('revenue_ajustments')}}
),final as(
    select
        adjustment_id,
        conversion_id,
        CASE
                WHEN delta_amount_raw IS NULL
                     OR TRIM(delta_amount_raw) = ''
                     OR UPPER(TRIM(delta_amount_raw)) IN ('N/A', 'NULL', '-', 'NA', 'NONE')
                     OR REGEXP_REPLACE(UPPER(delta_amount_raw), '[^0-9.-]', '', 'g') = ''
                     OR REGEXP_REPLACE(UPPER(delta_amount_raw), '[^0-9.-]', '', 'g') = '-'
                THEN NULL
                ELSE CAST(REGEXP_REPLACE(UPPER(delta_amount_raw), '[^0-9.-]', '', 'g') AS NUMERIC(10,2))
            END AS delta_amount,
        reason,
        case
            when adjusted_at_raw ~ '^[0-9]{10}$' then to_timestamp(adjusted_at_raw::bigint)
            when adjusted_at_raw ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' then to_timestamp(adjusted_at_raw, 'YYYY-MM-DD HH24:MI:SS')
            when adjusted_at_raw ~ '^\d{4}-\d{2}-\d{2}$' then to_timestamp(adjusted_at_raw, 'YYYY-MM-DD')::timestamp
            when adjusted_at_raw ~ '^\d{2}/\d{2}/\d{4}$' then to_timestamp(adjusted_at_raw, 'MM/DD/YYYY')::timestamp
            when adjusted_at_raw ~ '^\d{2}-\d{2}-\d{4}$' then to_timestamp(adjusted_at_raw, 'DD-MM-YYYY')::timestamp
            when adjusted_at_raw ~ '^[A-Za-z]{3} \d{1,2}, \d{4}$' then to_timestamp(adjusted_at_raw, 'Mon DD, YYYY')::timestamp
            else NULL
        end as adjusted_at,
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
    from revenue_ajust
)
select * from final where adjustment_id != 'adjustment_id'