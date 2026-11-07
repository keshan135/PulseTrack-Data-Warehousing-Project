{{ config(
    materialized='table',
    schema='pulsetrack_gold'
) }}


WITH touchpoints AS (
    SELECT
        touchpoint_id,
        conversion_id,
        click_id,
        touch_position,
        weight,
        created_at,
        updated_at
    FROM {{ref("conversion_touch_ref")}}
),

final AS (
    SELECT
        t.touchpoint_id,

        d.date_key,
        fc.campaign_key,
        fc.advertiser_key,
        fc.account_manager_key,
        fc.partner_key,

        t.conversion_id,
        t.click_id,

        t.touch_position,
        t.weight,

        t.created_at,
        t.updated_at,

        1 AS touchpoint_count

    FROM touchpoints t

    LEFT JOIN {{ref("fact_conversion")}} fc
        ON t.conversion_id = fc.conversion_id

    LEFT JOIN {{ref("dim_date")}} d
        ON t.created_at::date = d.full_date
)

SELECT *
FROM final