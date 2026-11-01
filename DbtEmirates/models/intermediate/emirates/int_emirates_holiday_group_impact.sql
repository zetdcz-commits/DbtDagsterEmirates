-- One row per holiday group and haul type: how much each kind of holiday moves
-- fares, load and punctuality (rules R19, R27). 'none' is the non-holiday baseline.
select
    coalesce(i.holiday_period_group, 'none') || '|' || r.haul_type          as group_haul_key,
    coalesce(i.holiday_period_group, 'none')                                as holiday_group,
    r.haul_type,
    count(*)                                                                as flights,
    round(avg(i.fare_index), 3)                                             as avg_fare_index,
    round(avg(c.load_factor_percent), 1)                                    as avg_load_factor_percent,
    round(100.0 * avg(case when d.is_on_time then 1 else 0 end), 1)         as on_time_percent
from {{ ref('int_emirates_flight_fare_index') }}  i
join {{ ref('int_emirates_flight_routes') }}      r on i.flight_record_id = r.flight_record_id
join {{ ref('int_emirates_flight_capacity') }}    c on i.flight_record_id = c.flight_record_id
join {{ ref('int_emirates_flight_delays') }}      d on i.flight_record_id = d.flight_record_id
group by 1, 2, 3
