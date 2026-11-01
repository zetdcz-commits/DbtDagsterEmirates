{% docs flight_record_id %}
Identifier of the flight from the source flights file. One row per flight in every flight-level silver model.
{% enddocs %}

{% docs flight_date %}
Date of the flight (the scheduled departure date), parsed from text that may be ISO (2026-12-15) or day/month/year (15/12/2026).
{% enddocs %}

{% docs route %}
Directional route: origin IATA code, a dash, destination IATA code, for example DXB-CAI. DXB-CAI and CAI-DXB are different routes. See `route_pair` for the direction-free version.
{% enddocs %}

{% docs iata_code %}
Three-letter IATA airport code, for example DXB.
{% enddocs %}

{% docs country_code %}
ISO 3166-1 alpha-2 country code. `NA` is Namibia and must never become NULL.
{% enddocs %}

{% docs holiday_group %}
Kind of holiday, for example christmas, easter, eid_al_fitr, eid_al_adha, chinese_new_year, diwali, new_year or other. Assigned by keywords in the holiday name in `scripts/generate_holidays.py`. Rule R18.
{% enddocs %}

{% docs is_holiday_period %}
True when the flight is within the holiday window (variable `holiday_window_days`) before or after a holiday in its origin or destination country. Rule R19.
{% enddocs %}

{% docs fare_index %}
The flight's average ticket price divided by the baseline for the same route and ticket class outside holiday periods. 1.15 means 15% above baseline. Null when the route and class have too few baseline flights. Rule R27.
{% enddocs %}

{% docs is_on_time %}
True when the flight was not cancelled and arrived no later than the on-time threshold after schedule. Cancelled flights count as not on time. Rule R02.
{% enddocs %}

{% docs usd_per_gallon %}
Jet fuel price in US dollars per gallon for the month (US Gulf Coast kerosene-type spot price). Months with no reported price carry the latest earlier price. Rule R24.
{% enddocs %}
