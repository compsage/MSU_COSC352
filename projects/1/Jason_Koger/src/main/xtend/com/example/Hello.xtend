
package com.example

import java.io.File
import java.util.concurrent.Executors
import org.jsoup.Jsoup
import java.io.PrintWriter

class Hello {
    static def main(String[] args) {
        val files = #[
            "data/page1.html",
            "data/page2.html"
        ]

        println("Sequential Execution:")
        val startSeq = System.nanoTime
        for (file : files) {
            extractTables(file)
        }
        val endSeq = System.nanoTime
        println("Sequential Execution Time: " + (endSeq - startSeq) / 1_000_000_000.0 + " seconds")

        println("Multithreaded Execution:")
        val startPar = System.nanoTime
        val executor = Executors::newFixedThreadPool(4)
        for (file : files) {
            executor.execute([| extractTables(file) ])
        }
        executor.shutdown
        while (!executor.isTerminated) {}
        val endPar = System.nanoTime
        println("Multithreaded Execution Time: " + (endPar - startPar) / 1_000_000_000.0 + " seconds")
    }

    static def extractTables(String filePath) {
        val file = new File(filePath)
        if (!file.exists) {
            println("File not found: " + filePath)
            return
        }
        val doc = Jsoup::parse(file, "UTF-8")
        val tables = doc.select("table")
        var i = 1
        for (table : tables) {
            val csvFile = new File("output_" + file.name.replace(".html", "") + "_table_" + i + ".csv")
            val writer = new PrintWriter(csvFile)
            for (row : table.select("tr")) {
                val cells = row.select("th, td").map[it.text].join(",")
                writer.println(cells)
            }
            writer.close
            i++
        }
    }
}
