{{ config(schema='gold_internal') }}

-- Gold (internal): one row per flight — data quality flags for the data/
-- analytics engineering team. Kept out of the business-facing gold schema
-- so bad-data monitoring doesn't surface on stakeholder dashboards.
select
    flight_record_id,
    to_char(flight_date, 'YYYYMMDD')::int   as date_key,
    flight_date,
    has_distance_mismatch,
    has_load_factor_mismatch,
    is_over_capacity,
    has_revenue_mismatch,
    is_missing_coordinates,
    is_missing_burn_rate,
    is_missing_fuel_price,
    has_delay_on_cancelled_flight,
    issue_count,
    has_any_issue
from {{ ref('int_emirates_flight_quality_flags') }}