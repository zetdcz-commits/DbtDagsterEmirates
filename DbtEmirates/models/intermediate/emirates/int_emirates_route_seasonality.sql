-- One row per route, ticket class and calendar month (rule R28).
with fares as (

    select
        r.route,
        v.ticket_class,
        c.calendar_month,
        c.month_name,
        v.average_ticket_price_usd,
        cap.load_factor_percent
    from {{ ref('int_emirates_flight_revenue') }}   v
    join {{ ref('int_emirates_flight_routes') }}    r   on v.flight_record_id = r.flight_record_id
    join {{ ref('int_emirates_flight_calendar') }}  c   on v.flight_record_id = c.flight_record_id
    join {{ ref('int_emirates_flight_capacity') }}  cap on v.flight_record_id = cap.flight_record_id

),

route_avg as (

    select route, ticket_class, avg(average_ticket_price_usd) as route_avg_fare_usd
    from fares
    group by route, ticket_class

),

monthly as (

    select
        route,
        ticket_class,
        calendar_month,
        min(month_name)                        as month_name,
        count(*)                               as flights,
        avg(average_ticket_price_usd)          as avg_fare_usd,
        avg(load_factor_percent)               as avg_load_factor_percent
    from fares
    group by route, ticket_class, calendar_month

)

select
    m.route || '|' || m.ticket_class || '|' || m.calendar_month     as route_class_month_key,
    m.route,
    m.ticket_class,
    m.calendar_month,
    m.month_name,
    m.flights,
    round(m.avg_fare_usd, 2)                                        as avg_fare_usd,
    round(m.avg_load_factor_percent, 1)                             as avg_load_factor_percent,
    round(a.route_avg_fare_usd, 2)                                  as route_avg_fare_usd,
    round(m.avg_fare_usd / nullif(a.route_avg_fare_usd, 0), 3)      as seasonality_index,
    case
        when m.avg_fare_usd / nullif(a.route_avg_fare_usd, 0) >= {{ var('peak_season_index') }}     then 'peak'
        when m.avg_fare_usd / nullif(a.route_avg_fare_usd, 0) <= {{ var('off_peak_season_index') }} then 'off_peak'
        else 'normal'
    end                                                             as season_label
from monthly m
join route_avg a
  on m.route = a.route
 and m.ticket_class = a.ticket_class
