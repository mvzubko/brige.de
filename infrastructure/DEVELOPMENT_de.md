# Entwicklungsumgebung einrichten

Diese Anleitung erklärt, wie Sie eine lokale Entwicklungsumgebung mit einer virtuellen Maschine einrichten, die die Produktions-VPS-Konfiguration widerspiegelt.

**Sprachen:** [English](DEVELOPMENT.md) | [Русский](DEVELOPMENT_ru.md) | [Deutsch](DEVELOPMENT_de.md)

## Überblick

Die Entwicklungsumgebung läuft auf einer lokalen virtuellen Maschine mit derselben Konfiguration wie der Produktions-VPS. Dies bietet:
- Vollständige Isolation von der Produktion
- Schnelle Entwicklungszyklen
- Offline-Entwicklungsfähigkeit
- Identische Umgebung zur Produktion

## Voraussetzungen

- Virtualisierungssoftware:
  - **VirtualBox** (kostenlos, plattformübergreifend) - Empfohlen
  - **VMware Workstation Player** (kostenlos für den persönlichen Gebrauch)
  - **Hyper-V** (nur Windows Pro/Enterprise)
- Mindestens 8 GB RAM auf dem Host-Rechner
- 50-100 GB freier Festplattenspeicher

## Schritt 1: Virtuelle Maschine erstellen

### Mit VirtualBox

1. **VirtualBox herunterladen und installieren:**
   - https://www.virtualbox.org/wiki/Downloads

2. **Neue VM erstellen:**
   - Name: `Brige Dev Environment`
   - Typ: Linux
   - Version: Ubuntu (64-bit)

3. **VM-Ressourcen konfigurieren:**
   - **RAM:** 4096 MB (4 GB) Minimum, 8192 MB (8 GB) empfohlen
   - **CPU:** 2-4 Kerne
   - **Festplatte:** 50-100 GB, dynamisch zugewiesen

4. **Netzwerkeinstellungen:**
   - Adapter 1: NAT (für Internetzugang)
   - Adapter 2: Host-only Adapter (für Zugriff vom Host-Rechner)
     - Wenn Host-only-Adapter nicht existiert, erstellen Sie ihn in den VirtualBox-Einstellungen

### Mit VMware

1. **VMware Workstation Player herunterladen:**
   - https://www.vmware.com/products/workstation-player.html

2. **Neue VM erstellen:**
   - Wählen Sie "Create a New Virtual Machine"
   - Wählen Sie "I will install the operating system later"
   - Gastbetriebssystem: Linux, Ubuntu 24.04 LTS 64-bit
   - Name: `Brige Dev Environment`

3. **Ressourcen konfigurieren:**
   - Festplatte: 50-100 GB
   - Speicher: 4096-8192 MB
   - Prozessoren: 2-4

4. **Netzwerk:**
   - NAT für Internet
   - Custom: VMnet1 (Host-only) für Host-Zugriff

## Schritt 2: Ubuntu installieren

1. **Ubuntu ISO herunterladen:**
   - https://ubuntu.com/download/server
   - Wählen Sie Ubuntu 24.04 LTS (Server ISO)

2. **Ubuntu in VM installieren:**
   - ISO an VM anhängen
   - Von ISO booten
   - Installationsassistenten folgen
   - **Wichtig:** Installieren Sie SSH-Server während der Installation
   - Benutzerkonto erstellen (Anmeldedaten merken)

3. **Nach der Installation:**
   - System aktualisieren: `sudo apt update && sudo apt upgrade -y`
   - Wesentliche Tools installieren: `sudo apt install -y curl wget git vim`

## Schritt 3: Docker installieren

Folgen Sie denselben Docker-Installationsschritten wie in [INSTALL_de.md](INSTALL_de.md):

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
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Repository einrichten
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker Engine installieren
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Benutzer zur docker-Gruppe hinzufügen
sudo usermod -aG docker $USER

