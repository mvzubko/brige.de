# Руководство по установке для Debian VPS

Это руководство поможет вам настроить инфраструктуру Brige на свежем Debian VPS.

## Шаг 1: Начальная настройка сервера

### Обновление системы
```bash
sudo apt update
sudo apt upgrade -y
```

### Установка базовых инструментов
```bash
sudo apt install -y curl wget git vim ufw
```

## Шаг 2: Установка Docker

### Установка Docker из официального репозитория
```bash
# Удалить старые версии
sudo apt remove -y docker docker-engine docker.io containerd runc

# Установить необходимые пакеты
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Добавить официальный GPG ключ Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Настроить репозиторий
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Установить Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Добавить текущего пользователя в группу docker (опционально, для запуска docker без sudo)
sudo usermod -aG docker $USER

# Проверить установку
docker --version
docker compose version
```

**Примечание:** Возможно, потребуется выйти и войти снова, чтобы изменения группы вступили в силу.

## Шаг 3: Настройка файрвола

```bash
# Разрешить SSH
sudo ufw allow 22/tcp

# Разрешить HTTP и HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Включить файрвол
sudo ufw enable

# Проверить статус
sudo ufw status
```

## Шаг 4: Клонирование репозитория

```bash
# Перейти в предпочитаемую директорию
cd /opt  # или /home/ваш-пользователь

# Клонировать репозиторий (замените URL на ваш реальный репозиторий)
git clone <your-repo-url> brige.de
cd brige.de/infrastructure
```

## Шаг 5: Настройка окружения

```bash
# Скопировать шаблон
cp env.template .env

# Редактировать конфигурацию
nano .env
```

**Важно:** Установите надежные пароли для всех сервисов!

Сгенерировать безопасные пароли:
```bash
# Сгенерировать случайный пароль (пример)
openssl rand -base64 32
```

## Шаг 6: Развертывание инфраструктуры

```bash
# Сделать скрипты исполняемыми
chmod +x scripts/*.sh

# Запустить развертывание
./scripts/deploy.sh
```

Или используя Makefile:
```bash
make deploy
```

## Шаг 7: Проверка установки

Проверить, что все сервисы запущены:
```bash
docker-compose ps
```

Все сервисы должны показывать статус "Up".

## Шаг 8: Настройка DNS

Направьте ваши доменные имена на IP-адрес VPS:

- `keycloak.brige.de` → IP вашего VPS
- `minio.brige.de` → IP вашего VPS
- `minio-api.brige.de` → IP вашего VPS
- `prometheus.brige.de` → IP вашего VPS
- `grafana.brige.de` → IP вашего VPS
- `api.brige.de` → IP вашего VPS
- `service.brige.de` → IP вашего VPS

## Шаг 9: Настройка SSL сертификатов (Продакшен)

### Вариант A: Let's Encrypt (Рекомендуется)

```bash
# Установить certbot
sudo apt install -y certbot

# Временно остановить nginx
docker-compose stop nginx

# Получить сертификаты
sudo certbot certonly --standalone \
    -d brige.de \
    -d *.brige.de \
    --email your-email@brige.de \
    --agree-tos \
    --non-interactive

# Скопировать сертификаты
sudo cp /etc/letsencrypt/live/brige.de/fullchain.pem infrastructure/nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/brige.de/privkey.pem infrastructure/nginx/ssl/key.pem

# Установить права доступа
sudo chmod 644 infrastructure/nginx/ssl/cert.pem
sudo chmod 600 infrastructure/nginx/ssl/key.pem

# Перезапустить nginx
docker-compose start nginx
```

### Вариант B: Самоподписанные (Только для разработки)

Самоподписанные сертификаты автоматически создаются скриптом развертывания для целей разработки.

## Шаг 10: Настройка автоматических резервных копий

Создать cron задачу для автоматических резервных копий:

```bash
# Редактировать crontab
crontab -e

# Добавить эту строку (запускается ежедневно в 2:00)
0 2 * * * cd /opt/brige.de/infrastructure && ./scripts/backup.sh

# Для обновления SSL сертификатов (если используете Let's Encrypt)
0 3 * * 0 certbot renew --quiet && cd /opt/brige.de/infrastructure && docker-compose restart nginx
```

## Шаг 11: Первоначальная настройка сервисов

### Keycloak

1. Откройте https://keycloak.brige.de
2. Войдите с учетными данными администратора из `.env`
3. Создайте новый realm с именем "brige"
4. Настройте клиентов для ваших приложений

### MinIO

1. Откройте https://minio.brige.de
2. Войдите с root учетными данными из `.env`
3. Создайте buckets:
   - `brige-media` - для загруженных изображений и документов
   - `brige-reports` - для сгенерированных отчетов
4. Создайте ключи доступа для приложений

### Grafana

1. Откройте https://grafana.brige.de
2. Войдите с учетными данными администратора из `.env`
3. Источник данных Prometheus предварительно настроен
4. Импортируйте или создайте дашборды для мониторинга

## Устранение неполадок

### Демон Docker не запущен
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### Ошибки прав доступа
```bash
# Добавить пользователя в группу docker
sudo usermod -aG docker $USER
# Выйти и войти снова
```

### Сервисы не запускаются
```bash
# Проверить логи
docker-compose logs

# Проверить дисковое пространство
df -h

# Проверить память
free -h
```

### Порт уже используется
```bash
# Найти процесс, использующий порт
sudo lsof -i :80
sudo lsof -i :443

# Остановить конфликтующий сервис или изменить порты в docker-compose.yml
```

## Следующие шаги

1. Настройте Keycloak realm и клиентов
2. Настройте MinIO buckets и политики доступа
3. Настройте дашборды мониторинга в Grafana
4. Настройте алерты в Prometheus
5. Настройте автоматические резервные копии
6. Проверьте настройки безопасности

## Рекомендации по безопасности

1. **Изменить SSH порт** (опционально, но рекомендуется):
   ```bash
   sudo nano /etc/ssh/sshd_config
   # Изменить Port 22 на другой порт
   sudo systemctl restart sshd
   ```

2. **Отключить вход root**:
   ```bash
   sudo nano /etc/ssh/sshd_config
   # Установить PermitRootLogin no
   sudo systemctl restart sshd
   ```

3. **Настроить fail2ban**:
   ```bash
   sudo apt install -y fail2ban
   sudo systemctl enable fail2ban
   sudo systemctl start fail2ban
   ```

4. **Регулярные обновления**:
   ```bash
   # Добавить в crontab
   0 4 * * 0 apt update && apt upgrade -y
   ```

5. **Мониторинг логов**:
   ```bash
   # Настроить ротацию логов
   sudo nano /etc/logrotate.d/docker
   ```
