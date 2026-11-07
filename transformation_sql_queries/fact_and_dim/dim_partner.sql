{{ config(
    materialized='table',
    schema='pulsetrack_gold'
) }}

with partner as(
    select
        partner_id,
        partner_name,
        channel,
        media_buyer,
        payment_terms,
        join_date
    from {{ ref("partner_ref") }}
),final as(
    select
        ROW_NUMBER() OVER (
            ORDER BY partner_id
        ) AS partner_key,

        partner_id,
        partner_name,
        channel,
        media_buyer,
        payment_terms,
        join_date
    from partner
)select * from final