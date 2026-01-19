# Настройка окружения разработки

Это руководство объясняет, как настроить локальное окружение разработки с использованием виртуальной машины, которая зеркалирует настройку продакшн VPS.

**Языки:** [English](DEVELOPMENT.md) | [Русский](DEVELOPMENT_ru.md) | [Deutsch](DEVELOPMENT_de.md)

## Обзор

Окружение разработки работает на локальной виртуальной машине с той же конфигурацией, что и продакшн VPS. Это обеспечивает:
- Полную изоляцию от продакшн
- Быстрые циклы разработки
- Возможность разработки офлайн
- Идентичное окружение с продакшн

## Требования

- Программное обеспечение для виртуализации:
  - **VirtualBox** (бесплатно, кроссплатформенно) - Рекомендуется
  - **VMware Workstation Player** (бесплатно для личного использования)
  - **Hyper-V** (только Windows Pro/Enterprise)
- Минимум 8 GB RAM на хостовой машине
- 50-100 GB свободного места на диске

## Шаг 1: Создание виртуальной машины

### Использование VirtualBox

1. **Скачайте и установите VirtualBox:**
   - https://www.virtualbox.org/wiki/Downloads

2. **Создайте новую VM:**
   - Имя: `Brige Dev Environment`
   - Тип: Linux
   - Версия: Debian (64-bit)

3. **Настройте ресурсы VM:**
   - **RAM:** 4096 MB (4 GB) минимум, 8192 MB (8 GB) рекомендуется
   - **CPU:** 2-4 ядра
   - **Жесткий диск:** 50-100 GB, динамически выделяемый

4. **Настройки сети:**
   - Адаптер 1: NAT (для доступа в интернет)
   - Адаптер 2: Host-only Adapter (для доступа с хостовой машины)
     - Если Host-only адаптер не существует, создайте его в настройках VirtualBox

### Использование VMware

1. **Скачайте VMware Workstation Player:**
   - https://www.vmware.com/products/workstation-player.html

2. **Создайте новую VM:**
   - Выберите "Create a New Virtual Machine"
   - Выберите "I will install the operating system later"
   - Гостевая ОС: Linux, Debian 11.x 64-bit
   - Имя: `Brige Dev Environment`

3. **Настройте ресурсы:**
   - Диск: 50-100 GB
   - Память: 4096-8192 MB
   - Процессоры: 2-4

4. **Сеть:**
   - NAT для интернета
   - Custom: VMnet1 (Host-only) для доступа с хоста

## Шаг 2: Установка Debian

1. **Скачайте Debian ISO:**
   - https://www.debian.org/download
   - Выберите Debian 11 или 12 (netinst ISO)

2. **Установите Debian в VM:**
   - Подключите ISO к VM
   - Загрузитесь с ISO
   - Следуйте мастеру установки
   - **Важно:** Установите SSH сервер во время установки
   - Создайте учетную запись пользователя (запомните учетные данные)

3. **После установки:**
   - Обновите систему: `sudo apt update && sudo apt upgrade -y`
   - Установите необходимые инструменты: `sudo apt install -y curl wget git vim`

## Шаг 3: Установка Docker

Следуйте тем же шагам установки Docker, что и в [INSTALL_ru.md](INSTALL_ru.md):

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

# Добавить пользователя в группу docker
sudo usermod -aG docker $USER

