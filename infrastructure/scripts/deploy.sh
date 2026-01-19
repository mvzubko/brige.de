#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Brige Infrastructure Deployment ==="

# Check if .env file exists
if [ ! -f "$INFRA_DIR/.env" ]; then
    echo "Error: .env file not found!"
    echo "Please copy env.template to .env and configure it:"
    echo "  cp $INFRA_DIR/env.template $INFRA_DIR/.env"
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
        -subj "/C=DE/ST=State/L=City/O=Brige/CN=57.128.239.26"
    echo "Self-signed certificates created. For production, use Let's Encrypt or proper certificates."
fi

# Navigate to infrastructure directory
cd "$INFRA_DIR"

# Pull latest images
echo "Pulling Docker images..."
docker-compose pull

# Start services
echo "Starting services..."
docker-compose up -d

# Wait for services to be healthy
echo "Waiting for services to start..."
sleep 10

# Check service status
echo "Service status:"
docker-compose ps

echo ""
echo "=== Deployment completed ==="
echo ""
echo "Services are available at:"
echo "  - Keycloak: http://57.128.239.26:8080 or https://57.128.239.26"
echo "  - MinIO Console: http://57.128.239.26:9001 or https://57.128.239.26"
echo "  - MinIO API: http://57.128.239.26:9000"
echo "  - Prometheus: http://57.128.239.26:9090 or https://57.128.239.26"
echo "  - Grafana: http://57.128.239.26:3000 or https://57.128.239.26"
echo ""
echo "To view logs: docker-compose logs -f [service_name]"
echo "To stop services: docker-compose down"
