# -*- mode: dockerfile; -*- vim: set ft=dockerfile:
FROM node:16-alpine AS development
RUN apk add --no-cache git
USER node
WORKDIR /convert-coord
COPY LICENSE index.html index.js location-service.js package.json \
    vite.config.js vite.config.prod.js \
    utils-service.js ./
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
