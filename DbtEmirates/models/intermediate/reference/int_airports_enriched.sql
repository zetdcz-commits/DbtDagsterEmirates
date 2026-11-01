-- One row per airport with country, region and infrastructure facts (rule R31).
with airports as (

    select * from {{ ref('stg_airports') }}

),

countries as (

    select country_code, country_name, continent as country_continent
    from {{ ref('stg_countries') }}

),

regions as (

    select region_code, region_name
    from {{ ref('stg_regions') }}

),

runways as (

    select
        airport_id,
        count(*)                                        as runway_count,
        count(*) filter (where is_closed)               as closed_runway_count,
        max(length_ft)                                  as longest_runway_ft,
        coalesce(bool_or(is_lighted and not is_closed), false) as has_lighted_runway
    from {{ ref('stg_runways') }}
    group by 1

),

navaids as (

    select associated_airport_ident as airport_ident, count(*) as navaid_count
    from {{ ref('stg_navaids') }}
    group by 1

),

frequencies as (

    select
        airport_id,
        count(*)                                                as frequency_count,
        coalesce(bool_or(upper(frequency_type) = 'TWR'), false) as has_tower_frequency
    from {{ ref('stg_airport_frequencies') }}
    group by 1

),

comments as (

    select
        airport_id,
        count(*)            as comment_count,
        max(commented_at)   as latest_comment_at
    from {{ ref('stg_airport_comments') }}
    group by 1

)

select
    a.airport_id,
    a.airport_ident,
    a.iata_code,
    a.airport_name,
    a.airport_type,
    a.municipality,
    a.iso_region,
    r.region_name,
    a.iso_country,
    c.country_name,
    c.country_continent,
    a.latitude_deg,
    a.longitude_deg,
    a.elevation_ft,
    a.has_scheduled_service,

    coalesce(rw.runway_count, 0)            as runway_count,
    coalesce(rw.closed_runway_count, 0)     as closed_runway_count,
    rw.longest_runway_ft,
    coalesce(rw.has_lighted_runway, false)  as has_lighted_runway,
    coalesce(n.navaid_count, 0)             as navaid_count,
    coalesce(f.frequency_count, 0)          as frequency_count,
    coalesce(f.has_tower_frequency, false)  as has_tower_frequency,
    coalesce(cm.comment_count, 0)           as comment_count,
    cm.latest_comment_at

from airports a
left join countries c    on a.iso_country   = c.country_code
left join regions r      on a.iso_region    = r.region_code
left join runways rw     on a.airport_id    = rw.airport_id
left join navaids n      on a.airport_ident = n.airport_ident
left join frequencies f  on a.airport_id    = f.airport_id
left join comments cm    on a.airport_id    = cm.airport_id
