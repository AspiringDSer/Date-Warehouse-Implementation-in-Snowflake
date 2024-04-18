{% snapshot snap_sellers %}

{{
    config(
      target_database='OLIST',
      target_schema='SNAPSHOTS',
      unique_key='seller_id',

      strategy='timestamp',
      updated_at='updated_at',
    )
}}

select * from {{ source('src_snowflake', 's3_sellers') }}

{% endsnapshot %}