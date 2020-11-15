#!/bin/bash
# Author  : Quach Chi Cuong
# Website : https://cuongquach.com/
# Description :


## CONFIGURATION FOR USER SETUP


script_working_environment()
{
    SCRIPT_PWD="$(pwd)"
    SCRIPT_MODULE_DIR="${SCRIPT_PWD}/ngx-modules"
    SCRIPT_PACKAGE_DIR="${SCRIPT_PWD}/ngx-packages"
    SCRIPT_ETC_DIR="${SCRIPT_PWD}/ngx-etc"
    SCRIPT_LOG_REPORT="${SCRIPT_PWD}/ngx-install.log"
    SCRIPT_NGINX_SOURCE="${SCRIPT_PWD}/ngx-source"
    SCRIPT_NGINX_COMPILING="${SCRIPT_PWD}/ngx-compiling.sh"
    SCRIPT_COMPILING_DIR="${SCRIPT_PWD}/ngx-compiling"
    SCRIPT_MODULES_LIST="${SCRIPT_PACKAGE_DIR}/modules_list.txt"
    SCRIPT_STARTUP_DIR="${SCRIPT_PWD}/ngx-startup"
    SCRIPT_MODULES_CUSTOM_CONFIG="${SCRIPT_PWD}/ngx-modules-install.conf"
    SCRIPT_CUSTOM_NGINX="${SCRIPT_PWD}/custom"
    SCRIPT_CUSTOM_NGINX_CONFIG="${SCRIPT_CUSTOM_NGINX}/nginx-compiling-custom.sh"
    SCRIPT_ADDITIONAL_INSTALL="${SCRIPT_CUSTOM_NGINX}/nginx-additional-install.sh"

    ## Modules's dir define
    OPENSSL_MODULES="${SCRIPT_MODULE_DIR}/openssl"
    ZLIB_MODULES="${SCRIPT_MODULE_DIR}/zlib"
    PCRE_MODULES="${SCRIPT_MODULE_DIR}/pcre"

    # Additional flag
    flag_installl_luajt="false"

    # Remove leftover dir/file
    if [[ -f ${SCRIPT_LOG_REPORT} ]];then
        rm -f ${SCRIPT_LOG_REPORT}
    fi

    if [[ -d ${SCRIPT_CUSTOM_NGINX} ]];then
        rm -rf ${SCRIPT_CUSTOM_NGINX}
    fi    
}


script_install_luajt()
{
LUAJT_INSTALL_DIR="$1"
cat <<EOF > ${SCRIPT_ADDITIONAL_INSTALL}
cd ${LUAJT_INSTALL_DIR}
make install -j ${number_cpu_core}
EOF
}


script_template_compiling()
{

cat <<-'EOF' > ${SCRIPT_CUSTOM_NGINX_CONFIG}
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
        --with-stream \
        --with-stream_ssl_module \
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
        --without-http_uwsgi_module \
        --without-http_scgi_module \
        --without-mail_imap_module \
        --without-mail_smtp_module \
        --without-mail_pop3_module \
        --with-pcre="../ngx-modules/pcre" \
        --with-zlib="../ngx-modules/zlib" \
        --with-openssl="../ngx-modules/openssl" \
EOF

}

script_modules_decompress()
{
    LIBRARY_ARRAY=("nginx" "openssl" "zlib" "pcre")
    for pkg in "${LIBRARY_ARRAY[@]}"
    do
        CUSTOM_PACKAGE_NAME="$(echo ${pkg})"
        CUSTOM_PACKAGE_MODULE="${SCRIPT_MODULE_DIR}/${CUSTOM_PACKAGE_NAME}"
        if [[ $(cat ${SCRIPT_MODULES_LIST} | grep -i "^${CUSTOM_PACKAGE_NAME}" | awk -F'=' '{print $2}') ]];then
            VERSION_PACKAGE="$(cat ${SCRIPT_MODULES_LIST} | grep -i "^${CUSTOM_PACKAGE_NAME}=" | awk -F'=' '{print $2}')"
            PACKAGE_PATH="${SCRIPT_PACKAGE_DIR}/${CUSTOM_PACKAGE_NAME}-${VERSION_PACKAGE}.tar.gz"

            if [ ! -f "${PACKAGE_PATH}" ];then
                echo "ERROR.PACKAGE_NOT_EXISTS : ${PACKAGE_PATH}" | tee -a "${SCRIPT_LOG_REPORT}"
            elif [ -f "${PACKAGE_PATH}" ];then
                if [ ${CUSTOM_PACKAGE_NAME} == "nginx" ];then
                    CUSTOM_PACKAGE_MODULE="${SCRIPT_COMPILING_DIR}"
                fi
                    if [ -d ${CUSTOM_PACKAGE_MODULE} ];then
                        rm -rf ${CUSTOM_PACKAGE_MODULE}
                    fi
                    
                    mkdir -p ${CUSTOM_PACKAGE_MODULE}
                    tar xvf ${PACKAGE_PATH} -C ${CUSTOM_PACKAGE_MODULE} --strip-components 1 1> /dev/null \
                    && echo "SUCCESS.PACKAGE_DECOMPRESS : ${PACKAGE_PATH}" | tee -a "${SCRIPT_LOG_REPORT}" \
                    || echo "FAILED.PACKAGE_DECOMPRESS : ${PACKAGE_PATH}" | tee -a "${SCRIPT_LOG_REPORT}"
            fi
        fi
    done
}

