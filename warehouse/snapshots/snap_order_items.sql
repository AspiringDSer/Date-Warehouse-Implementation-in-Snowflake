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



