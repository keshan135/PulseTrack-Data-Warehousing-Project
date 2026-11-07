{{ config(
    materialized='table',
    schema='pulsetrack_gold'
) }}

with impression as(
    select
        impression_id,
        campaign_id,
        creative_id,
        partner_id,
        impression_time,
        placemenet as placement,
        country,
        device,
        bot_score,
        created_at
    from {{ ref("impression_ref")}}
),timestamp_handling AS (

    SELECT
        *,

        impression_time AS selected_event_time,

        CASE
            WHEN impression_time IS NOT NULL
                 THEN 'impression_time'
        ELSE 'unknown'
        END AS timestamp_source

    FROM impression

),merge as(
    select
        t.impression_id,
        t.campaign_id,
        t.creative_id,
        t.partner_id,
        t.impression_time,
        t.placement,
        t.country,
        t.device,
        t.bot_score,
        t.created_at,
        t.selected_event_time,
        t.timestamp_source,
        d.date_key,
        c.campaign_key,
        cr.creative_key,
        p.partner_key
    from timestamp_handling t
    left join {{ ref("dim_date") }} d
    on selected_event_time::date=d.full_date
    left join {{ ref("dim_campaign") }} c
    on t.campaign_id=c.campaign_id
    left join {{ ref("dim_creative") }} cr
    on t.creative_id=cr.creative_id
    left join  {{ ref("dim_partner") }} p
    on t.partner_id=p.partner_id

),final as(
    select
        impression_id,
        date_key,
        campaign_key,
        creative_key,
        partner_key,
        selected_event_time,
        placement,
        country,
        device,
        bot_score,
        1 as impression_count
    from merge
)
select * from final order by impression_id asc