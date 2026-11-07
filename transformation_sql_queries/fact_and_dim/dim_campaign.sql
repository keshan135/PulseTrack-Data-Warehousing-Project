{{ config(
    materialized='table',
    schema='pulsetrack_gold'
) }}

with camp as(
    select
        campaign_id,
        campaign_name,
        offer_id,
        advertiser_id,
        price_type,
        start_date,
        end_date
    from {{ ref("campaign_ref")}}
),
final AS (

    SELECT
        ROW_NUMBER() OVER (
            ORDER BY campaign_id
        ) AS campaign_key,

        campaign_id,
        campaign_name,
        offer_id,
        advertiser_id,
        price_type,
        start_date,
        end_date

    FROM camp

)

SELECT *
FROM final