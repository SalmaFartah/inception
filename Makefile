yaml_path = srcs/docker-compose.yml

all:
	@mkdir -p ~/data/wordpress ~/data/mariadb
<<<<<<< HEAD
	@docker compose --file $(yaml_path) up --build -d

down:
	@docker compose --file $(yaml_path) down

#stop containers and remove them
clean:
	@docker compose --file $(yaml_path) down -v --rmi all

#stop containers and remove them and also remove volumes, images // full reset
#--rmi		Remove images used by services. "local" remove only images that don't have a custom tag ("local"|"all")
fclean:
=======
	@docker compose --file $(yaml_path) up --build

# stop and remove containers, images, volumes, and data in host
clean:
	@docker compose --file $(yaml_path) down -v --rmi all
	@sudo rm -rf ~/data

# stop and remove containers, images, volumes, data in host, networks, and also cached layers
fclean: clean
>>>>>>> structured
	@docker system prune -af
	@sudo rm -rf ~/data

re: fclean all

<<<<<<< HEAD
.PHPNY: all clean fclean re
=======
re_cach: clean all

.PHONY: all clean fclean re
>>>>>>> structured
