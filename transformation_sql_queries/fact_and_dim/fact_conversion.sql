{{ config(
    materialized='table',
    schema='pulsetrack_gold'
) }}



WITH conversions AS (

    SELECT
        conversion_id,
        click_id,
        campaign_id,
        partner_id,
        conversion_time,
        revenue,
        payout,
        currency,
        status,
        country,
        device,
        is_test,
        price_type

    FROM {{ref("conversion_ref")}}

),

final AS (

    SELECT
        c.conversion_id,

        -- Dimension keys
        d.date_key,
        ca.campaign_key,
        ad.advertiser_key,
        ad.account_manager_key,
        p.partner_key,

        -- Event details
        c.click_id,
        c.conversion_time AS selected_event_time,
        c.currency,
        c.status,
        c.country,
        c.device,
        c.price_type,
        c.is_test,

        -- Measures
        c.revenue AS base_revenue,
        c.payout,
        1 AS conversion_count

    FROM conversions c

    LEFT JOIN {{ref("dim_date")}} d
        ON c.conversion_time::date = d.full_date

    LEFT JOIN {{ref("dim_campaign")}} ca
        ON c.campaign_id = ca.campaign_id

    LEFT JOIN {{ref("dim_advertiser_history")}} ad
        ON ca.advertiser_id = ad.advertiser_id
        AND c.conversion_time >= ad.valid_from
        AND (
            c.conversion_time < ad.valid_to
            OR ad.valid_to IS NULL
        )

    LEFT JOIN {{ref("dim_partner")}} p
        ON c.partner_id = p.partner_id

)
SELECT
    *
FROM final