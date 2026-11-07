{{ config(
    materialized='table',
    schema='pulsetrack_gold'
) }}

WITH clicks AS (

    SELECT
        click_id,
        impression_id,
        campaign_id,
        creative_id,
        partner_id,
        click_time,
        country,
        device,
        is_unique,
        referrer

    FROM {{ref("clicks_ref")}}

),

final AS (

    SELECT
        c.click_id,

        -- Dimension keys
        d.date_key,
        ca.campaign_key,
        cr.creative_key,
        p.partner_key,

        -- Event details
        c.impression_id,
        c.click_time AS selected_event_time,

        CASE
            WHEN c.click_time IS NOT NULL
                THEN 'click_time'
            ELSE 'unknown'
        END AS timestamp_source,

        c.country,
        c.device,
        c.is_unique,
        c.referrer,

        -- Fact measure
        1 AS click_count

    FROM clicks c

    LEFT JOIN {{ref("dim_date")}} d
        ON c.click_time::date = d.full_date

    LEFT JOIN {{ref("dim_campaign")}} ca
        ON c.campaign_id = ca.campaign_id

    LEFT JOIN {{ref("dim_creative")}} cr
        ON c.creative_id = cr.creative_id

    LEFT JOIN {{ ref("dim_partner")}} p
        ON c.partner_id = p.partner_id

)

SELECT *
FROM final