{{ config(materialized='table') }}

with payment as(
    select
        cast(partner_id as numeric) as partner_id,
        trim(name)as name,
        trim(payment ->> 'terms') as terms,
        trim(payment ->> 'method') as method,
        cast(trim(payment ->> 'min_payout')as numeric)as min_payout
    from {{ ref("partner_mongo") }}
)
select * from payment