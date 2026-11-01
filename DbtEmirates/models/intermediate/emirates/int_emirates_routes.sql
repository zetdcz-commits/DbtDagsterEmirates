-- One row per route pair, where DXB-CAI and CAI-DXB are the same pair (rules R05, R06, R30).
select
    route_pair,
    min(least(origin_airport, destination_airport))       as airport_a,
    max(greatest(origin_airport, destination_airport))    as airport_b,
    count(*)                                              as flights,
    min(flight_date)                                      as first_flight_date,
    max(flight_date)                                      as last_flight_date,
    round(avg(distance_km), 0)                            as avg_distance_km,
    {{ haul_type('avg(distance_km)') }}                   as haul_type,
    bool_or(is_international)                             as is_international,
    mode() within group (order by region)                 as region
from {{ ref('int_emirates_flight_routes') }}
group by route_pair
