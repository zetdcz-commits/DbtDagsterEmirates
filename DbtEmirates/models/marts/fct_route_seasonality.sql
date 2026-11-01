-- Gold: one row per route, ticket class and calendar month.
select
    route_class_month_key,
    route,
    ticket_class,
    calendar_month,
    month_name,
    flights,
    avg_fare_usd,
    avg_load_factor_percent,
    route_avg_fare_usd,
    seasonality_index,
    season_label
from {{ ref('int_emirates_route_seasonality') }}