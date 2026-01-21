# Development Environment Setup

This guide explains how to set up a local development environment using a virtual machine that mirrors the production VPS setup.

**Languages:** [English](DEVELOPMENT.md) | [Русский](DEVELOPMENT_ru.md) | [Deutsch](DEVELOPMENT_de.md)

## Overview

The development environment runs on a local virtual machine with the same configuration as the production VPS. This provides:
- Complete isolation from production
- Fast development cycles
- Offline development capability
- Identical environment to production

## Prerequisites

- Virtualization software:
  - **VirtualBox** (free, cross-platform) - Recommended
  - **VMware Workstation Player** (free for personal use)
  - **Hyper-V** (Windows Pro/Enterprise only)
- At least 8 GB RAM on host machine
- 50-100 GB free disk space

## Step 1: Create Virtual Machine

### Using VirtualBox

1. **Download and install VirtualBox:**
   - https://www.virtualbox.org/wiki/Downloads

2. **Create new VM:**
   - Name: `Brige Dev Environment`
   - Type: Linux
   - Version: Ubuntu (64-bit)

3. **Configure VM resources:**
   - **RAM:** 4096 MB (4 GB) minimum, 8192 MB (8 GB) recommended
   - **CPU:** 2-4 cores
   - **Hard disk:** 50-100 GB, dynamically allocated

4. **Network settings:**
   - Adapter 1: NAT (for internet access)
   - Adapter 2: Host-only Adapter (for access from host machine)
     - If Host-only adapter doesn't exist, create it in VirtualBox settings

### Using VMware

1. **Download VMware Workstation Player:**
   - https://www.vmware.com/products/workstation-player.html

2. **Create new VM:**
   - Select "Create a New Virtual Machine"
   - Choose "I will install the operating system later"
   - Guest OS: Linux, Ubuntu 24.04 LTS 64-bit
   - Name: `Brige Dev Environment`

3. **Configure resources:**
   - Disk: 50-100 GB
   - Memory: 4096-8192 MB
   - Processors: 2-4

4. **Network:**
   - NAT for internet
   - Custom: VMnet1 (Host-only) for host access

## Step 2: Install Ubuntu

1. **Download Ubuntu ISO:**
   - https://ubuntu.com/download/server
   - Choose Ubuntu 24.04 LTS (Server ISO)

2. **Install Ubuntu in VM:**
   - Attach ISO to VM
   - Boot from ISO
   - Follow installation wizard
   - **Important:** Install SSH server during installation
   - Create a user account (remember credentials)

3. **After installation:**
   - Update system: `sudo apt update && sudo apt upgrade -y`
   - Install essential tools: `sudo apt install -y curl wget git vim`

## Step 3: Install Docker

Follow the same Docker installation steps as in [INSTALL.md](INSTALL.md):

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
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER

# Log out and log back in, then verify
docker --version
docker compose version
```

## Step 4: Transfer Infrastructure Files

### Option A: Using Git (Recommended)

```bash
# In VM
cd ~
git clone <your-repo-url> brige.de
cd brige.de/infrastructure
```

### Option B: Using SCP from Host

```bash
# From host machine
scp -r infrastructure/ user@vm-ip:~/
```

### Option C: Using Shared Folder (VirtualBox)

1. Install VirtualBox Guest Additions in VM
2. In VirtualBox settings, add shared folder pointing to your project directory
3. Mount in VM: `sudo mount -t vboxsf <share-name> /mnt/share`

## Step 5: Configure Development Environment

1. **Copy environment template:**
```bash
cd infrastructure
cp env.dev.template .env.dev
```

2. **Edit configuration:**
```bash
nano .env.dev
```

Set development passwords (can be simpler than production, but still secure).

3. **Make scripts executable:**
```bash
chmod +x scripts/*.sh
```

## Step 6: Deploy Development Services

```bash
./scripts/deploy-dev.sh
```

Or using docker-compose directly:
```bash
docker-compose -f docker-compose.dev.yml --env-file .env.dev up -d
```

## Step 7: Configure Host Machine

### Find VM IP Address

In VM, run:
```bash
ip addr show
```

Look for IP in the host-only network adapter (usually `192.168.x.x`).

### Configure Hosts File

**Linux/Mac:**
```bash
sudo nano /etc/hosts
```

**Windows:**
```cmd
notepad C:\Windows\System32\drivers\etc\hosts
```

Note: Since we use IP addresses instead of domain names, you can access services directly by IP and port.

## Step 8: Access Services

After deployment, services are available at (VM IP: 192.168.1.200):

- **Keycloak:** http://192.168.1.200:8080 or https://192.168.1.200
- **MinIO Console:** http://192.168.1.200:9001 or https://192.168.1.200
- **MinIO API:** http://192.168.1.200:9000
- **Prometheus:** http://192.168.1.200:9090 or https://192.168.1.200
- **Grafana:** http://192.168.1.200:3000 or https://192.168.1.200

## Development Workflow

### Starting Services
```bash
cd infrastructure
docker-compose -f docker-compose.dev.yml --env-file .env.dev up -d
```

### Stopping Services
```bash
docker-compose -f docker-compose.dev.yml --env-file .env.dev down
```

### Viewing Logs
```bash
docker-compose -f docker-compose.dev.yml --env-file .env.dev logs -f [service_name]
```

### Restarting a Service
```bash
docker-compose -f docker-compose.dev.yml --env-file .env.dev restart [service_name]
```

### Accessing Services from Host

Services are accessible from your host machine using the domains configured in `/etc/hosts`.

## Differences from Production

1. **Self-signed SSL certificates** (acceptable for development)
2. **HTTP allowed** (in addition to HTTPS)
3. **Separate data volumes** (prefixed with `_dev`)
4. **Separate network** (`brige-network-dev`)
5. **Different container names** (suffixed with `-dev`)

## Troubleshooting

### Can't access services from host

1. **Check VM IP address:**
   ```bash
   # In VM
   ip addr show
   ```

2. **Verify hosts file** on host machine

3. **Check firewall** in VM:
   ```bash
   sudo ufw status
   # If needed, allow ports:
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   ```

### Services won't start

1. **Check logs:**
   ```bash
   docker-compose -f docker-compose.dev.yml --env-file .env.dev logs
   ```

2. **Check disk space:**
   ```bash
   df -h
   ```

3. **Check memory:**
   ```bash
   free -h
   ```

### VM is slow

- Increase allocated RAM
- Increase CPU cores
- Enable hardware acceleration in VM settings
- Close unnecessary applications on host

## Best Practices

1. **Regular snapshots:** Create VM snapshots before major changes
2. **Backup data:** Periodically backup development data
3. **Keep updated:** Update VM and Docker regularly
4. **Separate data:** Never mix dev and prod data
5. **Test locally:** Always test changes in dev before deploying to prod

## Next Steps

1. Configure Keycloak realm for development
2. Set up MinIO buckets with test data
3. Configure Grafana dashboards
4. Start developing your application!

---

**Languages:** [English](DEVELOPMENT.md) | [Русский](DEVELOPMENT_ru.md) | [Deutsch](DEVELOPMENT_de.md)
