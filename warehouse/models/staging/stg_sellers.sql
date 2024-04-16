with source as (

    select * from {{ source('src_snowflake', 's3_sellers') }}

),

renamed as (

    select
        seller_id,
        seller_zip_code_prefix,
        seller_city,
        seller_state

    from source

)

select * from renamed