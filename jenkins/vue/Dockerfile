FROM nginx:alpine

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /usr/share/nginx/html

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' /etc/apk/repositories

RUN apk update \
    && apk upgrade \
    && apk --update add logrotate \
    && apk add --no-cache openssl \
    && apk add --no-cache bash

RUN apk add --no-cache curl

RUN set -x ; \
    addgroup -g 82 -S www-data ; \
    adduser -u 82 -D -S -G www-data www-data && exit 0 ; exit 1

# ARG PHP_UPSTREAM_CONTAINER=php-fpm
# ARG PHP_UPSTREAM_PORT=9000

# Create 'messages' file used from 'logrotate'
RUN touch /var/log/messages

# Copy 'logrotate' config file
# COPY logrotate/nginx /etc/logrotate.d/

COPY ./dist /usr/share/nginx/html 
COPY ./nginx.conf /etc/nginx
# CMD ["nginx", "-g", "'daemon off;'"]
# ADD ./startup.sh /opt/startup.sh
# RUN sed -i 's/\r//g' /opt/startup.sh
# CMD ["/bin/bash", "/opt/startup.sh"]

EXPOSE 8080