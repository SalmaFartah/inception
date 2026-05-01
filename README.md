*This project has been created as part of the 42 curriculum by sfartah.*

---

# Inception

> A Docker-based infrastructure project — setting up a small but complete web stack using NGINX, WordPress, and MariaDB, all orchestrated with Docker Compose inside a Virtual Machine.

---

## Description

**Inception** is a system administration project from the 42 curriculum. The goal is to deepen your understanding of containerization by building a multi-service infrastructure entirely from scratch using **Docker** and **Docker Compose**.

Instead of using pre-made images from DockerHub, every service is built from a custom `Dockerfile` based on either the penultimate stable version of **Alpine** or **Debian**. The result is a fully functional, secure, and production-minded web stack.

### Services included

#### Mandatory

| Container | Role |
|---|---|
| **NGINX** | HTTPS reverse proxy — the sole entry point via port 443 (TLSv1.2/1.3) |
| **WordPress + php-fpm** | The web application, running without NGINX inside its container |
| **MariaDB** | The relational database backend for WordPress |

#### Bonus

| Container | Role |
|---|---|
| **Redis** | In-memory cache layer for WordPress (object caching) |
| **FTP Server** (vsftpd) | FTP access to the WordPress volume files |
| **Static Website** | A simple static site served on its own port (no PHP) |
| **Adminer** | Lightweight web-based database management UI |
| **Portainer** | Docker container management dashboard (custom choice) |

Persistent data is stored on the host machine under `~/data/wordpress` and `~/data/mariadb`, mounted into containers via Docker named volumes.

All containers communicate through a custom **Docker bridge network** and are configured to **restart automatically** in case of a crash.

---

## Instructions

### Requirements

- **Docker and Docker compose**
- **Make**
- **Git**
- **openssl** (for generating the self-signed TLS certificate)

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/SalmaFartah/inception
cd inception
```

**2. Create the secrets files** (never committed to Git)

```bash
mkdir -p secrets
echo "your_db_user_password"  > secrets/db_password.txt
echo "your_db_root_password"  > secrets/db_root_password.txt
echo "your_wp_admin_password" > secrets/wp_admin_pass.txt
echo "your_wp_user_password"  > secrets/wp_pass.txt
```

**3. Configure the environment file**

Create `srcs/.env` — passwords are intentionally absent here, they live exclusively in `secrets/`:

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

> Replace `login` with your actual 42 username. The `WP_ADMIN` value must not contain `admin` or `administrator`.

**4. Add your domain to `/etc/hosts`**

```bash
echo "127.0.0.1   login.42.fr" | sudo tee -a /etc/hosts
```

### Build and run

```bash
make
```

The Makefile automatically creates `~/data/wordpress` and `~/data/mariadb` on the host, then builds all Docker images and starts all containers.

### Access the site

Open your browser and go to:

```
https://login.42.fr
```

Accept the self-signed certificate warning. <br>The admin panel is at:

```
https://login.42.fr/wp-admin
```

Log in with the username set in `WP_ADMIN` and the password from `secrets/wp_admin_pass.txt`.

### Bonus service access

| Service | URL | Port |
|---|---|---|
| Static website | `https://login.42.fr:3000` | 3000 |
| Adminer | `https://login.42.fr:8080` | 8080 |
| Portainer | `https://login.42.fr:9443` | 9443 |
| FTP Server | `ftp://login.42.fr` | 21 |
| Redis | Internal only (used by WordPress) | 6379 |

> Ports may differ depending on your `docker-compose.yml` configuration.

### Makefile targets

| Target | Description |
|---|---|
| `make` / `make all` | Create data dirs, build images, and start all containers |
| `make clean` | Stop containers, remove volumes, images, and `~/data` |
| `make fclean` | `clean` + full Docker system prune (`docker system prune -af`) |
| `make re` | `fclean` followed by `all` — full rebuild from scratch |

---

## Project Description

### Use of Docker and project sources

This project uses **Docker Compose** to orchestrate all services, each defined by its own `Dockerfile` located under `srcs/requirements/`. No pre-built images are pulled from DockerHub — every image is built locally. The `Makefile` at the project root drives the entire build process.

Non-sensitive configuration is stored in `srcs/.env` and injected into containers as environment variables. **All passwords** are stored exclusively as plaintext files inside the `secrets/` folder at the repository root and mounted into containers as Docker secrets — never embedded in any `Dockerfile` or passed as plain environment variables.

```
secrets/
├── db_password.txt       ← MariaDB user password (MARIADB_USER)
├── db_root_password.txt  ← MariaDB root password
├── wp_admin_pass.txt     ← WordPress admin password (WP_ADMIN)
└── wp_pass.txt           ← WordPress regular user password (WP_USER)
```

### Bonus services description

Each bonus service runs in its own dedicated container with its own `Dockerfile` inside `srcs/requirements/bonus/`.

- **Redis** — An in-memory key-value store used as a WordPress object cache. Connected via the internal Docker network using `REDIS_HOST` and `REDIS_PORT` from `.env`. Reduces database queries and speeds up page loads significantly.

- **FTP Server (vsftpd)** — A lightweight FTP server that mounts the same WordPress volume, allowing direct file management of the WordPress installation.

- **Static Website** — A simple portfolio/showcase site built with plain HTML and CSS (no PHP), served completely independently from the WordPress stack.

