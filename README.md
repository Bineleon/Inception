# Inception – WordPress stack on Docker (42 Project)

A clean, from‑scratch Dockerized WordPress stack using **Debian Bookworm _slim_** bases and minimal packages.  
Services are split by responsibility and wired through a private Docker network with TLS termination at **nginx**.

> Domain used in this repo: **neleon.42.fr** and **game.neleon.42.fr** for a static site (bonus).  
> Certificates are **self‑signed** and generated at container start. Adjust the domain in `.env` if needed.

---

## Stack Overview

- **MariaDB** – database server (custom image from `debian:bookwork-slim`)
- **WordPress (php‑fpm)** – PHP runtime only (served by nginx via FastCGI)
- **nginx** – reverse proxy + TLS (self‑signed certs generated at runtime)
- **(Bonus) Adminer** – simple DB UI on port **8080**
- **(Bonus) Static site** – served by nginx and proxied at **game.neleon.42.fr**

All images are built **locally** from Dockerfiles under `srcs/requirements/*`.

---

## Repository Layout

```
Inception/
├─ Makefile
├─ srcs/
│  ├─ .env                       # domain + WordPress / DB config (non-secret)
│  ├─ docker-compose.yml         # service wiring, volumes, secrets, network
│  └─ requirements/
│     ├─ mariadb/
│     │  ├─ Dockerfile           # debian:bookworm-slim + mariadb-server
│     │  ├─ conf/my.cnf
│     │  └─ tools/entrypoint.sh  # init DB, users, grants (reads Docker secrets)
│     ├─ wordpress/
│     │  ├─ Dockerfile           # debian:bookworm-slim + php-fpm + wp-cli
│     │  └─ tools/entrypoint.sh  # wp config/install (reads Docker secrets)
│     ├─ nginx/
│     │  ├─ Dockerfile           # debian:bookworm-slim + nginx + openssl
│     │  ├─ conf/default.conf    # vhosts for neleon.42.fr + game.neleon.42.fr
│     │  └─ tools/entrypoint.sh  # generates self-signed certs, starts nginx
│     └─ bonus/
│        ├─ adminer/Dockerfile   # php -S 0.0.0.0:8080
│        └─ static_site/
│           ├─ Dockerfile        # nginx serving /var/www/static_site
│           ├─ src/              # simple static pages (index.html, resume.html…)
│           └─ conf/, tools/     # minimal configs
└─ secrets/
   ├─ db_root_password.txt
   ├─ db_password.txt
   ├─ wp_admin_password.txt
   └─ wp_user_password.txt
```

---

## Configuration & Secrets

### 1) `.env` (non‑secret runtime config)

`srcs/.env` ships with sensible defaults (edit as needed):

```env
DOMAIN_NAME=neleon.42.fr

MARIADB_DATABASE=wordpress
MARIADB_USER=wp_user

WORDPRESS_DB_HOST=mariadb
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wp_user

WP_ADMIN_USER=neleon42
WP_ADMIN_EMAIL=admin@neleon.42.fr
WP_SITE_TITLE="Inception by Nelbi"
WP_USER=user42
```

### 2) Docker **Secrets** (do **not** commit)

Create the four files below (already present in this repo under `secrets/`; change the contents for your setup):

```
secrets/db_root_password.txt     # e.g. "my_root_pwd"
secrets/db_password.txt          # e.g. "my_wp_db_pwd"
secrets/wp_admin_password.txt    # e.g. "my_admin_pwd"
secrets/wp_user_password.txt     # e.g. "my_user_pwd"
```

The compose file mounts these as **Docker secrets**, read at runtime by entrypoints:
- **MariaDB** sets the root password, creates DB `wordpress`, user `wp_user`, grants.
- **WordPress** uses `wp-cli` to generate `wp-config.php`, run `wp core install` (admin user), and create a regular subscriber user.

> Storing credentials as **secrets** (not plain env vars) avoids leaking them in `docker inspect`, process lists, and logs.

---

## Persistence (Volumes)

**This project is designed to run entirely inside a Virtual Machine**, as required by the subject.
All containers, volumes, and configurations are managed within the VM environment, with persistent data stored in /home/login/data/ (here /home/neleon/data/).

Two persistent volumes (local bind mounts) are used to keep data across rebuilds:

- **MariaDB data** → `/var/lib/mysql`
- **WordPress files** → `/var/www/wordpress`

In this repo, the Makefile’s `fclean` suggests host paths like:
```
/home/neleon/data/mariadb
/home/neleon/data/wordpress
```
If you’re on another machine, adapt those host paths in `docker-compose.yml` (or keep named volumes).

---

## Network & TLS

