# Build stage
FROM golang:1.22-alpine AS builder

# Install build dependencies including gcc for CGO
RUN apk add --no-cache git ca-certificates tzdata gcc musl-dev

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application with specific build tags for SQLite compatibility
RUN CGO_ENABLED=1 GOOS=linux go build -tags "sqlite_omit_load_extension" -a -installsuffix cgo -o gophish .

# Final stage
FROM alpine:latest

# Install runtime dependencies
RUN apk --no-cache add ca-certificates tzdata sqlite wget

# Create non-root user
RUN addgroup -g 1001 -S gophish && \
    adduser -u 1001 -S gophish -G gophish

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
