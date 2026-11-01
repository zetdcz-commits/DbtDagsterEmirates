-- One row per date and country with a public holiday flag: the SQL version of a
-- Power BI date table with an IsHoliday column. Holidays depend on the country,
-- so this sits beside int_calendar instead of inside it (rule R18).
with calendar as (

    select date_day from {{ ref('int_calendar') }}

),

countries as (

    select distinct country_code from {{ ref('int_holidays') }}

),

holidays as (

    select country_code, holiday_date, holiday_name, holiday_group
    from {{ ref('int_holidays') }}

)

select
    c.date_day || '-' || k.country_code            as country_date_key,
    c.date_day,
    k.country_code,
    (h.holiday_date is not null)                   as is_public_holiday,
    h.holiday_name,
    h.holiday_group
from calendar c
cross join countries k
left join holidays h
       on h.holiday_date = c.date_day
      and h.country_code = k.country_code
