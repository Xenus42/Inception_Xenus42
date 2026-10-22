*This project has been created as part of the 42 curriculum by lebroue.*

# Inception

## Description

Inception sets up a WordPress infrastructure inside a virtual machine.
It consists of three services built from custom Dockerfiles and orchestrated
with Docker Compose:

| Service | EADME check

    Ensure that a README.md file is present at the root of the repository.
    The very first line must follow the required format: "This project has been created as part of the 42 curriculum by <login...>" (italicized).
    Check that the README contains at least the required sections: Description, Instructions, Resources (with explanation of how AI was used).
    If any of these elements are missing, the evaluation ends now.
Role | Locally built image |
| --- | --- | --- |
| NGINX | HTTPS entry point, TLS 1.2 and TLS 1.3 | `nginx:bookworm` |
| WordPress and PHP-FPM | Website and administration | `wordpress:bookworm` |
| MariaDB | WordPress database | `mariadb:bookworm` |

All three images are based on Debian 12 Bookworm. Only the Debian base image
is pulled from a registry; the service images are built locally.
The `latest` tag is not used.

```text
Browser -- HTTPS :443 --> NGINX -- FastCGI :9000 --> WordPress / PHP-FPM
                                                        |
                                                     MariaDB :3306
```

The containers communicate over the private `inception` bridge network.
Only NGINX port 443 is published on the host.
Each service uses the `restart: unless-stopped` policy.

### Directory structure

```text
.
|-- Makefile
|-- README.md
|-- USER_DOC.md
|-- DEV_DOC.md
|-- secrets/                 # Local files ignored by Git
`-- srcs/
    |-- .env                # Local configuration ignored by Git
    |-- docker-compose.yml
    `-- requirements/
        |-- mariadb/
        |-- nginx/
        `-- wordpress/
```

### Technical choices

- **Virtual machines versus Docker:** a VM has its own kernel, whereas
  containers share the host kernel and isolate processes. This project runs
  Docker inside a VM, as required by the subject.
- **Secrets versus environment variables:** the `.env` file contains local
  settings and account identifiers. The four passwords are kept in Docker
  secret files mounted under `/run/secrets/`. None of these local files
  should be tracked by Git.
- **Bridge versus host networking:** the bridge connects services through
  a dedicated network and provides name resolution. Host mode would share
  the host network directly; it is not used.
- **Docker volumes versus bind mounts:** services use two named volumes
  instead of mounting host paths directly. The `local` driver, configured
  with `type: none`, `o: bind` and `device`, backs these volumes with
  `/home/lebroue/data/mariadb` and `/home/lebroue/data/wordpress`.
  Data survives container recreation. NGINX mounts the WordPress volume
  read-only.

## Instructions

### Prerequisites

- A Linux virtual machine.
- Docker Engine and the Docker Compose v2 plugin.
- GNU Make and Internet access for builds and the initial WordPress download.
- An available port 443 and permission to access the Docker daemon.

### Local configuration

After cloning the repository, create `srcs/.env` and the four secret files:
they are not distributed through Git.

The `.env` file must define the following variables:

```text
LOCAL
WP_DB_HOST
DOMAIN_NAME
WP_SITE_TITLE
MYSQL_DATABASE
MYSQL_USER
WP_ADMIN_NAME
WP_ADMIN_EMAIL
WP_USER_NAME
WP_USER_EMAIL
```

This installation uses the domain `lebroue.42.fr` and the database host
`mariadb`. The WordPress administrator username must not contain `admin`,
regardless of case. The second account is a separate user with the author role.

The local `secrets/` directory must contain:

```text
mysql_root_password.txt
mysql_wp_password.txt
wp_admin_pass.txt
wp_user_pass.txt
```

See the [developer guide](DEV_DOC.md) for example values, permissions,
current initialization script constraints and the complete setup procedure
from a fresh clone. Never publish credentials or passwords.

On the machine used to access the website, configure `lebroue.42.fr`
to resolve to the VM's IP address.

### Building and launching

From the repository root:

```sh
make check
sudo make
sudo make ps
```

The Makefile builds the images, creates the required data directories
and starts the containers in the background. You can omit `sudo` if your
account already has access to the Docker daemon.

On first installation, MariaDB initializes its database and WordPress
downloads its files and configures the website. WordPress waits for the
MariaDB healthcheck to pass before starting. Full startup may take some
time, especially during the initial download.

- Website: <https://lebroue.42.fr>
- Administration: <https://lebroue.42.fr/wp-admin/>

The TLS certificate is self-signed, so a browser warning is expected.

### Management and verification

```sh
sudo make logs
sudo make stop
sudo make up
sudo make down
sudo make re
sudo make fclean
```

`stop` stops the containers; `down` removes them along with the project network.
`re` runs `down`, then rebuilds and restarts the infrastructure.
These commands preserve volumes and data directories.
`clean` is an alias for `down` and does not perform a global Docker cleanup.
`fclean` removes the project containers, network, volumes, locally built
images, and the persistent data directories under `/home/lebroue/data`.

To test the homepage from the VM:

```sh
curl -k --resolve lebroue.42.fr:443:127.0.0.1 \
  -o /dev/null -w '%{http_code}\n' https://lebroue.42.fr/
```

The expected status code is `200`. The `-k` option accepts the self-signed
certificate for this test; it does not validate its chain of trust.
A successful HTTP response does not replace persistence, fresh-installation
or crash-recovery tests. Do not delete persistent data for testing without
first preparing and verifying a backup.

## Documentation

- [USER_DOC.md](USER_DOC.md): services, website access, credential management
  and routine checks.
- [DEV_DOC.md](DEV_DOC.md): environment setup, configuration, builds,
  volume management and persistence.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Dockerfiles](https://docs.docker.com/reference/dockerfile/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Docker volumes](https://docs.docker.com/engine/storage/volumes/)
- [Secrets with Docker Compose](https://docs.docker.com/compose/how-tos/use-secrets/)
- [Debian releases](https://www.debian.org/releases/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress documentation](https://developer.wordpress.org/advanced-administration/)
- [WP-CLI](https://developer.wordpress.org/cli/commands/)
- [MariaDB documentation](https://mariadb.com/docs/)

### Use of AI

An AI assistant was used as a learning aid to better understand Docker,
Docker Compose, networking, persistent volumes, TLS and the roles of the
project's services. It also helped explain commands, interpret error messages.

This README was written with AI assistance.
The developer remains responsible for understanding the implementation,
reviewing changes and verifying the project's behavior.
