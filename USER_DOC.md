# User Guide

## Services

This infrastructure provides:

- NGINX: HTTPS access on port 443, using TLS 1.2 or TLS 1.3.
- WordPress and PHP-FPM: the website and administration interface.
- MariaDB: storage for the WordPress database.

Only NGINX publishes a port on the host machine. MariaDB and PHP-FPM
communicate over the private `inception` Docker network.

## Starting and stopping

From the repository root, inside the virtual machine:

```sh
sudo make
sudo make ps
sudo make stop
sudo make up
```

`make` builds the images and starts the services in the background.
`make stop` stops the containers without removing them.
`make down` removes the containers and the project network but preserves
volumes and data. `make re` rebuilds the images and recreates the containers.
`sudo make fclean` resets the project by removing its containers, network,
volumes, locally built images and persistent data.

The commands use `sudo` if your account cannot access the Docker daemon
directly.

## Accessing the website

Configure `lebroue.42.fr` to resolve to the VM's IP address, for example
in `/etc/hosts` on the machine running the browser.

- Website: <https://lebroue.42.fr>
- Administration: <https://lebroue.42.fr/wp-admin/>

The certificate is self-signed, so a browser warning is expected.
Verify the domain and the machine before accepting this local exception.
There is no HTTP service on port 80.

## Credentials and passwords

Local settings and account identifiers are stored in [srcs/.env](srcs/.env).
The four passwords are stored in the following local files:

- `secrets/mysql_root_password.txt`: MariaDB root account.
- `secrets/mysql_wp_password.txt`: MariaDB account used by WordPress.
- `secrets/wp_admin_pass.txt`: WordPress administrator.
- `secrets/wp_user_pass.txt`: second WordPress user, with the author role.

These files are ignored by Git. Do not publish them, add them using
`git add -f`, or share configuration output containing their values.

The administrator username is defined by `WP_ADMIN_NAME` in the `.env` file.
It must not contain `admin` or `administrator`, regardless of case.
The second username, defined by `WP_USER_NAME`, must be different.

On an initialized website, editing these files is not enough to update
existing accounts. For WordPress, change the password in the administration
interface and update the corresponding local file.
For MariaDB, coordinate the database account change with the secret update:
the script does not replace the password of an existing MariaDB user.
Do not delete data to rotate a password.

## Checking service health

```sh
sudo make ps
sudo make logs
curl -k --resolve lebroue.42.fr:443:127.0.0.1 \
  -o /dev/null -w '%{http_code}\n' https://lebroue.42.fr/
```

Run the `curl` command inside the VM; `-k` accepts the self-signed certificate
for this test only. The expected result is `200`.
All three containers should remain running, and MariaDB should be `healthy`.
WordPress and NGINX do not have configured healthchecks.
Visiting `/wp-admin/` without being logged in should redirect to the login page.
Exiting the log display with `Ctrl+C` does not stop the services.

## Persistent data

The database is stored in `/home/lebroue/data/mariadb`, and website files
are stored in `/home/lebroue/data/wordpress`. This data persists after
`make stop`, `make down`, `make clean` and `make re`, but is deleted by
`sudo make fclean`.
Back up the database and website files before any destructive operation.
