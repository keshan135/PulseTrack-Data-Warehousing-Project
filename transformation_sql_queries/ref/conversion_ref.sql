{{ config(materialized='table') }}

with conversion as(
    select
        cast(trim(conversion_id) as varchar)as conversion_id,
        cast(trim(click_id) as varchar)as click_id,
        cast(trim(campaign_id) as varchar)as campaign_id,
        trim(advertiser_name) as advertiser_name_raw,
        initcap(trim(account_manager)) as account_manager,
        initcap(trim(campaign_name)) as campaign_name,
        partner_id as partner_id_raw,
        initcap(trim(partner_name)) as partner_name,
        initcap(trim(offer_name)) as offer_name,
        upper(trim(price_type)) as price_type,
        conversion_time as conversion_time_raw,
        revenue as revenue_raw,
        payout as payout_raw,
        currency as currency_type_raw,
        status as status_raw,
        country as country_raw,
        initcap(trim(device)) as device,
        cast(trim(sub_id) as numeric) as sub_id,
        is_test as is_test_raw,
        legacy_flag as legacy_flag_raw,
        pixel_fired as pixel_fired_raw,
        trim(reserved_1) as reserved_1,
        created_at as raw_created_at,
        updated_at as raw_updated_at
    from {{ ref('conversions') }}
),transform as(
        select
            conversion_id,
            click_id,
            campaign_id,
            CASE
                WHEN LOWER(advertiser_name_raw) LIKE '%autoquote%' THEN 'AutoQuote'
                WHEN LOWER(advertiser_name_raw) LIKE '%brightroof solar%' OR LOWER(advertiser_name_raw) LIKE '%brightroofsolar%' THEN 'BrightRoof Solar'
                WHEN LOWER(advertiser_name_raw) LIKE '%brightsmile%' THEN 'BrightSmile'
                WHEN LOWER(advertiser_name_raw) LIKE '%carelink%' THEN 'CareLink'
                WHEN LOWER(advertiser_name_raw) LIKE '%cashflow loans%' OR LOWER(advertiser_name_raw) LIKE '%cashflowloans%' THEN 'CashFlow Loans'
                WHEN LOWER(advertiser_name_raw) LIKE '%cleanco%' THEN 'CleanCo'
                WHEN LOWER(advertiser_name_raw) LIKE '%connectfast%' THEN 'ConnectFast'
                WHEN LOWER(advertiser_name_raw) LIKE '%creditbridge%' THEN 'CreditBridge'
                WHEN LOWER(advertiser_name_raw) LIKE '%dentalbright%' THEN 'DentalBright'
                WHEN LOWER(advertiser_name_raw) LIKE '%dermabright%' THEN 'DermaBright'
                WHEN LOWER(advertiser_name_raw) LIKE '%ecosolar%' THEN 'EcoSolar'
                WHEN LOWER(advertiser_name_raw) LIKE '%edupath%' THEN 'EduPath'
                WHEN LOWER(advertiser_name_raw) LIKE '%eliteauto%' THEN 'EliteAuto'
                WHEN LOWER(advertiser_name_raw) LIKE '%fitfuel%' THEN 'FitFuel'
                WHEN LOWER(advertiser_name_raw) LIKE '%fixitnow%' THEN 'FixItNow'
                WHEN LOWER(advertiser_name_raw) LIKE '%fortihome%' THEN 'FortiHome'
                WHEN LOWER(advertiser_name_raw) LIKE '%fundfast%' THEN 'FundFast'
                WHEN LOWER(advertiser_name_raw) LIKE '%getawaygo%' THEN 'GetawayGo'
                WHEN LOWER(advertiser_name_raw) LIKE '%greenlawn%' THEN 'GreenLawn'
                WHEN LOWER(advertiser_name_raw) LIKE '%guardianlink%' THEN 'GuardianLink'
                WHEN LOWER(advertiser_name_raw) LIKE '%gymgo%' THEN 'GymGo'
                WHEN LOWER(advertiser_name_raw) LIKE '%handyhub%' THEN 'HandyHub'
                WHEN LOWER(advertiser_name_raw) LIKE '%homeguard%' THEN 'HomeGuard'
                WHEN LOWER(advertiser_name_raw) LIKE '%insurenow%' THEN 'InsureNow'
                WHEN LOWER(advertiser_name_raw) LIKE '%laseraway%' THEN 'LaserAway'
                WHEN LOWER(advertiser_name_raw) LIKE '%leanlife%' THEN 'LeanLife'
                WHEN LOWER(advertiser_name_raw) LIKE '%learnnow%' THEN 'LearnNow'
                WHEN LOWER(advertiser_name_raw) LIKE '%lendwise%' THEN 'LendWise'
                WHEN LOWER(advertiser_name_raw) LIKE '%lumabeauty%' THEN 'LumaBeauty'
                WHEN LOWER(advertiser_name_raw) LIKE '%medical alert hub%' OR LOWER(advertiser_name_raw) LIKE '%medicalalerthub%' THEN 'Medical Alert Hub'
                WHEN LOWER(advertiser_name_raw) LIKE '%motormatch%' THEN 'MotorMatch'
                WHEN LOWER(advertiser_name_raw) LIKE '%moveeasy%' THEN 'MoveEasy'
                WHEN LOWER(advertiser_name_raw) LIKE '%pawplan%' THEN 'PawPlan'
                WHEN LOWER(advertiser_name_raw) LIKE '%petcarepro%' THEN 'PetCarePro'
                WHEN LOWER(advertiser_name_raw) LIKE '%petjoy%' THEN 'PetJoy'
                WHEN LOWER(advertiser_name_raw) LIKE '%policypal%' THEN 'PolicyPal'
                WHEN LOWER(advertiser_name_raw) LIKE '%purewater%' THEN 'PureWater'
                WHEN LOWER(advertiser_name_raw) LIKE '%quicktax%' THEN 'QuickTax'
                WHEN LOWER(advertiser_name_raw) LIKE '%quotebridge%' THEN 'QuoteBridge'
                WHEN LOWER(advertiser_name_raw) LIKE '%roofright%' THEN 'RoofRight'
                WHEN LOWER(advertiser_name_raw) LIKE '%safedrive insurance%' OR LOWER(advertiser_name_raw) LIKE '%safedriveinsurance%' THEN 'SafeDrive Insurance'
                WHEN LOWER(advertiser_name_raw) LIKE '%safenest security%' OR LOWER(advertiser_name_raw) LIKE '%safenestsecurity%' THEN 'SafeNest Security'
                WHEN LOWER(advertiser_name_raw) LIKE '%savemore bank%' OR LOWER(advertiser_name_raw) LIKE '%savemorebank%' THEN 'SaveMore Bank'
                WHEN LOWER(advertiser_name_raw) LIKE '%seniorsafe%' THEN 'SeniorSafe'
                WHEN LOWER(advertiser_name_raw) LIKE '%shieldhome%' THEN 'ShieldHome'
                WHEN LOWER(advertiser_name_raw) LIKE '%sleepwell%' THEN 'SleepWell'
                WHEN LOWER(advertiser_name_raw) LIKE '%smilecare%' THEN 'SmileCare'
                WHEN LOWER(advertiser_name_raw) LIKE '%solarnest%' THEN 'SolarNest'
                WHEN LOWER(advertiser_name_raw) LIKE '%sunvolt%' THEN 'SunVolt'
                WHEN LOWER(advertiser_name_raw) LIKE '%toothpro%' THEN 'ToothPro'
                WHEN LOWER(advertiser_name_raw) LIKE '%tripsaver%' THEN 'TripSaver'
                WHEN LOWER(advertiser_name_raw) LIKE '%vetdirect%' THEN 'VetDirect'
                WHEN LOWER(advertiser_name_raw) LIKE '%warmhome hvac%' OR LOWER(advertiser_name_raw) LIKE '%warmhomehvac%' THEN 'WarmHome HVAC'
                ELSE INITCAP(TRIM(BOTH '"' FROM REGEXP_REPLACE(advertiser_name_raw, ',?\s*LLC$', '', 'i')))
            END AS advertiser_name,
            account_manager,
            campaign_name,
            CASE
                WHEN TRIM(partner_id_raw) ~ '^[0-9]{5}_[0-9]+$' THEN SPLIT_PART(TRIM(partner_id_raw), '_', 1)
                WHEN TRIM(partner_id_raw) ~ '^[0-9]{5}$' THEN TRIM(partner_id_raw)
                ELSE NULL
            END AS partner_id,
            partner_name,
            offer_name,
            price_type,
            case
            when conversion_time_raw ~ '^[0-9]{10}$' then
                to_timestamp(conversion_time_raw::bigint)
            when conversion_time_raw ~ '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$' then
                conversion_time_raw::timestamptz
            when conversion_time_raw ~ '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}' then
                to_timestamp(left(replace(conversion_time_raw, 'T', ' '), 19), 'YYYY-MM-DD HH24:MI:SS')
            when conversion_time_raw ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' then
                to_timestamp(conversion_time_raw, 'YYYY-MM-DD HH24:MI:SS')
            when conversion_time_raw ~ '^\d{4}-\d{2}-\d{2}$' then
                to_timestamp(conversion_time_raw, 'YYYY-MM-DD')::timestamp
            when conversion_time_raw ~ '^[A-Za-z]{3} \d{1,2}, \d{4}$' then
                to_timestamp(conversion_time_raw, 'Mon DD, YYYY')::timestamp
            else null
            end as conversion_time,

            CASE
                WHEN revenue_raw IS NULL
                     OR TRIM(revenue_raw) = ''
                     OR UPPER(TRIM(revenue_raw)) IN ('N/A', 'NULL', '-', 'NA', 'NONE')
                     OR REGEXP_REPLACE(UPPER(revenue_raw), '[^0-9.]', '', 'g') = ''
                THEN NULL
                ELSE CAST(REGEXP_REPLACE(UPPER(revenue_raw), '[^0-9.-]', '', 'g') AS NUMERIC(10,2))
            END AS revenue,

            CASE
                WHEN payout_raw IS NULL
                     OR TRIM(payout_raw) = ''
                     OR UPPER(TRIM(payout_raw)) IN ('N/A', 'NULL', '-', 'NA', 'NONE')
                     OR REGEXP_REPLACE(UPPER(payout_raw), '[^0-9.]', '', 'g') = ''
                THEN NULL
                ELSE CAST(REGEXP_REPLACE(UPPER(payout_raw), '[^0-9.-]', '', 'g') AS NUMERIC(10,2))
            END AS payout,

            case
                when currency_type_raw='USD' or currency_type_raw='usd' or currency_type_raw='$' or currency_type_raw='US$' then 'usd'
            else null
            end as currency,

            case
                when status_raw='Pending' or status_raw='pending' then 'pending'
                when status_raw='Reversed' or status_raw='returned' or status_raw='reversed' then 'reversed'
                when status_raw='APPROVED' or status_raw='app' or status_raw='1' or status_raw='approved' or status_raw='Approved' then 'approved'
                else null
            end as status,

            case
            when country_raw='US' then replace(country_raw,'US','USA')
            when country_raw='United States' then replace(country_raw,'United States','USA')
            when country_raw='USA' then replace(country_raw,'USA','USA')
            when country_raw='AU' then replace(country_raw,'AU','AU')
            when country_raw='Australia' then replace(country_raw,'Australia','AU')
            when country_raw='U.S.' then replace(country_raw,'U.S.','USA')
            when country_raw='Canada' then replace(country_raw,'Canada','CA')
            when country_raw='us' then replace(country_raw,'us','USA')
            when country_raw='UK' then replace(country_raw,'UK','UK')
            when country_raw='GB' then replace(country_raw,'GB','GB')
            when country_raw='CA' then replace(country_raw,'CA','CA')
            else null
        end as country,

            device,
            sub_id,
            case when is_test_raw='0' then FALSE
                 when is_test_raw='1' then TRUE
            else null
            end as is_test,
        CASE
                WHEN UPPER(TRIM(legacy_flag_raw)) IN ('Y', 'YES', 'TRUE', '1', 'LEGACY') THEN TRUE
                WHEN UPPER(TRIM(legacy_flag_raw)) IN ('N', 'NO', 'FALSE', '0') THEN FALSE
                ELSE NULL
            END AS legacy_flag,
            case when pixel_fired_raw='0' or pixel_fired_raw='N' then FALSE
                 when pixel_fired_raw='1' or pixel_fired_raw='Y' then TRUE
            else null
        end as pixel_fired,

            reserved_1,
            case
            when raw_created_at ~ '^[0-9]{10}$' then to_timestamp(raw_created_at::bigint)
            when raw_created_at ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' then to_timestamp(raw_created_at, 'YYYY-MM-DD HH24:MI:SS')
            when raw_created_at ~ '^\d{4}-\d{2}-\d{2}$' then to_timestamp(raw_created_at, 'YYYY-MM-DD')::timestamp
            when raw_created_at ~ '^\d{2}/\d{2}/\d{4}$' then to_timestamp(raw_created_at, 'MM/DD/YYYY')::timestamp
            when raw_created_at ~ '^\d{2}-\d{2}-\d{4}$' then to_timestamp(raw_created_at, 'DD-MM-YYYY')::timestamp
            when raw_created_at ~ '^[A-Za-z]{3} \d{1,2}, \d{4}$' then to_timestamp(raw_created_at, 'Mon DD, YYYY')::timestamp
            else NULL
        end as created_at,

        case
            when raw_updated_at ~ '^[0-9]{10}$' then to_timestamp(raw_updated_at::bigint)
            when raw_updated_at ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' then to_timestamp(raw_updated_at, 'YYYY-MM-DD HH24:MI:SS')
            when raw_updated_at ~ '^\d{4}-\d{2}-\d{2}$' then to_timestamp(raw_updated_at, 'YYYY-MM-DD')::timestamp
            when raw_updated_at ~ '^\d{2}/\d{2}/\d{4}$' then to_timestamp(raw_updated_at, 'MM/DD/YYYY')::timestamp
            when raw_updated_at ~ '^\d{2}-\d{2}-\d{4}$' then to_timestamp(raw_updated_at, 'DD-MM-YYYY')::timestamp
            when raw_updated_at ~ '^[A-Za-z]{3} \d{1,2}, \d{4}$' then to_timestamp(raw_updated_at, 'Mon DD, YYYY')::timestamp
            else NULL
        end as updated_at
        from conversion

),final as(
    select
            conversion_id,
            click_id,
            campaign_id,
            advertiser_name,
            account_manager,
            campaign_name,
            cast(partner_id as numeric) as partner_id,
            partner_name,
            offer_name,
            price_type,
            conversion_time,
            revenue,
            payout,
            currency,
            status,
            country,
            device,
            sub_id,
            is_test,
            legacy_flag,
            pixel_fired,
            reserved_1,
            created_at,
            updated_at,
            row_number() over (partition by conversion_id order by updated_at desc  ) as rn
    from transform
)

select * from final where rn = 1