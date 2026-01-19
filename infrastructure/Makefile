.PHONY: help deploy deploy-dev start start-dev stop stop-dev restart restart-dev logs logs-dev status status-dev backup restore clean update

help:
	@echo "Brige Infrastructure Management"
	@echo ""
	@echo "Production commands:"
	@echo "  make deploy     - Deploy production services"
	@echo "  make start      - Start production services"
	@echo "  make stop       - Stop production services"
	@echo "  make restart    - Restart production services"
	@echo "  make logs       - View production logs (use SERVICE=name for specific service)"
	@echo "  make status     - Show production service status"
	@echo ""
	@echo "Development commands:"
	@echo "  make deploy-dev - Deploy development services"
	@echo "  make start-dev  - Start development services"
	@echo "  make stop-dev   - Stop development services"
	@echo "  make restart-dev- Restart development services"
	@echo "  make logs-dev   - View development logs (use SERVICE=name for specific service)"
	@echo "  make status-dev - Show development service status"
	@echo ""
	@echo "Common commands:"
	@echo "  make backup     - Create backup"
	@echo "  make restore    - Restore from backup (use TIMESTAMP=value)"
	@echo "  make clean      - Stop and remove all containers and volumes"
	@echo "  make update     - Pull latest images and restart services"

deploy:
	@./scripts/deploy.sh

deploy-dev:
	@./scripts/deploy-dev.sh

start:
	docker-compose up -d

start-dev:
	docker-compose -f docker-compose.dev.yml --env-file .env.dev up -d

stop:
	docker-compose down

stop-dev:
	docker-compose -f docker-compose.dev.yml --env-file .env.dev down

restart:
	docker-compose restart

restart-dev:
	docker-compose -f docker-compose.dev.yml --env-file .env.dev restart

logs:
	@if [ -z "$(SERVICE)" ]; then \
		docker-compose logs -f; \
	else \
		docker-compose logs -f $(SERVICE); \
	fi

logs-dev:
	@if [ -z "$(SERVICE)" ]; then \
		docker-compose -f docker-compose.dev.yml --env-file .env.dev logs -f; \
	else \
		docker-compose -f docker-compose.dev.yml --env-file .env.dev logs -f $(SERVICE); \
	fi

status:
	docker-compose ps

status-dev:
	docker-compose -f docker-compose.dev.yml --env-file .env.dev ps

backup:
	@./scripts/backup.sh

restore:
	@if [ -z "$(TIMESTAMP)" ]; then \
		echo "Usage: make restore TIMESTAMP=YYYYMMDD_HHMMSS"; \
		./scripts/restore.sh; \
	else \
		./scripts/restore.sh $(TIMESTAMP); \
	fi

clean:
	docker-compose down -v
	docker system prune -f

update:
	docker-compose pull
	docker-compose up -d
