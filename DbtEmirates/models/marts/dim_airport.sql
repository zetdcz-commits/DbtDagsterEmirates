-- Gold: one row per airport, keyed by IATA code (rule R09 — dedup logic lives
-- upstream in int_airports_iata). Merges IATA and infrastructure facts so the
-- analytics team has one airport dimension instead of two silver models to join.
select
    iata.iata_code,
    iata.airport_id,
    iata.airport_ident,
    iata.airport_name,
    iata.airport_type,
    iata.municipality,
    iata.iso_country,
    iata.iso_region,
    iata.latitude_deg,
    iata.longitude_deg,
    iata.elevation_ft,

    enr.region_name,
    enr.country_name,
    enr.country_continent,
    enr.has_scheduled_service,

    enr.runway_count,
    enr.closed_runway_count,
    enr.longest_runway_ft,
    enr.has_lighted_runway,
    enr.navaid_count,
    enr.frequency_count,
    enr.has_tower_frequency,
    enr.comment_count,
    enr.latest_comment_at

from {{ ref('int_airports_iata') }} iata
left join {{ ref('int_airports_enriched') }} enr
       on iata.airport_id = enr.airport_id