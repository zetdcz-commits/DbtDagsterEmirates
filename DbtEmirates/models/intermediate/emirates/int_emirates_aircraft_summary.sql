-- One row per aircraft model (rule R02: cancelled flights count as not on time).
select
    c.aircraft_model,
    count(*)                                                           as flights,
    sum(c.passenger_count)                                             as passengers,
    round(avg(c.load_factor_percent), 1)                               as avg_load_factor_percent,
    round(100.0 * avg(case when d.is_on_time then 1 else 0 end), 1)    as on_time_percent,
    sum(v.estimated_revenue_usd)                                       as total_revenue_usd

from {{ ref('int_emirates_flight_capacity') }} c
join {{ ref('int_emirates_flight_delays') }}   d on c.flight_record_id = d.flight_record_id
join {{ ref('int_emirates_flight_revenue') }}  v on c.flight_record_id = v.flight_record_id
group by c.aircraft_model
