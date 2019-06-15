# Pull base image.
FROM ubuntu:18.04

LABEL maintainer="msmohotti@gmail.com"

ENV TZ=Asia/Dubai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV MYSQL_USER=mysql \
    MYSQL_DATA_DIR=/var/lib/mysql \
    MYSQL_RUN_DIR=/run/mysqld \
    MYSQL_LOG_DIR=/var/log/mysql

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server \
 && rm -rf ${MYSQL_DATA_DIR}

# Install Nginx.
RUN apt-get install -y nginx && \
#  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/lib/nginx

# Define mountable directories.
VOLUME ["/etc/nginx/sites-available", "/etc/nginx/certs", "/var/log/nginx", "/var/www/html"]

RUN apt-get install -y \
	vim \
	git \
	composer \
	rabbitmq-server \
	php-fpm php-common php-gd php-mysql php-curl php-intl php-xsl php-mbstring php-zip php-bcmath php-iconv php-soap


COPY ./files/auth.json /root/.composer/auth.json

COPY ./files/entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

# Define working directory.
WORKDIR /var/www/html/magento2

ENTRYPOINT ["/sbin/entrypoint.sh"]

EXPOSE 80 3306 15672

CMD ["/usr/bin/mysqld_safe"]

