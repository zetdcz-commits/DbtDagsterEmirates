with source as (

    select * from {{ source('raw', 'airport_frequencies') }}

),

renamed as (

    select
        id::int                  as frequency_id,
        airport_ref::int         as airport_id,
        airport_ident,
        type                     as frequency_type,
        description,
        frequency_mhz::numeric   as frequency_mhz

    from source

)

select * from renamed
