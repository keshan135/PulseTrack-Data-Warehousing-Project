from airflow.decorators import dag
from datetime import datetime,timedelta
from airflow.providers.standard.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.operators.trigger_dagrun import TriggerDagRunOperator


table_list=["clicks_raw",
            "account_managers_raw",
            "advertisers_raw",
            "partners_raw",
            "offers_raw",
            "campaigns_raw",
            "creatives_raw",
            "impressions_raw",
            "conversions_raw",
            "conversion_touchpoints_raw",
            "revenue_adjustments_raw"]


def get_data_from_the_source():

    #get the connection to the source database
    hook_oltp=PostgresHook(
        postgres_conn_id="pulsetrack_oltp"
    )  
    #get the connection to the destination database
    hook_olap=PostgresHook(
        postgres_conn_id="pulsetrack_olap"
    )

    #cursor to oltp
    conn_oltp=hook_oltp.get_conn()
    cur_oltp=conn_oltp.cursor()

    #cursor to olap
    conn_olap=hook_olap.get_conn()
    cur_olap=conn_olap.cursor()


    try:
        for table in table_list:
            
            cur_olap.execute(
                f"TRUNCATE TABLE pulsetrack_postgres_bronze.{table} CASCADE;"
            )

            #get data from oltp
            cur_oltp.execute(
                f"select * from pulsetrack_raw.{table};"
                )

            records_bronze_raw=cur_oltp.fetchall()
    
            if not records_bronze_raw:
                continue

            elif table=="clicks_raw": 
                cur_olap.executemany(
                """
                    INSERT INTO pulsetrack_postgres_bronze.clicks_raw
                    (click_id, impression_id, campaign_id, creative_id, partner_id,
                    click_time, ip, user_agent, country, device, is_unique,
                    referrer_raw, created_at, updated_at)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
                            %s, %s, %s, %s)
                """,records_bronze_raw
                            )

            elif table=="account_managers_raw":
                cur_olap.executemany(
                """
                    INSERT INTO pulsetrack_postgres_bronze.account_managers_raw
                    (am_id, am_name, team, region, hire_date, created_at, updated_at)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                """,records_bronze_raw
                )


            elif table=="advertisers_raw":
                cur_olap.executemany(
                """
                    INSERT INTO pulsetrack_postgres_bronze.advertisers_raw
                    (advertiser_id, advertiser_name, vertical, account_manager_id,
                    status, signup_date, billing_country, created_at, updated_at)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                """,records_bronze_raw
                            )


            elif table=="partners_raw":
                cur_olap.executemany(
                        """
                INSERT INTO pulsetrack_postgres_bronze.partners_raw
                (partner_id, partner_name, channel, media_buyer, join_date,
                payment_terms, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """,records_bronze_raw
                )


            elif table=="offers_raw":
                cur_olap.executemany(
                        """
                INSERT INTO pulsetrack_postgres_bronze.offers_raw
                (offer_id, offer_name, advertiser_id, vertical, default_payout,
                payout_type, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """,records_bronze_raw
                )


            elif table=="campaigns_raw":
                cur_olap.executemany(
                        """
                INSERT INTO pulsetrack_postgres_bronze.campaigns_raw
                (campaign_id, campaign_name, offer_id, advertiser_id, price_type,
                start_date, end_date, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """,records_bronze_raw
                )


            elif table=="creatives_raw":
                cur_olap.executemany(
                        """
                INSERT INTO pulsetrack_postgres_bronze.creatives_raw
                (creative_id, campaign_id, creative_name, format, size,
                landing_url, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """,records_bronze_raw
                )


            elif table=="impressions_raw":
                cur_olap.executemany(
                        """
                INSERT INTO pulsetrack_postgres_bronze.impressions_raw
                (impression_id, campaign_id, creative_id, partner_id,
                impression_time, placement_raw, country, device, bot_score,
                created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """,records_bronze_raw
                )
            elif table=="conversions_raw":
                cur_olap.executemany(
                        """
                INSERT INTO pulsetrack_postgres_bronze.conversions_raw
                (conversion_id, click_id, campaign_id, advertiser_name,
                account_manager, campaign_name, partner_id, partner_name,
                offer_name, price_type, conversion_time, revenue, payout,
                currency, status, country, device, sub_id, is_test, legacy_flag,
                pixel_fired, internal_note, reserved_1, created_at, updated_at)
                VALUES (
                    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
                    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
                    %s, %s, %s, %s, %s
                )
            """,records_bronze_raw
                )


            elif table=="conversion_touchpoints_raw":
                cur_olap.executemany(
                        """
                INSERT INTO pulsetrack_postgres_bronze.conversion_touchpoints_raw
                (touchpoint_id, conversion_id, click_id, touch_position,
                weight, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """,records_bronze_raw
                )


            elif table=="revenue_adjustments_raw":
                cur_olap.executemany(
                        """
                INSERT INTO pulsetrack_postgres_bronze.revenue_adjustments_raw
                (adjustment_id, conversion_id, delta_amount, reason, adjusted_at,
                created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """,records_bronze_raw
                        )
        conn_olap.commit()

    except Exception:
        conn_olap.rollback()
        raise

    finally:
        cur_oltp.close()
        cur_olap.close()
        conn_oltp.close()
        conn_olap.close()
    
default_args={
    'owner':'keshan',
    'retries':2,
    'retry_delay':timedelta(minutes=5)
}
@dag(
    dag_id="postgres_ingest",
    default_args=default_args,
    schedule=None,
    start_date=datetime(2026, 10, 19),
    catchup=False,
    tags=['postgres', 'ingest']
)

def postgres_ingest():
    import_data_from_postgres=PythonOperator(
        task_id="import_data_from_oltp",
        python_callable=get_data_from_the_source
    )
    trigger_dbt_dag = TriggerDagRunOperator(
        task_id="trigger_dbt_transformation",
        trigger_dag_id="pulsetrack_dbt_transformation", 
    )
    
    import_data_from_postgres >> trigger_dbt_dag

postgres_ingest()    
    
