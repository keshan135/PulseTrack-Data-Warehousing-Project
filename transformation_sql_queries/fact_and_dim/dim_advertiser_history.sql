{{ config(
    materialized='table',
    schema='pulsetrack_gold'
) }}


WITH am AS (
    SELECT
        am_id,
        am_name,
        team,
        region,
        hire_date
    FROM {{ ref('account_manager_ref') }}
),

final_am AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY am_id) AS account_manager_key,
        am_id,
        am_name,
        team,
        region,
        hire_date
    FROM am
),

advertiser AS (
    SELECT
        advertiser_id,
        am_id,
        advertiser_name,
        vertical,
        status,
        billing_country,
        signup_date
    FROM {{ ref('advertiser_ref') }}
),

history AS (
    SELECT
        advertiser_id,
        am_id,
        am_name,
        validate_from,
        validate_to
    FROM {{ ref('advertiser_mongo_am_history_ref') }}
),

joins AS (
    SELECT
        ad.am_id,
        ad.advertiser_id,
        ad.advertiser_name,
        ad.vertical,
        ad.status,
        ad.billing_country,
        ad.signup_date,

        COALESCE(his.validate_from, ad.signup_date)
            AS valid_from_date,

        his.validate_to AS valid_to_date

    FROM advertiser ad
    LEFT JOIN history his
        ON ad.advertiser_id = his.advertiser_id
),

resolved AS (
    SELECT
        j.*,
        am.account_manager_key
    FROM joins j
    LEFT JOIN final_am am
        ON am.am_id = j.am_id
),

final AS (
    SELECT
        MD5(
            CONCAT(
                advertiser_id,
                '|',
                valid_from_date::text
            )
        ) AS advertiser_key,

        advertiser_id,
        advertiser_name,
        vertical,
        status,
        billing_country,
        signup_date,

        am_id,
        account_manager_key,

        valid_from_date::timestamp
            AT TIME ZONE 'Asia/Colombo' AS valid_from,

        valid_to_date::timestamp
            AT TIME ZONE 'Asia/Colombo' AS valid_to,

        (valid_to_date IS NULL) AS is_current

    FROM resolved
)

SELECT *
FROM final
