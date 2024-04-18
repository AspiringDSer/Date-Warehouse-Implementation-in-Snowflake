with source as (

    select * from {{ ref('snap_sellers') }}

),

renamed as (

    select
        seller_id,
        seller_zip_code_prefix,
        seller_city,
        seller_state,
        dbt_updated_at,
        dbt_valid_from,
        dbt_valid_to

    from source

)

select * from renamed