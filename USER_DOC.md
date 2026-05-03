# USER_DOC.md — User & Administrator Documentation

---

## 📦 What Services Are Provided by the Stack?

### Mandatory services

| Service | Container Name | Role |
|---|---|---|
| **NGINX** | nginx | Reverse proxy / HTTPS entrypoint — port 443, TLSv1.2/1.3 only |
| **WordPress + php-fpm** | wordpress | Web application with PHP processing |
| **MariaDB** | mariadb | Relational database storing all WordPress data |

### Bonus services

| Service | Container Name | Role | Port |
|---|---|---|---|
| **Redis** | redis | Object cache for WordPress (speeds up page loads) | 6379 (internal) |
| **FTP Server** | ftp | FTP access to WordPress files via vsftpd | 21 |
| **Static Website** | static-site | A simple HTML/CSS showcase site | 3000 |
| **Adminer** | adminer | Web UI to browse and manage the MariaDB database | 8080 |
| **Portainer** | portainer | Docker management dashboard (custom bonus service) | 9443 |

Two **Docker named volumes** provide persistent storage:

| Volume | Content | Host Path |
|---|---|---|
| `wordpress` volume | WordPress website files | `~/data/wordpress` |
| `mariadb` volume | MariaDB database files | `~/data/mariadb` |

All containers are on the same private Docker bridge network. **NGINX is the only entry point** exposed to the outside — exclusively on port 443.

---

## ▶️ Start and Stop the Project

### Start the project

From the root of the repository (where the `Makefile` is located):

```bash
make
```

This will create the data directories, build all Docker images, and start all containers.

### Stop the project

```bash
make down
```

Stops and removes all containers

### Stop and clean the project (removes data)

```bash
make clean
```

Stops and removes all containers, volumes, images, and deletes `~/data`.

### Full reset — clean everything including Docker cache

```bash
make fclean
```

Equivalent to `make clean` plus a full `docker system prune -af`. Use this when you want a completely fresh state.

### Rebuild from scratch

```bash
make re
```

Runs `fclean` then `all` — a complete teardown and rebuild.


---

## 🌐 Access the Website and Administration Panel

### Prerequisites

Make sure your `/etc/hosts` contains:

```
127.0.0.1   login.42.fr
```

> Replace `login` with your actual 42 login.

### Access the WordPress website

```
https://login.42.fr
```

Your browser will warn about the self-signed certificate — accept the exception to proceed.

### Access the WordPress Administration Panel

```
https://login.42.fr/wp-admin
```

Log in with:
- **Username:** the value of `WP_ADMIN` in `srcs/.env`
- **Password:** the content of `secrets/wp_admin_pass.txt`

---

## 🎁 Bonus Services Access

### Static Website

```
https://login.42.fr:3000
```

A simple HTML/CSS showcase site running independently of WordPress.

### Adminer (Database Manager)

```
https://login.42.fr:8080
```

Log in with:
- **System:** MySQL
- **Server:** `mariadb`
- **Username:** value of `MARIADB_USER` from `srcs/.env`
- **Password:** content of `secrets/db_password.txt`
- **Database:** value of `MARIADB_DATABASE` from `srcs/.env`

### Portainer (Docker Dashboard)

```
https://login.42.fr:9443
```

On first access, create an admin account through the web interface. Portainer gives you a live view of all containers, volumes, networks, and images in the stack.

### FTP Server

Connect using FTP client:

Connect using FTP client:

- **Host:** `login.42.fr`
- **Port:** `21`
- **Protocol:** FTP
- **Username:** `anonymous`
- **Password:** *(leave blank or type anything — it is not checked)*

This gives you direct access to the WordPress files volume (`~/data/wordpress`).

### Redis

Redis runs internally and is used automatically by WordPress. No browser access is needed. You can verify it by this cmd
```
docker exec -it redis redis-cli DBSIZE
```
or this
```
docker exec -it redis redis-cli MONITOR
```

---

## 🔑 Locate and Manage Credentials

All credentials are stored **locally and never committed to Git**.

### Passwords — `secrets/` folder

Located at the root of the repository:

```
secrets/
├── db_password.txt       ← MariaDB user password
├── db_root_password.txt  ← MariaDB root password
├── wp_admin_pass.txt     ← WordPress admin password
└── wp_pass.txt           ← WordPress regular user password
```

### Non-sensitive configuration — `srcs/.env`

```env
DOMAIN_NAME=login.42.fr

MARIADB_DATABASE=wordpress
MARIADB_USER=wpuser

SITE_TITLE=My Inception Site
WP_ADMIN=wpadmin42
WP_ADMIN_EMAIL=admin@login.42.fr
WP_USER=wpeditor
WP_USER_EMAIL=editor@login.42.fr

REDIS_HOST=redis
REDIS_PORT=6379
```

> Both `secrets/` and `srcs/.env` must be listed in `.gitignore` and must never be pushed to any remote repository.

### Changing credentials

1. Edit the relevant file in `secrets/` or update `srcs/.env`.
2. Rebuild the entire stack: `make re`.

---

## ✅ Check That the Services Are Running Correctly

### View running containers

```bash
docker ps
```

You should see all containers listed as `Up`.

### Check container logs

```bash
# Follow logs from all services
docker compose -f srcs/docker-compose.yml logs -f

# A specific service
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
docker compose -f srcs/docker-compose.yml logs redis
```

### Verify HTTPS is working

```bash
curl -k https://login.42.fr
```

You should receive an HTML response from WordPress.

### Verify the database is reachable

```bash
docker exec -it mariadb mariadb -u root -p
# Enter the password from secrets/db_root_password.txt
```

Then inside the MariaDB shell:

```sql
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
```

### Verify Redis is caching

```bash
docker exec -it redis redis-cli ping
# Expected output: PONG

docker exec -it redis redis-cli monitor
# Watch live cache activity while browsing the site
```

### Verify data is persisted on the host

```bash
ls ~/data/wordpress/
ls ~/data/mariadb/
```

Both directories should contain data after the first run.
