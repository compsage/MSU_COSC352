# Use the official Clojure base image
FROM clojure:latest

# Set the working directory inside the container
WORKDIR /app

# Copy the project files into the container
COPY . /app

# Set default command to execute your script
CMD ["clojure", "-M", "extract_tables.clj"]