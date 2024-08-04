FROM nginx:latest

COPY files/nginx.conf /etc/nginx/nginx.conf

RUN  mkdir -p            /etc/nginx/conf.d
COPY files/conf.d/*.conf /etc/nginx/conf.d/
