-- One row per flight: revenue after estimated fuel cost (rule R26). This is not
-- profit: crew, fees, maintenance and aircraft costs are not included.
select
    v.flight_record_id,
    v.flight_date,
    v.estimated_revenue_usd,
    fu.estimated_fuel_cost_usd,
    v.estimated_revenue_usd - fu.estimated_fuel_cost_usd                        as fuel_margin_usd,
    round((100 * (v.estimated_revenue_usd - fu.estimated_fuel_cost_usd)
           / nullif(v.estimated_revenue_usd, 0))::numeric, 1)                   as fuel_margin_pct,
    round((100 * fu.estimated_fuel_cost_usd
           / nullif(v.estimated_revenue_usd, 0))::numeric, 1)                   as fuel_cost_pct_of_revenue,
    round(((v.estimated_revenue_usd - fu.estimated_fuel_cost_usd)
           / nullif(cap.seat_capacity * fu.distance_km_used, 0))::numeric, 4)   as fuel_margin_per_ask_usd
from {{ ref('int_emirates_flight_revenue') }} v
join {{ ref('int_emirates_flight_fuel') }} fu on v.flight_record_id = fu.flight_record_id
join (
    select flight_record_id, seat_capacity from {{ ref('int_emirates_flight_capacity') }}
) cap on v.flight_record_id = cap.flight_record_id
