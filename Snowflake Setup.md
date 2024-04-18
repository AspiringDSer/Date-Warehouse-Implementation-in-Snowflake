# Introduction and Environment Setup

## Snowflake User Creation
Copy these SQL statements into a Snowflake Worksheet, select all and execute them (i.e. pressing the play button).

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

## Snowflake Data Import

Copy these SQL statements into a Snowflake Worksheet, select all and execute them (i.e. pressing the play button).

```sql
-- Set up the defaults
USE WAREHOUSE OLIST_WH;
USE DATABASE OLIST;
USE SCHEMA SOURCE;

-- Create our tables and import the data from S3
CREATE OR REPLACE TABLE s3_customers
    (customer_id VARCHAR(32) PRIMARY KEY,
     customer_unique_id VARCHAR(32),
     customer_zip_code_prefix INTEGER,
     customer_city STRING,
     customer_state STRING,
     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

COPY INTO s3_customers (customer_id,
                         customer_unique_id,
                         customer_zip_code_prefix,
                         customer_city,
                         customer_state)
                   FROM 's3://jmah-public-data/olist/customers.csv'
                   FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

CREATE OR REPLACE TABLE s3_geolocation 
    (geolocation_zip STRING,
     geolocation_lat DOUBLE,
     geolocation_lng DOUBLE,
     geolocation_city STRING,
     geolocation_state STRING,
     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

COPY INTO s3_geolocation (geolocation_zip,
                           geolocation_lat,
                           geolocation_lng,
                           geolocation_city,
                           geolocation_state)
                   FROM 's3://jmah-public-data/olist/geolocation.csv'
                   FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

CREATE OR REPLACE TABLE s3_orders
    (order_id VARCHAR(32) PRIMARY KEY,
     customer_id VARCHAR(32),
     order_status STRING,
     order_purchase_timestamp TIMESTAMP,
     order_approved_at TIMESTAMP,
     order_delivered_carrier_date TIMESTAMP,
     order_delivered_customer_date TIMESTAMP,
     order_estimated_delivery_date TIMESTAMP,
     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     FOREIGN KEY (customer_id) REFERENCES s3_customers(customer_id));

COPY INTO s3_orders (order_id,
                      customer_id,
                      order_status,
                      order_purchase_timestamp,
                      order_approved_at,
                      order_delivered_carrier_date,
                      order_delivered_customer_date,
                      order_estimated_delivery_date)
                   FROM 's3://jmah-public-data/olist/orders.csv'
                   FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

CREATE OR REPLACE TABLE s3_order_payments
    (order_id VARCHAR(32),
     payment_sequential INTEGER,
     payment_type STRING,
     payment_installments INTEGER,
     payment_value NUMBER(8, 2),
     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     FOREIGN KEY (order_id) REFERENCES s3_orders(order_id));

COPY INTO s3_order_payments (order_id,
                              payment_sequential,
                              payment_type,
                              payment_installments,
                              payment_value)
                   FROM 's3://jmah-public-data/olist/order_payments.csv'
                   FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');


CREATE OR REPLACE TABLE s3_order_reviews
    (review_id VARCHAR(32),
     order_id VARCHAR(32),
     review_score INTEGER,
     review_comment_title STRING,
     review_comment_message STRING,
     review_creation_date TIMESTAMP,
     review_answer_timestamp TIMESTAMP,
     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    
     FOREIGN KEY (order_id) REFERENCES s3_orders(order_id));

COPY INTO s3_order_reviews (review_id,
                             order_id,
                             review_score,
                             review_comment_title,
                             review_comment_message,
                             review_creation_date,
                             review_answer_timestamp)
                   FROM 's3://jmah-public-data/olist/order_reviews.csv'
                   FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

CREATE OR REPLACE TABLE s3_products
    (product_id VARCHAR(32) PRIMARY KEY,
     product_category_name STRING,
     product_name_length INTEGER,
     product_description_length INTEGER,
     product_photos_qty INTEGER,
     products_weight_g INTEGER,
     products_length_cm INTEGER,
     products_height_cm INTEGER,
     products_width_cm INTEGER,
     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

COPY INTO s3_products (product_id,
                        product_category_name,
                        product_name_length,
                        product_description_length,
                        product_photos_qty,
                        products_weight_g,
                        products_length_cm,
                        products_height_cm,
                        products_width_cm)
                   FROM 's3://jmah-public-data/olist/products.csv'
                   FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

CREATE OR REPLACE TABLE s3_sellers
    (seller_id VARCHAR(32) PRIMARY KEY,
     seller_zip_code_prefix INTEGER,
     seller_city STRING,
     seller_state STRING,
     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

COPY INTO s3_sellers (seller_id,
                       seller_zip_code_prefix,
                       seller_city,
                       seller_state)
                   FROM 's3://jmah-public-data/olist/sellers.csv'
                   FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');            

CREATE OR REPLACE TABLE s3_product_category_name_translation (
     product_category_name STRING PRIMARY KEY,
     product_category_name_english STRING,
     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

COPY INTO s3_product_category_name_translation (
     product_category_name,
     product_category_name_english)
                   FROM 's3://jmah-public-data/olist/product_category_name_translation.csv'
                   FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

CREATE OR REPLACE TABLE s3_order_items
    (order_id VARCHAR(32),
     order_item_id INTEGER,
     product_id VARCHAR(32),
     seller_id VARCHAR(32),
     shipping_limit_date TIMESTAMP,
     price NUMBER(8, 2),
     freight_value NUMBER(8, 2),
     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     FOREIGN KEY (order_id) REFERENCES s3_orders(order_id),
     FOREIGN KEY (product_id) REFERENCES s3_products(product_id),
     FOREIGN KEY (seller_id) REFERENCES s3_sellers(seller_id));

COPY INTO s3_order_items (order_id,
                           order_item_id,
                           product_id,
                           seller_id,
                           shipping_limit_date,
                           price,
                           freight_value)
                   FROM 's3://jmah-public-data/olist/order_items.csv'
                   FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');
                   
```
