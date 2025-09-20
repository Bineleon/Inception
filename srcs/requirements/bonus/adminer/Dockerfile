FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    php php-cli php-mysql curl ca-certificates tzdata \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

RUN curl -L https://www.adminer.org/latest.php -o index.php

CMD ["php", "-S", "0.0.0.0:8080"]