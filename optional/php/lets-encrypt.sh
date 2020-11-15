#!/bin/bash

# This script is to generate Let's Encrypt SSL Certificate
certbot certonly --rsa-key-size 4096 --webroot --agree-tos --no-eff-email --email cuongquach.secondary@gmail.com -w /var/lib/letsencrypt/ -d nguago.com -d www.nguago.com

# Auto renew certificate
/usr/bin/certbot renew