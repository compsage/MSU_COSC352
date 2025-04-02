package main

import (
	"encoding/csv"
	"fmt"
	"golang.org/x/net/html"
	"net/http"
	"os"
	"strings"
)


func downloadHTML(url string) (string, error) {
	resp, err := http.Get(url)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	var sb strings.Builder
	_, err = sb.ReadFrom(resp.Body)
	if err != nil {
		return "", err
	}
	return sb.String(), nil
}


func extractTablesFromHTML(htmlContent string) ([][][]string, error) {
	var tables [][][]string
	tokenizer := html.NewTokenizer(strings.NewReader(htmlContent))

	var currentTable [][]string
	var currentRow []string
	var isTable bool
	var isRow bool

	for {
		tt := tokenizer.Next()
		switch tt {
		case html.ErrorToken:
			return tables, nil // End of document
		case html.StartTagToken, html.SelfClosingTagToken:
			token := tokenizer.Token()
			switch token.Data {
			case "table":
				currentTable = [][]string{} 
				isTable = true
			case "tr":
				currentRow = []string{} 
				isRow = true
			case "td", "th":
				
			}
		case html.TextToken:
			if isRow {
				token := tokenizer.Token()
				currentRow = append(currentRow, strings.TrimSpace(token.Data))
			}
		case html.EndTagToken:
			token := tokenizer.Token()
			switch token.Data {
			case "tr":
				if isRow {
					currentTable = append(currentTable, currentRow)
					isRow = false
				}
			case "table":
				if isTable {
					tables = append(tables, currentTable)
					isTable = false
				}
			}
		}
	}
}


func writeToCSV(table [][]string, index int) error {
	fileName := fmt.Sprintf("table_%d.csv", index+1)
	file, err := os.Create(fileName)
	if err != nil {
		return err
	}
	defer file.Close()

	writer := csv.NewWriter(file)
	defer writer.Flush()

	for _, row := range table {
		err := writer.Write(row)
		if err != nil {
			return err
		}
	}
	return nil
}

func main() {
	url := "https://en.wikipedia.org/wiki/List_of_largest_companies_in_the_United_States_by_revenue"
	htmlContent, err := downloadHTML(url)
	if err != nil {
		fmt.Println("Error downloading HTML:", err)
		return
	}

	tables, err := extractTablesFromHTML(htmlContent)
	if err != nil {
		fmt.Println("Error extracting tables:", err)
		return
	}

	for i, table := range tables {
		err := writeToCSV(table, i)
		if err != nil {
			fmt.Println("Error writing table to CSV:", err)
			return
		}
		fmt.Printf("Table %d written to CSV\n", i+1)
	}
}
