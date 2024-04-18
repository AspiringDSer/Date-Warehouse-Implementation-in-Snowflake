with source as (

    select * from {{ ref('snap_order_payments') }}

),

renamed as (

    select
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value,
        dbt_updated_at,
        dbt_valid_from,
        dbt_valid_to

    from source

)

select * from renamed