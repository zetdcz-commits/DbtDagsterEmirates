import pandas as pd
import requests
from io import StringIO

url = "https://en.wikipedia.org/wiki/Fuel_economy_in_aircraft"

headers = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/140.0.0.0 Safari/537.36 "
        "FuelEconomyScraper/1.0"
    )
}

response = requests.get(url, headers=headers, timeout=30)
response.raise_for_status()

# Pass downloaded HTML to pandas
tables = pd.read_html(StringIO(response.text))

print(f"Number of tables found: {len(tables)}")

for number, table in enumerate(tables):
    print(f"\nTable {number}")
    print(table.head())
    print("Columns:", table.columns.tolist())

# Save every table temporarily so you can identify the correct table numbers
for number, table in enumerate(tables):
    table.to_csv(f"wikipedia_table_{number}.csv", index=False)

print("\nAll tables were saved as wikipedia_table_0.csv, wikipedia_table_1.csv, etc.")