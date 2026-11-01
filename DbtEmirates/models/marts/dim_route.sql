-- Gold: one row per route pair (DXB-CAI and CAI-DXB are the same row per R30).
select
    route_pair,
    airport_a,
    airport_b,
    flights,
    first_flight_date,
    last_flight_date,
    avg_distance_km,
    haul_type,
    is_international,
    region
from {{ ref('int_emirates_routes') }}