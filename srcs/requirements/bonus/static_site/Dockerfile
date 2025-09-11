# FROM debian:bookworm-slim

# ENV DEBIAN_FRONTEND=noninteractive

# RUN apt-get update && apt-get install -y --no-install-recommends \
#     nginx openssl ca-certificates tzdata \
#  && rm -rf /var/lib/apt/lists/*

# RUN mkdir -p /etc/nginx/ssl

# COPY conf/bonus.conf /etc/nginx/sites-enabled/default

# COPY src/ /var/www/static_site/

# COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
# RUN chmod +x /usr/local/bin/entrypoint.sh

# EXPOSE 443

# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx-full \
 && rm -rf /var/lib/apt/lists/*

COPY src/ /var/www/static_site/

RUN sed -i 's|root /var/www/html;|root /var/www/static_site;|' /etc/nginx/sites-available/default

CMD ["nginx", "-g", "daemon off;"]
