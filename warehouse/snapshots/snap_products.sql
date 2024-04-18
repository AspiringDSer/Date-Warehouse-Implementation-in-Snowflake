{% snapshot snap_products %}

{{
    config(
      target_database='OLIST',
      target_schema='SNAPSHOTS',
      unique_key='product_id',

      strategy='timestamp',
      updated_at='updated_at',
    )
}}

select * from {{ source('src_snowflake', 's3_products') }}

{% endsnapshot %}