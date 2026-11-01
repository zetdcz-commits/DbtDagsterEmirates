-- One row per flight: estimated fuel burn and cost (rules R22 to R24, R26).
-- Fuel burn benchmarks come from wiki_5 (long-haul wide-body data); since that
-- table has multiple rows per aircraft model at different sector distances and
-- seat configurations, each flight is matched to its nearest benchmark row by
-- weighing distance and seat-capacity difference together.

with flights as (

    select flight_record_id, flight_date, aircraft_model, passenger_count
    from {{ ref('stg_emirates_flights') }}

),

distance as (

    select flight_record_id, distance_km_used, distance_miles
    from {{ ref('int_emirates_flight_distance') }}

),

-- Wikipedia's aircraft names don't match the fleet's naming convention;
-- normalize them here so the join below works cleanly.
burn_benchmarks as (

    select
        case aircraft_model_raw
            when 'Boeing 777-200LR' then 'B777-200LR'
            when 'Boeing 777-300ER' then 'B777-300ER'
            when 'Airbus A350-900'  then 'A350-900'
            when 'Airbus A380'      then 'A380-800'
            else aircraft_model_raw
        end                     as aircraft_model,
        seats                   as benchmark_seats,
        sector_distance_km      as benchmark_distance_km,
        fuel_burn_kg_per_km
    from {{ ref('stg_wikipedia_table_5') }}

),

prices as (

    select price_month, usd_per_gallon, is_carried_forward
    from {{ ref('int_jet_fuel_prices_monthly') }}

),

flights_with_distance as (

    select
        f.flight_record_id,
        f.flight_date,
        f.aircraft_model,
        f.passenger_count,
        d.distance_km_used,
        d.distance_miles
    from flights f
    join distance d on f.flight_record_id = d.flight_record_id

),

-- For each flight, pick the single closest benchmark row for its aircraft
-- model: closeness is a combined score of distance gap and seat-count gap,
-- both normalized so neither dimension dominates just because its numbers
-- are bigger (km values run into the thousands, seats only hundreds).
matched as (

    select
        fl.*,
        b.fuel_burn_kg_per_km
    from flights_with_distance fl
    left join lateral (
        select
            bb.fuel_burn_kg_per_km
        from burn_benchmarks bb
        where bb.aircraft_model = fl.aircraft_model
        order by
            abs(bb.benchmark_distance_km - fl.distance_km_used) / nullif(bb.benchmark_distance_km, 0)
            + abs(bb.benchmark_seats - fl.passenger_count) / nullif(bb.benchmark_seats, 0)
        limit 1
    ) b on true

),

fuel as (

    select
        flight_record_id,
        flight_date,
        aircraft_model,
        passenger_count,
        distance_km_used,
        distance_miles,
        fuel_burn_kg_per_km,
        distance_km_used * fuel_burn_kg_per_km                                    as fuel_burn_kg_raw,
        distance_km_used * fuel_burn_kg_per_km
            / {{ var('jet_fuel_density_kg_per_l') }}                              as fuel_burn_litres_raw,
        distance_km_used * fuel_burn_kg_per_km
            / {{ var('jet_fuel_density_kg_per_l') }} / {{ var('litres_per_gallon') }} as fuel_burn_gallons_raw
    from matched

)

select
    u.flight_record_id,
    u.flight_date,
    u.aircraft_model,
    u.distance_km_used,
    u.distance_miles,
    u.fuel_burn_kg_per_km,
    round(u.fuel_burn_kg_raw::numeric, 0)                                            as fuel_burn_kg,
    round(u.fuel_burn_litres_raw::numeric, 0)                                        as fuel_burn_litres,
    round(u.fuel_burn_gallons_raw::numeric, 0)                                       as fuel_burn_gallons,
    round((u.fuel_burn_gallons_raw / nullif(u.distance_miles, 0))::numeric, 2)       as gallons_per_mile,
    p.usd_per_gallon,
    coalesce(p.is_carried_forward, false)                                            as price_is_carried_forward,
    round((u.fuel_burn_gallons_raw * p.usd_per_gallon)::numeric, 2)                  as estimated_fuel_cost_usd,
    round((u.fuel_burn_gallons_raw * p.usd_per_gallon
           / nullif(u.passenger_count, 0))::numeric, 2)                              as fuel_cost_per_passenger_usd
from fuel u
left join prices p on date_trunc('month', u.flight_date)::date = p.price_month