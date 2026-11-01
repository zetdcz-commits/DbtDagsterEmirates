with source as (

    select * from {{ source('raw', 'airports') }}

),

renamed as (

    select
        id::int                          as airport_id,
        ident                            as airport_ident,
        type                             as airport_type,
        name                             as airport_name,
        latitude_deg::numeric            as latitude_deg,
        longitude_deg::numeric           as longitude_deg,
        elevation_ft::int                as elevation_ft,
        continent,
        iso_country,
        iso_region,
        municipality,
        (scheduled_service = 'yes')      as has_scheduled_service,
        icao_code,
        iata_code,
        gps_code,
        local_code,
        home_link,
        wikipedia_link,
        keywords

    from source

)

select * from renamed
