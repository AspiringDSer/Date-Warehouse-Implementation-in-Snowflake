select
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value,
    dbt_updated_at,
    dbt_valid_from,
    dbt_valid_to

from {{ ref('stg_order_payments') }}