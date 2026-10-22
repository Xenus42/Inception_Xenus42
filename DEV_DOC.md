# Developer Guide

## Prerequisites

- A Linux virtual machine, as required by the subject.
- Docker Engine and the Docker Compose v2 plugin.
- GNU Make, Git and Internet access to build the images.
- An available port 443.
- An account authorized to use Docker, or `sudo`.

The Dockerfiles use Debian Bookworm and build all three services locally.
Check that this version still matches the penultimate stable release
required at the time of evaluation.

## Setup from a fresh clone

Local files ignored by Git are not included in a clone.
Create `srcs/.env` with the following keys and replace the example account
identifiers and email addresses before the first launch:

```dotenv
LOCAL=fr_FR
WP_DB_HOST=mariadb
DOMAIN_NAME=lebroue.42.fr
WP_SITE_TITLE=Inception
MYSQL_DATABASE=example_database
MYSQL_USER=example_db_user
WP_ADMIN_NAME=site_owner
WP_ADMIN_EMAIL=owner@example.invalid
WP_USER_NAME=site_author
WP_USER_EMAIL=author@example.invalid
```

The administrator username must not contain `admin` (case-insensitive).
Use simple names for the MariaDB database and user: they are inserted
into the initialization SQL.

Next, create a `secrets` directory at the repository root with four non-empty
files, each containing a different password on a single line:

| File | Consumers |
| --- | --- |
| `mysql_root_password.txt` | MariaDB |
| `mysql_wp_password.txt` | MariaDB and WordPress |
| `wp_admin_pass.txt` | WordPress |
| `wp_user_pass.txt` | WordPress |

The current scripts interpolate MariaDB passwords into SQL strings.
Avoid single quotes and backslashes in both MariaDB passwords.
Secret files must remain readable by Docker.
Restrict permissions on the `.env` and secret files, for example:

```sh
chmod 600 srcs/.env secrets/*.txt
git check-ignore srcs/.env secrets/*.txt
```

Never commit these values. Compose reads the `.env` file to interpolate
variables, and only variables declared in `environment` are passed to services.
Passwords are mounted read-only under `/run/secrets/` and read by the
entrypoint scripts.

The domain is also configured in
[nginx.conf](srcs/requirements/nginx/conf/nginx.conf). The certificate is
generated at container start by the
[NGINX entrypoint](srcs/requirements/nginx/tools/entrypoint.sh), which uses the
`DOMAIN_NAME` variable passed by Compose.
To change the domain, update `nginx.conf` and the `.env` file, then rebuild
NGINX. For an existing website, also update the WordPress URLs.
Configure the domain to resolve to the VM's IP address on the client machine.

Storage paths use the login `lebroue` in
[the Compose file](srcs/docker-compose.yml) and [the Makefile](Makefile).
For a different login, update both files consistently.

## Building and launching

From the repository root:

```sh
make check
sudo make
sudo make ps
```

`make check` verifies the presence of the `.env` file and the four secrets,
and validates the Compose configuration without accessing the Docker daemon.
`make` builds the `mariadb:bookworm`, `wordpress:bookworm` and
`nginx:bookworm` images, creates data directories and starts the containers.
It does not use prebuilt images for these services.

## Management commands

| Command | Effect |
| --- | --- |
| `sudo make build` | Builds images without starting containers |
| `sudo make up` | Builds and starts the project |
| `sudo make stop` | Stops containers |
| `sudo make down` | Removes containers and the network, preserving volumes |
| `sudo make re` | Runs `down`, then rebuilds and restarts |
| `sudo make clean` | Same as `down`, without a global Docker cleanup |
| `sudo make fclean` | Removes the project containers, network, volumes, images, and persistent data |
| `sudo make ps` | Lists all project containers |
| `sudo make logs` | Follows logs, including the last 100 lines per service |
| `sudo make shell SERVICE=wordpress` | Opens a shell inside a service |

For more detailed checks:

```sh
sudo docker compose -f srcs/docker-compose.yml exec nginx nginx -t
sudo docker compose -f srcs/docker-compose.yml exec wordpress \
  wp core is-installed --allow-root
sudo docker compose -f srcs/docker-compose.yml exec wordpress \
  wp user list --fields=ID,user_login,roles --allow-root
sudo docker compose -f srcs/docker-compose.yml config --volumes
sudo docker volume ls --filter label=com.docker.compose.project=srcs
sudo docker volume inspect srcs_mariadb_data srcs_wordpress_data
```

The `srcs_*` names correspond to the default Compose project name here.
If it is overridden, adjust the inspection commands accordingly.
Do not share unfiltered `docker compose config` output:
it contains account identifiers from the `.env` file.

## Storage and lifecycle

Two named volumes are declared in Compose:

- `mariadb_data`, mounted at `/var/lib/mysql`, with host data in
  `/home/lebroue/data/mariadb`.
- `wordpress_data`, mounted at `/var/www/html`, with host data in
  `/home/lebroue/data/wordpress`. NGINX mounts it read-only.

The `local` driver uses `type: none`, `o: bind` and `device` to back these
named volumes with the required host directories. Services reference volume
names rather than host paths directly.
Do not replace these declarations with direct host-path mounts in services.

MariaDB initializes its system directory only if it is absent.
WordPress downloads its files and creates its configuration only when
necessary, preserving an existing installation.
Changing variables or secrets therefore does not automatically reconfigure
existing accounts, URLs or database access.

The `stop`, `down`, `clean` and `re` targets preserve volumes, data directories
and images. The destructive `fclean` target removes all project resources and
persistent data.
Do not run a global Docker cleanup on a shared machine.
For backups, export the database consistently and back up the WordPress files;
copying MariaDB data files while the database is running is not a reliable
backup.

## Verification after changes

```sh
make check
sh -n srcs/requirements/wordpress/tools/entrypoint.sh
bash -n srcs/requirements/mariadb/tools/entrypoint.sh
bash -n srcs/requirements/nginx/tools/entrypoint.sh
git diff --check
sudo make
sudo make ps
curl -k --resolve lebroue.42.fr:443:127.0.0.1 \
  -o /dev/null -w '%{http_code}\n' https://lebroue.42.fr/
```

Also check WordPress login, both user roles, logs, TLS 1.2/1.3 support and
persistence of test content after `make re`.
Services use the `restart: unless-stopped` policy; only MariaDB currently
has a healthcheck.
