{{ config(materialized='table') }}

with tags as(
    select
        cast(partner_id as numeric) as partner_id,
        trim(name)as name,
        trim(payment ->> 'terms') as terms,
        trim(payment ->> 'method') as method,
        ARRAY(
        select TRIM(value)
        from jsonb_array_elements_text(
            COALESCE(tags, '[]'::JSONB)
        ) as x(value)
    ) as tags
    from {{ ref("partner_mongo") }}
)
select * from tags