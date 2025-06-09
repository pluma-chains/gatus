# Build the go application into a binary
FROM golang:alpine AS builder
RUN apk --update add ca-certificates sqlite gcc musl-dev
WORKDIR /app
COPY . ./
RUN go mod tidy
RUN CGO_ENABLED=1 GOOS=linux go build -a -installsuffix cgo -o gatus .

# Run Tests inside docker image if you don't have a configured go environment
#RUN apk update && apk add --virtual build-dependencies build-base gcc
#RUN go test ./... -mod vendor

# Create a minimal runtime image with security enhancements
FROM alpine:latest
RUN apk --no-cache add ca-certificates sqlite sqlite-dev wget && \
    addgroup -g 1000 gatus && \
    adduser -u 1000 -G gatus -s /bin/sh -D gatus

COPY --from=builder /app/gatus /usr/local/bin/gatus
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# Set secure environment variables
ENV GATUS_CONFIG_PATH="/config/config.yaml"
ENV GATUS_LOG_LEVEL="INFO"
ENV PORT="8080"
ENV GATUS_DATABASE_PATH="/data/gatus.db"

# Create data directory and set ownership
RUN mkdir -p /data /config && \
    chown -R gatus:gatus /data /config && \
    chmod 755 /data /config

# Switch to non-root user
USER gatus

# Create data directory with proper permissions
VOLUME ["/data", "/config"]

EXPOSE ${PORT}

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT}/health || exit 1

ENTRYPOINT ["/usr/local/bin/gatus"]
