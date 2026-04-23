#!/bin/bash

docker stop mariadb nginx wordpress

docker compose down -v

docker rmi $(docker image ls -aq) #remove images

sudo rm -rf /home/sfartah/data/mariadb/* /home/sfartah/data/wordpress/* #remove host volume

