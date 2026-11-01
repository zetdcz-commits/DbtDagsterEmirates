-- Gold: one row per flight — fuel burn, cost and margin. Merges
-- int_emirates_flight_fuel and int_emirates_flight_fuel_margin so the
-- analytics team gets fuel economics in a single fact table.
select
    fu.flight_record_id,
    to_char(fu.flight_date, 'YYYYMMDD')::int   as date_key,
    fu.flight_date,
    fu.aircraft_model,
    fu.distance_km_used,
    fu.distance_miles,
    fu.fuel_burn_kg_per_km,
    fu.fuel_burn_kg,
    fu.fuel_burn_litres,
    fu.fuel_burn_gallons,
    fu.gallons_per_mile,
    fu.usd_per_gallon,
    fu.price_is_carried_forward,
    fu.estimated_fuel_cost_usd,
    fu.fuel_cost_per_passenger_usd,

    m.estimated_revenue_usd,
    m.fuel_margin_usd,
    m.fuel_margin_pct,
    m.fuel_cost_pct_of_revenue,
    m.fuel_margin_per_ask_usd

from {{ ref('int_emirates_flight_fuel') }}        fu
left join {{ ref('int_emirates_flight_fuel_margin') }} m
       on fu.flight_record_id = m.flight_record_id