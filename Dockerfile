# Build stage
FROM golang:1.22-bullseye AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    git \
    ca-certificates \
    gcc \
    libc6-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=1 GOOS=linux go build -a -installsuffix cgo -o gophish .

# Final stage
FROM debian:bullseye-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    sqlite3 \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -g 1001 gophish && \
    useradd -u 1001 -g gophish -s /bin/bash gophish

# Set working directory
WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /app/gophish .
COPY --from=builder /app/config.json .
COPY --from=builder /app/db ./db
COPY --from=builder /app/static ./static
COPY --from=builder /app/templates ./templates
COPY --from=builder /app/VERSION .

# Create necessary directories
RUN mkdir -p /tmp && \
    chown -R gophish:gophish /app /tmp

# Switch to non-root user
USER gophish

# Expose ports
EXPOSE 3333 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3333/ || exit 1

# Run the application
CMD ["./gophish"]
