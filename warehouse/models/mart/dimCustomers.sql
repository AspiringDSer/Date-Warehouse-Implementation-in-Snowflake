select
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state,
    dbt_updated_at,
    dbt_valid_from,
    dbt_valid_to
from {{ ref('stg_customers') }}