- **Adminer** — A single-file database management web application. Connects to the MariaDB container over the internal network using `MARIADB_USER` and `MARIADB_DATABASE` from `.env`.

- **Portainer** — A web-based Docker management dashboard chosen as the custom bonus service because it provides real-time visibility into all running containers, volumes, networks, and images — making the infrastructure easier to monitor and debug.

### Main design choices

- **Base image:** Debian bookworm (penultimate stable) — chosen for its wider package availability and easier debugging.
- **TLS:** Self-signed certificate generated with `openssl` at build time, enforcing TLSv1.2/TLSv1.3 only in NGINX.
- **php-fpm:** WordPress communicates with NGINX over a TCP socket; no web server runs inside the WordPress container.
- **Restart policy:** `restart: always` ensures containers recover from crashes automatically.
- **PID 1:** Each container runs its main process as PID 1 directly (e.g., `php-fpm -F`, `nginx -g "daemon off;"`, `mysqld`) to handle signals correctly.
- **Secrets vs `.env`:** Passwords live only in `secrets/` files. The `.env` holds only non-sensitive config — usernames, domain name, site title, and Redis connection info.

---

### Virtual Machines vs Docker

| | Virtual Machine | Docker Container |
|---|---|---|
| **Isolation** | Full OS-level isolation via hypervisor | Process-level isolation via Linux namespaces & cgroups |
| **Resources** | Heavy — each VM runs a full kernel | Lightweight — shares the host kernel |
| **Startup time** | Minutes | Seconds |
| **Portability** | VM image is large and hypervisor-dependent | Image is small and runs anywhere Docker is installed |
| **Use case** | Strong security boundaries, full OS control | Microservices, reproducible deployments, CI/CD |

In this project, Docker containers run **inside** a VM — combining the security boundary of a VM with the lightweight, reproducible nature of containers.

---

### Secrets vs Environment Variables

| | Docker Secrets | Environment Variables |
|---|---|---|
| **Storage** | Mounted as a file in `/run/secrets/` inside the container | Passed directly into the container environment |
| **Visibility** | Not visible via `docker inspect` or `ps` | May appear in `docker inspect` output |
| **Security** | More secure — only accessible by the specific container | Less secure — risk of leakage via logs or inspection |
| **Best for** | Passwords, API keys, certificates | Non-sensitive config (domain, usernames, ports, etc.) |

In this project, all passwords (`db_password.txt`, `db_root_password.txt`, `wp_admin_pass.txt`, `wp_pass.txt`) are Docker secrets. Everything else goes in `srcs/.env`.

---

### Docker Network vs Host Network

| | Docker Bridge Network | Host Network |
|---|---|---|
| **Isolation** | Containers are isolated in their own virtual network | Container shares the host's network stack directly |
| **Communication** | Containers reach each other by service name (DNS) | Container uses host ports — no isolation |
| **Security** | Only explicitly exposed ports are reachable from outside | All container ports are accessible from the host |
| **Usage in subject** | ✅ Required — custom bridge network | ❌ Forbidden by the subject |

Using a custom bridge network means `wordpress` can reach `mariadb:3306` and `redis:6379` by container name without exposing those ports externally.

---

### Docker Volumes vs Bind Mounts

| | Docker Named Volumes | Bind Mounts |
|---|---|---|
| **Managed by** | Docker — stored in Docker's internal storage area | You — mapped directly to a host path |
| **Portability** | More portable, path abstracted by Docker | Tied to a specific host filesystem path |
| **Permissions** | Docker manages ownership automatically | Host file permissions apply directly |
| **Use case** | Production persistent data (databases, uploads) | Development (live code editing) |
| **In this project** | ✅ Required for both `mariadb` and `wordpress` volumes | ❌ Forbidden by the subject for these volumes |

Named volumes store data at `~/data/mariadb` and `~/data/wordpress` on the host. These directories are created automatically by `make all` before the stack starts.

---

## Resources

### Documentation & references

- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress CLI (WP-CLI)](https://wp-cli.org/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [php-fpm configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [Docker secrets overview](https://docs.docker.com/engine/swarm/secrets/)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Understanding PID 1 in Docker containers](https://cloud.google.com/architecture/best-practices-for-building-containers#signal-handling)
- [TLS configuration in NGINX](https://nginx.org/en/docs/http/ngx_http_ssl_module.html)
- [openssl self-signed certificate](https://www.openssl.org/docs/man1.1.1/man1/req.html)
- [Redis documentation](https://redis.io/docs/)
- [WordPress Redis Object Cache plugin](https://wordpress.org/plugins/redis-cache/)
- [vsftpd documentation](https://security.appspot.com/vsftpd.html)
- [Adminer documentation](https://www.adminer.org/)
- [Portainer documentation](https://docs.portainer.io/)

### How AI was used in this project

AI tools were used as a **learning assistant and productivity aid** during this project, in accordance with the 42 AI usage policy:

| Task | How AI was used |
|---|---|
| **Understanding concepts** | Asked for explanations of Docker networking, volumes, PID 1, and TLS configuration to build foundational understanding before writing any code |
| **Dockerfile structure** | Used AI to get a starting outline, then reviewed, questioned, and rewrote each instruction manually to fully understand it |
