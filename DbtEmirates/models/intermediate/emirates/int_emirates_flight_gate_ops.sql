-- One row per flight: terminal, gate and baggage belt assignment.
select
    flight_record_id,
    flight_date,
    flight_type,
    terminal,
    gate,
    baggage_belt,
    nullif(concat_ws('-', terminal, gate), '')    as terminal_gate,
    (baggage_belt is not null)                    as has_baggage_belt
from {{ ref('stg_emirates_flights') }}
