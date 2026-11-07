## PulseTrack – End-to-End Data Engineering Project

An end-to-end data engineering and analytics platform built using Apache Airflow, PostgreSQL, MongoDB, dbt, and Power BI.

PulseTrack integrates data from multiple sources, orchestrates automated data ingestion, applies data transformations using a Medallion Architecture, and delivers analytical insights through Power BI dashboards.

## Project Overview

The project demonstrates a modern data engineering workflow, covering data ingestion, data warehousing, transformation, orchestration, and business intelligence.



## Technologies Used

Python     ->                      Data ingestion and processing

Apache Airflow      ->              Workflow orchestration

PostgreSQL          ->              Source database and data warehouse

MongoDB            ->               NoSQL data source

dbt              ->                 Data transformation and modeling

SQL              ->               Data extraction and transformation

Power BI          ->                Data visualization and analytics

Git & GitHub         ->             Version control

## Data Pipeline

## 1. Data Ingestion

Apache Airflow orchestrates data extraction from:

-> PostgreSQL OLTP database.<br>
-> MongoDB database

![postgres_ingest](postgres_ingest_dag.png)
![mongodb_ingest](mongodb_ingest.png)

Python and PostgreSQL hooks are used to manage ingestion workflows.

## 2. Bronze Layer

Raw ingested data is stored in PostgreSQL data warehouse schemas.<br>
The Bronze layer preserves source data for downstream processing.
 ![dbt_airflow](dbt_airflow.png)

## 3. Data Transformation

dbt is used to transform and organize the ingested data into:
Silver Layer – cleaned and transformed data.
Gold Layer – analytical fact and dimension models.

dbt Lineage Graph
![dbt_dag](dbt-dag.png)

## 4. Data Visualization

Power BI is used to create dashboards and visualize analytical data from the Gold layer.
Workflow Orchestration

The Airflow DAGs manage the ingestion and transformation workflows.

Python and PostgreSQL hooks are used to manage ingestion workflows.






