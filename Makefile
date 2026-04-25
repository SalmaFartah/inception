yaml_path = srcs/docker-compose.yml

all:
	@mkdir -p ~/data/wordpress ~/data/mariadb
	@docker compose --file $(yaml_path) up --build -d

down:
	@docker compose --file $(yaml_path) down

#stop containers and remove them
clean:
	@docker compose --file $(yaml_path) down -v --rmi all

#stop containers and remove them and also remove volumes, images // full reset
#--rmi		Remove images used by services. "local" remove only images that don't have a custom tag ("local"|"all")
fclean:
	@docker system prune -af
	@sudo rm -rf ~/data

re: fclean all

.PHPNY: all clean fclean re