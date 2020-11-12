#!/bin/bash
#Author: Quach Chi Cuong
#Website: https://cuongquach.com/
#Install PHP7-FPM
#

#Install packages dependencies
yum install -y wget libcurl* libstdc++44-devel bzip2-devel bzip2 curl-devel curl libpng-devel libpng readline-devel db4-devel freetype-devel libXpm-devel gmp-devel libc-client-devel openldap-devel unixODBC-devel postgresql-devel sqlite-devel aspell-devel net-snmp-devel net-snmp libxslt-devel libxml2-devel pcre-devel t1lib-devel.x86_64 libmcrypt-devel.x86_64 libtidy libtidy-devel libjpeg-devel libjpeg8-dev mysql-devel libicu-devel recode-devel zlib zlib-devel openssl openssl-devel pcre pcre-devel enchant enchant-devel


# Download Package PHP
# Decompress package PHP
cd /opt/
rm -rf /opt/php56/
mkdir -p /opt/php56/
wget -O php-5.6.32.tar.gz http://php.net/get/php-5.6.32.tar.gz/from/this/mirror
tar xvf php-5.6.32.tar.gz -C /opt/php56/ --strip-components 1 1> /dev/null 

# Begin compile PHP7
cd /opt/php56/
./configure --prefix=/usr/bin/php56 --exec-prefix=/usr/local/php56 --bindir=/usr/local/php56/usr/bin --sbindir=/usr/local/php56/usr/sbin --datadir=/usr/local/php56/usr/share --sysconfdir=/usr/local/php56/etc --with-config-file-scan-dir=/usr/local/php56/etc/php.d --mandir=/usr/local/php56/usr/share/man --includedir=/usr/local/php56/usr/include --libdir=/usr/local/php56/usr/lib64 --libexecdir=/usr/local/php56/usr/libexec --infodir=/usr/local/php56/usr/share/info --with-config-file-path=/usr/bin/php56/etc --with-pdo-pgsql --with-zlib-dir --with-freetype-dir --enable-mbstring --with-libxml-dir=/usr --enable-soap --enable-calendar --with-curl --with-mcrypt --with-zlib --with-gd --with-pgsql --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --enable-exif --enable-bcmath --with-mhash --enable-zip --with-pcre-regex --with-pdo-mysql --with-mysqli --with-mysql-sock=/var/run/mysqld/mysqld.sock --with-jpeg-dir=/usr --with-png-dir=/usr --enable-gd-native-ttf --with-openssl --with-fpm-user=fpm --with-fpm-group=fpm --with-gettext --with-xmlrpc --with-xsl --enable-opcache --enable-fpm

# Determine CPU Core
CPU_CORE="$(cat /proc/cpuinfo  | grep -i "^processor" | wc -l)"
if [[ "${CPU_CORE}" == "0" || "${CPU_CORE}" == "1" ]];then
    CPU_CORE="1"
fi

make -j ${CPU_CORE} && make install -j ${CPU_CORE}

# Initial configuration
mkdir -p /var/log/php-fpm/
chmod 755 /var/log/php-fpm/
mkdir -p /var/run/php-fpm/
chown root:root /var/run/php-fpm/
chmod 755 /var/run/php-fpm/

# Copy current init PHP-FPM
cp -f /opt/php56/php.ini-production /usr/local/php56/etc/php.ini
cp -f /usr/local/php56/etc/php-fpm.conf.default /usr/local/php56/etc/php-fpm.conf
cp -f /usr/local/php56/etc/php-fpm.d/www.conf.default /usr/local/php56/etc/php-fpm.d/www.conf

# Copy init start service PHP-FPM
cp -f /opt/php56/sapi/fpm/php-fpm.service /etc/systemd/system/php-fpm.service
cp -f /opt/php56/sapi/fpm/php-fpm.service /etc/systemd/system/php-fpm56.service
chmod +x /etc/systemd/system/php-fpm.service
chmod +x /etc/systemd/system/php-fpm56.service

# Start php-fpm && set startup service
systemctl enable php-fpm.service
systemctl start php-fpm.service

#Install zend opcache

exit 0