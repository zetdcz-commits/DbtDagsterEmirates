-- Gold: one row per route and month — fuel's share of the fare.
select
    route_month_key,
    route,
    flight_month,
    to_char(flight_month, 'YYYYMM')::int   as year_month_key,
    flights,
    avg_fare_usd,
    avg_fuel_cost_per_passenger_usd,
    avg_jet_fuel_usd_per_gallon,
    fuel_share_of_fare
from {{ ref('int_emirates_fuel_fare_monthly') }}