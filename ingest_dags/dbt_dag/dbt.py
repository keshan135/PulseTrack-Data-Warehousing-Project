from airflow.decorators import dag
from datetime import datetime,timedelta
from airflow.providers.standard.operators.bash import BashOperator


default_args={
    'owner':'keshan',
    'retries':2,
    'retry_delay':timedelta(minutes=5)
}

@dag(
    dag_id="pulsetrack_dbt_transformation",
    default_args=default_args,
    schedule=None,
    start_date=datetime(2026,10,19),
    catchup=False,
    tags=["transformations","dbt"]
)
def dbt_transform():
    run_source_connect = BashOperator(
    task_id="run_dbt_source",
    bash_command="""
        cd /home/keshan/airflow/dags/Capstone_project_dag/dbt_transformations/pulsetrack_dbt &&
        dbt run --select path:models/pulsetrack_models/source_connect
    """
        )

    run_reference = BashOperator(
    task_id="run_dbt_source_ref",
    bash_command="""
        cd /home/keshan/airflow/dags/Capstone_project_dag/dbt_transformations/pulsetrack_dbt &&
        dbt run --select path:models/pulsetrack_models/ref
    """
        )

    run_fact_dim = BashOperator(
    task_id="run_dbt_fact_dim",
    bash_command="""
        cd /home/keshan/airflow/dags/Capstone_project_dag/dbt_transformations/pulsetrack_dbt &&
        dbt run --select path:models/pulsetrack_models/fact_and_dim
    """
        )

    run_source_connect >> run_reference >> run_fact_dim

dbt_transform()
