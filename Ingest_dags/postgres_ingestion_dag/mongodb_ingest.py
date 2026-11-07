from airflow.decorators import dag
from airflow.providers.mongo.hooks.mongo import MongoHook
from airflow.providers.postgres.hooks.postgres import PostgresHook
from datetime import datetime,timedelta
from airflow.providers.standard.operators.python import PythonOperator
import json
from psycopg.types.json import Jsonb
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

def jsonb_value(value):
    if value is None:
        return None

    return Jsonb(value, dumps=lambda obj: json.dumps(obj, default=str))

def import_data_from_mongo():
    mongo_client = None
    conn = None
    cur = None

    try:  
        #connection to the source database(mongodb)
        mongo_hook = MongoHook( mongo_conn_id="pulsetrack_mongodb")

        mongo_client = mongo_hook.get_conn()
        mongo_client.admin.command("ping")

        mongo_db = mongo_client["pulsetrackmdb"]

        collection_profiles = mongo_db["partner_profiles"]
        collection_advertisers = mongo_db["advertiser_accounts"]
        
        #connection to the destination database(postgres)
        connection = PostgresHook(
            postgres_conn_id="pulsetrack_olap_mongodb"
        )
        conn=connection.get_conn()
        cur=conn.cursor()

        #partner_profiles_raw table full load

        cur.execute("TRUNCATE TABLE pulsetrack_mongodb_bronze.partner_profiles_raw CASCADE;")

        fetched_profiles = list(collection_profiles.find({}))
        profile_rows = []
        for doc in fetched_profiles:
            profile_rows.append((
                str(doc["_id"]),
                doc.get("partner_id"),
                doc.get("name"),
                jsonb_value(doc.get("contact")),
                jsonb_value(doc.get("channels")),
                jsonb_value(doc.get("payment")),
                jsonb_value(doc.get("tags")),
                doc.get("joinedAt"),
                doc.get("createdAt"),
                doc.get("updatedAt")
                ))
        if profile_rows:
            cur.executemany(
                """
                INSERT INTO pulsetrack_mongodb_bronze.partner_profiles_raw
                (
                    mongo_id,
                    partner_id,
                    name,
                    contact,
                    channels,
                    payment,
                    tags,
                    "joinedAt",
                    "createdAt",
                    "updatedAt"
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """,
                profile_rows
            )

        #advertiser_accounts_raw table full load

        cur.execute("TRUNCATE TABLE pulsetrack_mongodb_bronze.advertiser_accounts_raw CASCADE;")

        fetched_advertisers = list(collection_advertisers.find({}))
        advertiser_rows = []
        for doc in fetched_advertisers:
            advertiser_rows.append((
                str(doc["_id"]),
                doc.get("advertiser_id"),
                doc.get("legal_name"),
                doc.get("display_name"),
                doc.get("vertical"),
                doc.get("status"),
                jsonb_value(doc.get("billing")),
                jsonb_value(doc.get("contacts")),
                jsonb_value(doc.get("account_manager_history")),
                jsonb_value(doc.get("contract")),
                doc.get("createdAt"),
                doc.get("updatedAt")
                ))

        
        if advertiser_rows:
            cur.executemany(
                """
                INSERT INTO pulsetrack_mongodb_bronze.advertiser_accounts_raw
                (
                    mongo_id,
                    advertiser_id,
                    legal_name,
                    display_name,
                    vertical,
                    status,
                    billing,
                    contacts,
                    account_manager_history,
                    contract,
                    "createdAt",
                    "updatedAt"
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """,
                advertiser_rows
            )

        conn.commit()

    except Exception:
        if conn is not None:
            conn.rollback()
        raise

    finally:
        if cur is not None:
            cur.close()

        if conn is not None:
            conn.close()

        if mongo_client is not None:
            mongo_client.close()

default_args = {
    "owner": "keshan",
    "retries": 2,
    "retry_delay": timedelta(minutes=5)
}

@dag(
    dag_id="mongodb_ingest_dag",
    default_args=default_args,
    start_date=datetime(2026, 10, 19),
    schedule=None,
    catchup=False,
    tags=["mongodb", "ingestion", "pulsetrack"]
)
def ingest_data_from_mongodb():

    import_data_from_mongodb = PythonOperator(
        task_id="import_data_from_mongo",
        python_callable=import_data_from_mongo
    )

    trigger_dbt_dag = TriggerDagRunOperator(
        task_id="trigger_dbt_transformation",
        trigger_dag_id="pulsetrack_dbt_transformation"
    )

    import_data_from_mongodb >> trigger_dbt_dag




ingest_data_from_mongodb()
