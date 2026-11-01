-- One row per day for whole calendar years covering the flight dates (like
-- CALENDARAUTO in Power BI). Rules R20 (weekend) and R21 (fiscal year).
with bounds as (

    select
        date_trunc('year', min(flight_date))::date                                          as start_date,
        (date_trunc('year', max(flight_date)) + interval '1 year' - interval '1 day')::date as end_date
    from {{ ref('stg_emirates_flights') }}

),

days as (

    select d::date as date_day
    from bounds,
         generate_series(bounds.start_date, bounds.end_date, interval '1 day') as d

),

base as (

    select
        date_day,
        extract(year    from date_day)::int   as calendar_year,
        extract(quarter from date_day)::int   as calendar_quarter,
        extract(month   from date_day)::int   as calendar_month,
        extract(day     from date_day)::int   as day_of_month,
        extract(doy     from date_day)::int   as day_of_year,
        extract(isodow  from date_day)::int   as iso_day_of_week,
        extract(week    from date_day)::int   as iso_week,
        extract(isoyear from date_day)::int   as iso_year,
        date_trunc('month', date_day)::date   as month_start_date,
        (date_trunc('month', date_day) + interval '1 month' - interval '1 day')::date as month_end_date
    from days

)

select
    date_day,
    to_char(date_day, 'YYYYMMDD')::int                        as date_key,

    calendar_year,
    calendar_quarter,
    'Q' || calendar_quarter                                   as quarter_label,
    calendar_year || '-Q' || calendar_quarter                 as year_quarter,

    calendar_month,
    to_char(date_day, 'FMMonth')                              as month_name,
    to_char(date_day, 'Mon')                                  as month_short,
    to_char(date_day, 'Mon YYYY')                             as month_year_label,
    to_char(date_day, 'YYYY-MM')                              as year_month,
    calendar_year * 100 + calendar_month                      as year_month_key,

    iso_year,
    iso_week,
    date_trunc('week', date_day)::date                        as week_start_date,
    (date_trunc('week', date_day) + interval '6 days')::date  as week_end_date,

    day_of_month,
    day_of_year,
    iso_day_of_week,
    to_char(date_day, 'FMDay')                                as day_name,
    to_char(date_day, 'Dy')                                   as day_short,
    (iso_day_of_week in (6, 7))                               as is_weekend,
    (iso_day_of_week not in (6, 7))                           as is_weekday,

    month_start_date,
    month_end_date,
    (date_day = month_start_date)                             as is_month_start,
    (date_day = month_end_date)                               as is_month_end,
    extract(day from month_end_date)::int                     as days_in_month,

    -- fiscal year is named for the calendar year it ends in
    calendar_year + case
        when {{ var('fiscal_year_start_month') }} > 1
         and calendar_month >= {{ var('fiscal_year_start_month') }} then 1
        else 0
    end                                                       as fiscal_year,
    ((calendar_month - {{ var('fiscal_year_start_month') }} + 12) % 12) / 3 + 1
                                                              as fiscal_quarter,

    (date_day - interval '1 year')::date                      as same_day_last_year

from base
