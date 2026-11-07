{{ config(materialized='table') }}

with contact as(
    select
        cast(partner_id as numeric) as partner_id,
        trim(name)as name,
        trim(contact ->> 'email') as email,
        trim(contact ->> 'phone') as phone,
        trim(contact ->> 'person') as person_name,
        "joinedAt" AS joined_at,
        "createdAt" AS created_at,
        "updatedAt" AS updated_at

    from {{ ref("partner_mongo") }}

)
select * from contact