require "http/client"
require "csv"
require "io"
require "colorize"
require "uri"
require "time"

# ====== Configuration ======

sources = ARGV.any? ? ARGV.dup : [
  "https://www.w3schools.com/html/html_tables.asp",
  "https://www.contextures.com/xlSampleData01.html",
  "https://en.wikipedia.org/wiki/List_of_countries_by_GDP_(nominal)",
]

Dir.mkdir_p("output") unless Dir.exists?("output")

# ====== Utility Functions ======

def sanitize_filename(url : String) : String
  URI.parse(url).host.to_s.gsub(".", "_") + "_" + URI.parse(url).path.gsub("/", "_").gsub(/[^a-zA-Z0-9_]/, "")
end

def fetch_html(url : String) : String
  puts "Fetching: #{url}".colorize.green
  response = HTTP::Client.get(url)
  response.body.to_s
rescue ex
  puts "Failed to fetch #{url}: #{ex.message}".colorize.red
  ""
end

def extract_tables(html : String) : Array(Array(Array(String)))
  tables = html.split("<table")[1..] || [] of String
  tables.map do |table|
    raw = table.split("</table>").first
    rows = raw.split("<tr>")[1..] || [] of String
    rows.map do |row|
      row.split("<td>")[1..].map do |cell|
        cell.split("</td>").first.strip.gsub(/<[^>]+>/, "")
      end
    end
  end
end

def save_tables(tables : Array(Array(String)), base_name : String)
  tables.each_with_index do |table, index|
    file_name = "output/#{base_name}_table_#{index + 1}.csv"
    File.open(file_name, "w") do |file|
      CSV.build(file) { |csv| table.each { |row| csv.row(row) } }
    end
    puts "Saved #{file_name}".colorize.cyan
  end
end

def process_url(url : String)
  html = fetch_html(url)
  return if html.empty?

  base = sanitize_filename(url)
  tables = extract_tables(html)
  puts "Found #{tables.size} tables at #{url}".colorize.yellow

  tables.each_with_index do |table, index|
    file_name = "#{base}_table_#{index + 1}.csv"
    File.open(file_name, "w") do |file|
      CSV.build(file) { |csv| table.each { |row| csv.row(row) } }
    end
    puts "Saved #{file_name}".colorize.cyan
  end
end


# ====== Sequential Execution ======

puts "\n>>> Running in SEQUENTIAL mode...\n".colorize.light_blue
start_seq = Time.monotonic
sources.each { |url| process_url(url) }
end_seq = Time.monotonic
puts "Sequential Execution Time: #{(end_seq - start_seq).total_seconds.round(2)} seconds.".colorize.yellow

# ====== Multithreaded Execution ======

puts "\n>>> Running in MULTITHREADED mode...\n".colorize.light_blue
start_threaded = Time.monotonic

done = Channel(Nil).new

sources.each do |url|
  spawn do
    process_url(url)
    done.send(nil)
  end
end

sources.size.times { done.receive }

end_threaded = Time.monotonic
puts "Multithreaded Execution Time: #{(end_threaded - start_threaded).total_seconds.round(2)} seconds.".colorize.magenta