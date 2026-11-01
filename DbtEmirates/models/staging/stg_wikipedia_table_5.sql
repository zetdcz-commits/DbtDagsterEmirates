-- Cleans wiki_5 (long-haul wide-body fuel benchmarks): parses out numeric
-- sector distance (km) and fuel burn (kg/km) from the combined text columns.
with source as (

    select
        "Model"       as aircraft_model_raw,
        "First flight" as first_flight,
        "Seats"       as seats,
        "Sector"      as sector_raw,
        "Fuel burn"   as fuel_burn_raw
    from {{ ref('wikipedia_table_5') }}

),

cleaned as (

    select
        aircraft_model_raw,
        first_flight,
        seats,

        -- grab the digits inside "(...km)", stopping at the first non-digit
        -- run before "km" — position-based, so odd whitespace bytes don't matter
        replace(
            (regexp_match(sector_raw, '\(([0-9,.]+)\D*km\)'))[1],
            ',', ''
        )::numeric as sector_distance_km,

        -- grab the digits at the very start of the string, before whatever
        -- separates them from "kg/km" — again position-based, not text-based
        replace(
            (regexp_match(fuel_burn_raw, '^([0-9,.]+)'))[1],
            ',', ''
        )::numeric as fuel_burn_kg_per_km

    from source

)

select
    aircraft_model_raw,
    first_flight,
    seats,
    sector_distance_km,
    fuel_burn_kg_per_km
from cleaned