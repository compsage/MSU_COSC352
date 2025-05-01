import pandas as pd
import os
import sys

def extract_tables_from_html(html_file):
    # Read the HTML file
    with open(html_file, 'r', encoding='utf-8') as file:
        tables = pd.read_html(file.read())
    
    os.makedirs("/output", exist_ok=True)
    
    for i, table in enumerate(tables, start=1):
        csv_filename = f"/output/table_{i}.csv"
        table.to_csv(csv_filename, index=False)
        print(f"Saved: {csv_filename}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python extract_html_tables.py <html_file>")
        sys.exit(1)
    
    extract_tables_from_html(sys.argv[1])
