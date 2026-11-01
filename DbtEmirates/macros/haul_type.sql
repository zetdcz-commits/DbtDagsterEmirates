{#- Haul type from a distance in km (rule R05). Thresholds come from vars. -#}
{% macro haul_type(distance_km) -%}
    case
        when {{ distance_km }} < {{ var('haul_short_max_km') }}  then 'short_haul'
        when {{ distance_km }} < {{ var('haul_medium_max_km') }} then 'medium_haul'
        else 'long_haul'
    end
{%- endmacro %}
