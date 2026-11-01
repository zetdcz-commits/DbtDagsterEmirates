-- One open airport per IATA code (rule R09), so joining flights on an IATA code
-- can never duplicate a flight.
with airports as (

    select * from {{ ref('stg_airports') }}
    where iata_code is not null
      and iata_code <> ''
      and airport_type <> 'closed'

),

ranked as (

    select
        *,
        row_number() over (
            partition by iata_code
            order by
                case airport_type
                    when 'large_airport'  then 1
                    when 'medium_airport' then 2
                    when 'small_airport'  then 3
                    else 4
                end,
                has_scheduled_service desc,
                airport_id
        ) as rn
    from airports

)

select
    iata_code,
    airport_id,
    airport_ident,
    airport_name,
    airport_type,
    municipality,
    iso_country,
    iso_region,
    latitude_deg,
    longitude_deg,
    elevation_ft
from ranked
where rn = 1
