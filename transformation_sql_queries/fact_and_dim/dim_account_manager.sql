{{ config(
    materialized='table',
    schema='pulsetrack_gold'
) }}

with am as(
    select
        am_id,
        am_name,
        team,
        region,
        hire_date
    from {{ ref ("account_manager_ref")}}
),final AS (

    SELECT
        ROW_NUMBER() OVER (
            ORDER BY am_id
        ) AS account_manager_key,

        am_id,
        am_name,
        team,
        region,
        hire_date

    FROM am

)

SELECT *
FROM final