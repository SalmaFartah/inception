*This project has been created as part of the 42 curriculum by sfartah*

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

