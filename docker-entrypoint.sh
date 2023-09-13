#!/bin/bash
set -e

chown node:node /convert-coord/node_modules

if [ -f /convert-coord/package.json ]
then
    DIR=$(pwd)
    cd /convert-coord
    yarn
    yarn build-release
    yarn build
    cd "$DIR"
fi

if [ ! -d /var/www/html/convert-coord ]; then
    mkdir /var/www/html/convert-coord
fi
if [ -d /convert-coord/dist-prod ]; then
    cp -a /convert-coord/dist-prod/* /var/www/html/convert-coord
fi
if [ -d /convert-coord/dist ]; then
    cp -a /convert-coord/dist/* /var/www/html
fi

exec "$@"
