with source as (

    select * from {{ ref('snap_order_items') }}

),

renamed as (

    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date,
        price AS price_BR,
        round((price * 0.27), 2) AS price_CAD,
        freight_value AS freight_value_BR,
        round((freight_value * 0.27), 2) AS freight_value_CAD,
        dbt_updated_at,
        dbt_valid_from,
        dbt_valid_to

    from source

)

select * from renamed