# Brige Infrastruktur

Infrastruktur-Setup für das Brige Service Management System auf Debian VPS.

**Sprachen:** [English](README.md) | [Русский](README_ru.md) | [Deutsch](README_de.md)

## Voraussetzungen

- Debian 11+ (oder Ubuntu 20.04+)
- Docker 20.10+
- Docker Compose 2.0+
- OpenSSL (für selbstsignierte Zertifikate)

## Schnellstart

1. **Repository klonen und zum Infrastruktur-Verzeichnis navigieren:**
```bash
cd infrastructure
```

2. **Umgebungsdatei erstellen:**
```bash
cp env.template .env
```

3. **`.env` Datei bearbeiten und starke Passwörter setzen:**
```bash
nano .env
```

4. **Deployment-Skript ausführbar machen:**
```bash
chmod +x scripts/deploy.sh
```

5. **Deployment ausführen:**
```bash
./scripts/deploy.sh
```

## Dienste

Nach dem Deployment sind folgende Dienste verfügbar:

- **PostgreSQL** (Port 5432) - Hauptdatenbank
- **Redis** (Port 6379) - Cache und Sitzungsspeicher
- **MinIO** (Ports 9000, 9001) - Objektspeicher für Mediendateien
- **Keycloak** (Port 8080) - Identitäts- und Zugriffsverwaltung
- **Prometheus** (Port 9090) - Metriken-Sammlung
- **Grafana** (Port 3000) - Metriken-Visualisierung
- **Nginx** (Ports 80, 443) - Reverse Proxy und SSL-Terminierung

## SSL-Zertifikate

Für die Entwicklung erstellt das Deployment-Skript automatisch selbstsignierte Zertifikate.

Für die Produktion sollten Sie:

1. Let's Encrypt mit certbot verwenden:
```bash
# certbot installieren
sudo apt-get update
sudo apt-get install certbot

# Zertifikate erhalten
sudo certbot certonly --standalone -d brige.de -d *.brige.de

# Zertifikate nach nginx/ssl/ kopieren
sudo cp /etc/letsencrypt/live/brige.de/fullchain.pem infrastructure/nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/brige.de/privkey.pem infrastructure/nginx/ssl/key.pem
```

2. Automatische Erneuerung in crontab einrichten:
```bash
0 0 * * * certbot renew --quiet && docker-compose -f /path/to/infrastructure/docker-compose.yml restart nginx
```

## DNS-Konfiguration

DNS-Einträge für Ihre Domain konfigurieren:

- `keycloak.brige.de` → VPS IP
- `minio.brige.de` → VPS IP
- `minio-api.brige.de` → VPS IP
- `prometheus.brige.de` → VPS IP
- `grafana.brige.de` → VPS IP
- `api.brige.de` → VPS IP
- `service.brige.de` → VPS IP

## Ersteinrichtung

### Keycloak

1. Zugriff auf https://keycloak.brige.de
2. Anmeldung mit Admin-Anmeldedaten aus `.env`
3. Realm für Brige erstellen
4. Clients und Benutzer konfigurieren

### MinIO

1. Zugriff auf https://minio.brige.de
2. Anmeldung mit Root-Anmeldedaten aus `.env`
3. Buckets erstellen:
   - `brige-media` - für hochgeladene Bilder und Dokumente
   - `brige-reports` - für generierte Berichte

### Grafana

1. Zugriff auf https://grafana.brige.de
2. Anmeldung mit Admin-Anmeldedaten aus `.env`
3. Prometheus-Datenquelle ist vorkonfiguriert
4. Dashboards importieren oder erstellen

## Verwaltungsbefehle

### Logs anzeigen
```bash
docker-compose logs -f [service_name]
```

### Dienste stoppen
```bash
docker-compose down
```

### Dienste starten
```bash
docker-compose up -d
```

### Dienst neu starten
```bash
docker-compose restart [service_name]
```

### Dienste aktualisieren
```bash
docker-compose pull
docker-compose up -d
```

## Backup

Backup erstellen:
```bash
./scripts/backup.sh
```

Aus Backup wiederherstellen:
```bash
./scripts/restore.sh <timestamp>
```

Backups werden im Verzeichnis `backups/` gespeichert.

## Sicherheitshinweise

1. **Ändern Sie alle Standardpasswörter** in der `.env` Datei
2. **Verwenden Sie starke Passwörter** (mindestens 16 Zeichen, gemischte Groß-/Kleinschreibung, Zahlen, Symbole)
3. **Firewall einschränken** - nur Ports 80, 443 und SSH (22) öffnen
4. **Docker aktuell halten**: `sudo apt-get update && sudo apt-get upgrade docker-ce`
5. **Regelmäßige Backups** - Cron-Job für automatisierte Backups einrichten
6. **Logs überwachen** - regelmäßig auf verdächtige Aktivitäten prüfen

## Fehlerbehebung

### Dienste starten nicht
- Logs prüfen: `docker-compose logs`
- Überprüfen, ob `.env` Datei existiert und korrekte Werte hat
- Festplattenspeicher prüfen: `df -h`
- Docker prüfen: `docker ps`

### Kein Zugriff auf Dienste über HTTPS
- Überprüfen, ob SSL-Zertifikate in `nginx/ssl/` existieren
- Nginx-Logs prüfen: `docker-compose logs nginx`
- Überprüfen, ob DNS-Einträge auf die richtige IP zeigen

### Datenbankverbindungsprobleme
- Warten, bis PostgreSQL vollständig gestartet ist (Health-Status prüfen)
- Anmeldedaten in `.env` überprüfen
- PostgreSQL-Logs prüfen: `docker-compose logs postgres`

## Umgebungen

Diese Infrastruktur unterstützt zwei Umgebungen:

- **Produktion:** Bereitstellung auf VPS-Server (siehe [INSTALL.md](INSTALL.md))
- **Entwicklung:** Lokale virtuelle Maschine für Entwicklung (siehe [DEVELOPMENT.md](DEVELOPMENT.md))

## Installation

- **Produktions-Setup:** [INSTALL.md](INSTALL.md) | [INSTALL_ru.md](INSTALL_ru.md) | [INSTALL_de.md](INSTALL_de.md)
- **Entwicklungs-Setup:** [DEVELOPMENT.md](DEVELOPMENT.md) | [DEVELOPMENT_ru.md](DEVELOPMENT_ru.md) | [DEVELOPMENT_de.md](DEVELOPMENT_de.md)

## Nächste Schritte

1. Keycloak-Realm und Clients konfigurieren
2. MinIO-Buckets und Zugriffsrichtlinien einrichten
3. Prometheus-Alarme konfigurieren
4. Grafana-Dashboards erstellen
5. Automatisierte Backups einrichten (Cron-Job)
6. Monitoring-Alarme konfigurieren

## Produktions-Checkliste

- [ ] Alle Standardpasswörter ändern
- [ ] Ordentliche SSL-Zertifikate einrichten (Let's Encrypt)
- [ ] Firewall konfigurieren (UFW oder iptables)
- [ ] Automatisierte Backups einrichten
- [ ] Monitoring-Alarme konfigurieren
- [ ] Log-Rotation einrichten
- [ ] Sicherheitseinstellungen überprüfen und härten
- [ ] DNS-Einträge einrichten
- [ ] E-Mail-Benachrichtigungen konfigurieren
- [ ] Zugangsdaten sicher dokumentieren

---

**Sprachen:** [English](README.md) | [Русский](README_ru.md) | [Deutsch](README_de.md)
