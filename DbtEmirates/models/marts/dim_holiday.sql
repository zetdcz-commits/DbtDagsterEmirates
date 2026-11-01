-- Gold: one row per country and holiday date.
select
    holiday_key,
    holiday_date,
    country_code,
    holiday_name,
    holiday_group
from {{ ref('int_holidays') }}