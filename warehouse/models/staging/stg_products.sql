with source as (

    select * from {{ source('src_snowflake', 's3_products') }}

),

renamed as (

    select
        product_id,
        product_category_name,
        product_name_length,
        product_description_length,
        product_photos_qty,
        products_weight_g,
        products_length_cm,
        products_height_cm,
        products_width_cm

    from source

)

select * from renamed