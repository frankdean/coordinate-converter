# -*- mode: dockerfile; -*- vim: set ft=dockerfile:
FROM node:16-alpine AS build
RUN apk add --no-cache git
USER node
WORKDIR -- /convert-coord
COPY LICENSE index.html index.js location-service.js package.json \
    utils-service.js ./
RUN npm install
RUN npm run build
FROM node:16-alpine
USER node
WORKDIR -- /convert-coord
COPY --from=build /convert-coord ./
CMD ["npm", "run", "preview", "--", "--host"]
