
# Use the official Python image from Docker Hub
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the Python script into the container
COPY hello.py /app

# Make sure the container has the necessary entry point to run the Python script
ENTRYPOINT ["python", "hello.py"]
