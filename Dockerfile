# -*- mode: dockerfile; -*- vim: set ft=dockerfile:
FROM nginx:alpine
WORKDIR /usr/share/nginx/html
COPY app .
COPY node_modules ./node_modules