# Ab- und wieder anmelden, dann überprüfen
docker --version
docker compose version
```

## Schritt 4: Infrastrukturdateien übertragen

### Option A: Mit Git (Empfohlen)

```bash
# In VM
cd ~
git clone <your-repo-url> brige.de
cd brige.de/infrastructure
```

### Option B: Mit SCP vom Host

```bash
# Vom Host-Rechner
scp -r infrastructure/ user@vm-ip:~/
```

### Option C: Mit gemeinsamem Ordner (VirtualBox)

1. VirtualBox Guest Additions in VM installieren
2. In VirtualBox-Einstellungen gemeinsamen Ordner hinzufügen, der auf Ihr Projektverzeichnis zeigt
3. In VM mounten: `sudo mount -t vboxsf <share-name> /mnt/share`

## Schritt 5: Entwicklungsumgebung konfigurieren

1. **Umgebungsvorlage kopieren:**
```bash
cd infrastructure
cp env.dev.template .env.dev
```

2. **Konfiguration bearbeiten:**
```bash
nano .env.dev
```

Entwicklungspasswörter setzen (können einfacher sein als in der Produktion, aber dennoch sicher).

3. **Skripte ausführbar machen:**
```bash
chmod +x scripts/*.sh
```

## Schritt 6: Entwicklungsservices bereitstellen

```bash
./scripts/deploy-dev.sh
```

Oder direkt mit docker-compose:
```bash
docker-compose -f docker-compose.dev.yml --env-file .env.dev up -d
```

## Schritt 7: Host-Rechner konfigurieren

### VM-IP-Adresse finden

In VM ausführen:
```bash
ip addr show
```

Suchen Sie nach IP im Host-only-Netzwerkadapter (normalerweise `192.168.x.x`).

### Hosts-Datei konfigurieren

**Linux/Mac:**
```bash
sudo nano /etc/hosts
```

**Windows:**
```cmd
notepad C:\Windows\System32\drivers\etc\hosts
```

Hinweis: Da wir IP-Adressen anstelle von Domänennamen verwenden, können Sie direkt über IP und Port auf Services zugreifen.

## Schritt 8: Auf Services zugreifen

Nach der Bereitstellung sind Services verfügbar unter (VM-IP: 192.168.1.200):

- **Keycloak:** http://192.168.1.200:8080 oder https://192.168.1.200
- **MinIO Console:** http://192.168.1.200:9001 oder https://192.168.1.200
- **MinIO API:** http://192.168.1.200:9000
- **Prometheus:** http://192.168.1.200:9090 oder https://192.168.1.200
- **Grafana:** http://192.168.1.200:3000 oder https://192.168.1.200

## Entwicklungs-Workflow

### Services starten
```bash
cd infrastructure
docker-compose -f docker-compose.dev.yml --env-file .env.dev up -d
```

### Services stoppen
```bash
docker-compose -f docker-compose.dev.yml --env-file .env.dev down
```

### Logs anzeigen
```bash
docker-compose -f docker-compose.dev.yml --env-file .env.dev logs -f [service_name]
```

### Service neu starten
```bash
docker-compose -f docker-compose.dev.yml --env-file .env.dev restart [service_name]
```

### Auf Services vom Host zugreifen

Services sind von Ihrem Host-Rechner aus über die in `/etc/hosts` konfigurierten Domains erreichbar.

## Unterschiede zur Produktion

1. **Selbstsignierte SSL-Zertifikate** (für Entwicklung akzeptabel)
2. **HTTP erlaubt** (zusätzlich zu HTTPS)
3. **Separate Datenvolumes** (mit Präfix `_dev`)
4. **Separates Netzwerk** (`brige-network-dev`)
5. **Verschiedene Containernamen** (mit Suffix `-dev`)

## Fehlerbehebung

### Kann nicht vom Host auf Services zugreifen

1. **VM-IP-Adresse überprüfen:**
   ```bash
   # In VM
   ip addr show
   ```

2. **Hosts-Datei** auf Host-Rechner überprüfen

3. **Firewall** in VM überprüfen:
   ```bash
   sudo ufw status
   # Falls nötig, Ports erlauben:
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   ```

### Services starten nicht

1. **Logs überprüfen:**
   ```bash
   docker-compose -f docker-compose.dev.yml --env-file .env.dev logs
   ```

2. **Festplattenspeicher überprüfen:**
   ```bash
   df -h
   ```

3. **Speicher überprüfen:**
   ```bash
   free -h
   ```

### VM ist langsam

- Zugewiesenen RAM erhöhen
- CPU-Kerne erhöhen
- Hardwarebeschleunigung in VM-Einstellungen aktivieren
- Unnötige Anwendungen auf Host schließen

## Best Practices

1. **Regelmäßige Snapshots:** Erstellen Sie VM-Snapshots vor größeren Änderungen
2. **Daten sichern:** Sichern Sie Entwicklungsdaten regelmäßig
3. **Aktuell halten:** Aktualisieren Sie VM und Docker regelmäßig
4. **Daten trennen:** Mischen Sie niemals Dev- und Prod-Daten
5. **Lokal testen:** Testen Sie Änderungen immer in Dev vor dem Bereitstellen in Prod

## Nächste Schritte

1. Keycloak-Realm für Entwicklung konfigurieren
2. MinIO-Buckets mit Testdaten einrichten
3. Grafana-Dashboards konfigurieren
4. Beginnen Sie mit der Entwicklung Ihrer Anwendung!

---

**Sprachen:** [English](DEVELOPMENT.md) | [Русский](DEVELOPMENT_ru.md) | [Deutsch](DEVELOPMENT_de.md)
