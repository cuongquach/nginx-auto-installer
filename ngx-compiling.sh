#!/bin/bash
# Script compile nginx

./configure \
	--user=nginx \
	--group=nginx \
	--prefix=/etc/nginx \
	--sbin-path=/usr/sbin/nginx \
	--conf-path=/etc/nginx/nginx.conf \
	--error-log-path=/var/log/nginx/error.log \
	--http-log-path=/var/log/nginx/access.log \
	--pid-path=/var/run/nginx.pid \
	--lock-path=/var/run/nginx.lock \
	--http-client-body-temp-path=/var/cache/nginx/client_temp \
	--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
	--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
	--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
	--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
	--with-file-aio \
	--with-http_gzip_static_module \
	--with-http_stub_status_module \
	--with-http_ssl_module \
	--with-http_realip_module \
	--with-http_addition_module \
	--with-http_sub_module \
	--with-http_dav_module \
	--with-http_gunzip_module \
	--with-http_degradation_module \
	--with-http_perl_module \
	--with-debug \
	--with-http_v2_module \
	--with-cc-opt='-D FD_SETSIZE=32768' \
	--without-http_uwsgi_module \
	--without-http_scgi_module \
	--without-mail_imap_module \
	--without-mail_smtp_module \
	--without-mail_pop3_module \
	--with-pcre="../ngx-modules/pcre" \
	--with-zlib="../ngx-modules/zlib" \
	--with-openssl="../ngx-modules/openssl"
