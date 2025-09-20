COMPOSE = docker compose -f srcs/docker-compose.yml

.PHONY: build up down logs clean fclean re

build:
	$(COMPOSE) build mariadb wordpress nginx static_site adminer

up:
	$(COMPOSE) up -d mariadb wordpress nginx static_site adminer

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f mariadb wordpress nginx static_site adminer

clean:
	$(COMPOSE) down -v

fclean: down
	sudo rm -rf /home/neleon/data/mariadb/*
	sudo rm -rf /home/neleon/data/wordpress/*

re: fclean build up
