# Use the official Go image from Docker Hub
FROM golang:1.18-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the Go source code into the container
COPY hello.go /app

# Build the Go program inside the container
RUN go build -o hello hello.go

# Set the default command to run the Go program
CMD ["./hello"]
