-- Gold: one row per route and ticket class — holiday vs regular fares.
select
    route_class_key,
    route,
    ticket_class,
    holiday_flights,
    regular_flights,
    avg_price_holiday_usd,
    avg_price_regular_usd,
    avg_fare_index_holiday,
    holiday_price_uplift_pct
from {{ ref('int_emirates_holiday_fare_impact') }}