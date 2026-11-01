-- One row per flight: delays and on-time status (rules R01 to R04).
{% set hr  = "extract(hour from scheduled_departure_at)" %}
{% set tod = var('time_of_day_start_hours') %}
{% set cancelled_pattern = var('cancelled_status_prefix') ~ '%' %}

select
    flight_record_id,
    flight_date,
    status,
    scheduled_departure_at,
    actual_departure_at,
    scheduled_arrival_at,
    actual_arrival_at,
    departure_delay_minutes,
    arrival_delay_minutes,
    flight_duration_minutes,

    arrival_delay_minutes - departure_delay_minutes                as delay_change_in_flight_minutes,
    {{ hr }}::int                                                  as scheduled_departure_hour,

    case
        when {{ hr }} >= {{ tod['morning'] }}   and {{ hr }} < {{ tod['afternoon'] }} then 'morning'
        when {{ hr }} >= {{ tod['afternoon'] }} and {{ hr }} < {{ tod['evening'] }}   then 'afternoon'
        when {{ hr }} >= {{ tod['evening'] }}   and {{ hr }} < {{ tod['night'] }}     then 'evening'
        else 'night'
    end                                                            as departure_time_of_day,

    (lower(coalesce(status, '')) like '{{ cancelled_pattern }}')   as is_cancelled,
    (lower(coalesce(status, '')) not like '{{ cancelled_pattern }}'
        and coalesce(arrival_delay_minutes, 0) <= {{ var('on_time_threshold_minutes') }})
                                                                   as is_on_time,

    case
        when lower(coalesce(status, '')) like '{{ cancelled_pattern }}'                  then 'cancelled'
        when coalesce(arrival_delay_minutes, 0) <= {{ var('on_time_threshold_minutes') }} then 'on_time'
        when arrival_delay_minutes <= {{ var('delay_bucket_1_max_minutes') }}            then 'delayed_short'
        when arrival_delay_minutes <= {{ var('delay_bucket_2_max_minutes') }}            then 'delayed_medium'
        else 'delayed_long'
    end                                                            as arrival_delay_bucket

from {{ ref('stg_emirates_flights') }}
