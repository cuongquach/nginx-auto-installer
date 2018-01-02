#!/bin/bash
#Author: CuongQC
#Website: https://cuongquach.com/
#Description: install MariaDB 10.2 on CentOS 7


# Create repository for MariaDB 10.2
cat << EOF > /etc/yum.repos.d/MariaDB.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.2/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1

EOF

yum repolist

# Install MariaDB
yum install MariaDB-server MariaDB-client MariaDB-devel -y

# Copy sample config
mv /etc/my.cnf /etc/my.$(date -I)
cp /usr/share/mysql/my-medium.cnf /etc/my.cnf

# Start mariadb and set startu service
systemctl start mysql.service
systemctl enable mysql.service

# Secure mariadb
mysql_secure_installation

exit 0