*This project has been created as part of the 42 curriculum by sfartah*

<<<<<<< HEAD
# Description
## What is the project?
Inception is a system administration project from the 42 curriculum.
It consists to set up a small  infrastructure composed of different services using Docker inside a virtual machine.

## What is the goal?
This project establishes a working WordPress website served by NGINX with TLS, using MariaDB as the database, all running in separate Docker containers orchestrated by Docker Compose.

## Architecture overview:
| Service | Role |
| :--- | :--- |
| **NGINX** | The secure web server that handles all incoming traffic. |
| **WordPress** | The website builder and engine that creates the pages. |
| **MariaDB** | The database where all the website information is saved. |

## What is Docker and Why Use It?
Docker is a platform that packages applications and all their required dependencies into lightweight, isolated environments called containers.
> [!WARNING]
> Why it is used in this project: It ensures our infrastructure is modular and secure by isolating NGINX, WordPress, and MariaDB into their own environments.

=======
## 📄 Description
### ℹ️ What is the project:
- **Inception** is a system administration project from the 42 curriculum. <br> It consists to set up a small  infrastructure composed of different services using Docker inside a virtual machine.

### 🎯 What is the goal:
- This project establishes a working WordPress website served by NGINX with TLS, using MariaDB as the database, all running in separate Docker containers orchestrated by Docker Compose.

### 🏗️ Architecture overview:
| Service | Role | Key Responsibilities |
| :--- | :--- | :--- |
| **NGINX** | Reverse Proxy | The entry point for all traffic. Handles **TLS encryption (Port 443)** and routes PHP requests to WordPress via the **FastCGI** protocol. |
| **WordPress + PHP-FPM** | Website Engine | The core application. **PHP-FPM** processes the dynamic script execution and generates the HTML content for the site. |
| **MariaDB** | Database | The persistent storage layer. Safely stores all website data, including posts, user credentials, and system settings. |

### 🐋 Docker:
- 📦 what is Docker ?
is a platform that packages applications and all their required dependencies into lightweight, isolated environments called containers.
- 💡 Why it is used in this project ?
It ensures our infrastructure is modular and secure by isolating NGINX, WordPress, and MariaDB into their own environments.

### 📂 Sources & Design Choices:
- **OS**: Built on `Debian bookworm` for stability and security.
- **Software**: All services (NGINX, MariaDB, WordPress) were installed via official repositories using `apt-get`.
- **Configurations**: All configuration files (`.conf`, `.cnf`, `.sh`) are custom-written to ensure that only the required protocols and connections are active.
- **Services**: Adhered to the `One Service per Container` rule to ensure scalability and easier debugging.
- **Networking**: Utilized a private `bridge network` so the Database is never exposed to the public internet.

### Virtual Machines vs Docker:
**Virtual Machines** (VMs) simulate hardware to run a complete, independent operating system. **Docker**, however, is not a virtual machine, it virtualizes the OS kernel, allowing isolated containers to share the host's resources. This makes Docker significantly more lightweight and faster than a traditional VM.

### Secrets vs Environment Variables:
| | Environment Variables | Docker Secrets |
|---|---|---|
| **Storage** | Plain text in container environment | Mounted as a file at `/run/secrets/` |
| **Visibility** | Visible with `printenv` or `docker inspect` | Not in environment, file only |
| **Security** | Less secure | More secure |
| **Access** | Any process in the container | Only processes that read the file |
| **Location** | Defined in `.env`, ignored by Git | Stored in `secrets/` folder, ignored by Git |


## Docker Network vs Host Network:

| | Bridge Network | Host Network |
|---|---|---|
| **Isolation** | Fully isolated from host | Shares host network directly |
| **Container DNS** | Service names resolve automatically | No Docker DNS |
| **Port exposure** | Only explicitly mapped ports | All ports open on host |
| **Security** | MariaDB and WordPress hidden | Everything potentially exposed |
| **In Inception** | Required | Forbidden by subject |

## Docker Volumes vs Bind Mounts

| | Named Volume | Bind Mount |
|---|---|---|
| **Storage location** | Docker decides | You decide the exact path |
| **Portability** | Works on any machine | Path must exist on host |
| **Control** | Docker manages it | You manage the folder |
| **Data inspection** | Harder to access | Open folder and see files |
| **In Inception** | Not used directly | Required by the subject |

## Instructions:

### Prerequisites
- Docker and Docker Compose installed
- Git installed
- sudo privileges
- make installed

### 1. Clone the repository
- git clone https://github.com/SalmaFartah/inception.git
- cd inception

### 2. Create the .env file
Create the file at **srcs/.env** with these variables:

- `DOMAIN_NAME:`      → yourlogin.42.fr
 
- `MARIADB_DATABASE:` → database name
 
- `MARIADB_USER:`     → username of database
- 
- `SITE_TITLE:`       → the site title
- 
- `WP_ADMIN:`         → admin username of wordpress
- 
- `WP_ADMIN_EMAIL:`   → email of the admin
- 
- `WP_USER:`          → username of a second user
- 
- `WP_USER_EMAIL:`    → email of second user


### 3. Add the domain to /etc/hosts
run this cmd:
- echo "127.0.0.1 yourlogin.42.fr" | sudo tee -a /etc/hosts

### 3. Create the secrets folder
Create a secrets/ folder at the root of the project with these files:
```
secrets/
├── db_password.txt      → database user password
├── db_root_password.txt → database root password
├── wp_admin_pass.txt    → wordpress admin password
└── wp_pass.txt          → wordpress second user password
```
⚠️ Each file contains only the password value and nothing else. <br> Example: echo "yourpassword" > secrets/db_password.txt

### 4. Build and run
make

### 5. Open in your browser
https://yourlogin.42.fr <br> (Accept the self-signed certificate warning and proceed)

> #### Other commands:
> Stop the project: <br> `make stop` <br>
> Simple reset (stop and remove all containers, images, volumes, data):  <br>`make clean` <br>
> Full reset (stop and remove all containers, images, volumes, networks, data, cached layers): <br> `make fclean`

## Bonus

The following bonus services are implemented in addition to the
mandatory part.

### Redis Cache
A Redis container is connected to WordPress as an object cache. <br>
It stores the result of database queries in memory so repeated requests do not hit MariaDB every time. <br>
The WordPress Redis plugin is installed and configured via WP-CLI in the entrypoint script.

### FTP Server
A vsftpd FTP server is configured to point to the WordPress volume at /var/www/html. <br>
An FTP user is created with credentials from the .env file. <br>
Connect using any FTP client on port 21.

### Adminer
A lightweight database management UI accessible through the browser.<br>
It connects to the MariaDB container and allows you to browse tables, run queries, and inspect data visually.<br>
Access: https://yourlogin.42.fr:8080

### Static Website
A simple static HTML/CSS website served directly by NGINX on a
dedicated location block. No PHP involved.
Access: https://yourlogin.42.fr/3000
>>>>>>> structured
