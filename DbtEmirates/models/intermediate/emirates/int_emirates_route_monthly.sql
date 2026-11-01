-- One row per route and month (rule R02: cancelled flights count as not on time).
select
    r.route || '|' || date_trunc('month', r.flight_date)::date::text   as route_month_key,
    r.route,
    r.origin_airport,
    r.destination_airport,
    r.is_international,
    r.haul_type,
    date_trunc('month', r.flight_date)::date                           as flight_month,

    count(*)                                                           as flights,
    count(*) filter (where d.is_cancelled)                             as cancelled_flights,
    sum(c.passenger_count)                                             as passengers,
    round(avg(c.load_factor_percent), 1)                               as avg_load_factor_percent,
    round(100.0 * avg(case when d.is_on_time then 1 else 0 end), 1)    as on_time_percent,
    round(avg(d.arrival_delay_minutes), 1)                             as avg_arrival_delay_minutes,
    sum(v.estimated_revenue_usd)                                       as total_revenue_usd

from {{ ref('int_emirates_flight_routes') }}   r
join {{ ref('int_emirates_flight_delays') }}   d on r.flight_record_id = d.flight_record_id
join {{ ref('int_emirates_flight_capacity') }} c on r.flight_record_id = c.flight_record_id
join {{ ref('int_emirates_flight_revenue') }}  v on r.flight_record_id = v.flight_record_id
group by 1, 2, 3, 4, 5, 6, 7
