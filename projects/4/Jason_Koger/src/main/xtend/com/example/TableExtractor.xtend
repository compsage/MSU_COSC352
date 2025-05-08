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
	
	val htmlSources = newArrayList(
	    "https://www.w3.org/2003/01/dom2-javadoc/org/w3c/dom/Document.html",
		"https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml",
		"https://w1.weather.gov/xml/current_obs/KSEA.rss",
		"https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.atom",
		"https://www.nasa.gov/rss/dyn/breaking_news.rss",
        "https://www.w3.org/TR/2006/REC-xml11-20060816"
	)
	
	def static void main(String[] args) {
		val extractor = new TableExtractor
		extractor.run()
	}
	
	def run() {
		println("Running sequential extraction...")
		val sequentialStart = System.nanoTime
		processSourcesSequentially(htmlSources)
		val sequentialEnd = System.nanoTime
		val sequentialTime = (sequentialEnd - sequentialStart) / 1_000_000_000.0
		println("Sequential Execution Time: " + sequentialTime + " seconds")
		
		println("\nRunning multi-threaded extraction...")
		val threadedStart = System.nanoTime
		processSourcesMultithreaded(htmlSources)
		val threadedEnd = System.nanoTime
		val threadedTime = (threadedEnd - threadedStart) / 1_000_000_000.0
		println("Multi-threaded Execution Time: " + threadedTime + " seconds")
	}
	
	def processSourcesSequentially(List<String> sources) {
		for (source : sources) {
			try {
				processSource(source)
			} catch (Exception e) {
				System.err.println("Error processing " + source + ": " + e.message)
			}
		}
	}
	
	def processSourcesMultithreaded(List<String> sources) {
		val executor = Executors.newFixedThreadPool(sources.size)
		for (source : sources) {
			executor.submit [|
				try {
					processSource(source)
				} catch (Exception e) {
					System.err.println("Error processing " + source + ": " + e.message)
				}
			]
		}
		executor.shutdown()
		executor.awaitTermination(Long.MAX_VALUE, TimeUnit.NANOSECONDS)
	}
	
	def processSource(String source) {
		val html = fetchHtmlFromUrl(source)
		val document = parseHtml(html)
		val tables = extractTables(document)
		
		if (tables.isEmpty) {
			println("No tables found in " + source)
			return
		}
		
		val baseName = getBaseName(source)
		var tableIndex = 1
		
		for (table : tables) {
			val csvData = extractTableData(table)
			val outputFilename = baseName + "_table_" + tableIndex + ".csv"
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
