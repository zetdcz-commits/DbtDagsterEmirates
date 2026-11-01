{% docs __overview__ %}

# Emirates flights analytics

Emirates flight data for 2024 to 2026, combined with airport, holiday and jet fuel price reference data.

| Layer | Schema | Contents |
|---|---|---|
| Bronze | `bronze` | `stg_*` staging models and reference seeds |
| Silver | `silver` | `int_*` intermediate models: enrichment, flags and aggregates |
| Gold | planned | Facts and dimensions for reporting |

## Business rules

Every definition and threshold used in the silver models is listed below. The Variable column gives the setting name in `dbt_project.yml` under `vars:` and its default. To change a rule, change the variable, not the SQL. Status is **Assumed** until a business owner has confirmed the rule, and then it becomes **Confirmed**. The Used in column lists model names without the `int_emirates_` prefix, and "(planned)" marks models that are not built yet.

### Flight status and delays

| ID | Rule | Definition | Variable (default) | Used in | Status |
|---|---|---|---|---|---|
| R01 | Cancelled flight | Status text starts with "Cancel", any case | `cancelled_status_prefix` (cancel) | flight_delays | Assumed |
| R02 | On time | Not cancelled and arrived at most 15 minutes after schedule. Early arrivals count as on time. Cancelled flights count as not on time in every on-time percentage | `on_time_threshold_minutes` (15) | flight_delays, route_monthly, aircraft_summary, airport_daily_ops, holiday_group_impact | Assumed |
| R03 | Arrival delay bucket | cancelled; on_time (R02); delayed_short (over 15 up to 60 minutes); delayed_medium (over 60 up to 180 minutes); delayed_long (over 180 minutes) | `delay_bucket_1_max_minutes` (60), `delay_bucket_2_max_minutes` (180) | flight_delays | Assumed |
| R04 | Departure time of day | Hour of scheduled departure: morning from 5, afternoon from 12, evening from 17, night from 22 until 4 | `time_of_day_start_hours` (5, 12, 17, 22) | flight_delays | Assumed |

### Routes and distance

| ID | Rule | Definition | Variable (default) | Used in | Status |
|---|---|---|---|---|---|
| R05 | Haul type | Based on the distance in the flights file: short under 1,500 km, medium from 1,500 up to 4,000 km, long from 4,000 km | `haul_short_max_km` (1500), `haul_medium_max_km` (4000) | flight_routes, routes, holiday_group_impact | Assumed |
| R06 | International flight | Origin country differs from destination country as written in the flights file | none | flight_routes, routes, route_monthly | Assumed |
| R07 | Distance used | Great-circle (haversine) distance between airport coordinates, earth radius 6,371.0088 km, also in miles (1 km = 0.621371 mi). Falls back to the distance in the flights file when an airport has no coordinates. Flown routes are usually longer than great-circle | none (constants) | flight_distance, flight_revenue, flight_fuel, flight_fuel_margin | Assumed |
| R08 | Distance check | Flagged when the computed distance differs from the file's distance by more than 5% | `distance_mismatch_tolerance_pct` (0.05) | flight_distance, flight_quality_flags | Assumed |
| R09 | One airport per IATA code | Closed airports and airports without a code are excluded. If several airports share a code, keep the largest (large, then medium, then small), then one with scheduled service, then the lowest id | none | airports_iata, flight_routes | Assumed |

### Capacity and revenue

| ID | Rule | Definition | Variable (default) | Used in | Status |
|---|---|---|---|---|---|
| R10 | Load factor band | High at 85% or more, medium at 65% or more, otherwise low | `load_factor_high_pct` (85), `load_factor_medium_pct` (65) | flight_capacity | Assumed |
| R11 | Load factor check | Flagged when the file's load factor differs from passengers divided by seats by more than 1 percentage point | `load_factor_tolerance_pts` (1) | flight_capacity, flight_quality_flags | Assumed |
| R12 | Over capacity | Passengers exceed seats | none | flight_capacity, flight_quality_flags | Assumed |
| R13 | Revenue check | Flagged when the file's estimated revenue differs from passengers times average ticket price by more than 1 USD | `revenue_tolerance_usd` (1) | flight_revenue, flight_quality_flags | Assumed |
| R14 | RASK | Revenue divided by seats times the distance used (R07): USD per available seat km | none | flight_revenue | Assumed |

### Weather

| ID | Rule | Definition | Variable (default) | Used in | Status |
|---|---|---|---|---|---|
| R15 | Low visibility | Visibility under 5 km | `low_visibility_km` (5) | flight_weather | Assumed |
| R16 | High wind | Wind speed of 50 km/h or more | `high_wind_kmh` (50) | flight_weather | Assumed |
| R17 | Adverse weather | Low visibility or high wind | none | flight_weather, airport_daily_ops | Assumed |

### Holidays and calendar

