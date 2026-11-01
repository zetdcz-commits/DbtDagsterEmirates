-- Gold: one row per aircraft model. Consolidates the fleet's own seat capacity
-- (from the flights file) with fuel-burn benchmark data (from wiki_5), so the
-- analytics team has a single aircraft dimension instead of joining seed and
-- benchmark data themselves.
with fleet as (

    select
        aircraft_model,
        max(seat_capacity)   as seat_capacity,
        count(*)             as flights_operated
    from {{ ref('stg_emirates_flights') }}
    group by aircraft_model

),

-- Same name normalization used in int_emirates_flight_fuel, so this dimension's
-- aircraft_model values line up with the fleet's naming convention.
benchmarks as (

    select
        case aircraft_model_raw
            when 'Boeing 777-200LR' then 'B777-200LR'
            when 'Boeing 777-300ER' then 'B777-300ER'
            when 'Airbus A350-900'  then 'A350-900'
            when 'Airbus A380'      then 'A380-800'
            else aircraft_model_raw
        end                     as aircraft_model,
        avg(fuel_burn_kg_per_km) as avg_benchmark_fuel_burn_kg_per_km,
        min(sector_distance_km)  as min_benchmark_sector_km,
        max(sector_distance_km)  as max_benchmark_sector_km,
        count(*)                 as benchmark_row_count
    from {{ ref('stg_wikipedia_table_5') }}
    group by 1

)

select
    f.aircraft_model,
    f.seat_capacity,
    f.flights_operated,
    b.avg_benchmark_fuel_burn_kg_per_km,
    b.min_benchmark_sector_km,
    b.max_benchmark_sector_km,
    b.benchmark_row_count,
    (b.aircraft_model is null)   as is_missing_fuel_benchmark
from fleet f
left join benchmarks b on f.aircraft_model = b.aircraft_model