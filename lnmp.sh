#!/bin/bash

custom_setting_file='/etc/my_custom_profile'
nginx_source='http://nginx.org/download/nginx-1.8.1.tar.gz'
mysql_source='https://mirrors.tuna.tsinghua.edu.cn/mariadb//mariadb-10.1.21/source/mariadb-10.1.21.tar.gz'
php_source='http://cn2.php.net/distributions/php-5.6.30.tar.gz'
php_ext_redis_source='http://pecl.php.net/get/redis-2.2.7.tgz'
php_ext_memcache_source='http://pecl.php.net/get/memcache-2.2.7.tgz'
php_ext_igbinary_source='http://pecl.php.net/get/igbinary-1.2.1.tgz'
php_ext_swoole_source='https://github.com/swoole/swoole-src/archive/v1.9.2-stable.tar.gz'
php_ext_mongo_source='http://pecl.php.net/get/mongo-1.6.13.tgz'
php_ext_mongodb_source='http://pecl.php.net/get/mongodb-1.1.5.tgz'

source_download_path='/tmp/lnmp-tmp'
nginx_prefix='/usr/local/nginx'
php_prefix='/usr/local/php'
mysql_prefix='/usr/local/mysql'

install_init(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r\n";
    yum update -y
    yum install -y epel-release \
        wget \
        libmcrypt \
        libmcrypt-devel \
        mcrypt \
        mhash \
        lrzsz \
        gcc \
        gcc-c++ \
        autoconf \
        libjpeg \
        libjpeg-devel \
        libpng \
        libpng-devel \
        freetype \
        freetype-devel \
        libxml2 \
        libxml2-devel \
        zlib \
        zlib-devel \
        glibc \
        glibc-devel \
        glib2 \
        glib2-devel \
        bzip2 \
        bzip2-devel \
        ncurses \
        ncurses-devel \
        curl \
        curl-devel \
        e2fsprogs \
        e2fsprogs-devel \
        krb5 \
        krb5-devel \
        libidn \
        libidn-devel \
        openssl \
        openssl-devel \
        openldap \
        openldap-devel \
        nss_ldap \
        openldap-clients \
        openldap-servers \
        gd \
        gd2 \
        gd-devel \
        gd2-devel \
        perl-CPAN \
        pcre-devel \
        libmcrypt \
        libmcrypt-devel \
        mcrypt \
        git \
        mhash

    if [ ! -d "${source_download_path}" ]; then
        `mkdir ${source_download_path}`
    fi

    if [ ! -d "${custom_setting_file}" ]; then
        touch ${custom_setting_file}
    fi

    echo "if [ -f ${custom_setting_file} ]; then
        . ${custom_setting_file}
fi" >> /etc/profile

    echo 'echo -e "\r\n\E[1;33m load '${custom_setting_file}' file.\E[0m\r\n";' >> ${custom_setting_file}
    echo '`git config --global alias.co checkout`
 `git config --global alias.br branch`
 `git config --global alias.cm commit`
 `git config --global alias.st status`' >> ${custom_setting_file}
 
}

install_nginx(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r\n";
    nginx_dir=`basename ${nginx_source} | sed -r 's/^(.*)\..*$/\1/g' | sed -r 's/^(.*)\..*$/\1/g'`
    cd ${source_download_path}
    wget -C nginx.tar.gz ${nginx_source}
    tar -zvx -f nginx.tar.gz
    cd ${source_download_path}/${nginx_dir}
    ./configure --prefix=${nginx_prefix} && make && make install
    echo "export PATH=/usr/local/nginx/sbin:"'$PATH' >> ${custom_setting_file}
    source /etc/profile

    restart_nginx
}

install_mysql(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r\n";
}

install_php(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r\n";
    cd ${source_download_path}
    php_dir=`basename ${php_source} | sed -r 's/^(.*)\..*$/\1/g' | sed -r 's/^(.*)\..*$/\1/g'`
    `wget -O php.tar.gz ${php_source}`
    `tar -zvx  -f php.tar.gz`
    cd ${source_download_path}/${php_dir}
    ./configure --prefix=${php_prefix} --with-config-file-path=/etc/php \
        --enable-fpm \
        --enable-pcntl \
        --enable-mysqlnd \
        --enable-opcache \
        --enable-sockets \
        --enable-sysvmsg \
        --enable-sysvsem \
        --enable-sysvshm \
        --enable-shmop \
        --enable-zip \
        --enable-ftp \
        --enable-soap \
        --enable-xml \
        --enable-mbstring \
        --disable-rpath \
        --disable-debug \
        --disable-fileinfo \
        --with-mysql=mysqlnd \
        --with-mysqli=mysqlnd \
        --with-pdo-mysql=mysqlnd \
        --with-pcre-regex \
        --with-iconv \
        --with-zlib \
        --with-mcrypt \
        --with-gd \
        --with-openssl \
        --with-mhash \
        --with-xmlrpc \
        --with-curl \
        --with-imap-ssl && make && make install
    echo "export PATH=${php_prefix}/bin:"'$PATH' >> ${custom_setting_file}
    echo "export PATH=${php_prefix}/sbin:"'$PATH' >> ${custom_setting_file}
    source /etc/profile
    if [ ! -d "/etc/php" ]; then
        `mkdir /etc/php`
    fi
    if [ ! -d "/etc/php/php.ini" ]; then
        cp ${source_download_path}/${php_dir}/php.ini-development /etc/php/php.ini
    fi
    if [ ! -d "${php_prefix}/etc/php-fpm.conf" ]; then
        cp ${php_prefix}/etc/php-fpm.conf.default ${php_prefix}/etc/php-fpm.conf
    fi

    restart_php_fpm
}

