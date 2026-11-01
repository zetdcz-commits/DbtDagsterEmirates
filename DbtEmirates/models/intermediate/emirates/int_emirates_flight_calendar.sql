-- One row per flight: calendar attributes and the nearest holiday at each end
-- (rules R18, R19, R20). Holidays are matched by the ISO country of the origin
-- and destination airports.
with flights as (

    select flight_record_id, flight_date, origin_iso_country, destination_iso_country
    from {{ ref('int_emirates_flight_routes') }}

),

calendar as (

    select * from {{ ref('int_calendar') }}

),

holidays as (

    select * from {{ ref('int_holidays') }}

),

joined as (

    select
        f.flight_record_id,
        f.flight_date,
        c.calendar_year,
        c.calendar_quarter,
        c.calendar_month,
        c.month_name,
        c.day_name,
        c.is_weekend,
        oh.holiday_name    as nearest_origin_holiday,
        oh.holiday_group   as nearest_origin_holiday_group,
        oh.gap_days        as origin_holiday_gap_days,
        dh.holiday_name    as nearest_destination_holiday,
        dh.holiday_group   as nearest_destination_holiday_group,
        dh.gap_days        as destination_holiday_gap_days
    from flights f
    left join calendar c on f.flight_date = c.date_day
    left join lateral (
        select h.holiday_name, h.holiday_group, abs(h.holiday_date - f.flight_date) as gap_days
        from holidays h
        where h.country_code = f.origin_iso_country
        order by abs(h.holiday_date - f.flight_date), h.holiday_date
        limit 1
    ) oh on true
    left join lateral (
        select h.holiday_name, h.holiday_group, abs(h.holiday_date - f.flight_date) as gap_days
        from holidays h
        where h.country_code = f.destination_iso_country
        order by abs(h.holiday_date - f.flight_date), h.holiday_date
        limit 1
    ) dh on true

)

select
    *,
    coalesce(origin_holiday_gap_days = 0, false)         as is_origin_holiday,
    coalesce(destination_holiday_gap_days = 0, false)    as is_destination_holiday,
    (coalesce(origin_holiday_gap_days, 999999)      <= {{ var('holiday_window_days') }}
     or coalesce(destination_holiday_gap_days, 999999) <= {{ var('holiday_window_days') }})
                                                         as is_holiday_period,
    -- the group of the closer holiday when both ends are inside the window (origin wins a tie)
    case
        when coalesce(origin_holiday_gap_days, 999999) <= {{ var('holiday_window_days') }}
         and coalesce(origin_holiday_gap_days, 999999) <= coalesce(destination_holiday_gap_days, 999999)
            then nearest_origin_holiday_group
        when coalesce(destination_holiday_gap_days, 999999) <= {{ var('holiday_window_days') }}
            then nearest_destination_holiday_group
    end                                                  as holiday_period_group
from joined
