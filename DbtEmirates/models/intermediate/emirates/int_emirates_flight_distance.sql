-- One row per flight: great-circle distance from airport coordinates (rules R07, R08).
with routes as (

    select
        flight_record_id, flight_date, origin_airport, destination_airport, distance_km,
        origin_latitude_deg, origin_longitude_deg,
        destination_latitude_deg, destination_longitude_deg
    from {{ ref('int_emirates_flight_routes') }}

),

computed as (

    select
        *,
        round(({{ haversine_km('origin_latitude_deg', 'origin_longitude_deg',
                               'destination_latitude_deg', 'destination_longitude_deg') }})::numeric, 1)
            as great_circle_km
    from routes

)

select
    flight_record_id,
    flight_date,
    origin_airport,
    destination_airport,
    distance_km                                                     as source_distance_km,
    great_circle_km,
    coalesce(great_circle_km, distance_km)                          as distance_km_used,
    round(coalesce(great_circle_km, distance_km) * 0.621371, 1)     as distance_miles,
    round(great_circle_km - distance_km, 1)                         as distance_diff_km,
    coalesce(
        abs(great_circle_km - distance_km) / nullif(distance_km, 0)
            > {{ var('distance_mismatch_tolerance_pct') }},
        false
    )                                                               as distance_mismatch
from computed
