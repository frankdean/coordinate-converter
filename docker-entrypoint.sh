#!/bin/bash
set -e

chown node:node /convert-coord/node_modules

if [ -f /convert-coord/package.json ]
then
    DIR=$(pwd)
    cd /convert-coord
    npm install
    npm run build-release
    cd "$DIR"
fi

sed -i 's~root /var/www/html~root /convert-coord/dist~' /etc/nginx/sites-available/default

exec "$@"
