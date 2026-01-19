#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="${BACKUP_DIR:-$INFRA_DIR/backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "=== Brige Infrastructure Backup ==="

mkdir -p "$BACKUP_DIR"

cd "$INFRA_DIR"

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Backup PostgreSQL
echo "Backing up PostgreSQL..."
docker-compose exec -T postgres pg_dump -U "${POSTGRES_USER:-brige_user}" "${POSTGRES_DB:-brige_db}" | gzip > "$BACKUP_DIR/postgres_${TIMESTAMP}.sql.gz"

# Backup Redis (if needed)
echo "Backing up Redis..."
docker-compose exec -T redis redis-cli --rdb - | gzip > "$BACKUP_DIR/redis_${TIMESTAMP}.rdb.gz" || echo "Redis backup skipped (may require password)"

# Backup MinIO data
echo "Backing up MinIO volumes..."
docker run --rm \
    -v "$INFRA_DIR/minio_data:/data:ro" \
    -v "$BACKUP_DIR:/backup" \
    alpine tar czf "/backup/minio_${TIMESTAMP}.tar.gz" -C /data .

# Backup configuration files
echo "Backing up configuration..."
tar czf "$BACKUP_DIR/config_${TIMESTAMP}.tar.gz" \
    -C "$INFRA_DIR" \
    nginx/ prometheus/ grafana/ .env docker-compose.yml

echo ""
echo "=== Backup completed ==="
echo "Backups saved to: $BACKUP_DIR"
ls -lh "$BACKUP_DIR" | grep "$TIMESTAMP"
