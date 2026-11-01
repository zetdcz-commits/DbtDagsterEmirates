with source as (

    select * from {{ source('raw', 'runways') }}

),

renamed as (

    select
        id::int                              as runway_id,
        airport_ref::int                     as airport_id,
        airport_ident,
        length_ft::int                       as length_ft,
        width_ft::int                        as width_ft,
        surface,
        (lighted::int = 1)                   as is_lighted,
        (closed::int = 1)                    as is_closed,

        le_ident,
        le_latitude_deg::numeric             as le_latitude_deg,
        le_longitude_deg::numeric            as le_longitude_deg,
        le_elevation_ft::int                 as le_elevation_ft,
        le_heading_deg_t::numeric            as le_heading_deg_true,
        le_displaced_threshold_ft::int       as le_displaced_threshold_ft,

        he_ident,
        he_latitude_deg::numeric             as he_latitude_deg,
        he_longitude_deg::numeric            as he_longitude_deg,
        he_elevation_ft::int                 as he_elevation_ft,
        he_heading_deg_t::numeric            as he_heading_deg_true,
        he_displaced_threshold_ft::int       as he_displaced_threshold_ft

    from source

)

select * from renamed
