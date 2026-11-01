-- One row per flight: every data quality flag in one place (rule R29).
with routes as (

    select flight_record_id, flight_date from {{ ref('int_emirates_flight_routes') }}

),

distance as (

    select flight_record_id, distance_mismatch, great_circle_km
    from {{ ref('int_emirates_flight_distance') }}

),

capacity as (

    select flight_record_id, load_factor_mismatch, is_over_capacity
    from {{ ref('int_emirates_flight_capacity') }}

),

revenue as (

    select flight_record_id, revenue_mismatch
    from {{ ref('int_emirates_flight_revenue') }}

),

delays as (

    select flight_record_id, is_cancelled, departure_delay_minutes, arrival_delay_minutes
    from {{ ref('int_emirates_flight_delays') }}

),

fuel as (

    select flight_record_id, fuel_burn_kg_per_km, usd_per_gallon
    from {{ ref('int_emirates_flight_fuel') }}

),

flags as (

    select
        r.flight_record_id,
        r.flight_date,
        di.distance_mismatch                                       as has_distance_mismatch,
        cap.load_factor_mismatch                                   as has_load_factor_mismatch,
        cap.is_over_capacity                                       as is_over_capacity,
        rev.revenue_mismatch                                       as has_revenue_mismatch,
        (di.great_circle_km is null)                               as is_missing_coordinates,
        (fu.fuel_burn_kg_per_km is null)                           as is_missing_burn_rate,
        (fu.usd_per_gallon is null)                                as is_missing_fuel_price,
        (de.is_cancelled
            and (coalesce(de.departure_delay_minutes, 0) > 0
                 or coalesce(de.arrival_delay_minutes, 0) > 0))    as has_delay_on_cancelled_flight
    from routes r
    left join distance di   on r.flight_record_id = di.flight_record_id
    left join capacity cap  on r.flight_record_id = cap.flight_record_id
    left join revenue rev   on r.flight_record_id = rev.flight_record_id
    left join delays de     on r.flight_record_id = de.flight_record_id
    left join fuel fu       on r.flight_record_id = fu.flight_record_id

)

select
    flight_record_id,
    flight_date,
    coalesce(has_distance_mismatch, false)           as has_distance_mismatch,
    coalesce(has_load_factor_mismatch, false)        as has_load_factor_mismatch,
    coalesce(is_over_capacity, false)                as is_over_capacity,
    coalesce(has_revenue_mismatch, false)            as has_revenue_mismatch,
    coalesce(is_missing_coordinates, false)          as is_missing_coordinates,
    coalesce(is_missing_burn_rate, false)            as is_missing_burn_rate,
    coalesce(is_missing_fuel_price, false)           as is_missing_fuel_price,
    coalesce(has_delay_on_cancelled_flight, false)   as has_delay_on_cancelled_flight,
    (coalesce(has_distance_mismatch, false)::int
     + coalesce(has_load_factor_mismatch, false)::int
     + coalesce(is_over_capacity, false)::int
     + coalesce(has_revenue_mismatch, false)::int
     + coalesce(is_missing_coordinates, false)::int
     + coalesce(is_missing_burn_rate, false)::int
     + coalesce(is_missing_fuel_price, false)::int
     + coalesce(has_delay_on_cancelled_flight, false)::int)  as issue_count,
    ((coalesce(has_distance_mismatch, false)::int
      + coalesce(has_load_factor_mismatch, false)::int
      + coalesce(is_over_capacity, false)::int
      + coalesce(has_revenue_mismatch, false)::int
      + coalesce(is_missing_coordinates, false)::int
      + coalesce(is_missing_burn_rate, false)::int
      + coalesce(is_missing_fuel_price, false)::int
      + coalesce(has_delay_on_cancelled_flight, false)::int) > 0) as has_any_issue
from flags
