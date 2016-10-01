# version: v1.1.20160527

FROM nginx:1.10
MAINTAINER chloroplast "41893204@qq.com"

ADD ./conf/nginx.conf   /etc/nginx/nginx.conf
ADD ./conf/conf.d/*     /etc/nginx/conf.d

WORKDIR /var/www/html