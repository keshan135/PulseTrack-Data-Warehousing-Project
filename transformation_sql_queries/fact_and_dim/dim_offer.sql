{{ config(
    materialized='table',
    schema='pulsetrack_gold'
) }}

with offer as(  
    select
        offer_id,
        offer_name,
        advertiser_id,
        vertical,
        default_payout,
        payout_type
    from {{ ref("offers_ref") }}
),final AS (

    SELECT
        ROW_NUMBER() OVER (
            ORDER BY offer_id
        ) AS offer_key,

        offer_id,
        offer_name,
        advertiser_id,
        vertical,
        default_payout,
        payout_type

    FROM offer

)

SELECT *
FROM final