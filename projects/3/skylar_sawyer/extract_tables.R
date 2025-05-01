# Define URL of the Wikipedia page
url <- "https://en.wikipedia.org/wiki/List_of_largest_companies_in_the_United_States_by_revenue"

# Download the HTML file
html_file <- "page.html"
download.file(url, html_file)

# Read the HTML file
html_content <- readLines(html_file, warn = FALSE)

# Extract tables using regular expressions (since we're not using external packages)
#tables <- regmatches(html_content, gregexpr("<table.*?</table>", html_content, perl = TRUE))[[1]]

tables <- html_content[grep("<table", html_content)]
if (length(tables) == 0) {
  stop("No tables found in the HTML file.")
} else {
  print(paste("Extracted", length(tables), "tables."))
}

# Save each table to a CSV file
for (i in seq_along(tables)) {
  table_file <- paste0("table_", i, ".csv")
  cat("Saved:", table_file, "\n")
  writeLines(tables[i], table_file)
}

if (file.exists(html_file)) {
  cat("Downloaded HTML file successfully.\n")
} else {
  cat("Failed to download HTML file.\n")
}

