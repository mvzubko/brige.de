# Installationsanleitung für Debian VPS

Diese Anleitung hilft Ihnen beim Einrichten der Brige-Infrastruktur auf einem neuen Debian VPS.

## Schritt 1: Erste Server-Einrichtung

### System aktualisieren
```bash
sudo apt update
sudo apt upgrade -y
```

### Grundlegende Tools installieren
```bash
sudo apt install -y curl wget git vim ufw
```

## Schritt 2: Docker installieren

### Docker aus offiziellem Repository installieren
```bash
# Alte Versionen entfernen
sudo apt remove -y docker docker-engine docker.io containerd runc

# Voraussetzungen installieren
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Docker's offiziellen GPG-Schlüssel hinzufügen
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Repository einrichten
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker Engine installieren
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Aktuellen Benutzer zur docker-Gruppe hinzufügen (optional, um docker ohne sudo auszuführen)
sudo usermod -aG docker $USER

# Installation überprüfen
docker --version
docker compose version
```

**Hinweis:** Möglicherweise müssen Sie sich ab- und wieder anmelden, damit Gruppenänderungen wirksam werden.

## Schritt 3: Firewall konfigurieren

```bash
# SSH erlauben
sudo ufw allow 22/tcp

# HTTP und HTTPS erlauben
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Firewall aktivieren
sudo ufw enable

# Status überprüfen
sudo ufw status
```

## Schritt 4: Repository klonen

```bash
# Zu bevorzugtem Verzeichnis navigieren
cd /opt  # oder /home/ihr-benutzer

# Repository klonen (URL an Ihr tatsächliches Repository anpassen)
git clone <your-repo-url> brige.de
cd brige.de/infrastructure
```

## Schritt 5: Umgebung konfigurieren

```bash
# Vorlage kopieren
cp env.template .env

# Konfiguration bearbeiten
nano .env
```

**Wichtig:** Setzen Sie starke Passwörter für alle Dienste!

Sichere Passwörter generieren:
```bash
# Zufälliges Passwort generieren (Beispiel)
openssl rand -base64 32
```

## Schritt 6: Infrastruktur bereitstellen

```bash
# Skripte ausführbar machen
chmod +x scripts/*.sh

# Bereitstellung ausführen
./scripts/deploy.sh
```

Oder mit Makefile:
```bash
make deploy
```

## Schritt 7: Installation überprüfen

Überprüfen, dass alle Dienste laufen:
```bash
docker-compose ps
```

Alle Dienste sollten den Status "Up" anzeigen.

## Schritt 8: DNS konfigurieren

Richten Sie Ihre Domänennamen auf die VPS-IP-Adresse:

- `keycloak.brige.de` → Ihre VPS IP
- `minio.brige.de` → Ihre VPS IP
- `minio-api.brige.de` → Ihre VPS IP
- `prometheus.brige.de` → Ihre VPS IP
- `grafana.brige.de` → Ihre VPS IP
- `api.brige.de` → Ihre VPS IP
- `service.brige.de` → Ihre VPS IP

## Schritt 9: SSL-Zertifikate einrichten (Produktion)

### Option A: Let's Encrypt (Empfohlen)

```bash
# certbot installieren
sudo apt install -y certbot

# nginx vorübergehend stoppen
docker-compose stop nginx

# Zertifikate erhalten
sudo certbot certonly --standalone \
    -d brige.de \
    -d *.brige.de \
    --email your-email@brige.de \
    --agree-tos \
    --non-interactive

# Zertifikate kopieren
sudo cp /etc/letsencrypt/live/brige.de/fullchain.pem infrastructure/nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/brige.de/privkey.pem infrastructure/nginx/ssl/key.pem

# Berechtigungen setzen
sudo chmod 644 infrastructure/nginx/ssl/cert.pem
sudo chmod 600 infrastructure/nginx/ssl/key.pem

# nginx neu starten
docker-compose start nginx
```

### Option B: Selbstsigniert (Nur für Entwicklung)

Selbstsignierte Zertifikate werden automatisch vom Bereitstellungsskript für Entwicklungszwecke erstellt.

## Schritt 10: Automatische Backups einrichten

Erstellen Sie einen Cron-Job für automatisierte Backups:

```bash
# crontab bearbeiten
crontab -e

# Diese Zeile hinzufügen (läuft täglich um 2 Uhr)
0 2 * * * cd /opt/brige.de/infrastructure && ./scripts/backup.sh

# Für SSL-Zertifikatserneuerung (wenn Let's Encrypt verwendet wird)
0 3 * * 0 certbot renew --quiet && cd /opt/brige.de/infrastructure && docker-compose restart nginx
```

## Schritt 11: Erste Dienstkonfiguration

### Keycloak

1. Zugriff auf https://keycloak.brige.de
2. Anmeldung mit Admin-Anmeldedaten aus `.env`
3. Neuen Realm mit dem Namen "brige" erstellen
4. Clients für Ihre Anwendungen konfigurieren

### MinIO

1. Zugriff auf https://minio.brige.de
2. Anmeldung mit Root-Anmeldedaten aus `.env`
3. Buckets erstellen:
   - `brige-media` - für hochgeladene Bilder und Dokumente
   - `brige-reports` - für generierte Berichte
4. Zugriffsschlüssel für Anwendungen erstellen

### Grafana

1. Zugriff auf https://grafana.brige.de
2. Anmeldung mit Admin-Anmeldedaten aus `.env`
3. Prometheus-Datenquelle ist vorkonfiguriert
4. Dashboards für die Überwachung importieren oder erstellen

## Fehlerbehebung

### Docker-Daemon läuft nicht
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### Berechtigungsfehler
```bash
# Benutzer zur docker-Gruppe hinzufügen
sudo usermod -aG docker $USER
# Ab- und wieder anmelden
```

### Dienste starten nicht
```bash
# Logs überprüfen
docker-compose logs

# Festplattenspeicher überprüfen
df -h

# Speicher überprüfen
free -h
```

### Port bereits in Verwendung
```bash
# Prozess finden, der Port verwendet
sudo lsof -i :80
sudo lsof -i :443

# Konfliktierenden Dienst stoppen oder Ports in docker-compose.yml ändern
```

## Nächste Schritte

1. Keycloak-Realm und Clients konfigurieren
2. MinIO-Buckets und Zugriffsrichtlinien einrichten
3. Überwachungs-Dashboards in Grafana konfigurieren
4. Alarmierung in Prometheus einrichten
5. Automatisierte Backups konfigurieren
6. Sicherheitseinstellungen überprüfen

## Sicherheitsempfehlungen

1. **SSH-Port ändern** (optional, aber empfohlen):
   ```bash
   sudo nano /etc/ssh/sshd_config
   # Port 22 auf einen anderen Port ändern
   sudo systemctl restart sshd
   ```

2. **Root-Login deaktivieren**:
   ```bash
   sudo nano /etc/ssh/sshd_config
   # PermitRootLogin no setzen
   sudo systemctl restart sshd
   ```

3. **fail2ban einrichten**:
   ```bash
   sudo apt install -y fail2ban
   sudo systemctl enable fail2ban
   sudo systemctl start fail2ban
   ```

4. **Regelmäßige Updates**:
   ```bash
   # Zu crontab hinzufügen
   0 4 * * 0 apt update && apt upgrade -y
   ```

5. **Logs überwachen**:
   ```bash
   # Log-Rotation einrichten
   sudo nano /etc/logrotate.d/docker
   ```
