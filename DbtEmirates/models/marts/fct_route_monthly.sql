-- Gold: one row per route and month.
select
    route_month_key,
    route,
    origin_airport,
    destination_airport,
    is_international,
    haul_type,
    flight_month,
    to_char(flight_month, 'YYYYMM')::int   as year_month_key,
    flights,
    cancelled_flights,
    passengers,
    avg_load_factor_percent,
    on_time_percent,
    avg_arrival_delay_minutes,
    total_revenue_usd
from {{ ref('int_emirates_route_monthly') }}