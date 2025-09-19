FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      mariadb-server mariadb-client ca-certificates tzdata \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld /var/lib/mysql \
 && chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY conf/my.cnf /etc/mysql/my.cnf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chown root:root /usr/local/bin/entrypoint.sh \
 && chmod 755 /usr/local/bin/entrypoint.sh

ENV MARIADB_DATA_DIR=/var/lib/mysql \
    MARIADB_SOCKET=/run/mysqld/mysqld.sock

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# FROM debian:bookworm-slim

# ENV DEBIAN_FRONTEND=noninteractive

# RUN apt-get update \
#  && apt-get install -y --no-install-recommends \
#       mariadb-server mariadb-client ca-certificates tzdata \
#  && rm -rf /var/lib/apt/lists/*

# RUN mkdir -p /run/mysqld /var/lib/mysql \
#  && chown -R mysql:mysql /run/mysqld /var/lib/mysql

# COPY conf/my.cnf /etc/mysql/my.cnf
# COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

# RUN chown root:root /usr/local/bin/entrypoint.sh \
#  && chmod 755 /usr/local/bin/entrypoint.sh

# ENV MARIADB_DATA_DIR=/var/lib/mysql \
#     MARIADB_SOCKET=/run/mysqld/mysqld.sock

# EXPOSE 3306

# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
