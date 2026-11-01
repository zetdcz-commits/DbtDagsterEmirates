-- Gold: one row per flight — fares and revenue measures.
select
    flight_record_id,
    to_char(flight_date, 'YYYYMMDD')::int   as date_key,
    flight_date,
    ticket_class,
    average_ticket_price_usd,
    estimated_revenue_usd,
    revenue_per_passenger_usd,
    revenue_per_seat_usd,
    rask_usd,
    revenue_mismatch
from {{ ref('int_emirates_flight_revenue') }}