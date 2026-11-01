select *
from {{ ref('stg_countries') }}
where length(country_code) <> 2