| ID | Rule | Definition | Variable (default) | Used in | Status |
|---|---|---|---|---|---|
| R18 | Holiday data | Public holidays per country from the Python `holidays` package (English names), plus country-tied extras (currently Christmas Eve, Christmas Day, New Year's Eve and Easter Sunday for the UAE). A holiday belongs to a country and is matched to a flight through the ISO country code of its origin and destination airports. Islamic and other lunar dates are calculated and can be one day off the official announcement. When two holidays fall on the same day, the names are joined and the group is the alphabetically first group other than "other" | none (seed `public_holidays`) | holidays, country_calendar, flight_calendar, airport_daily_ops | Assumed |
| R19 | Holiday period | A flight is in a holiday period when it is within 3 days before or after a holiday in its origin or destination country. Its holiday group is that of the closer holiday, and the origin wins a tie | `holiday_window_days` (3) | flight_calendar, holiday_fare_impact, holiday_group_impact | Assumed |
| R20 | Weekend | Saturday and Sunday, the same for every country. Not adjusted per country | none | calendar, flight_calendar | Assumed |
| R21 | Fiscal year | Starts in month 1, so the fiscal year equals the calendar year. A fiscal year is named for the calendar year it ends in | `fiscal_year_start_month` (1) | calendar | Assumed |

### Fuel

| ID | Rule | Definition | Variable (default) | Used in | Status |
|---|---|---|---|---|---|
| R22 | Fuel burn | Distance used (R07) times the aircraft model's average kg per km from seed `aircraft_fuel_burn`. One average per model, including climb and descent. **Current values are placeholders until replaced with sourced figures.** Aircraft models missing from the seed have no fuel estimate | none (seed) | flight_fuel | Assumed |
| R23 | Fuel units | Jet fuel weighs 0.8 kg per litre. One US gallon is 3.78541 litres | `jet_fuel_density_kg_per_l` (0.8), `litres_per_gallon` (3.78541) | flight_fuel | Assumed |
| R24 | Fuel price | US Gulf Coast kerosene-type jet fuel spot price in USD per gallon, monthly (EIA, via IndexMundi, seed `jet_fuel_prices`). A flight uses the price of its month. A month with no reported price uses the latest earlier month and is flagged as carried forward | none (seed) | jet_fuel_prices_monthly, flight_fuel, fuel_fare_monthly | Assumed |
| R25 | Price spike | A month-on-month price change of more than 25% is flagged for review | `fuel_price_spike_pct` (0.25) | jet_fuel_prices_monthly | Assumed |
| R26 | Fuel cost and margin | Fuel cost is gallons times price. Fuel margin is revenue minus fuel cost, and fuel share is fuel cost divided by revenue. This is not profit, since crew, fees, maintenance and aircraft costs are not included | none | flight_fuel, flight_fuel_margin, fuel_fare_monthly | Assumed |

### Fares and seasonality

| ID | Rule | Definition | Variable (default) | Used in | Status |
|---|---|---|---|---|---|
| R27 | Fare baseline and index | Baseline is the average fare for the same route and ticket class on flights outside holiday periods (R19), excluding cancelled flights, and needs at least 5 such flights. Fare index is fare divided by baseline, so 1.15 means 15% above baseline. Holiday uplift is the average fare index in holiday periods minus 1 | `fare_baseline_min_flights` (5) | flight_fare_index, holiday_fare_impact, holiday_group_impact | Assumed |
| R28 | Seasonality | A calendar month's average fare divided by the average fare of the same route and ticket class over all months. Peak at 1.1 or more, off-peak at 0.9 or less, otherwise normal | `peak_season_index` (1.1), `off_peak_season_index` (0.9) | route_seasonality | Assumed |

### Data quality and reference facts

| ID | Rule | Definition | Variable (default) | Used in | Status |
|---|---|---|---|---|---|
| R29 | Data quality issue | Any of R08, R11, R12, R13, missing airport coordinates, missing burn rate, missing fuel price, or delay minutes recorded on a cancelled flight. Counted in `issue_count`, with `has_any_issue` true when the count is above zero | none | flight_quality_flags | Assumed |
| R30 | Route pair | The two airport codes sorted alphabetically, so DXB-CAI and CAI-DXB are one pair | none | flight_routes, routes | Assumed |
| R31 | Airport facts | One row per airport. Tower means a radio frequency of type TWR. A runway counts as lighted only when it is not closed. Navaids are linked by the airport's ident code | none | airports_enriched | Assumed |

## How to change a rule

1. Change the value under `vars:` in `dbt_project.yml`.
2. Update the Default in the table above and add a line to the change log below.
3. Run `dbt build --select` with the models in the rule's "Used in" column and their downstream models.
4. Compare the affected numbers and check the tests before merging.
5. When the business owner agrees, change Status to Confirmed and add their name and the date to the log.

Rules with "none" in the Variable column are fixed in SQL, macros or seeds. To change one, edit the model or macro named in the Used in column, and record the change in the log.

## Change log

| Date | Rule | Change | Reason | Changed by |
|---|---|---|---|---|
| 2026-09-20 | All | First version. All rules Assumed | Initial documentation | |

{% enddocs %}
