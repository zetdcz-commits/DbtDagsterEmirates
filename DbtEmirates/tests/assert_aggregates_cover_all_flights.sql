-- The route-month and aircraft aggregates must account for every flight.
with expected as (

    select count(*) as n from {{ ref('stg_emirates_flights') }}

),

actual as (

    select 'route_monthly' as model, sum(flights)::bigint as n from {{ ref('int_emirates_route_monthly') }}
    union all select 'aircraft_summary', sum(flights)::bigint from {{ ref('int_emirates_aircraft_summary') }}

)

select a.model, a.n as actual_rows, e.n as expected_rows
from actual a
cross join expected e
where a.n <> e.n
