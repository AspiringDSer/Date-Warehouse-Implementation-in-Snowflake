# Data Warehouse Implementation in Snowflake

# Table of Content <a id="top"></a>

1. [Project Overview](#Project-Overview)
2. [Setup Instructions](#Setup-Instructions)
3. [Data Storage and Management](#Data-Storage-and-Management)
    1. [Data Source](#3.1) 
	2. [Data Storage](#3.2) 
4. [ELT Process](#ELT-Process)
    1. [Snowflake User Creation](#4.1) 
	2. [Snowflake Data Import](#4.2)
5. [Data Warehouse Architecture](#Data-Warehouse-Architecture)
	1. [Architecture Components](#5.1)
	2. [Analytical Tool](#5.2)
	3. [Slowly Changing Dimensions in dbt](#5.3)
6. [Queries](#Queries)
	1. [Staging Tables](#6.1)
	2. [Production Tables](#6.2)
7. [Data Quality Checks](#Data-Quality-Checks)
8. [Future Developments](#Future-Developments)
9. [Appendix](#Appendix)

<a name='Project-Overview'></a>
# Project Overview
[Go to TOC](#top)

This project demonstrates the construction of a scalable and efficient data warehousing solution using Snowflake, AWS S3, SQL, and dbt.

**Objective**: The primary objective of this project is to demonstrate my ability to design and implement a robust data warehouse solution. By storing a large-scale dataset in AWS S3, orchestrating an ELT pipeline to load data into Snowflake, and implementing Dimensional Data Modeling with dbt, I showcase my proficiency in handling complex data engineering tasks.

**Key Highlights**:

- **Data Storage Optimization**: I optimized storage efficiency in AWS S3 for scalability and future data processing needs.
- **ELT Pipeline Orchestration**: I used SQL to extract and load data into Snowflake, enabling data transformation and modeling workflows.
- **Data Warehouse Architecture**: I designed and implemented a data warehouse using dbt, managing Slowly Changing Dimensions and documenting the data model for efficient testing and maintenance.

![ELT Architecture](https://github.com/AspiringDSer/Date-Warehouse-Implementation-in-Snowflake/assets/79289892/cde069eb-0e63-416b-8eb5-cec0709f9075)

<a name='Setup-Instructions'></a>
# Setup Instructions
[Go to TOC](#top)

To follow along with this project, you will need the following Tech Stack:

1. **Snowflake 30-Day Trial**: Sign up for a Snowflake trial [here](https://signup.snowflake.com/).
2. **AWS S3**: Sign up for an AWS account and set up an S3 bucket [here](https://aws.amazon.com/s3/).
3. **dbt Setup**: Install dbt by following the installation guide [here](https://docs.getdbt.com/docs/core/pip-install).
4. **Python 3.8 or Above**: Download Python from the official website [here](https://www.python.org/downloads/).
5. **dbt 1.7.11 or Above**: Install dbt version 1.7.11 or above.
6. **dbt Snowflake Plugin**: Install the dbt Snowflake plugin by following the instructions [here](https://pypi.org/project/dbt-snowflake/).

These tools and setups are essential for replicating the project environment and running the code successfully. Once you have set up your environment, refer to the project documentation for further instructions on running the project.

<a name='Data-Storage-and-Management'></a>
# Data Storage and Management  
[Go to TOC](#top)

<a name='3.1'></a>
## Data Sources

The project datasets comes from the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). 

The dataset has information of 100k orders from 2016 to 2018 made at multiple marketplaces in Brazil. Its features allows viewing an order from multiple dimensions: from order status, price, payment and freight performance to customer location, product attributes and finally reviews written by customers.  

<a name='3.2'></a>
## Data Storage

The dataset is stored in Amazon S3, a highly scalable and secure object storage service. Amazon S3 provides durable and reliable storage for large datasets, making it ideal for storing the extensive Brazilian E-Commerce dataset. By storing the dataset in Amazon S3, we ensure storage efficiency and scalability, allowing for easy access and management of the data.

Extracting data from Amazon S3 provides a real-world experience for the project, as it simulates working with large-scale datasets in a production environment. This process involves accessing the dataset stored in Amazon S3 and loading it into the data warehouse for analysis and reporting.

<a name='ELT-Process'></a>
# ELT Process  
[Go to TOC](#top)

The ELT (Extract, Load, Transform) process for this project involves extracting data from a public S3 bucket (`jmah-public-data/olist/`) and loading it into Snowflake as source tables. The data loaded from AWS S3 is then staged and modeled using dbt (Data Build Tool) with a dimensional data modeling approach.

<a name='4.1'></a>
## Snowflake User Creation

To set up the necessary user and roles in Snowflake for this project, follow these steps:

1. Copy the following SQL statements into a Snowflake Worksheet.
2. Select all statements and execute them (i.e., press the play button).

```sql
-- Use an admin role
USE ROLE ACCOUNTADMIN;

-- Create the `dbt_role` role
CREATE ROLE IF NOT EXISTS DBT_ROLE;
GRANT ROLE DBT_ROLE TO ROLE ACCOUNTADMIN;

-- Create the default warehouse if necessary
CREATE WAREHOUSE IF NOT EXISTS OLIST_WH;
GRANT OPERATE ON WAREHOUSE OLIST_WH TO ROLE DBT_ROLE;

-- Create the `OLIST_DBT` user and assign to role
CREATE USER IF NOT EXISTS OLIST_DBT
  PASSWORD='dbtPassword123'
  LOGIN_NAME='OLIST_DBT'
  MUST_CHANGE_PASSWORD=FALSE
  DEFAULT_WAREHOUSE='OLIST_WH'
  DEFAULT_ROLE='DBT_ROLE'
  DEFAULT_NAMESPACE='OLIST.SOURCE'
  COMMENT='DBT user used for data transformation';
GRANT ROLE DBT_ROLE to USER OLIST_DBT;

-- Create our database and schemas
CREATE DATABASE IF NOT EXISTS OLIST;
CREATE SCHEMA IF NOT EXISTS OLIST.SOURCE;

-- Set up permissions to role `DBT_ROLE`
GRANT ALL ON WAREHOUSE OLIST_WH TO ROLE DBT_ROLE;
GRANT ALL ON DATABASE OLIST to ROLE DBT_ROLE;
GRANT ALL ON ALL SCHEMAS IN DATABASE OLIST to ROLE DBT_ROLE;
GRANT ALL ON FUTURE SCHEMAS IN DATABASE OLIST to ROLE DBT_ROLE;
GRANT ALL ON ALL TABLES IN SCHEMA OLIST.SOURCE to ROLE DBT_ROLE;
GRANT ALL ON FUTURE TABLES IN SCHEMA OLIST.SOURCE to ROLE DBT_ROLE;
```

<a name='4.2'></a>
## Snowflake Data Import

For instructions on importing data into Snowflake, refer to `Snowflake Setup.md`. Copy the SQL statements from the markdown file into a Snowflake Worksheet, select all, and execute them.

<a name='Data-Warehouse-Architecture'></a>
# Data Warehouse Architecture 
[Go to TOC](#top)

![ELT Architecture](https://github.com/AspiringDSer/Date-Warehouse-Implementation-in-Snowflake/assets/79289892/cde069eb-0e63-416b-8eb5-cec0709f9075)

The ELT data architecture involves storing dataset files in Amazon S3, extracting data using SQL queries, and loading it into Snowflake. The loaded data is converted into source tables, and dbt is used for staging, data modeling, and managing Slowly Changing Dimensions.

<a name='5.1'></a>
## Architecture Components

1. **Data Extraction**: Dataset files are stored in Amazon S3.
2. **Data Loading**: Data is extracted from S3 using SQL queries and loaded into Snowflake.
3. **Data Transformation**: dbt is used for creating the staging layer and performing data modeling.
4. **Data Modeling**: Data is modeled using Data Dimensional Modeling principles to create the data warehouse in Snowflake.
5. **Slowly Changing Dimensions**: dbt is utilized for managing Slowly Changing Dimensions.
6. **Documentation**: dbt is also used for data model documentation, ensuring the data warehouse is well-documented.
7. **Version Control**: GitHub is used for version control to track changes to dbt projects and collaborate with team members.

<a name='5.2'></a>
## Analytical Tool

Once the production layer is complete, Power BI is used as the analytical tool for visualizing and analyzing the data stored in Snowflake.

This architecture enables efficient data processing and analysis, ensuring that the data warehouse is optimized for analytics and reporting purposes.

<a name='5.3'></a>
## Slowly Changing Dimensions in dbt

The Ecommerce dataset inherently exhibits characteristics of SCD Type 2 changes, where stakeholders and analysts are keen on reviewing historical data changes.
### Implementation Details

To manage SCD Type 2 changes, I leveraged dbt to create snapshot tables. Within the snapshot block, it's crucial to specify:

1. The unique key for the table (dimension) that dbt will use to identify a unique row.
2. The strategy for detecting changes, which can be either "timestamp" (utilizing an updated_at column) or "check" (comparing specific columns)."
### Example Scenario

For instance, consider a scenario where a product's price changes over time in the Ecommerce dataset. By using dbt snapshot tables, I captured these changes by creating a new record for the product with the updated price, while maintaining the previous record as historical. This allows analysts to track the price changes for each product over time.

``` sql
{# The s3_order_items table contains data on product prices. #}
{# We create a snapshot table to capture price changes by creating a new record for #}
{# the product with the updated price, while maintaining the previous record as historical. #}

{# Configuration settings for the snapshot #}
{% snapshot snap_order_items %}
{{
    config(
        target_database='OLIST',            
        target_schema='SNAPSHOTS',          
        unique_key='order_id',              

        strategy='timestamp',               
        updated_at='updated_at'            
    )
}}

{# SQL query to select data from the source table #}
select * from {{ source('src_snowflake', 's3_order_items') }}

{% endsnapshot %}
```

### Benefits and Impact

The use of dbt snapshot tables for managing SCD Type 2 changes provides several benefits, including improved data integrity, simplified historical data analysis, and enhanced reporting capabilities. Stakeholders can easily access and analyze historical data changes, leading to better-informed business decisions.

### Slowly Changing Dimensions
For detailed explanations of Slowly Changing Dimension (SCD) types 1, 2, and 3, please see the [Appendix](#Appendix).

<a name='Queries'></a>
# Queries 
[Go to TOC](#top)

Below are example SQL queries used for creating and transforming staging and production tables:

<a name='6.1'></a>
## Staging Tables

Data Transformation in `stg_order_items` Staging Table
```sql
with source as (
    select * 
    from {{ ref('snap_order_items') }}
),

renamed as (

    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date,
        price AS price_BR,
        round((price * 0.27), 2) AS price_CAD,
        freight_value AS freight_value_BR,
        round((freight_value * 0.27), 2) AS freight_value_CAD,
        dbt_updated_at,
        dbt_valid_from,
        dbt_valid_to
        
    from source
    
)

select * 
from renamed
```

<a name='6.2'></a>
## Production Tables 

Data Transformation in `dimProducts` Production Table
```sql
select
    product_id,
    product_category_name_english as product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    products_weight_g,
    products_length_cm,
    products_height_cm,
    products_width_cm,
	dbt_updated_at,
	dbt_valid_from,
	dbt_valid_to
from {{ ref('stg_products') }}
JOIN {{ ref('stg_product_category_name_translation') }}
    ON stg_products.product_category_name =   stg_product_category_name_translation.product_category_name
```

<a name='Data-Quality-Checks'></a>
# Data Quality Checks
[Go to TOC](#top)

Ensuring data quality is crucial for maintaining the integrity of the data in our data warehouse. In the staging layer, we have implemented various data quality checks to validate the data before it is transformed and loaded into the production tables. These checks help us identify and address any issues with the data, ensuring that only high-quality data is used for analysis and reporting.

In the staging layer, we setup 18 tests to check all the tables data quality. For more details check out `schema.yml` under the warehouse/models/staging/ folder. 
## Overview

We use dbt's `schema.yml` file to define and configure these data quality checks. This file contains the metadata for each table, including column definitions, descriptions, and the tests to be performed.
### Example Data Quality Checks

Here are some examples of the data quality checks we perform on the `stg_orders` table:

1. **Check for Unique Order IDs**: The `order_id` column should have unique values for each order. This is important to ensure that there are no duplicate orders in the dataset.
    
2. **Check Foreign Key Relationship**: The `customer_id` column should be a valid foreign key that references the `customer_id` column in the `stg_customers` table. This ensures that each order is associated with a valid customer.
    
3. **Validate Order Status Values**: The `order_status` column should contain values that fall within a predefined set of accepted values, such as 'delivered', 'shipped', 'processing', etc. This helps ensure consistency and accuracy in reporting.
### Additional Data Quality Checks

In addition to the above examples, we also perform the following data quality checks:

- **Check for Null Values**: Ensure that essential columns do not contain null values, which could indicate missing or incomplete data.
- **Format Validation**: Validate that certain columns (e.g., date columns) are formatted correctly according to a specified format.

These data quality checks help us maintain high data quality standards and ensure the reliability of our data warehouse for analysis and reporting purposes.

<a name='Future-Developments'></a>
# Future Developments
[Go to TOC](#top)
### PowerBI Dashboard

- **Objective**: Create a PowerBI dashboard connected to the data warehouse.
- **Benefits**: Provide interactive visualizations and insights for stakeholders.
### Data Ingestion Tool Integration

- **Objective**: Integrate a data ingestion tool (e.g., Fivetran, Stitch, Airbyte) into the data architecture.
- **Benefits**: Streamline the process of extracting, transforming, and loading data from various sources into the data warehouse, enhancing data integration capabilities.
### Orchestration Tool Implementation

- **Objective**: Implement an orchestrator (e.g., Prefect, Dagster, Airflow) to manage and automate data workflows.
- **Benefits**: Improve efficiency in data processing, ensure reliability, and scalability of the data architecture.

These future developments aim to enhance the data architecture's capabilities, improve data accessibility and usability, and streamline data management processes for more effective and efficient data-driven decision-making.

<a name='Appendix'></a>
# Appendix
[Go to TOC](#top)

**Slowly Changing Dimensions** 

Type 1 Slowly Changing Dimension (SCD)

- **Definition:** In Type 1 SCD, the dimension attribute is updated directly, overwriting the existing value with the new one.
- **Example:** If a customer changes their email address, the existing email address in the customer dimension table would be updated directly with the new email address.
- **Impact:** This change is immediate and does not retain any historical information. It is useful for attributes that are not expected to change frequently and do not require historical tracking.

Type 2 Slowly Changing Dimension (SCD)

- **Definition:** In Type 2 SCD, a new record is added to the dimension table to represent the change, while the original record is marked as historical.
- **Example:** If a customer changes their name, a new record with the updated name is added to the customer dimension table, while the original record is marked as historical with an end date.
- **Impact:** This approach retains historical information and allows analysis of data changes over time. It is suitable for attributes where historical tracking is important.

Type 3 Slowly Changing Dimension (SCD)

- **Definition:** In Type 3 SCD, the dimension table contains columns to store both the current and previous values of an attribute.
- **Example:** If a product's price changes, the product dimension table would have columns for both the current price and the previous price.
- **Impact:** This approach allows easy access to both current and historical information but is limited in the number of changes that can be tracked for an attribute.

**dbt DAGs**

![dbtDAGs](https://github.com/AspiringDSer/Date-Warehouse-Implementation-in-Snowflake/assets/79289892/a86f2863-8318-4934-98d4-83128fe7d934)
  
**Snowflake Source Tables**

![snowflake_source_tables](https://github.com/AspiringDSer/Date-Warehouse-Implementation-in-Snowflake/assets/79289892/589a1bcd-933c-473a-a75e-d7d4c8fcf32a)

**Snowflake Snapshot Tables**

![snowflake_snapshot_tables](https://github.com/AspiringDSer/Date-Warehouse-Implementation-in-Snowflake/assets/79289892/c9076e23-2065-438c-9671-d270ee858287)

**Snowflake Staging Views**

![snowflake_staging_tables](https://github.com/AspiringDSer/Date-Warehouse-Implementation-in-Snowflake/assets/79289892/50f8152f-0108-4cbd-a0f3-1a4dc326c118)

**Snowflake Production Tables**

![snowflake_production_tables](https://github.com/AspiringDSer/Date-Warehouse-Implementation-in-Snowflake/assets/79289892/e8a9ba74-4bda-4f04-8017-ccf6bffc7b64)
