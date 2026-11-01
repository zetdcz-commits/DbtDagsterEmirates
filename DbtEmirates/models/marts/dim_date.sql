-- Gold: one row per day. Thin pass-through of int_calendar for the analytics
-- team — stable column set, no business logic, safe for BI tools to model
-- relationships against without touching the silver layer.
select
    date_day,
    date_key,

    calendar_year,
    calendar_quarter,
    quarter_label,
    year_quarter,

    calendar_month,
    month_name,
    month_short,
    month_year_label,
    year_month,
    year_month_key,

    iso_year,
    iso_week,
    week_start_date,
    week_end_date,

    day_of_month,
    day_of_year,
    iso_day_of_week,
    day_name,
    day_short,
    is_weekend,
    is_weekday,

    month_start_date,
    month_end_date,
    is_month_start,
    is_month_end,
    days_in_month,

    fiscal_year,
    fiscal_quarter,

    same_day_last_year

from {{ ref('int_calendar') }}