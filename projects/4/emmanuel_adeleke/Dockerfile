# Use Alpine as the base image
FROM alpine:latest

# Set the working directory
WORKDIR /app

# Install Crystal and required dependencies
RUN apk add --no-cache crystal shards build-base libffi-dev yaml-dev zlib-dev openssl-dev git

# Copy the Crystal script and HTML file into the container
COPY . /app

# Compile the Crystal program (static binary)
RUN crystal build extract_tables.cr --release

# Ensure the compiled binary is executable
RUN chmod +x extract_tables

# Create a non-root user and set the ownership of the application directory
RUN adduser -D -g '' -h /app -s /bin/sh appuser
RUN chown -R appuser:appuser /app

# Switch to the non-root user
USER appuser

# Define a volume to store extracted CSV files
VOLUME ["/app"]

# Set the default command to run the compiled binary
CMD ["crystal", "run", "extract_tables.cr"]