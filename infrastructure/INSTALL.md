# Installation Guide for Debian VPS

This guide will help you set up the Brige infrastructure on a fresh Debian VPS.

## Step 1: Initial Server Setup

### Update system
```bash
sudo apt update
sudo apt upgrade -y
```

### Install basic tools
```bash
sudo apt install -y curl wget git vim ufw
```

## Step 2: Install Docker

### Install Docker using official repository
```bash
# Remove old versions
sudo apt remove -y docker docker-engine docker.io containerd runc

# Install prerequisites
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to docker group (optional, to run docker without sudo)
sudo usermod -aG docker $USER

# Verify installation
docker --version
docker compose version
```

**Note:** You may need to log out and log back in for group changes to take effect.

## Step 3: Configure Firewall

```bash
# Allow SSH
sudo ufw allow 22/tcp

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status
```

## Step 4: Clone Repository

```bash
# Navigate to your preferred directory
cd /opt  # or /home/your-user

# Clone repository (adjust URL to your actual repository)
git clone <your-repo-url> brige.de
cd brige.de/infrastructure
```

## Step 5: Configure Environment

```bash
# Copy template
cp env.template .env

# Edit configuration
nano .env
```

**Important:** Set strong passwords for all services!

Generate secure passwords:
```bash
# Generate random password (example)
openssl rand -base64 32
```

## Step 6: Deploy Infrastructure

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run deployment
./scripts/deploy.sh
```

Or using Makefile:
```bash
make deploy
```

## Step 7: Verify Installation

Check that all services are running:
```bash
docker-compose ps
```

All services should show "Up" status.

## Step 8: Configure DNS

Point your domain names to the VPS IP address:

- `keycloak.brige.de` → Your VPS IP
- `minio.brige.de` → Your VPS IP
- `minio-api.brige.de` → Your VPS IP
- `prometheus.brige.de` → Your VPS IP
- `grafana.brige.de` → Your VPS IP
- `api.brige.de` → Your VPS IP
- `service.brige.de` → Your VPS IP

## Step 9: Set Up SSL Certificates (Production)

### Option A: Let's Encrypt (Recommended)

```bash
# Install certbot
sudo apt install -y certbot

# Stop nginx temporarily
docker-compose stop nginx

# Obtain certificates
sudo certbot certonly --standalone \
    -d brige.de \
    -d *.brige.de \
    --email your-email@brige.de \
    --agree-tos \
    --non-interactive

# Copy certificates
sudo cp /etc/letsencrypt/live/brige.de/fullchain.pem infrastructure/nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/brige.de/privkey.pem infrastructure/nginx/ssl/key.pem

# Set permissions
sudo chmod 644 infrastructure/nginx/ssl/cert.pem
sudo chmod 600 infrastructure/nginx/ssl/key.pem

# Restart nginx
docker-compose start nginx
```

### Option B: Self-Signed (Development Only)

Self-signed certificates are automatically created by the deployment script for development purposes.

## Step 10: Set Up Automatic Backups

Create a cron job for automated backups:

```bash
# Edit crontab
crontab -e

# Add this line (runs daily at 2 AM)
0 2 * * * cd /opt/brige.de/infrastructure && ./scripts/backup.sh

# For SSL certificate renewal (if using Let's Encrypt)
0 3 * * 0 certbot renew --quiet && cd /opt/brige.de/infrastructure && docker-compose restart nginx
```

## Step 11: Initial Service Configuration

### Keycloak

1. Access https://keycloak.brige.de
2. Login with admin credentials from `.env`
3. Create a new realm named "brige"
4. Configure clients for your applications

### MinIO

1. Access https://minio.brige.de
2. Login with root credentials from `.env`
3. Create buckets:
   - `brige-media` - for uploaded images and documents
   - `brige-reports` - for generated reports
4. Create access keys for applications

### Grafana

1. Access https://grafana.brige.de
2. Login with admin credentials from `.env`
3. Prometheus datasource is pre-configured
4. Import or create dashboards for monitoring

## Troubleshooting

### Docker daemon not running
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### Permission denied errors
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Log out and log back in
```

### Services won't start
```bash
# Check logs
docker-compose logs

# Check disk space
df -h

# Check memory
free -h
```

### Port already in use
```bash
# Find process using port
sudo lsof -i :80
sudo lsof -i :443

# Stop conflicting service or change ports in docker-compose.yml
```

## Next Steps

1. Configure Keycloak realm and clients
2. Set up MinIO buckets and access policies
3. Configure monitoring dashboards in Grafana
4. Set up alerting in Prometheus
5. Configure automated backups
6. Review security settings

## Security Recommendations

1. **Change SSH port** (optional but recommended):
   ```bash
   sudo nano /etc/ssh/sshd_config
   # Change Port 22 to another port
   sudo systemctl restart sshd
   ```

2. **Disable root login**:
   ```bash
   sudo nano /etc/ssh/sshd_config
   # Set PermitRootLogin no
   sudo systemctl restart sshd
   ```

3. **Set up fail2ban**:
   ```bash
   sudo apt install -y fail2ban
   sudo systemctl enable fail2ban
   sudo systemctl start fail2ban
   ```

4. **Regular updates**:
   ```bash
   # Add to crontab
   0 4 * * 0 apt update && apt upgrade -y
   ```

5. **Monitor logs**:
   ```bash
   # Set up log rotation
   sudo nano /etc/logrotate.d/docker
   ```
