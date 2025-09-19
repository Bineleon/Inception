#!/bin/sh
set -e

SSL_DIR="/etc/nginx/ssl"
DOMAIN=${DOMAIN_NAME:-neleon.42.fr}

if [ ! -f "$SSL_DIR/$DOMAIN.key" ]; then
  openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout "$SSL_DIR/$DOMAIN.key" \
    -out "$SSL_DIR/$DOMAIN.crt" \
    -subj "/C=FR/ST=France/L=Paris/O=42/CN=$DOMAIN"
fi

if [ ! -f "$SSL_DIR/game.neleon.42.fr.crt" ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$SSL_DIR/game.neleon.42.fr.key" \
        -out "$SSL_DIR/game.neleon.42.fr.crt" \
        -subj "/C=FR/ST=42/L=Paris/O=42/OU=Student/CN=game.neleon.42.fr"
fi

exec nginx -g 'daemon off;'
