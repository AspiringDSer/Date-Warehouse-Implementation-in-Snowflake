{% snapshot snap_customers %}

{{
    config(
      target_database='OLIST',
      target_schema='SNAPSHOTS',
      unique_key='customer_unique_id',

      strategy='timestamp',
      updated_at='updated_at',
    )
}}

select * from {{ source('src_snowflake', 's3_customers') }}

{% endsnapshot %}