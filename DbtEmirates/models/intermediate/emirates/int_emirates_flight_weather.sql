-- One row per flight: weather flags (rules R15 to R17).
select
    flight_record_id,
    flight_date,
    weather_condition,
    temperature_c,
    wind_speed_kmh,
    visibility_km,

    coalesce(visibility_km < {{ var('low_visibility_km') }}, false)   as is_low_visibility,
    coalesce(wind_speed_kmh >= {{ var('high_wind_kmh') }}, false)     as is_high_wind,
    coalesce(visibility_km < {{ var('low_visibility_km') }}
             or wind_speed_kmh >= {{ var('high_wind_kmh') }}, false)  as is_adverse_weather

from {{ ref('stg_emirates_flights') }}
