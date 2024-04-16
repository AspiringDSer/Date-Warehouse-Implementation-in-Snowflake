with source as (

    select * from {{ source('src_snowflake', 's3_geolocation') }}

),

renamed as (

    select
        geolocation_zip AS zipcode,
        geolocation_lat AS latitude,
        geolocation_lng AS longitude,
        geolocation_city AS city_name,
        geolocation_state AS state

    from source

)

select * from renamed