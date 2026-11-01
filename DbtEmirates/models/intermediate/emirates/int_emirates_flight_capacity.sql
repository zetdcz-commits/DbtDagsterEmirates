-- One row per flight: seats, passengers and load factor (rules R10 to R12).
select
    flight_record_id,
    flight_date,
    aircraft_model,
    seat_capacity,
    passenger_count,
    load_factor_percent,

    seat_capacity - passenger_count                                          as empty_seats,
    round(passenger_count::numeric / nullif(seat_capacity, 0) * 100, 1)      as calculated_load_factor_percent,

    coalesce(passenger_count > seat_capacity, false)                         as is_over_capacity,
    coalesce(
        abs(load_factor_percent
            - passenger_count::numeric / nullif(seat_capacity, 0) * 100)
            > {{ var('load_factor_tolerance_pts') }},
        false
    )                                                                        as load_factor_mismatch,

    case
        when load_factor_percent >= {{ var('load_factor_high_pct') }}   then 'high'
        when load_factor_percent >= {{ var('load_factor_medium_pct') }} then 'medium'
        else 'low'
    end                                                                      as load_factor_band

from {{ ref('stg_emirates_flights') }}
