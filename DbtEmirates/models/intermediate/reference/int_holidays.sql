{{ config(indexes=[{'columns': ['country_code', 'holiday_date']}]) }}

-- One row per country and holiday date (rule R18). Two holidays on the same day
-- are merged: names are joined, and the group is the alphabetically first group
-- other than 'other' (or 'other' if that is all there is).
select
    country_code || '-' || holiday_date::text                     as holiday_key,
    holiday_date::date                                            as holiday_date,
    country_code,
    string_agg(distinct holiday_name, '; ' order by holiday_name) as holiday_name,
    coalesce(
        min(holiday_group) filter (where holiday_group <> 'other'),
        'other'
    )                                                             as holiday_group
from {{ ref('public_holidays') }}
group by country_code, holiday_date
