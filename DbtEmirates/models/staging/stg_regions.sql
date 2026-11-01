with source as (

    select * from {{ source('raw', 'regions') }}

),

renamed as (

    select
        id::int          as region_id,
        code             as region_code,
        local_code,
        name             as region_name,
        continent,
        iso_country,
        wikipedia_link,
        keywords

    from source

)

select * from renamed
