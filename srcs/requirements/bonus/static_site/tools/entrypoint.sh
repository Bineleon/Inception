#!/bin/sh

openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/game.neleon.42.fr.key \
  -out /etc/nginx/ssl/game.neleon.42.fr.crt \
  -subj "/C=FR/ST=Paris/L=Paris/O=42/CN=game.neleon.42.fr" \
  -days 365

exec nginx -g "daemon off;"
