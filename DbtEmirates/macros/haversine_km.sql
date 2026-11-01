{#- Great-circle distance in km between two points given in degrees (rule R07).
    Pass column names as strings. 6371.0088 km is the mean earth radius.
    Returns NULL when any coordinate is missing: least() ignores NULLs, so
    without the guard a missing coordinate would give a bogus distance of
    about 20,000 km. least(1.0, ...) also guards against rounding pushing the
    square root above 1. -#}
{% macro haversine_km(lat1, lon1, lat2, lon2) -%}
    case
        when {{ lat1 }} is null or {{ lon1 }} is null
          or {{ lat2 }} is null or {{ lon2 }} is null then null
        else 2 * 6371.0088 * asin(least(1.0, sqrt(
            power(sin(radians({{ lat2 }} - {{ lat1 }}) / 2), 2)
            + cos(radians({{ lat1 }})) * cos(radians({{ lat2 }}))
              * power(sin(radians({{ lon2 }} - {{ lon1 }}) / 2), 2)
        )))
    end
{%- endmacro %}
