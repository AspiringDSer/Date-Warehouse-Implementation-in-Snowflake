select
    order_id,
    customer_id,
    order_status,
    order_date,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    dbt_updated_at,
    dbt_valid_from,
    dbt_valid_to

from {{ ref('stg_orders') }}