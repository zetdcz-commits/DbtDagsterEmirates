with source as (

    select * from {{ source('raw', 'emirates_flights_2024_2026') }}

),

renamed as (

    select
        record_id::int                                       as flight_record_id,
        {{ parse_date('flight_date') }}                      as flight_date,
        flight_year::int                                     as flight_year,
        flight_month::int                                    as flight_month,
        flight_day_of_week,
        flight_number,
        airline,
        flight_type,

        origin_airport,
        origin_city,
        origin_country,
        destination_airport,
        destination_city,
        destination_country,
        region,

        {{ parse_timestamp('scheduled_departure') }}         as scheduled_departure_at,
        {{ parse_timestamp('actual_departure') }}            as actual_departure_at,
        {{ parse_timestamp('scheduled_arrival') }}           as scheduled_arrival_at,
        {{ parse_timestamp('actual_arrival') }}              as actual_arrival_at,

        departure_delay_minutes::int                         as departure_delay_minutes,
        arrival_delay_minutes::int                           as arrival_delay_minutes,
        flight_duration_minutes::int                         as flight_duration_minutes,
        distance_km::numeric                                 as distance_km,

        aircraft_model,
        seat_capacity::int                                   as seat_capacity,
        passenger_count::int                                 as passenger_count,
        load_factor_percent::numeric                         as load_factor_percent,

        terminal,
        gate,
        baggage_belt,
        status,

        weather_condition,
        temperature_c::numeric                               as temperature_c,
        wind_speed_kmh::numeric                              as wind_speed_kmh,
        visibility_km::numeric                               as visibility_km,

        ticket_class,
        average_ticket_price_usd::numeric                    as average_ticket_price_usd,
        estimated_revenue_usd::numeric                       as estimated_revenue_usd

    from source

)

select * from renamed
