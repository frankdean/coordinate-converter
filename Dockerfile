# -*- mode: dockerfile; -*- vim: set ft=dockerfile:
FROM node:18-bookworm-slim AS development
RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
    git

# Update to latest version of npm
RUN npm install -g npm
USER node
WORKDIR /convert-coord
RUN chown node:node /convert-coord
COPY --chown=node:node LICENSE index.html index.js location-service.js \
    package.json vite.config.js vite.config.prod.js utils-service.js \
    package-lock.json* yarn.lock* ./
RUN npm install
# Create both distribution formats, one under the web root, the other under
# the folder configured in `vite.config.prod.js`.
RUN npm run build && \
    npm run build -- --config ./vite.config.prod.js
FROM debian:bookworm-slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
    nginx-light
WORKDIR /var/www/html
COPY --from=development /convert-coord/dist ./
COPY --from=development /convert-coord/dist-prod ./convert-coord
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
