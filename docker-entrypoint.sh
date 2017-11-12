#!/bin/sh
set -e

# Set UID/GID
PUID=${PUID:-911}
PGID=${PGID:-911}

# Set permissions
groupmod -o -g "$PGID" nginx
usermod -o -u "$PUID" nginx

exec nginx -c /etc/nginx/nginx.conf -g "daemon off;"
