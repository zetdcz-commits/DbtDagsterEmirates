-- Gold: one row per origin airport and day.
select
    airport_day_key,
    origin_airport,
    origin_iso_country,
    flight_date,
    to_char(flight_date, 'YYYYMMDD')::int   as date_key,
    flights,
    cancelled_flights,
    avg_departure_delay_minutes,
    on_time_percent,
    adverse_weather_percent,
    is_public_holiday,
    holiday_name
from {{ ref('int_emirates_airport_daily_ops') }}