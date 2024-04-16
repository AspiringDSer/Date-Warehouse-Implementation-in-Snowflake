with source as (

    select * from {{ source('src_snowflake', 's3_customers') }}

),

renamed as (

    select
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state

    from source

)

select * from renamed