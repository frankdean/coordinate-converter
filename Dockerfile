# -*- mode: dockerfile; -*- vim: set ft=dockerfile:
FROM node:14.21.3-bullseye-slim AS build
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app-server
COPY app package.json yarn.lock ./
RUN yarn
FROM nginx:1.23.4-alpine
WORKDIR /usr/share/nginx/html
COPY --from=build /app-server ./
