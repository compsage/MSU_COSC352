FROM golang:1.20-alpine AS builder

WORKDIR /app

COPY . .

RUN go mod init project4 && \
    go get golang.org/x/net/html

RUN go build -o extract_tables .

FROM alpine:latest

WORKDIR /root/

COPY --from=builder /app/extract_tables .

RUN chmod +x extract_tables

RUN mkdir -p output

ENTRYPOINT ["./extract_tables"]
