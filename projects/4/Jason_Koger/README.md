# Project 4 Multi-URL HTML Table Extractor with Sequential and Multithreaded Execution

## Overview
This project extends the functionality of Project 3 by processing multiple HTML files that contain `table` elements. It extracts all tables from each file and saves them as individual CSV files. The application supports both sequential and multithreaded execution to compare performance.

## Features
- Processes multiple local `.html` files from the `data` folder
- Extracts all HTML `table` elements
- Saves each table to a uniquely named CSV file
  - `revenue_page1_table_1.csv`
  - `revenue_page2_table_2.csv`
- Two execution modes
  - Sequential mode – one file at a time
  - Multithreaded mode – concurrent processing using native threading
- Reports execution time for both modes

## Usage

### 🛠 Build Docker Image
From inside `Projects4Jason_Koger`, run

```bash
docker build -t project4 .
