#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Brige Development Infrastructure Deployment ==="

# Check if .env.dev file exists
if [ ! -f "$INFRA_DIR/.env.dev" ]; then
    echo "Error: .env.dev file not found!"
    echo "Please copy env.dev.template to .env.dev and configure it:"
    echo "  cp $INFRA_DIR/env.dev.template $INFRA_DIR/.env.dev"
    exit 1
fi

# Check if SSL certificates exist
if [ ! -f "$INFRA_DIR/nginx/ssl/cert.pem" ] || [ ! -f "$INFRA_DIR/nginx/ssl/key.pem" ]; then
    echo "Warning: SSL certificates not found in nginx/ssl/"
    echo "Creating self-signed certificates for development..."
    mkdir -p "$INFRA_DIR/nginx/ssl"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$INFRA_DIR/nginx/ssl/key.pem" \
        -out "$INFRA_DIR/nginx/ssl/cert.pem" \
        -subj "/C=DE/ST=State/L=City/O=Brige/CN=192.168.1.200"
    echo "Self-signed certificates created for development."
fi

# Navigate to infrastructure directory
cd "$INFRA_DIR"

# Pull latest images
echo "Pulling Docker images..."
docker-compose -f docker-compose.dev.yml --env-file .env.dev pull

# Start services
echo "Starting development services..."
docker-compose -f docker-compose.dev.yml --env-file .env.dev up -d

# Wait for services to be healthy
echo "Waiting for services to start..."
sleep 10

# Check service status
echo "Service status:"
docker-compose -f docker-compose.dev.yml --env-file .env.dev ps

echo ""
echo "=== Development deployment completed ==="
echo ""
echo "Services are available at:"
echo "  - Keycloak: http://192.168.1.200:8080 or https://192.168.1.200"
echo "  - MinIO Console: http://192.168.1.200:9001 or https://192.168.1.200"
echo "  - MinIO API: http://192.168.1.200:9000"
echo "  - Prometheus: http://192.168.1.200:9090 or https://192.168.1.200"
echo "  - Grafana: http://192.168.1.200:3000 or https://192.168.1.200"
echo ""
echo "To view logs: docker-compose -f docker-compose.dev.yml --env-file .env.dev logs -f [service_name]"
echo "To stop services: docker-compose -f docker-compose.dev.yml --env-file .env.dev down"
