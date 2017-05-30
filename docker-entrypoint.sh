#!/bin/sh
set -e

exec nginx -c /config/nginx.conf -g "daemon off;"
