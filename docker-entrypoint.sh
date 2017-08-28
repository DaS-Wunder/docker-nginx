#!/bin/sh
set -e

# Set UID/GID
PUID=${PUID:-911}
PGID=${PGID:-911}

groupmod -o -g "$PGID" abc
usermod -o -u "$PUID" abc
chown abc:abc /config

exec nginx -c /config/nginx.conf -g "daemon off;"
