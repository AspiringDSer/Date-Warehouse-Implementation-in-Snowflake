select
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price_CAD AS price,
    freight_value_CAD AS freight_value,
    dbt_updated_at,
    dbt_valid_from,
    dbt_valid_to

from {{ ref('stg_order_items') }}