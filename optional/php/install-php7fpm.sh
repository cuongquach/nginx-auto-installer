#!/bin/bash
#Author: Quach Chi Cuong
#Website: https://cuongquach.com/
#Install PHP7-FPM
#Download php: https://www.php.net/downloads.php

PHP_VERSION="$1"

if [[ -z "${PHP_VERSION}" ]];then
    echo "[+] Please input PHP Version : (7.2/7.3)"
    exit 1
fi

# URL to download php version
if [[ "${PHP_VERSION}" == "7.2" ]];then
    PHP_DOWNLOAD_URL="https://www.php.net/distributions/php-7.2.30.tar.gz"
elif [[ "${PHP_VERSION}" == "7.3" ]];then
    PHP_DOWNLOAD_URL="https://www.php.net/distributions/php-7.3.17.tar.gz"
else
    echo "[x] No support input PHP Version: $PHP_VERSION. Exit."
    exit 1
fi


#Install packages dependencies
yum install -y wget libcurl* libstdc++44-devel bzip2-devel bzip2 curl-devel curl libpng-devel libpng readline-devel db4-devel freetype-devel libXpm-devel gmp-devel libc-client-devel openldap-devel unixODBC-devel postgresql-devel sqlite-devel aspell-devel net-snmp-devel net-snmp libxslt-devel libxml2-devel pcre-devel t1lib-devel.x86_64 libmcrypt-devel.x86_64 libtidy libtidy-devel libjpeg-devel libjpeg8-dev mysql-devel libicu-devel recode-devel zlib zlib-devel openssl openssl-devel pcre pcre-devel enchant enchant-devel libzip-devel


# Install libzip - centos 7
#wget http://packages.psychotic.ninja/7/plus/x86_64/RPMS//libzip-devel-0.11.2-6.el7.psychotic.x86_64.rpm
#wget http://packages.psychotic.ninja/7/plus/x86_64/RPMS//libzip-0.11.2-6.el7.psychotic.x86_64.rpm
#rpm -Uvh libzip-0.11.2-6.el7.psychotic.x86_64.rpm
#rpm -Uvh libzip-devel-0.11.2-6.el7.psychotic.x86_64.rpm

# Download Package PHP & Decompress package PHP
PHP_DOWNLOAD_DIR="/opt/php${PHP_VERSION}"
PHP_INSTALLED_DIR="/usr/local/php${PHP_VERSION}/"

cd /opt/
rm -rf ${PHP_DOWNLOAD_DIR}
mkdir -p ${PHP_DOWNLOAD_DIR}
wget --no-check-certificate -O php-${PHP_VERSION}.tar.gz "${PHP_DOWNLOAD_URL}"
tar xvf php-${PHP_VERSION}.tar.gz -C ${PHP_DOWNLOAD_DIR} --strip-components 1 1> /dev/null

# Create user/group fpm
if [[ ! $(grep "^fpm" /etc/group) ]];then
    groupadd fpm
fi

if [[ ! $(grep "^fpm" /etc/passwd) ]];then
    useradd -g fpm fpm
fi

# Begin compile PHP version
cd ${PHP_DOWNLOAD_DIR}
./configure --prefix=${PHP_INSTALLED_DIR} \
    --with-fpm-user=fpm \
    --with-fpm-group=fpm \
    --with-pdo-pgsql \
    --with-zlib-dir \
    --with-freetype-dir \
    --enable-mbstring \
    --with-libxml-dir=/usr \
    --enable-soap \
    --enable-calendar \
    --with-curl \
    --with-zlib \
    --with-gd \
    --with-pgsql \
    --disable-rpath \
    --enable-inline-optimization \
    --with-bz2 \
    --with-zlib \
    --enable-sockets \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-pcntl \
    --enable-mbregex \
    --enable-exif \
    --enable-bcmath \
    --enable-opcache \
    --enable-fpm \
    --enable-dom \
    --enable-intl \
    --enable-mysqlnd \
    --with-mhash \
    --enable-zip \
    --with-pcre-regex \
    --with-pdo-mysql \
    --with-mysqli \
    --with-jpeg-dir=/usr \
    --with-png-dir=/usr \
    --with-openssl \
    --with-gettext \
    --with-xmlrpc \
    --with-xsl

make && make install

# Initial configuration
mkdir -p /var/log/php-fpm/
chmod 755 /var/log/php-fpm/
mkdir -p /var/run/php-fpm/
chown root:root /var/run/php-fpm/
chmod 755 /var/run/php-fpm/

# Copy current init PHP-FPM
cp -f ${PHP_DOWNLOAD_DIR}/php.ini-production ${PHP_INSTALLED_DIR}/etc/php.ini
cp -f ${PHP_INSTALLED_DIR}/etc/php-fpm.conf.default ${PHP_INSTALLED_DIR}/etc/php-fpm.conf
cp -f ${PHP_INSTALLED_DIR}/etc/php-fpm.d/www.conf.default ${PHP_INSTALLED_DIR}/etc/php-fpm.d/www.conf

# Copy init start service PHP-FPM
cp -f ${PHP_DOWNLOAD_DIR}/sapi/fpm/php-fpm.service /etc/systemd/system/php${PHP_VERSION}-fpm.service
chmod +x /etc/systemd/system/php${PHP_VERSION}-fpm.service

# Start php-fpm && set startup service
echo "[+] Start and enable startup-service for php${PHP_VERSION}-fpm.service"
systemctl daemon-reload
systemctl enable php${PHP_VERSION}-fpm.service
systemctl start php${PHP_VERSION}-fpm.service
systemctl status php${PHP_VERSION}-fpm.service

exit 0
