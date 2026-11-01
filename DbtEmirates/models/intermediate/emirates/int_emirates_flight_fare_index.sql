-- One row per flight: fare compared with a non-holiday baseline for the same
-- route and ticket class (rule R27).
with fares as (

    select
        v.flight_record_id,
        v.flight_date,
        r.route,
        v.ticket_class,
        v.average_ticket_price_usd,
        c.is_holiday_period,
        c.holiday_period_group,
        d.is_cancelled
    from {{ ref('int_emirates_flight_revenue') }}   v
    join {{ ref('int_emirates_flight_routes') }}    r on v.flight_record_id = r.flight_record_id
    join {{ ref('int_emirates_flight_calendar') }}  c on v.flight_record_id = c.flight_record_id
    join {{ ref('int_emirates_flight_delays') }}    d on v.flight_record_id = d.flight_record_id

),

baseline as (

    select
        route,
        ticket_class,
        count(*)                          as baseline_flights,
        avg(average_ticket_price_usd)     as baseline_price_usd
    from fares
    where not is_holiday_period
      and not is_cancelled
    group by route, ticket_class
    having count(*) >= {{ var('fare_baseline_min_flights') }}

)

select
    f.flight_record_id,
    f.flight_date,
    f.route,
    f.ticket_class,
    f.is_holiday_period,
    f.holiday_period_group,
    f.average_ticket_price_usd,
    round(b.baseline_price_usd, 2)                                        as baseline_price_usd,
    b.baseline_flights,
    round(f.average_ticket_price_usd / nullif(b.baseline_price_usd, 0), 3) as fare_index
from fares f
left join baseline b
       on f.route = b.route
      and f.ticket_class = b.ticket_class
