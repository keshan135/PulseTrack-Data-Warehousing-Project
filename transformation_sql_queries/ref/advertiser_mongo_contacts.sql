{{ config(materialized='table') }}

with contacts as(
    select
        cast(trim(advertiser_id) as varchar) as advertiser_id,
        initcap(trim(con ->> 'name')) as contact_name,
        trim(con ->> 'role') as contact_role
    from {{ ref("advertiser_mongo") }}
    cross join lateral
        jsonb_array_elements(contacts) as con
)
select * from contacts