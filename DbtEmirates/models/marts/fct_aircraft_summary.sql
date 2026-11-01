-- Gold: one row per aircraft model.
select
    aircraft_model,
    flights,
    passengers,
    avg_load_factor_percent,
    on_time_percent,
    total_revenue_usd
from {{ ref('int_emirates_aircraft_summary') }}