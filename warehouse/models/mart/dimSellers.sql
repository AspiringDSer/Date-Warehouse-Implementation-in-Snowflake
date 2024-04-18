select
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state,
    dbt_updated_at,
    dbt_valid_from,
    dbt_valid_to

from {{ ref('stg_sellers') }}