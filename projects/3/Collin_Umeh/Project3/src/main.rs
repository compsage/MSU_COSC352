use std::fs::File;
use std::io::{self, Write, BufReader, BufRead};
use std::fs;
use std::process::Command;
use std::error::Error;
use reqwest;
use scraper::{Html, Selector};

fn download_html(url: &str, filename: &str) -> Result<(), Box<dyn Error>> {
    let response = reqwest::blocking::get(url)?.text()?;
    let mut file = File::create(filename)?;
    file.write_all(response.as_bytes())?;
    Ok(())
}

fn extract_tables(html_content: &str) -> Vec<Vec<Vec<String>>> {
    let document = Html::parse_document(html_content);
    let table_selector = Selector::parse("table").unwrap();
    let row_selector = Selector::parse("tr").unwrap();
    let cell_selector = Selector::parse("td, th").unwrap();

    let mut tables = Vec::new();
    for table in document.select(&table_selector) {
        let mut table_data = Vec::new();
        for row in table.select(&row_selector) {
            let mut row_data = Vec::new();
            for cell in row.select(&cell_selector) {
                row_data.push(cell.text().collect::<Vec<_>>().join(" ").trim().to_string());
            }
            table_data.push(row_data);
        }
        tables.push(table_data);
    }
    tables
}

fn save_tables_to_csv(tables: Vec<Vec<Vec<String>>>) -> io::Result<()> {
    fs::create_dir_all("output")?;
    for (i, table) in tables.iter().enumerate() {
        let filename = format!("output/table_{}.csv", i + 1);
        let mut file = File::create(filename)?;
        for row in table {
            writeln!(file, "{}", row.join(","))?;
        }
    }
    Ok(())
}

fn main() -> Result<(), Box<dyn Error>> {
    let url = "https://en.wikipedia.org/wiki/List_of_largest_companies_in_the_United_States_by_revenue";
    let html_file = "page.html";

    download_html(url, html_file)?;
    let html_content = fs::read_to_string(html_file)?;
    let tables = extract_tables(&html_content);
    save_tables_to_csv(tables)?;

    // Move the Dockerfile generation here
    write_dockerfile()?;

    println!("Extracted tables and saved to CSV files.");
    Ok(())
}