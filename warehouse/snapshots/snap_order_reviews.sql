{% snapshot snap_order_reviews %}

{{
    config(
      target_database='OLIST',
      target_schema='SNAPSHOTS',
      unique_key='review_id',

      strategy='timestamp',
      updated_at='updated_at',
    )
}}

select * from {{ source('src_snowflake', 's3_order_reviews') }}

{% endsnapshot %}