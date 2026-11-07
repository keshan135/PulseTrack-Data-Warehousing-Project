{{ config(materialized='table') }}

with channels as(
    select
        cast(partner_id as numeric) as partner_id,
        trim(name)as name,
        ARRAY(
        select TRIM(value)
        from jsonb_array_elements_text(
            COALESCE(channels, '[]'::JSONB)
        ) as x(value)
    ) as channels
    from {{ ref("partner_mongo") }}
)
select * from channels