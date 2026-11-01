-- One row per route and ticket class: fares in holiday periods against other
-- periods (rules R19, R27). Only routes and classes that have both are kept.
select
    route || '|' || ticket_class                                              as route_class_key,
    route,
    ticket_class,
    count(*) filter (where is_holiday_period and fare_index is not null)      as holiday_flights,
    count(*) filter (where not is_holiday_period and fare_index is not null)  as regular_flights,
    round(avg(average_ticket_price_usd) filter (where is_holiday_period), 2)  as avg_price_holiday_usd,
    round(avg(average_ticket_price_usd) filter (where not is_holiday_period), 2) as avg_price_regular_usd,
    round(avg(fare_index) filter (where is_holiday_period), 3)                as avg_fare_index_holiday,
    round(100 * (avg(fare_index) filter (where is_holiday_period) - 1), 1)    as holiday_price_uplift_pct
from {{ ref('int_emirates_flight_fare_index') }}
group by route, ticket_class
having count(*) filter (where is_holiday_period and fare_index is not null) > 0
   and count(*) filter (where not is_holiday_period and fare_index is not null) > 0
