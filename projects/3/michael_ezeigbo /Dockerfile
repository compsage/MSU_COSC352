# Step 1: Use official Golang image as a base
FROM golang:1.18-alpine

# Step 2: Set the Current Working Directory inside the container
WORKDIR /app

# Step 3: Copy everything from the current directory to the working directory
COPY . .

# Step 4: Install any dependencies (if you need any)
RUN go mod tidy

# Step 5: Build the Go app
RUN go build -o extract_tables .

# Step 6: Expose port if needed (optional)
# EXPOSE 8080

# Step 7: Command to run the executable
CMD ["./extract_tables"]
