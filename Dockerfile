# -*- mode: dockerfile; -*- vim: set ft=dockerfile:
FROM node:20-bookworm-slim AS development
RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
    git

# Update to latest version of npm
RUN npm install -g npm
USER node
WORKDIR /convert-coord
RUN chown node:node /convert-coord
COPY --chown=node:node LICENSE index.html index.js location-service.js \
    package.json vite.config.js utils-service.js \
    package-lock.json* yarn.lock* ./
RUN npm install
RUN npm run build
FROM debian:bookworm-slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
    nginx-light
WORKDIR /var/www/html
COPY --from=development /convert-coord/dist ./
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