script_modules_custom_decompress()
{
    if [ -f ${SCRIPT_MODULES_CUSTOM_CONFIG} ];then
        if [[ $(cat ${SCRIPT_MODULES_CUSTOM_CONFIG} | awk -F'=' '{print $2}' | sort | uniq | grep "1") ]];then
            if [ -d ${SCRIPT_CUSTOM_NGINX} ];then
                rm -rf ${SCRIPT_CUSTOM_NGINX}
            fi
            mkdir -p ${SCRIPT_CUSTOM_NGINX}

            MODULE_CUSTOM_ACTIVE="$(cat ${SCRIPT_MODULES_CUSTOM_CONFIG} | awk -F'=' '{print $2}' | sort | grep "1" | wc -l)"
            COUNT_MODULE=0

            while read module
            do
                if [[ $(echo ${module} | awk -F'=' '{print $2}') -eq 1 ]];then
                    ((COUNT_MODULE++))

                    # Decompress custom module
                    CUSTOM_PACKAGE_NAME="$(echo ${module} | awk -F'=' '{print $1}')"
                    CUSTOM_PACKAGE_MODULE="${SCRIPT_MODULE_DIR}/${CUSTOM_PACKAGE_NAME}"
                    if [[ $(cat ${SCRIPT_MODULES_LIST} | grep -i "^${CUSTOM_PACKAGE_NAME}" | awk -F'=' '{print $2}') ]];then
                        VERSION_PACKAGE="$(cat ${SCRIPT_MODULES_LIST} | grep -i "^${CUSTOM_PACKAGE_NAME}" | awk -F'=' '{print $2}')"
                        PACKAGE_PATH="${SCRIPT_PACKAGE_DIR}/${CUSTOM_PACKAGE_NAME}-${VERSION_PACKAGE}.tar.gz"
                        if [[ "${VERSION_PACKAGE}" == "null" ]];then
                            PACKAGE_PATH="${SCRIPT_PACKAGE_DIR}/${CUSTOM_PACKAGE_NAME}.tar.gz"
                        else
                            PACKAGE_PATH="${SCRIPT_PACKAGE_DIR}/${CUSTOM_PACKAGE_NAME}-${VERSION_PACKAGE}.tar.gz"
                        fi

                        if [ ! -f "${PACKAGE_PATH}" ];then
                            echo "ERROR.PACKAGE_NOT_EXISTS : ${PACKAGE_PATH}" | tee -a "${SCRIPT_LOG_REPORT}"
                        elif [ -f "${PACKAGE_PATH}" ];then

                            # Special case for compiling nginx with LUA
                            if [[ ${flag_installl_luajt} == "false" ]] && [[ ${CUSTOM_PACKAGE_NAME} == "lua-nginx-module" || ${CUSTOM_PACKAGE_NAME} == "stream-lua-nginx-module" ]];then

                                #Prepare LuaJT to install LuaJT
                                LUAJT_VERSION="$(cat ${SCRIPT_MODULES_LIST} | grep -i "^LuaJIT" | awk -F'=' '{print $2}')"
                                LUAJT_PACKAGE_PATH="${SCRIPT_PACKAGE_DIR}/LuaJIT-${LUAJT_VERSION}.tar.gz"
                                LUAJT_PACKAGE_MODULE="${SCRIPT_MODULE_DIR}/LuaJT/"
                                rm -rf ${LUAJT_PACKAGE_MODULE}
                                mkdir -p ${LUAJT_PACKAGE_MODULE}
                                tar xvf ${LUAJT_PACKAGE_PATH} -C ${LUAJT_PACKAGE_MODULE} --strip-components 1 1> /dev/null \
                                && echo "SUCCESS.PACKAGE_DECOMPRESS : ${LUAJT_PACKAGE_MODULE}" | tee -a "${SCRIPT_LOG_REPORT}" \
                                || echo "FAILED.PACKAGE_DECOMPRESS : ${LUAJT_PACKAGE_MODULE}" | tee -a "${SCRIPT_LOG_REPORT}"

                                # Create script to install luajt
                                script_install_luajt ${LUAJT_PACKAGE_MODULE}
                                echo "--with-ld-opt=\"-Wl,-rpath,/usr/local/lib/\" \\" >> ${SCRIPT_CUSTOM_NGINX_CONFIG}.tmp
                                flag_installl_luajt="true"

                                #Prepare ngx-devel-kit to compile with nginx source
                                NGXDEVKIT_VERSION="$(cat ${SCRIPT_MODULES_LIST} | grep -i "^ngx-devel-kit" | awk -F'=' '{print $2}')"
                                NGXDEVKIT_PACKAGE_PATH="${SCRIPT_PACKAGE_DIR}/ngx-devel-kit-${NGXDEVKIT_VERSION}.tar.gz"
                                NGXDEVKIT_PACKAGE_MODULE="${SCRIPT_MODULE_DIR}/ngx-devel-kit/"
                                rm -rf ${NGXDEVKIT_PACKAGE_MODULE}
                                mkdir -p ${NGXDEVKIT_PACKAGE_MODULE}
                                tar xvf ${NGXDEVKIT_PACKAGE_PATH} -C ${NGXDEVKIT_PACKAGE_MODULE} --strip-components 1 1> /dev/null \
                                && echo "SUCCESS.PACKAGE_DECOMPRESS : ${NGXDEVKIT_PACKAGE_MODULE}" | tee -a "${SCRIPT_LOG_REPORT}" \
                                || echo "FAILED.PACKAGE_DECOMPRESS : ${NGXDEVKIT_PACKAGE_MODULE}" | tee -a "${SCRIPT_LOG_REPORT}"
                                echo "--add-module=\"../ngx-modules/ngx-devel-kit/\" \\" >> ${SCRIPT_CUSTOM_NGINX_CONFIG}.tmp
                            fi

                            if [ -d ${CUSTOM_PACKAGE_MODULE} ];then
                                rm -rf ${CUSTOM_PACKAGE_MODULE}
                            fi

                            mkdir -p ${CUSTOM_PACKAGE_MODULE}
                            tar xvf ${PACKAGE_PATH} -C ${CUSTOM_PACKAGE_MODULE} --strip-components 1 1> /dev/null \
                            && echo "SUCCESS.PACKAGE_DECOMPRESS : ${PACKAGE_PATH}" | tee -a "${SCRIPT_LOG_REPORT}" \
                            || echo "FAILED.PACKAGE_DECOMPRESS : ${PACKAGE_PATH}" | tee -a "${SCRIPT_LOG_REPORT}"
                            if [[ $COUNT_MODULE -eq $MODULE_CUSTOM_ACTIVE ]];then
                                echo "--add-module=\"../ngx-modules/${CUSTOM_PACKAGE_NAME}\"" >> ${SCRIPT_CUSTOM_NGINX_CONFIG}.tmp
                            else
                                echo "--add-module=\"../ngx-modules/${CUSTOM_PACKAGE_NAME}\" \\" >> ${SCRIPT_CUSTOM_NGINX_CONFIG}.tmp
                            fi

                        fi
                    fi
                fi
            done < ${SCRIPT_MODULES_CUSTOM_CONFIG}
            script_template_compiling
            cat ${SCRIPT_CUSTOM_NGINX_CONFIG}.tmp >> ${SCRIPT_CUSTOM_NGINX_CONFIG}
            rm -f ${SCRIPT_CUSTOM_NGINX_CONFIG}.tmp
        fi
    fi
}

