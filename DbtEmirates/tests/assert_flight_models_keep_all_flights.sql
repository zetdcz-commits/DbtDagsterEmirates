-- Every flight-level silver model must have exactly one row per flight in
-- stg_emirates_flights. A different count means a join dropped or duplicated flights.
with expected as (

    select count(*) as n from {{ ref('stg_emirates_flights') }}

),

actual as (

    select 'flight_routes' as model, count(*) as n from {{ ref('int_emirates_flight_routes') }}
    union all select 'flight_distance',       count(*) from {{ ref('int_emirates_flight_distance') }}
    union all select 'flight_delays',         count(*) from {{ ref('int_emirates_flight_delays') }}
    union all select 'flight_capacity',       count(*) from {{ ref('int_emirates_flight_capacity') }}
    union all select 'flight_revenue',        count(*) from {{ ref('int_emirates_flight_revenue') }}
    union all select 'flight_weather',        count(*) from {{ ref('int_emirates_flight_weather') }}
    union all select 'flight_gate_ops',       count(*) from {{ ref('int_emirates_flight_gate_ops') }}
    union all select 'flight_fuel',           count(*) from {{ ref('int_emirates_flight_fuel') }}
    union all select 'flight_calendar',       count(*) from {{ ref('int_emirates_flight_calendar') }}
    union all select 'flight_quality_flags',  count(*) from {{ ref('int_emirates_flight_quality_flags') }}
    union all select 'flight_fare_index',     count(*) from {{ ref('int_emirates_flight_fare_index') }}
    union all select 'flight_fuel_margin',    count(*) from {{ ref('int_emirates_flight_fuel_margin') }}

)

select a.model, a.n as actual_rows, e.n as expected_rows
from actual a
cross join expected e
where a.n <> e.n
