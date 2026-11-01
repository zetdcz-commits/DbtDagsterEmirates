-- One row per flight: route keys, haul type and airport details (rules R05, R06, R09).
with flights as (

    select
        flight_record_id, flight_date, flight_number, flight_type,
        origin_airport, origin_city, origin_country,
        destination_airport, destination_city, destination_country,
        region, distance_km
    from {{ ref('stg_emirates_flights') }}

),

airports as (

    select * from {{ ref('int_airports_iata') }}

)

select
    f.*,
    f.origin_airport || '-' || f.destination_airport                          as route,
    least(f.origin_airport, f.destination_airport) || '-'
        || greatest(f.origin_airport, f.destination_airport)                  as route_pair,
    coalesce(f.origin_country <> f.destination_country, false)                as is_international,
    {{ haul_type('f.distance_km') }}                                          as haul_type,

    o.airport_name                                                            as origin_airport_name,
    o.iso_country                                                             as origin_iso_country,
    o.latitude_deg                                                            as origin_latitude_deg,
    o.longitude_deg                                                           as origin_longitude_deg,

    d.airport_name                                                            as destination_airport_name,
    d.iso_country                                                             as destination_iso_country,
    d.latitude_deg                                                            as destination_latitude_deg,
    d.longitude_deg                                                           as destination_longitude_deg

from flights f
left join airports o on f.origin_airport      = o.iata_code
left join airports d on f.destination_airport = d.iata_code
