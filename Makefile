yaml_path = srcs/docker-compose.yml

all:
	@mkdir -p ~/data/wordpress ~/data/mariadb
	@docker compose --file $(yaml_path) up --build -d

down:
	@docker compose --file $(yaml_path) down

# stop and remove containers, images, volumes, and data in host
clean:
	@docker compose --file $(yaml_path) down -v --rmi all
	@sudo rm -rf ~/data

# stop and remove containers, images, volumes, data in host, networks, and also cached layers
fclean: clean
	@docker system prune -af
	@sudo rm -rf ~/data

re: fclean all

re_cach: clean all

.PHONY: all clean fclean re
