# DEV_DOC.md — Developer Documentation

---

## 🛠️ Set Up the Environment from Scratch

### Prerequisites

Make sure the following are installed on your **Virtual Machine**:

| Tool | Minimum Version | Check |
|---|---|---|
| Docker Engine | 20.x+ | `docker --version` |
| Docker Compose (plugin) | 2.x+ | `docker compose version` |
| Make | any | `make --version` |
| Git | any | `git --version` |
| openssl | any | `openssl version` |

> The entire project **must run inside a Virtual Machine**, not directly on your host machine.

---

### Repository Structure

```
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── db_password.txt        ← MariaDB user password
│   ├── db_root_password.txt   ← MariaDB root password
│   ├── wp_admin_pass.txt      ← WordPress admin password
│   └── wp_pass.txt            ← WordPress regular user password
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        └── bonus/
            ├── redis/
            │   ├── Dockerfile
            │   └── conf/
            ├── ftp/
            │   ├── Dockerfile
            │   └── conf/
            ├── static-site/
            │   ├── Dockerfile
            │   └── site/
            ├── adminer/
            │   └── Dockerfile
            └── portainer/
                └── Dockerfile
```

---

### Step 1 — Clone the repository

```bash
git clone https://github.com/SalmaFartah/inception.git
cd inception
```

---

### Step 2 — Create the secrets files

These files must **never be committed to Git**. Create them manually:

```bash
mkdir -p secrets
echo "your_db_user_password"  > secrets/db_password.txt
echo "your_db_root_password"  > secrets/db_root_password.txt
echo "your_wp_admin_password" > secrets/wp_admin_pass.txt
echo "your_wp_user_password"  > secrets/wp_pass.txt
```

Make sure both `secrets/` and `srcs/.env` are listed in `.gitignore`:

```
secrets/
srcs/.env
```

---

### Step 3 — Configure the `.env` file

Create `srcs/.env`. All passwords are absent here — they live exclusively in `secrets/`:

```env
DOMAIN_NAME=login.42.fr

# MariaDB
MARIADB_DATABASE=wordpress
MARIADB_USER=wpuser

# WordPress
SITE_TITLE=My Inception Site
WP_ADMIN=wpadmin42
WP_ADMIN_EMAIL=admin@login.42.fr
WP_USER=wpeditor
WP_USER_EMAIL=editor@login.42.fr

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
```

> `WP_ADMIN` must **not** contain `admin` or `administrator` in any form.

> **Security rule:** No passwords may appear in any `Dockerfile`, `docker-compose.yml`, or `.env`. Always read them from the mounted secret files at `/run/secrets/<filename>`.

---

### Step 4 — Configure `/etc/hosts` on the VM

```bash
echo "127.0.0.1   login.42.fr" | sudo tee -a /etc/hosts
```

---

### Step 5 — Verify `.gitignore`

Confirm your `.gitignore` at minimum contains:

```
secrets/
srcs/.env
```

---

## 🚀 Build and Launch the Project

### Build all images and start containers

```bash
make
```

The `all` target does three things:
1. Creates `~/data/wordpress` and `~/data/mariadb` on the host if they don't exist.
2. Runs `docker compose --file srcs/docker-compose.yml up --build`.

All images are built from scratch — no pre-built DockerHub images are used (except Alpine/Debian as base).

### Makefile targets explained

| Target | Command(s) run | Effect |
|---|---|---|
| `make` / `make all` | `mkdir -p ~/data/wordpress ~/data/mariadb` + `docker compose up --build` | Build and start everything |
| `make down` | `docker compose down` | Stop and remove containers (volumes and data preserved) |
| `make clean` | `docker compose down -v --rmi all` + `sudo rm -rf ~/data` | Stop containers, delete volumes, images, and host data |
| `make fclean` | `clean` + `docker system prune -af` + `sudo rm -rf ~/data` | Complete Docker environment wipe |
| `make re` | `fclean` + `all` | Full teardown and rebuild |

---

## 🐳 Manage Containers and Volumes

### Useful Docker Compose commands

```bash
# Follow logs from all services
docker compose -f srcs/docker-compose.yml logs -f

# Follow logs from a specific service
docker compose -f srcs/docker-compose.yml logs -f wordpress

# Rebuild and restart a single service
docker compose -f srcs/docker-compose.yml build nginx
docker compose -f srcs/docker-compose.yml up -d nginx
```

