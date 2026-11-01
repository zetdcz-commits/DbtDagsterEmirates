with source as (

    select * from {{ source('raw', 'navaids') }}

),

renamed as (

    select
        id::int                          as navaid_id,
        filename,
        ident                            as navaid_ident,
        name                             as navaid_name,
        type                             as navaid_type,
        frequency_khz::int               as frequency_khz,
        latitude_deg::numeric            as latitude_deg,
        longitude_deg::numeric           as longitude_deg,
        elevation_ft::int                as elevation_ft,
        iso_country,
        dme_frequency_khz::int           as dme_frequency_khz,
        dme_channel,
        dme_latitude_deg::numeric        as dme_latitude_deg,
        dme_longitude_deg::numeric       as dme_longitude_deg,
        dme_elevation_ft::int            as dme_elevation_ft,
        slaved_variation_deg::numeric    as slaved_variation_deg,
        magnetic_variation_deg::numeric  as magnetic_variation_deg,
        usage_type,
        power,
        associated_airport               as associated_airport_ident

    from source

)

select * from renamed
