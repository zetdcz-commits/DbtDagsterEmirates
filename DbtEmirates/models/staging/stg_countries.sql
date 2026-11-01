with source as (

    select * from {{ source('raw', 'countries') }}

),

renamed as (

    select
        id::int          as country_id,
        code             as country_code,
        name             as country_name,
        continent,
        wikipedia_link,
        keywords

    from source

)

select * from renamed