- A user-defined bridge network named **`inception`** connects services privately.
- **nginx** is the only service exposed to the host (port **443**).
- Self‑signed certificates are generated at container start in `/etc/nginx/ssl` by the nginx entrypoint:
  - `neleon.42.fr.crt/key`
  - `game.neleon.42.fr.crt/key`
- TLS is configured with **TLSv1.3** only in the provided config.

> For real domains, replace self‑signed certs with **Let’s Encrypt** (e.g., via a separate ACME companion or by mounting real certs into the container).

---

## Build & Run

### Prerequisites
- Docker Engine + Docker Compose v2
- `make`
- Optional: add `neleon.42.fr` and `game.neleon.42.fr` to your `/etc/hosts` → `127.0.0.1` for local testing

### Make targets

```bash
# build everything (local images)
make build

# start stack in background
make up

# build then start
make all

# follow logs for all services
make logs

# stop + remove containers
make down

# remove containers + volumes (danger: destroys DB / WP files)
make clean

# nuke volumes on host (paths from Makefile), then rebuild & start
make re
```
> `clean` removes Docker volumes; `fclean` (called by `re`) also wipes host bind paths listed in the Makefile.

### Access
- **WordPress:** https://neleon.42.fr/  (browser will warn due to self‑signed cert; proceed)
- **Static Site (bonus):** https://game.neleon.42.fr/
- **Adminer (bonus):** http://localhost:8080  (use DB host `mariadb`, db `wordpress`, user `wp_user`)

> If DNS doesn’t resolve your domain locally, add entries to `/etc/hosts` or change `server_name` in `nginx/conf/default.conf` to `localhost` for quick tests.

---

## First‑run & Credentials

On first boot:
- **MariaDB** initializes the data directory and creates DB/user from secrets.
- **WordPress** downloads core, generates `wp-config.php`, installs the site using `.env` and secrets:
  - Admin: `$WP_ADMIN_USER` / password from `secrets/wp_admin_password.txt`
  - A regular user is also created with `$WP_USER` / password from `secrets/wp_user_password.txt`

You can login at `https://neleon.42.fr/wp-admin` after bypassing the self‑signed warning.

---

## Useful Commands

```bash
# open a shell in a service
docker compose -f srcs/docker-compose.yml exec mariadb sh
docker compose -f srcs/docker-compose.yml exec wordpress sh
docker compose -f srcs/docker-compose.yml exec nginx sh

# MySQL prompt (inside mariadb container)
mariadb -u root -p            # then use the root secret
SHOW DATABASES;
USE wordpress;
SHOW TABLES;

# regenerate self‑signed certs (nginx container)
rm -f /etc/nginx/ssl/*.crt /etc/nginx/ssl/*.key && exit
docker compose -f srcs/docker-compose.yml restart nginx
```

---

## Image Size & Build Optimizations

This project intentionally uses **`debian:bookworm-slim`** for all images and keeps them light:

- `apt-get install -y --no-install-recommends` (no extras)
- `rm -rf /var/lib/apt/lists/*` to drop apt index layers
- Combine commands in fewer `RUN` layers where sensible
- Only install what each service needs:
  - **MariaDB:** `mariadb-server mariadb-client tzdata ca-certificates`
  - **WordPress:** `php-fpm php-mysql php-cli php-curl php-mbstring php-xml php-zip curl`
  - **nginx:** `nginx-full openssl ca-certificates`
  - **Adminer (bonus):** `php php-cli php-mysql` + `curl`
  - **Static site (bonus):** `nginx-full` only
- **FastCGI** via php‑fpm (no Apache), clear separation of concerns
- **Docker secrets** for passwords (kept out of env / image layers)

---

## Troubleshooting

- **Browser says “Not secure / self‑signed”** → This is expected for local self‑signed certs. For production use real certs.
- **Can’t reach domain** → Add to `/etc/hosts` or use the host IP. Confirm `nginx` is listening on `443:443`.
- **WordPress install not running** → Ensure secrets exist and are readable; check `wordpress` logs for `wp-cli` output.
- **DB auth errors** → Verify `db_password.txt`, `db_root_password.txt` contents; try connecting via Adminer on `localhost:8080`.
- **Persistent data not saved** → Confirm volumes/bind paths in `docker-compose.yml` exist and are not being cleared by `clean`/`fclean`.

---

## 42 Subject Compliance Notes

- No prebuilt WordPress or MariaDB images – all images are **built from `debian:bookworm-slim`**.
- TLS via **nginx** on **port 443 only**.
- Data persistence via **local volumes**.
- Credentials handled via **Docker secrets**.
- Services isolated on a **user-defined network**; only nginx is exposed.

---
