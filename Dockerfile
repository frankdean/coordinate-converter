FROM nginx:alpine

#WORKDIR /usr/share/nginx/html

COPY app /usr/share/nginx/html

COPY node_modules /usr/share/nginx/html/node_modules
