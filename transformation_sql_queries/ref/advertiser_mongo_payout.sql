{{ config(materialized='table') }}

with payout as(
    select
        cast(advertiser_id as varchar)as advertiser_id,
        trim(payout ->> 'rate') as rate,
        trim(payout ->> 'tier') as tier,
        trim(payout ->> 'vertical') as vertical
    from {{ ref("advertiser_mongo") }}
    cross join lateral
        jsonb_array_elements(
                contract -> 'payout_tiers') as payout
)
select * from payout