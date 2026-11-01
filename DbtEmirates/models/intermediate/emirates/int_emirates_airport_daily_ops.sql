-- One row per origin airport and day: departures, punctuality, weather and
-- whether it is a public holiday in the airport's country (rules R02, R17, R18).
with flights as (

    select
        r.origin_airport,
        r.origin_iso_country,
        r.flight_date,
        d.is_cancelled,
        d.is_on_time,
        d.departure_delay_minutes,
        w.is_adverse_weather
    from {{ ref('int_emirates_flight_routes') }}   r
    join {{ ref('int_emirates_flight_delays') }}   d on r.flight_record_id = d.flight_record_id
    join {{ ref('int_emirates_flight_weather') }}  w on r.flight_record_id = w.flight_record_id

),

daily as (

    select
        origin_airport,
        origin_iso_country,
        flight_date,
        count(*)                                                          as flights,
        count(*) filter (where is_cancelled)                              as cancelled_flights,
        round(avg(departure_delay_minutes), 1)                            as avg_departure_delay_minutes,
        round(100.0 * avg(case when is_on_time then 1 else 0 end), 1)     as on_time_percent,
        round(100.0 * avg(case when is_adverse_weather then 1 else 0 end), 1) as adverse_weather_percent
    from flights
    group by origin_airport, origin_iso_country, flight_date

)

select
    d.origin_airport || '|' || d.flight_date::text     as airport_day_key,
    d.*,
    coalesce(cc.is_public_holiday, false)              as is_public_holiday,
    cc.holiday_name
from daily d
left join {{ ref('int_country_calendar') }} cc
       on cc.date_day = d.flight_date
      and cc.country_code = d.origin_iso_country
