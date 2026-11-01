-- One row per month with the jet fuel price (rules R24 and R25). A month with no
-- reported price takes the latest earlier price and is flagged as carried forward.
with seed_prices as (

    select price_month::date as price_month, usd_per_gallon::numeric as usd_per_gallon
    from {{ ref('jet_fuel_prices') }}

),

months as (

    select price_month from seed_prices
    union
    select distinct date_trunc('month', date_day)::date from {{ ref('int_calendar') }}

),

joined as (

    select
        m.price_month,
        p.usd_per_gallon as reported_usd_per_gallon
    from months m
    left join seed_prices p on m.price_month = p.price_month

),

-- carry the last reported price forward: every reported price starts a new group
grouped as (

    select
        *,
        count(reported_usd_per_gallon) over (order by price_month) as fill_group
    from joined

),

filled as (

    select
        price_month,
        reported_usd_per_gallon,
        first_value(reported_usd_per_gallon)
            over (partition by fill_group order by price_month) as usd_per_gallon
    from grouped

),

with_change as (

    select
        *,
        lag(usd_per_gallon) over (order by price_month) as prior_month_usd_per_gallon
    from filled

)

select
    price_month,
    usd_per_gallon,
    reported_usd_per_gallon,
    (reported_usd_per_gallon is null and usd_per_gallon is not null) as is_carried_forward,
    prior_month_usd_per_gallon,
    round((usd_per_gallon / nullif(prior_month_usd_per_gallon, 0) - 1)::numeric, 4)
                                                                     as month_on_month_change_pct,
    coalesce(
        abs(usd_per_gallon / nullif(prior_month_usd_per_gallon, 0) - 1)
            > {{ var('fuel_price_spike_pct') }},
        false
    )                                                                as is_price_spike
from with_change
