# Brige Infrastructure

Infrastructure setup for Brige Service Management System on Debian VPS.

**Languages:** [English](README.md) | [Русский](README_ru.md) | [Deutsch](README_de.md)

## Prerequisites

- Debian 11+ (or Ubuntu 20.04+)
- Docker 20.10+
- Docker Compose 2.0+
- OpenSSL (for self-signed certificates)

## Quick Start

1. **Clone repository and navigate to infrastructure directory:**
```bash
cd infrastructure
```

2. **Create environment file:**
```bash
cp env.template .env
```

3. **Edit `.env` file and set strong passwords:**
```bash
nano .env
```

4. **Make deployment script executable:**
```bash
chmod +x scripts/deploy.sh
```

5. **Run deployment:**
```bash
./scripts/deploy.sh
```

## Services

After deployment, the following services will be available:

- **PostgreSQL** (port 5432) - Main database
- **Redis** (port 6379) - Cache and session storage
- **MinIO** (ports 9000, 9001) - Object storage for media files
- **Keycloak** (port 8080) - Identity and Access Management
- **Prometheus** (port 9090) - Metrics collection
- **Grafana** (port 3000) - Metrics visualization
- **Nginx** (ports 80, 443) - Reverse proxy and SSL termination

## SSL Certificates

For development, the deployment script creates self-signed certificates automatically.

For production, you should:

1. Use Let's Encrypt with certbot:
```bash
# Install certbot
sudo apt-get update
sudo apt-get install certbot

# Obtain certificates
sudo certbot certonly --standalone -d brige.de -d *.brige.de

# Copy certificates to nginx/ssl/
sudo cp /etc/letsencrypt/live/brige.de/fullchain.pem infrastructure/nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/brige.de/privkey.pem infrastructure/nginx/ssl/key.pem
```

2. Set up automatic renewal in crontab:
```bash
0 0 * * * certbot renew --quiet && docker-compose -f /path/to/infrastructure/docker-compose.yml restart nginx
```

## DNS Configuration

Configure DNS records for your domain:

- `keycloak.brige.de` → VPS IP
- `minio.brige.de` → VPS IP
- `minio-api.brige.de` → VPS IP
- `prometheus.brige.de` → VPS IP
- `grafana.brige.de` → VPS IP
- `api.brige.de` → VPS IP
- `service.brige.de` → VPS IP

## Initial Setup

### Keycloak

1. Access https://keycloak.brige.de
2. Login with admin credentials from `.env`
3. Create realm for Brige
4. Configure clients and users

### MinIO

1. Access https://minio.brige.de
2. Login with root credentials from `.env`
3. Create buckets:
   - `brige-media` - for uploaded images and documents
   - `brige-reports` - for generated reports

### Grafana

1. Access https://grafana.brige.de
2. Login with admin credentials from `.env`
3. Prometheus datasource is pre-configured
4. Import or create dashboards

## Management Commands

### View logs
```bash
docker-compose logs -f [service_name]
```

### Stop services
```bash
docker-compose down
```

### Start services
```bash
docker-compose up -d
```

### Restart a service
```bash
docker-compose restart [service_name]
```

### Update services
```bash
docker-compose pull
docker-compose up -d
```

## Backup

Create backup:
```bash
./scripts/backup.sh
```

Restore from backup:
```bash
./scripts/restore.sh <timestamp>
```

Backups are stored in `backups/` directory.

## Security Notes

1. **Change all default passwords** in `.env` file
2. **Use strong passwords** (minimum 16 characters, mixed case, numbers, symbols)
3. **Restrict firewall** - only open ports 80, 443, and SSH (22)
4. **Keep Docker updated**: `sudo apt-get update && sudo apt-get upgrade docker-ce`
5. **Regular backups** - set up cron job for automated backups
6. **Monitor logs** - check for suspicious activity regularly

## Troubleshooting

### Services won't start
- Check logs: `docker-compose logs`
- Verify `.env` file exists and has correct values
- Check disk space: `df -h`
- Check Docker: `docker ps`

### Can't access services via HTTPS
- Verify SSL certificates exist in `nginx/ssl/`
- Check Nginx logs: `docker-compose logs nginx`
- Verify DNS records point to correct IP

### Database connection issues
- Wait for PostgreSQL to be fully started (check health status)
- Verify credentials in `.env`
- Check PostgreSQL logs: `docker-compose logs postgres`

## Environments

This infrastructure supports two environments:

- **Production:** Deployed on VPS server (see [INSTALL.md](INSTALL.md))
- **Development:** Local virtual machine for development (see [DEVELOPMENT.md](DEVELOPMENT.md))

## Installation

- **Production setup:** [INSTALL.md](INSTALL.md) | [INSTALL_ru.md](INSTALL_ru.md) | [INSTALL_de.md](INSTALL_de.md)
- **Development setup:** [DEVELOPMENT.md](DEVELOPMENT.md) | [DEVELOPMENT_ru.md](DEVELOPMENT_ru.md) | [DEVELOPMENT_de.md](DEVELOPMENT_de.md)

## Next Steps

1. Configure Keycloak realm and clients
2. Set up MinIO buckets and access policies
3. Configure Prometheus alerts
4. Create Grafana dashboards
5. Set up automated backups (cron job)
6. Configure monitoring alerts

## Production Checklist

- [ ] Change all default passwords
- [ ] Set up proper SSL certificates (Let's Encrypt)
- [ ] Configure firewall (UFW or iptables)
- [ ] Set up automated backups
- [ ] Configure monitoring alerts
- [ ] Set up log rotation
- [ ] Review and harden security settings
- [ ] Set up DNS records
- [ ] Configure email notifications
- [ ] Document access credentials securely

---

**Languages:** [English](README.md) | [Русский](README_ru.md) | [Deutsch](README_de.md)
