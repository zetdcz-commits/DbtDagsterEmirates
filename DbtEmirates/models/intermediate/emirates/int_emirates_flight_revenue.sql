-- One row per flight: fares and revenue measures (rules R13, R14).
with flights as (

    select
        flight_record_id, flight_date, ticket_class,
        average_ticket_price_usd, estimated_revenue_usd,
        passenger_count, seat_capacity
    from {{ ref('stg_emirates_flights') }}

),

distance as (

    select flight_record_id, distance_km_used
    from {{ ref('int_emirates_flight_distance') }}

)

select
    f.flight_record_id,
    f.flight_date,
    f.ticket_class,
    f.average_ticket_price_usd,
    f.estimated_revenue_usd,

    round(f.estimated_revenue_usd / nullif(f.passenger_count, 0), 2)               as revenue_per_passenger_usd,
    round(f.estimated_revenue_usd / nullif(f.seat_capacity, 0), 2)                 as revenue_per_seat_usd,
    -- revenue per available seat km
    round(f.estimated_revenue_usd / nullif(f.seat_capacity * d.distance_km_used, 0), 4) as rask_usd,

    round(f.passenger_count * f.average_ticket_price_usd, 2)                       as expected_revenue_usd,
    coalesce(
        abs(f.estimated_revenue_usd - f.passenger_count * f.average_ticket_price_usd)
            > {{ var('revenue_tolerance_usd') }},
        false
    )                                                                              as revenue_mismatch

from flights f
left join distance d on f.flight_record_id = d.flight_record_id
