-- Gold: one row per flight — the core operational fact. Revenue and fuel are
-- kept in their own fact tables (fct_flight_revenue, fct_flight_fuel) joined
-- on flight_record_id, rather than widened into this table.
select
    r.flight_record_id,
    to_char(r.flight_date, 'YYYYMMDD')::int                  as date_key,
    r.flight_date,
    r.flight_number,
    r.flight_type,
    r.aircraft_model,

    r.origin_airport,
    r.destination_airport,
    r.route,
    r.route_pair,
    r.haul_type,
    r.is_international,
    r.region,

    d.status,
    d.scheduled_departure_at,
    d.actual_departure_at,
    d.scheduled_arrival_at,
    d.actual_arrival_at,
    d.departure_delay_minutes,
    d.arrival_delay_minutes,
    d.flight_duration_minutes,
    d.delay_change_in_flight_minutes,
    d.scheduled_departure_hour,
    d.departure_time_of_day,
    d.is_cancelled,
    d.is_on_time,
    d.arrival_delay_bucket,

    c.seat_capacity,
    c.passenger_count,
    c.load_factor_percent,
    c.empty_seats,
    c.is_over_capacity,
    c.load_factor_band,

    w.weather_condition,
    w.temperature_c,
    w.wind_speed_kmh,
    w.visibility_km,
    w.is_low_visibility,
    w.is_high_wind,
    w.is_adverse_weather,

    g.terminal,
    g.gate,
    g.baggage_belt,
    g.terminal_gate,
    g.has_baggage_belt,

    cal.calendar_year,
    cal.calendar_quarter,
    cal.calendar_month,
    cal.is_weekend,
    cal.is_holiday_period,
    cal.holiday_period_group,
    cal.nearest_origin_holiday,
    cal.origin_holiday_gap_days,
    cal.nearest_destination_holiday,
    cal.destination_holiday_gap_days

from {{ ref('int_emirates_flight_routes') }}   r
join {{ ref('int_emirates_flight_delays') }}   d   on r.flight_record_id = d.flight_record_id
join {{ ref('int_emirates_flight_capacity') }} c   on r.flight_record_id = c.flight_record_id
join {{ ref('int_emirates_flight_weather') }}  w   on r.flight_record_id = w.flight_record_id
join {{ ref('int_emirates_flight_gate_ops') }} g   on r.flight_record_id = g.flight_record_id
join {{ ref('int_emirates_flight_calendar') }} cal on r.flight_record_id = cal.flight_record_id