{{ config(
    materialized='table',
    schema='pulsetrack_gold'
) }}

WITH date_spine AS (

    SELECT
        generate_series(
            DATE '2024-12-31',
            DATE '2027-12-31',
            INTERVAL '1 day'
)::date AS full_date

),

final AS (

    SELECT
        TO_CHAR(full_date, 'YYYYMMDD')::INTEGER
            AS date_key,

        full_date,

        EXTRACT(YEAR FROM full_date)::INTEGER
            AS year,

        EXTRACT(QUARTER FROM full_date)::INTEGER
            AS quarter,

        EXTRACT(MONTH FROM full_date)::INTEGER
            AS month,

        TO_CHAR(full_date, 'Month')
            AS month_name,

        EXTRACT(DAY FROM full_date)::INTEGER
            AS day,

        EXTRACT(ISODOW FROM full_date)::INTEGER
            AS day_of_week,

        TO_CHAR(full_date, 'Day')
            AS day_name

    FROM date_spine

)

SELECT * FROM final