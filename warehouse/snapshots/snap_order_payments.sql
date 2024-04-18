{% snapshot snap_order_payments %}

{{
    config(
      target_database='OLIST',
      target_schema='SNAPSHOTS',
      unique_key='order_id',

      strategy='timestamp',
      updated_at='updated_at',
    )
}}

select * from {{ source('src_snowflake', 's3_order_payments') }}

{% endsnapshot %}