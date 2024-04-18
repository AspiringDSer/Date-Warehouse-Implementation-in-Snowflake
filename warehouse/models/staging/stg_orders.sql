with source as (

    select * from {{ ref('snap_orders') }}

),

renamed as (

    select
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp::date as order_date,
        order_delivered_carrier_date::date as order_delivered_carrier_date,
        order_delivered_customer_date::date as order_delivered_customer_date,
        order_estimated_delivery_date::date as order_estimated_delivery_date,
        dbt_updated_at,
        dbt_valid_from,
        dbt_valid_to

    from source

)

select * from renamed