### Useful raw Docker commands

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Enter a container shell
docker exec -it nginx sh
docker exec -it wordpress sh
docker exec -it mariadb sh
docker exec -it redis sh

# View real-time resource usage
docker stats

# Inspect the Docker network
docker network inspect inception_network

# List volumes
docker volume ls

# Inspect a volume
docker volume inspect srcs_wordpress
docker volume inspect srcs_mariadb
```

---

## 💾 Data Storage and Persistence

### Named volumes

The project uses two **Docker named volumes** (bind mounts are forbidden by the subject for these):

| Volume | Mounted in container at | Host path |
|---|---|---|
| `wordpress` volume | `/var/www/html` (wordpress, nginx) | `~/data/wordpress` |
| `mariadb` volume | `/var/lib/mysql` (mariadb) | `~/data/mariadb` |

These are declared in `docker-compose.yml` using the `local` driver with a bind device pointing to the host path:

```yaml
volumes:
  wordpress:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ~/data/wordpress

  mariadb:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ~/data/mariadb
```

### Data persistence behavior

- Data **survives container restarts** — volumes are not affected by stopping containers.
- Data is **deleted** by `make clean`, `make fclean`, and `make re` because they run `docker compose down -v` and `sudo rm -rf ~/data`.
- Containers use `restart: always`, so they recover automatically after crashes.

### Verify data on the host

```bash
ls ~/data/wordpress/
ls ~/data/mariadb/
```

---

## 🎁 Bonus Services — Developer Notes

Each bonus service has its own `Dockerfile` under `srcs/requirements/bonus/<service>/` and shares the same `docker-compose.yml` and Docker network as the mandatory services.

### Redis

Redis reads its host and port from the `.env` file via `REDIS_HOST=redis` and `REDIS_PORT=6379`. The WordPress container installs the `redis` PHP extension and the Redis Object Cache plugin is activated via WP-CLI. The following must be defined in `wp-config.php`:

```php
define('WP_REDIS_HOST', getenv('REDIS_HOST'));
define('WP_REDIS_PORT', getenv('REDIS_PORT'));
```

Verify Redis is receiving cache requests:

```bash
docker exec -it redis redis-cli monitor
```

### FTP Server (vsftpd)

The FTP container mounts the same `wordpress` volume, giving FTP users direct read/write access to WordPress files. Key vsftpd config: passive mode enabled, local users only, write access enabled. FTP credentials are managed via environment variables or secrets.

Test the FTP connection:

```bash
curl -u ftpuser:password ftp://login.42.fr/
```

### Static Website

A minimal HTML/CSS site served by a lightweight server (e.g., `nginx` without PHP, or `python3 -m http.server`). Source files live in `srcs/requirements/bonus/static-site/site/`. It has no dependency on the WordPress stack.

### Adminer

A single PHP file served by a minimal web server. It connects to the `mariadb` container using `MARIADB_USER` and `MARIADB_DATABASE` from `.env`, and the password from `secrets/db_password.txt`. No volume needed.

### Portainer

Portainer requires access to the Docker socket to monitor the stack:

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
  - portainer_data:/data
```

Access the Portainer UI at `https://login.42.fr:9443`. On first run, create an admin account through the web interface.

> **Justification for evaluators:** Portainer was chosen as the custom bonus service because it provides a real-time graphical overview of the entire Docker infrastructure — containers, volumes, networks, and images — making it a genuinely useful operational tool for monitoring and debugging the stack during both development and evaluation.

---

## 🔐 Security Notes for Developers

- **Never hardcode passwords** in any `Dockerfile`, `docker-compose.yml`, or `srcs/.env`.
- All passwords are stored in `secrets/` as plaintext files and mounted as Docker secrets. Read them inside containers from `/run/secrets/<filename>`.
- Both `secrets/` and `srcs/.env` must be in `.gitignore`. Any credential found in the Git repository outside of properly configured secrets results in automatic project failure.
- The `latest` tag is **forbidden** for base images. Always pin to a specific version (e.g., `debian:bullseye` or `alpine:3.18`).
- Use only **TLSv1.2 or TLSv1.3** in the NGINX configuration. Older protocols must be explicitly disabled.
- Do **not** use `network: host`, `--link`, or `links:` in compose — use the custom bridge network.
- Do **not** use infinite loop hacks (`tail -f`, `sleep infinity`, `while true`) as container entrypoints. Run the main process in the foreground as PID 1.
