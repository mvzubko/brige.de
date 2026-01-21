# Инфраструктура Brige

Настройка инфраструктуры для системы управления сервисом Brige на VPS с Debian.

**Языки:** [English](README.md) | [Русский](README_ru.md) | [Deutsch](README_de.md)

## Быстрый старт

1. **Установите Docker и Docker Compose на VPS:**
   См. подробные инструкции в [INSTALL.md](INSTALL.md) | [INSTALL_ru.md](INSTALL_ru.md) | [INSTALL_de.md](INSTALL_de.md)

2. **Скопируйте файл конфигурации:**
```bash
cd infrastructure
cp env.template .env
```

3. **Отредактируйте `.env` и установите надежные пароли:**
```bash
nano .env
```

4. **Запустите развертывание:**
```bash
chmod +x scripts/*.sh
./scripts/deploy.sh
```

Или используйте Makefile:
```bash
make deploy
```

## Сервисы

После развертывания будут доступны следующие сервисы:

- **PostgreSQL** (порт 5432) - Основная база данных
- **Redis** (порт 6379) - Кэш и хранение сессий
- **MinIO** (порты 9000, 9001) - Объектное хранилище для медиафайлов
- **Keycloak** (порт 8080) - Управление идентификацией и доступом
- **Prometheus** (порт 9090) - Сбор метрик
- **Grafana** (порт 3000) - Визуализация метрик
- **Nginx** (порты 80, 443) - Обратный прокси и SSL

## Управление

### Просмотр логов
```bash
docker-compose logs -f [имя_сервиса]
# или
make logs SERVICE=postgres
```

### Остановка сервисов
```bash
docker-compose down
# или
make stop
```

### Запуск сервисов
```bash
docker-compose up -d
# или
make start
```

### Резервное копирование
```bash
./scripts/backup.sh
# или
make backup
```

### Восстановление из резервной копии
```bash
./scripts/restore.sh YYYYMMDD_HHMMSS
# или
make restore TIMESTAMP=YYYYMMDD_HHMMSS
```

## SSL сертификаты

Для разработки скрипт развертывания автоматически создает самоподписанные сертификаты.

Для продакшена используйте Let's Encrypt (см. [INSTALL.md](INSTALL.md) | [INSTALL_ru.md](INSTALL_ru.md) | [INSTALL_de.md](INSTALL_de.md)).

## DNS настройка

Сервисы доступны напрямую по IP адресу и порту (IP VPS: 57.128.239.26):

- **Keycloak:** http://57.128.239.26:8080 или https://57.128.239.26
- **MinIO Console:** http://57.128.239.26:9001 или https://57.128.239.26
- **MinIO API:** http://57.128.239.26:9000
- **Prometheus:** http://57.128.239.26:9090 или https://57.128.239.26
- **Grafana:** http://57.128.239.26:3000 или https://57.128.239.26

## Первоначальная настройка

### Keycloak

1. Откройте http://57.128.239.26:8080 или https://57.128.239.26
2. Войдите с учетными данными администратора из `.env`
3. Создайте realm для Brige
4. Настройте клиентов и пользователей

### MinIO

1. Откройте http://57.128.239.26:9001 или https://57.128.239.26
2. Войдите с root учетными данными из `.env`
3. Создайте buckets:
   - `brige-media` - для загруженных изображений и документов
   - `brige-reports` - для сгенерированных отчетов

### Grafana

1. Откройте http://57.128.239.26:3000 или https://57.128.239.26
2. Войдите с учетными данными администратора из `.env`
3. Источник данных Prometheus предварительно настроен
4. Импортируйте или создайте дашборды

## Безопасность

1. **Измените все пароли по умолчанию** в файле `.env`
2. **Используйте надежные пароли** (минимум 16 символов, смешанный регистр, цифры, символы)
3. **Настройте файрвол** - откройте только порты 80, 443 и SSH (22)
4. **Обновляйте Docker регулярно**
5. **Настройте автоматические резервные копии**
6. **Мониторьте логи** - проверяйте на подозрительную активность

## Окружения

Инфраструктура поддерживает два окружения:

- **Продакшн:** Развертывание на VPS сервере (см. [INSTALL.md](INSTALL.md))
- **Разработка:** Локальная виртуальная машина для разработки (см. [DEVELOPMENT.md](DEVELOPMENT.md))

## Установка

- **Настройка продакшн:** [INSTALL.md](INSTALL.md) | [INSTALL_ru.md](INSTALL_ru.md) | [INSTALL_de.md](INSTALL_de.md)
- **Настройка разработки:** [DEVELOPMENT.md](DEVELOPMENT.md) | [DEVELOPMENT_ru.md](DEVELOPMENT_ru.md) | [DEVELOPMENT_de.md](DEVELOPMENT_de.md)

## Следующие шаги

1. Настройте Keycloak realm и клиентов
2. Настройте MinIO buckets и политики доступа
3. Настройте Prometheus алерты
4. Создайте Grafana дашборды
5. Настройте автоматические резервные копии (cron job)
6. Настройте мониторинг алертов

## Структура проекта

```
infrastructure/
├── docker-compose.yml      # Конфигурация всех сервисов
├── env.template            # Шаблон переменных окружения
├── .env                    # Ваши настройки (не в git)
├── nginx/                  # Конфигурация Nginx
│   ├── nginx.conf
│   ├── conf.d/
│   └── ssl/                # SSL сертификаты
├── prometheus/             # Конфигурация Prometheus
├── grafana/                # Конфигурация Grafana
├── init-scripts/           # SQL скрипты для инициализации БД
├── scripts/                # Скрипты управления
│   ├── deploy.sh
│   ├── backup.sh
│   └── restore.sh
├── Makefile                # Удобные команды
├── README.md               # Документация (EN)
├── README_ru.md            # Документация (RU)
├── README_de.md            # Документация (DE)
├── INSTALL.md              # Инструкция по установке (EN)
├── INSTALL_ru.md           # Инструкция по установке (RU)
└── INSTALL_de.md           # Инструкция по установке (DE)
```

## Полезные команды

```bash
# Показать статус всех сервисов
make status

# Обновить все образы и перезапустить
make update

# Очистить все (осторожно!)
make clean

# Просмотр логов конкретного сервиса
make logs SERVICE=postgres
```

## Поддержка

При возникновении проблем:

1. Проверьте логи: `docker-compose logs`
2. Проверьте статус: `docker-compose ps`
3. Проверьте дисковое пространство: `df -h`
4. Проверьте документацию в [INSTALL.md](INSTALL.md) | [INSTALL_ru.md](INSTALL_ru.md) | [INSTALL_de.md](INSTALL_de.md)

---

**Языки:** [English](README.md) | [Русский](README_ru.md) | [Deutsch](README_de.md)