install_php_extend_redis(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r";
    cd ${source_download_path}
    php_redis_dir=`basename ${php_ext_redis_source} | sed -r 's/^(.*)\..*$/\1/g' `
    `wget -O php_redis.tar.gz ${php_ext_redis_source}`
    `tar -zvx  -f php_redis.tar.gz`
    cd ${source_download_path}/${php_redis_dir}
    source /etc/profile
    ${php_prefix}/bin/phpize && ./configure --prefix=${php_prefix} && make && make install
    echo "extension=redis.so" >> /etc/php/php.ini

    restart_php_fpm
}

install_php_extend_swoole(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r";
    cd ${source_download_path}
    if [ ! -d "${source_download_path}/php_swoole" ]; then
        mkdir ${source_download_path}/php_swoole
    fi
    php_swoole_dir=`basename ${php_ext_swoole_source} | sed -r 's/^(.*)\..*$/\1/g' | sed -r 's/^(.*)\..*$/\1/g' `
    `wget -O php_swoole.tar.gz ${php_ext_swoole_source}`
    `tar -zvx -C ${source_download_path}/php_swoole -f php_swoole.tar.gz`
    cd ${source_download_path}/php_swoole
    swoole_src_dir=`ls`
    cd ${source_download_path}/php_swoole/${swoole_src_dir}
    ${php_prefix}/bin/phpize && ./configure --prefix=${php_prefix} && make && make install
    echo "extension=swoole.so" >> /etc/php/php.ini
    source /etc/profile

    restart_php_fpm
}

install_php_extend_igbinary(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r";
    cd ${source_download_path}
    php_igbinary_dir=`basename ${php_ext_igbinary_source} | sed -r 's/^(.*)\..*$/\1/g' `
    `wget -O php_igbinary.tgz ${php_ext_igbinary_source}`
    `tar -zvx  -f php_igbinary.tgz`
    cd ${source_download_path}/${php_igbinary_dir}
    source /etc/profile
    ${php_prefix}/bin/phpize && ./configure --prefix=${php_prefix} && make && make install
    echo "extension=igbinary.so" >> /etc/php/php.ini
    restart_php_fpm
}

install_php_extend_memcache(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r";
    cd ${source_download_path}
    php_memcache_dir=`basename ${php_ext_memcache_source} | sed -r 's/^(.*)\..*$/\1/g' `
    `wget -O php_memcache.tgz ${php_ext_memcache_source}`
    `tar -zvx  -f php_memcache.tgz`
    cd ${source_download_path}/${php_memcache_dir}
    source /etc/profile
    ${php_prefix}/bin/phpize && ./configure --prefix=${php_prefix} && make && make install
    echo "extension=memcache.so" >> /etc/php/php.ini
    restart_php_fpm
}

install_php_extend_mongo(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r";
    cd ${source_download_path}
    php_mongo_dir=`basename ${php_ext_mongo_source} | sed -r 's/^(.*)\..*$/\1/g' `
    `wget -O php_mongo.tgz ${php_ext_mongo_source}`
    `tar -zvx  -f php_mongo.tgz`
    cd ${source_download_path}/${php_mongo_dir}
    source /etc/profile
    ${php_prefix}/bin/phpize && ./configure --prefix=${php_prefix} && make && make install
    echo "extension=mongo.so" >> /etc/php/php.ini
    restart_php_fpm
}
install_php_extend_mongodb(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r";
    cd ${source_download_path}
    php_mongodb_dir=`basename ${php_ext_mongodb_source} | sed -r 's/^(.*)\..*$/\1/g' `
    `wget -O php_mongodb.tgz ${php_ext_mongodb_source}`
    `tar -zvx  -f php_mongodb.tgz`
    cd ${source_download_path}/${php_mongodb_dir}
    source /etc/profile
    ${php_prefix}/bin/phpize && ./configure --prefix=${php_prefix} && make && make install
    echo "extension=mongodb.so" >> /etc/php/php.ini
    restart_php_fpm
}

restart_php_fpm(){
    php_fpm_count=`ps aux | grep php-fpm | grep -v 'grep' | wc -l`
    if [ ${php_fpm_count} -gt 0 ]; then
        killall php-fpm
    fi
    php-fpm -RD
}

restart_nginx(){
    nginx_count=`ps aux | grep nginx | grep -v 'grep' | awk '{print $2}' | wc -l`
    if [ ${nginx_count} -gt 0 ]; then
        ps aux | grep nginx | grep -v 'grep' | awk '{print $2}' | xargs kill -9
    fi
    /usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
    /usr/local/nginx/sbin/nginx -s reload
}

install_init
install_nginx
install_php
install_php_extend_redis
install_php_extend_swoole
install_php_extend_igbinary
install_php_extend_memcache
install_php_extend_mongo
install_php_extend_mongodb