COMPOSE ?= docker compose

.PHONY: up down logs reset

up:
	$(COMPOSE) up --build

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f --tail=200

reset:
	$(COMPOSE) down -v --remove-orphans
