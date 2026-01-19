#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="${BACKUP_DIR:-$INFRA_DIR/backups}"

if [ -z "$1" ]; then
    echo "Usage: $0 <backup_timestamp>"
    echo "Available backups:"
    ls -1 "$BACKUP_DIR" | grep -E "postgres_.*\.sql\.gz" | sed 's/postgres_\(.*\)\.sql\.gz/\1/' | sort -r
    exit 1
fi

TIMESTAMP=$1

echo "=== Brige Infrastructure Restore ==="
echo "Restoring from backup: $TIMESTAMP"
echo "WARNING: This will overwrite existing data!"
read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Restore cancelled."
    exit 0
fi

cd "$INFRA_DIR"

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Stop services
echo "Stopping services..."
docker-compose down

# Restore PostgreSQL
if [ -f "$BACKUP_DIR/postgres_${TIMESTAMP}.sql.gz" ]; then
    echo "Restoring PostgreSQL..."
    gunzip -c "$BACKUP_DIR/postgres_${TIMESTAMP}.sql.gz" | \
        docker-compose run --rm -T postgres psql -U "${POSTGRES_USER:-brige_user}" -d "${POSTGRES_DB:-brige_db}"
fi

# Restore MinIO
if [ -f "$BACKUP_DIR/minio_${TIMESTAMP}.tar.gz" ]; then
    echo "Restoring MinIO..."
    docker run --rm \
        -v "$INFRA_DIR/minio_data:/data" \
        -v "$BACKUP_DIR:/backup" \
        alpine sh -c "rm -rf /data/* && tar xzf /backup/minio_${TIMESTAMP}.tar.gz -C /data"
fi

# Restore configuration
if [ -f "$BACKUP_DIR/config_${TIMESTAMP}.tar.gz" ]; then
    echo "Restoring configuration..."
    tar xzf "$BACKUP_DIR/config_${TIMESTAMP}.tar.gz" -C "$INFRA_DIR"
fi

# Start services
echo "Starting services..."
docker-compose up -d

echo ""
echo "=== Restore completed ==="
