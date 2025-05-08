# Stage 1: Build the project using Maven
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package

# Stage 2: Run the compiled jar using JRE
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=builder /app/target/hell0-1.0-SNAPSHOT.jar /app/app.jar
CMD ["java", "-jar", "app.jar"]