script_nginx_installing()
{
    ## Calculate core cpu for compile speed
    number_cpu_core="$(cat /proc/cpuinfo  | grep -i "^processor" | wc -l)"
    if [[ -z "${number_cpu_core}" ]] || [[ "${number_cpu_core}" == " " ]];then
        number_cpu_core="1"
    fi

    ## Create user nginx
    if [[ ! $(cat /etc/passwd | grep -i "nginx") ]];then
        groupadd -r nginx 
        useradd -r -s /sbin/nologin --no-create-home -c "nginx service" -g nginx nginx \
                    && echo "SUCCESS.USER_ADD : nginx" | tee -a "${SCRIPT_LOG_REPORT}" \
                    || echo "FAILED.USER_ADD : nginx" | tee -a "${SCRIPT_LOG_REPORT}"
    fi

    ###

    ## Create directory for nginx loging and cache
    mkdir -p /var/log/nginx/domains/
    mkdir -p /var/cache/nginx/

    if [ ! -d ${SCRIPT_COMPILING_DIR} ];then
        echo "ERROR.DIR_NOT_EXISTS : ${SOURCE_COMPILING_DIR}" | tee -a "${SCRIPT_LOG_REPORT}"
        exit 1
    fi

    if [ -f ${SCRIPT_CUSTOM_NGINX_CONFIG} ];then
        # Install adition script first
        if [ -f ${SCRIPT_ADDITIONAL_INSTALL} ];then
            bash ${SCRIPT_ADDITIONAL_INSTALL}
        fi
        
        if [[ ${flag_installl_luajt} == "true" ]];then
            LUAJIT_INC_DIR="$(find /usr/local/include/ -type d -iname "luajit*")"
            export LUAJIT_LIB=/usr/local/lib
            export LUAJIT_INC=${LUAJIT_INC_DIR}
        fi

        cd ${SCRIPT_COMPILING_DIR}
        bash ${SCRIPT_CUSTOM_NGINX_CONFIG}
        make -j ${number_cpu_core}
        make install -j ${number_cpu_core} \
                && echo "SUCCESS.COMPILING_NGINX : nginx" | tee -a "${SCRIPT_LOG_REPORT}" \
                || echo "FAILED.COMPILING_NGINX : nginx" | tee -a "${SCRIPT_LOG_REPORT}"
    else
        cd ${SCRIPT_COMPILING_DIR}
        bash ${SCRIPT_NGINX_COMPILING}
        make -j ${number_cpu_core}
        make install -j ${number_cpu_core} \
                && echo "SUCCESS.COMPILING_NGINX : nginx" | tee -a "${SCRIPT_LOG_REPORT}" \
                || echo "FAILED.COMPILING_NGINX : nginx" | tee -a "${SCRIPT_LOG_REPORT}"
    fi

    ## Copying configuration
    if [ -d /etc/nginx/ ];then
        cp -rf ${SCRIPT_ETC_DIR}/* /etc/nginx/
    fi

    # Create startup file
    if [[ $(grep -i "centos" /etc/os-release) || $(grep -i "amazon" /etc/os-release) ]];then
        if [[ $(cat /etc/os-release | grep "^NAME" | grep -i centos) ]];then
            os_version="$(grep "VERSION_ID" /etc/os-release | awk -F'=' '{print $2}' | tr -d '\"')"
        elif [[ $(cat /etc/os-release | grep "^NAME" | grep -i amazon) ]];then
            os_version="$(grep "VERSION_ID" /etc/os-release | awk -F'=' '{print $2}' | tr -d '\"')"
            if [[ "${os_version}" == "2" ]];then
                os_version="7"
            elif [[ "${os_version}" == "2018.03" ]];then
                os_version="6"
            fi
        fi

        if [[ $(grep "^6" <<< ${os_version}) ]];then
            # Remove current init script Nginx service
            if [[ -f /etc/init.d/nginx ]];then
                rm -f /etc/init.d/nginx
            fi
            cp -f ${SCRIPT_STARTUP_DIR}/init-6.sh /etc/init.d/nginx
            chmod +x /etc/init.d/nginx

            #Start service Nginx and set startup service
            chkconfig nginx on
            /etc/init.d/nginx stop
            /etc/init.d/nginx start

        elif [[ $(grep "^7" <<< ${os_version}) ]];then
            # Remove current init script Nginx service
            if [[ -f /lib/systemd/system/nginx.service ]];then
                rm -f /lib/systemd/system/nginx.service
            fi
            cp -f ${SCRIPT_STARTUP_DIR}/init-7.sh /lib/systemd/system/nginx.service
            chmod +x /lib/systemd/system/nginx.service

            #Start service Nginx and set startup service
            systemctl enable nginx.service
            systemctl stop nginx.service
            systemctl start nginx.service
        fi
    fi

    ## Create vhost directory and copy vhost default
    mkdir -p /etc/nginx/{vhost,ssl}
    cp -rf ${SCRIPT_ETC_DIR}/vhost/* /etc/nginx/vhost/

    ## Generate DH pem
    if [[ -f /etc/nginx/dhparam.pem ]];then
        rm -f /etc/nginx/dhparam.pem
    fi
    openssl dhparam -out /etc/nginx/dhparam.pem 2048 \
                    && echo "SUCCESS.GENERATE_DH_PEM : 2048 bit" | tee -a "${SCRIPT_LOG_REPORT}" \
                    || echo "FAILED.GENERATE_DH_PEM : 2048 bit" | tee -a "${SCRIPT_LOG_REPORT}"

}



## Main function

if [[ "$(id -u)" != "0" ]];then
    echo "- This script must be run as root" 1>&2
    exit 1
fi

script_working_environment
script_modules_decompress
script_modules_custom_decompress
script_nginx_installing

exit 0
