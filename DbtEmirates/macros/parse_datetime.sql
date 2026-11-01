{#- The flights and comments files hold dates as text, in either ISO format
    (2026-12-15) or day/month/year (15/12/2026). These macros accept both. -#}
{% macro parse_date(column, format='DD/MM/YYYY') -%}
    case
        when {{ column }} ~ '^\d{4}-\d{2}-\d{2}' then {{ column }}::date
        else to_date({{ column }}, '{{ format }}')
    end
{%- endmacro %}


{% macro parse_timestamp(column, format='DD/MM/YYYY HH24:MI') -%}
    case
        when {{ column }} ~ '^\d{4}-\d{2}-\d{2}' then {{ column }}::timestamp
        else to_timestamp({{ column }}, '{{ format }}')::timestamp
    end
{%- endmacro %}
