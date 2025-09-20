FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx-full \
 && rm -rf /var/lib/apt/lists/*

COPY src/ /var/www/static_site/

RUN sed -i 's|root /var/www/html;|root /var/www/static_site;|' /etc/nginx/sites-available/default

CMD ["nginx", "-g", "daemon off;"]
