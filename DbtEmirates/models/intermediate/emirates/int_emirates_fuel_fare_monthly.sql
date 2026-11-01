-- One row per route and month: how much of the fare is fuel (rules R24, R26).
select
    r.route || '|' || date_trunc('month', r.flight_date)::date::text     as route_month_key,
    r.route,
    date_trunc('month', r.flight_date)::date                             as flight_month,
    count(*)                                                             as flights,
    round(avg(v.average_ticket_price_usd), 2)                            as avg_fare_usd,
    round(avg(fu.fuel_cost_per_passenger_usd), 2)                        as avg_fuel_cost_per_passenger_usd,
    round(avg(fu.usd_per_gallon)::numeric, 3)                                     as avg_jet_fuel_usd_per_gallon,
    round(avg(fu.fuel_cost_per_passenger_usd)
          / nullif(avg(v.average_ticket_price_usd), 0), 3)               as fuel_share_of_fare
from {{ ref('int_emirates_flight_routes') }} r
join {{ ref('int_emirates_flight_revenue') }} v  on r.flight_record_id = v.flight_record_id
join {{ ref('int_emirates_flight_fuel') }}    fu on r.flight_record_id = fu.flight_record_id
group by 1, 2, 3
