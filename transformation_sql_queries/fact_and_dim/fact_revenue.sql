{{ config(
    materialized='table',
    schema='pulsetrack_gold'
) }}

WITH adjustments AS (

    SELECT
        adjustment_id,
        conversion_id,
        delta_amount,
        reason,
        adjusted_at,
        created_at,
        updated_at
    FROM {{ref("revenue_adjust_ref")}}

),

final AS (

    SELECT
        r.adjustment_id,
        d.date_key,

        fc.campaign_key,
        fc.advertiser_key,
        fc.account_manager_key,
        fc.partner_key,

        r.conversion_id,
        r.delta_amount,
        r.reason,

        r.adjusted_at,
        r.created_at,
        r.updated_at,

        1 AS adjustment_count

    FROM adjustments r

    LEFT JOIN {{ref("fact_conversion")}} fc
        ON r.conversion_id = fc.conversion_id

    LEFT JOIN {{ref("dim_date")}} d
        ON r.adjusted_at::date = d.full_date

)

SELECT *
FROM final