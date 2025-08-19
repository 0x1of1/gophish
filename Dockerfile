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
    sed \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -g 1001 gophish && \
    useradd -u 1001 -g gophish -s /bin/bash gophish

# Set working directory
WORKDIR /app

# Copy binary and assets from builder
COPY --from=builder /app/gophish .
COPY --from=builder /app/config.json .
COPY --from=builder /app/db ./db
COPY --from=builder /app/static ./static
COPY --from=builder /app/templates ./templates
COPY --from=builder /app/VERSION .

# Copy entrypoint
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Create necessary directories
RUN mkdir -p /tmp && \
    chown -R gophish:gophish /app /tmp

# Switch to non-root user
USER gophish

# Expose ports
EXPOSE 3333 80

# Health check (admin UI on /login)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://127.0.0.1:${PORT:-3333}/login || exit 1

# Run the application via entrypoint to set PORT
env PORT=3333
ENTRYPOINT ["/app/entrypoint.sh"]
