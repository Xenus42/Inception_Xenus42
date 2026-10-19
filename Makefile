.DEFAULT_GOAL := all

ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
COMPOSE := docker compose -f $(ROOT)srcs/docker-compose.yml
DATA_DIR := /home/lebroue/data
SERVICE ?= wordpress
SECRET_NAMES := mysql_root_password mysql_wp_password wp_admin_pass wp_user_pass

.PHONY: all check build up stop down re clean ps logs shell

all: build
	mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	$(COMPOSE) up -d --no-build

check:
	@test -s "$(ROOT)srcs/.env" || { echo "Error: srcs/.env is missing or empty." >&2; exit 1; }
	@for name in $(SECRET_NAMES); do \
		test -s "$(ROOT)secrets/$$name.txt" || { \
			echo "Error: secrets/$$name.txt is missing or empty." >&2; exit 1; \
		}; \
	done
	$(COMPOSE) config --quiet

build: check
	$(COMPOSE) build

up: all

stop:
	$(COMPOSE) stop

down:
	$(COMPOSE) down

re:
	$(MAKE) down
	$(MAKE) all

clean: down

ps:
	$(COMPOSE) ps -a

logs:
	$(COMPOSE) logs --tail=100 -f

shell:
	$(COMPOSE) exec $(SERVICE) sh
