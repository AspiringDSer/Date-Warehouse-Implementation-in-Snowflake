select
    product_id,
    product_category_name_english as product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    products_weight_g,
    products_length_cm,
    products_height_cm,
    products_width_cm,
    dbt_updated_at,
    dbt_valid_from,
    dbt_valid_to

from {{ ref('stg_products') }}
JOIN {{ ref('stg_product_category_name_translation') }}
    ON stg_products.product_category_name = stg_product_category_name_translation.product_category_name