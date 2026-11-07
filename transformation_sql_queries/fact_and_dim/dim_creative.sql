{{ config(
    materialized='table',
    schema='pulsetrack_gold'
) }}

with creative as(
    select
        creative_id,
        campaign_id,
        creative_name,
        format,
        size_raw,
        landing_url
    from {{ ref("creative_ref") }}
),final AS (

    SELECT
        ROW_NUMBER() OVER (
            ORDER BY creative_id
        ) AS creative_key,

        creative_id,
        campaign_id,
        creative_name,
        format,
        size_raw AS size,
        landing_url

    FROM creative

)

SELECT *
FROM final