-- Gold: one row per holiday group and haul type.
select
    group_haul_key,
    holiday_group,
    haul_type,
    flights,
    avg_fare_index,
    avg_load_factor_percent,
    on_time_percent
from {{ ref('int_emirates_holiday_group_impact') }}