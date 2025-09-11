#!/bin/sh

set -e

SSL_DIR="/etc/nginx/ssl"
DOMAIN=${DOMAIN_NAME:-neleon.42.fr}

if [ ! -f "$SSL_DIR/$DOMAIN.key" ]; then
  echo "[🔐] Generating self-signed certificate for $DOMAIN"
  openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout "$SSL_DIR/$DOMAIN.key" \
    -out "$SSL_DIR/$DOMAIN.crt" \
    -subj "/C=FR/ST=France/L=Paris/O=42/CN=$DOMAIN"
fi

echo "[🚀] Starting Nginx..."
exec nginx -g 'daemon off;'
