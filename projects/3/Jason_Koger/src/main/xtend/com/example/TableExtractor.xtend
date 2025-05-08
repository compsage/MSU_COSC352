package com.example

import java.io.FileWriter
import java.io.IOException
import java.net.URL
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.io.ByteArrayInputStream
import javax.xml.parsers.DocumentBuilderFactory
import org.w3c.dom.Document
import org.w3c.dom.Element
import java.util.List
import java.util.ArrayList

class TableExtractor {
	
	val htmlSource = "https://en.wikipedia.org/wiki/List_of_largest_companies_in_the_United_States_by_revenue"
	
	def static void main(String[] args) {
		val extractor = new TableExtractor
		extractor.processSource(extractor.htmlSource)
	}
	
	
	def processSource(String source) {
		val html = fetchHtmlFromUrl(source)

		val attributeRegex = "(\\s+)([a-zA-Z0-9\\-:]+)(?=\\s|>|/)"

		val cleanedHtml = html
			.replaceAll("(?i)<link([^>]*)(?<!/)>", "<link$1/>")
			.replaceAll("(?i)<meta([^>]*)(?<!/)>", "<meta$1/>")
			.replaceAll("(?i)<img([^>]*)(?<!/)>", "<img$1/>")
			.replaceAll("(?i)<input([^>]*)(?<!/)>", "<input$1/>")	
            .replaceAll("(?i)<source([^>]*)(?<!/)>", "<source$1/>")
            .replaceAll("(?s)<!--.*?-->", "")
            .replace("<!DOCTYPE html>", "")
            .replaceAll(attributeRegex, "$1$2='true'");

		val document = parseHtml(cleanedHtml)
		val tables = extractTables(document)
		
		if (tables.isEmpty) {
			println("No tables found in " + source)
			return
		}
		
		val baseName = getBaseName(source)
		var tableIndex = 1
		
		for (table : tables) {
			val csvData = extractTableData(table)
			val outputFilename = "table_" + tableIndex + ".csv"
			writeCsvFile(outputFilename, csvData)
			tableIndex++
		}
	}
	
	def String fetchHtmlFromUrl(String urlString) {
		try {
			val url = new URL(urlString)
			val connection = url.openConnection()
			connection.connect()
			val inputStream = connection.inputStream
			val html = new String(inputStream.readAllBytes())
			inputStream.close()
			return html
		} catch (Exception e) {
			throw new RuntimeException("Failed to fetch URL " + urlString + ": " + e.message)
		}
	}

    def Document parseHtml(String html) {
        val factory = DocumentBuilderFactory.newInstance

		factory.setNamespaceAware(true);
        factory.setIgnoringComments(true);
        factory.setIgnoringElementContentWhitespace(true);

        // Disable only external DTD loading.
        factory.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false)

        factory.setFeature("http://xml.org/sax/features/validation", false)

        // Set secure processing attributes to prevent XXE attacks:
        factory.setAttribute("http://javax.xml.XMLConstants/property/accessExternalDTD", "")
        factory.setAttribute("http://javax.xml.XMLConstants/property/accessExternalSchema", "")

        val builder = factory.newDocumentBuilder
        val inputStream = new ByteArrayInputStream(html.bytes)
        return builder.parse(inputStream)
    }

	
	def List<Element> extractTables(Document document) {
		val tables = new ArrayList<Element>
		val nodeList = document.getElementsByTagName("table")

		for (i : 0 ..< nodeList.length) {
			tables.add(nodeList.item(i) as Element)
		}
		return tables
	}
	
	def String getBaseName(String source) {
		val fileName = source.replaceAll("[^a-zA-Z0-9]", "_")
		return fileName.toLowerCase()
	}
	
	def List<List<String>> extractTableData(Element table) {
		val data = new ArrayList<List<String>>
		val rows = table.getElementsByTagName("tr")
		
		for (i : 0 ..< rows.length) {
			val row = rows.item(i) as Element
			val rowData = new ArrayList<String>
			val thNodes = row.getElementsByTagName("th")
			for (j : 0 ..< thNodes.length) {
				rowData.add((thNodes.item(j) as Element).getTextContent.trim)
			}
			val tdNodes = row.getElementsByTagName("td")
			for (j : 0 ..< tdNodes.length) {
				rowData.add((tdNodes.item(j) as Element).getTextContent.trim)
			}
			if (!rowData.isEmpty) {
				data.add(rowData)
			}
		}
		
		return data
	}
	
	def void writeCsvFile(String filename, List<List<String>> data) {
		var writer = null as FileWriter
		try {
			writer = new FileWriter(filename)
			for (row : data) {
				val csvRow = row.map[escapeCsv(it)].join(",")
				writer.write(csvRow + "\n")
			}
			println("Created CSV file: " + filename)
		} catch (IOException e) {
			throw new RuntimeException("Failed to write CSV file " + filename + ": " + e.message)
		} finally {
			if (writer !== null) {
				try { writer.close() } catch (IOException e) {}
			}
		}
	}
	
	def String escapeCsv(String value) {
		if (value.contains('"') || value.contains(",") || value.contains("\n")) {
			return "\"" + value.replace("\"", "\"\"") + "\""
		}
		return value
	}
}