# Выйдите и войдите снова, затем проверьте
docker --version
docker compose version
```

## Шаг 4: Передача файлов инфраструктуры

### Вариант A: Использование Git (Рекомендуется)

```bash
# В VM
cd ~
git clone <your-repo-url> brige.de
cd brige.de/infrastructure
```

### Вариант B: Использование SCP с хоста

```bash
# С хостовой машины
scp -r infrastructure/ user@vm-ip:~/
```

### Вариант C: Использование общей папки (VirtualBox)

1. Установите VirtualBox Guest Additions в VM
2. В настройках VirtualBox добавьте общую папку, указывающую на директорию проекта
3. Смонтируйте в VM: `sudo mount -t vboxsf <share-name> /mnt/share`

## Шаг 5: Настройка окружения разработки

1. **Скопируйте шаблон окружения:**
```bash
cd infrastructure
cp env.dev.template .env.dev
```

2. **Отредактируйте конфигурацию:**
```bash
nano .env.dev
```

Установите пароли для разработки (могут быть проще, чем для продакшн, но все равно безопасными).

3. **Сделайте скрипты исполняемыми:**
```bash
chmod +x scripts/*.sh
```

## Шаг 6: Развертывание сервисов разработки

```bash
./scripts/deploy-dev.sh
```

Или используя docker-compose напрямую:
```bash
docker-compose -f docker-compose.dev.yml --env-file .env.dev up -d
```

## Шаг 7: Настройка хостовой машины

### Найдите IP адрес VM

В VM выполните:
```bash
ip addr show
```

Найдите IP в адаптере host-only сети (обычно `192.168.x.x`).

### Настройте файл hosts

**Linux/Mac:**
```bash
sudo nano /etc/hosts
```

**Windows:**
```cmd
notepad C:\Windows\System32\drivers\etc\hosts
```

Добавьте эти строки (замените `<VM_IP>` на реальный IP VM):
```
<VM_IP>  dev.brige.de
<VM_IP>  keycloak.dev.brige.de
<VM_IP>  minio.dev.brige.de
<VM_IP>  minio-api.dev.brige.de
<VM_IP>  prometheus.dev.brige.de
<VM_IP>  grafana.dev.brige.de
<VM_IP>  api.dev.brige.de
<VM_IP>  service.dev.brige.de
```

## Шаг 8: Доступ к сервисам

После развертывания сервисы доступны по адресам:

- **Keycloak:** http://keycloak.dev.brige.de (или https)
- **MinIO Console:** http://minio.dev.brige.de (или https)
- **Prometheus:** http://prometheus.dev.brige.de (или https)
- **Grafana:** http://grafana.dev.brige.de (или https)

## Рабочий процесс разработки

### Запуск сервисов
```bash
cd infrastructure
docker-compose -f docker-compose.dev.yml --env-file .env.dev up -d
```

### Остановка сервисов
```bash
docker-compose -f docker-compose.dev.yml --env-file .env.dev down
```

### Просмотр логов
```bash
docker-compose -f docker-compose.dev.yml --env-file .env.dev logs -f [service_name]
```

### Перезапуск сервиса
```bash
docker-compose -f docker-compose.dev.yml --env-file .env.dev restart [service_name]
```

### Доступ к сервисам с хоста

Сервисы доступны с вашей хостовой машины, используя домены, настроенные в `/etc/hosts`.

## Отличия от продакшн

1. **Самоподписанные SSL сертификаты** (приемлемо для разработки)
2. **HTTP разрешен** (в дополнение к HTTPS)
3. **Отдельные тома данных** (с префиксом `_dev`)
4. **Отдельная сеть** (`brige-network-dev`)
5. **Разные имена контейнеров** (с суффиксом `-dev`)

## Устранение неполадок

### Не могу получить доступ к сервисам с хоста

1. **Проверьте IP адрес VM:**
   ```bash
   # В VM
   ip addr show
   ```

2. **Проверьте файл hosts** на хостовой машине

3. **Проверьте файрвол** в VM:
   ```bash
   sudo ufw status
   # Если нужно, разрешите порты:
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   ```

### Сервисы не запускаются

1. **Проверьте логи:**
   ```bash
   docker-compose -f docker-compose.dev.yml --env-file .env.dev logs
   ```

2. **Проверьте дисковое пространство:**
   ```bash
   df -h
   ```

3. **Проверьте память:**
   ```bash
   free -h
   ```

### VM медленная

- Увеличьте выделенную RAM
- Увеличьте количество ядер CPU
- Включите аппаратное ускорение в настройках VM
- Закройте ненужные приложения на хосте

## Лучшие практики

1. **Регулярные снимки:** Создавайте снимки VM перед крупными изменениями
2. **Резервное копирование данных:** Периодически делайте резервные копии данных разработки
3. **Держите обновленным:** Регулярно обновляйте VM и Docker
4. **Разделяйте данные:** Никогда не смешивайте данные dev и prod
5. **Тестируйте локально:** Всегда тестируйте изменения в dev перед развертыванием в prod

## Следующие шаги

1. Настройте Keycloak realm для разработки
2. Настройте MinIO buckets с тестовыми данными
3. Настройте Grafana дашборды
4. Начните разрабатывать ваше приложение!

---

**Языки:** [English](DEVELOPMENT.md) | [Русский](DEVELOPMENT_ru.md) | [Deutsch](DEVELOPMENT_de.md)
