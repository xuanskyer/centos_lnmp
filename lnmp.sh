#!/bin/bash

# 变量配置列表
profile_path='/etc/profile'
custom_setting_file='/etc/my_custom_profile'
# 软件源列表
## 本地软件包列表
local_nginx_source='/./packages/nginx-1.8.1.tar.gz'
local_mysql_common_source='/./packages/mysql-5.7.16/mysql-community-common-5.7.16-1.el6.x86_64.rpm'
local_mysql_libs_compat_source='/./packages/mysql-5.7.16/mysql-community-libs-compat-5.7.16-1.el6.x86_64.rpm'
local_mysql_libs_source='/./packages/mysql-5.7.16/mysql-community-libs-5.7.16-1.el6.x86_64.rpm'
local_mysql_server_source='/./packages/mysql-5.7.16/mysql-community-server-5.7.16-1.el6.x86_64.rpm'
local_mysql_client_source='/./packages/mysql-5.7.16/mysql-community-client-5.7.16-1.el6.x86_64.rpm'
local_php_source='/./packages/php-5.6.30.tar.gz'
local_php_ext_redis_source='/./packages/php-ext/redis-2.2.7.tgz'
local_php_ext_memcache_source='/./packages/php-ext/memcache-2.2.7.tgz'
local_php_ext_igbinary_source='/./packages/php-ext/igbinary-1.2.1.tgz'
local_php_ext_swoole_source='/./packages/php-ext/swoole-v1.9.2-stable.tar.gz'
local_php_ext_mongo_source='/./packages/php-ext/mongo-1.6.13.tgz'
local_php_ext_mongodb_source='/./packages/php-ext/mongodb-1.1.5.tgz'

## 远程源列表
nginx_source='http://nginx.org/download/nginx-1.8.1.tar.gz'
mysql_source='http://repo.mysql.com//mysql57-community-release-el6-9.noarch.rpm'
php_source='http://cn2.php.net/distributions/php-5.6.30.tar.gz'
php_ext_redis_source='http://pecl.php.net/get/redis-2.2.7.tgz'
php_ext_memcache_source='http://pecl.php.net/get/memcache-2.2.7.tgz'
php_ext_igbinary_source='http://pecl.php.net/get/igbinary-1.2.1.tgz'
php_ext_swoole_source='https://github.com/swoole/swoole-src/archive/v1.9.2-stable.tar.gz'
php_ext_mongo_source='http://pecl.php.net/get/mongo-1.6.13.tgz'
php_ext_mongodb_source='http://pecl.php.net/get/mongodb-1.1.5.tgz'

# 软件包下载路径
source_download_path='/tmp/lnmp-tmp'
# nginx 安装路径
nginx_prefix='/usr/local/nginx'
# php 安装路径
php_prefix='/usr/local/php'
# mysql安装路径
mysql_prefix='/usr/local/mysql'


# 定义一些安装标记变量
install_var_init(){
    start_time=`date +'%Y-%m-%d %H:%M:%S'`
    status_nginx_install='×'
    status_php_install='×'
    status_php_redis_install='×'
    status_php_memcache_install='×'
    status_php_igbinary_install='×'
    status_php_swoole_install='×'
    status_php_mongo_install='×'
    status_php_mongodb_install='×'
    status_mysql_install='×'
}

install_info(){

    echo -e "\r\n\E[1;33m==============安装列表================\E[1;33m";
    echo -e "\E[1;33m=  nginx          : 1.8.1            =\E[1;33m";
    echo -e "\E[1;33m=  php            : 5.6.30           =\E[1;33m";
    echo -e "\E[1;33m=  php-redis      : 2.2.7            =\E[1;33m";
    echo -e "\E[1;33m=  php-memcache   : 2.2.7            =\E[1;33m";
    echo -e "\E[1;33m=  php-igbinary   : 1.2.1            =\E[1;33m";
    echo -e "\E[1;33m=  php-swoole     : v1.9.2-stable    =\E[1;33m";
    echo -e "\E[1;33m=  php-mongo      : 1.6.13           =\E[1;33m";
    echo -e "\E[1;33m=  php-mongodb    : 1.1.5            =\E[1;33m";
    echo -e "\E[1;33m=  mysql          : 5.7              =\E[1;33m";
    echo -e "\E[1;33m======================================\r\n\E[1;33m";

}


install_yum_init(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r\n";

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
        mhash \
        numactl \
        ca-certificates \
        postfix
    yum update -y

    if [ ! -d "${source_download_path}" ]; then
        `mkdir ${source_download_path}`
    fi

    if [ ! -d "${custom_setting_file}" ]; then
        touch ${custom_setting_file}
    fi

    profile_count=`cat ${profile_path} | grep '/etc/my_custom_profile' | wc -l`
    if [ ${profile_count} -le 0 ]; then
        echo "#加载自定义配置文件" >> ${profile_path}
        echo "if [ -f ${custom_setting_file} ]; then
    . ${custom_setting_file}
fi" >> ${profile_path}
    fi

    desc_content='echo -e "\\r\\n\\E[1;33m load '${custom_setting_file}' file.\\E[0m\\r\\n";'
    desc_count=`cat ${custom_setting_file} | grep 'load /etc/my_custom_profile' | wc -l`
    if [ ${desc_count} -le 0 ]; then
        `echo -e ${desc_content} >> ${custom_setting_file}`
    fi
}

install_nginx(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r\n";
    nginx_dir=`basename ${nginx_source} | sed -r 's/^(.*)\..*$/\1/g' | sed -r 's/^(.*)\..*$/\1/g'`
    cd ${source_download_path}
    if [ -f `dirname $0`${local_nginx_source} ]; then
        echo -e "\r\n\E[1;33m local install...\E[0m\r"
        cp `dirname $0`${local_nginx_source} nginx.tar.gz
    else
        wget -O nginx.tar.gz ${nginx_source}
    fi
    tar -zvx -f nginx.tar.gz
    cd ${source_download_path}/${nginx_dir}
    ./configure --prefix=${nginx_prefix} && make && make install


    nginx_sbin_count=`cat ${custom_setting_file} | grep "export PATH=/usr/local/nginx/sbin:"'$PATH' | wc -l`

    if [ ${nginx_sbin_count} -le 0 ]; then
        echo "export PATH=/usr/local/nginx/sbin:"'$PATH' >> ${custom_setting_file}
    fi
    source ${profile_path}
    include_count=`cat /usr/local/nginx/conf/nginx.conf | grep 'include[ ]*vhost/\*.conf' | wc -l`
    if [ ${include_count} -le 0 ]; then
        nginx_conf_line_count=`cat ${nginx_prefix}/conf/nginx.conf | wc -l`
        sed "${nginx_conf_line_count} iinclude  vhost/*.conf;" -i ${nginx_prefix}/conf/nginx.conf
    fi
    restart_nginx
    status_nginx_install='√'
    echo -e "\r\n\E[1;33m ${FUNCNAME} success!\E[0m\r\n";
}

install_php(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r\n";

    cd ${source_download_path}
    php_dir=`basename ${php_source} | sed -r 's/^(.*)\..*$/\1/g' | sed -r 's/^(.*)\..*$/\1/g'`

    if [ -f `dirname $0`${local_php_source} ]; then
        echo -e "\r\n\E[1;33m local install...\E[0m\r"
        cp `dirname $0`${local_php_source} php.tar.gz
    else
        `wget -O php.tar.gz ${php_source}`
    fi

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


    php_bin_count=`cat ${custom_setting_file} | grep "export PATH=${php_prefix}/bin:"'$PATH' | wc -l`

    if [ ${php_bin_count} -le 0 ]; then
        echo "export PATH=${php_prefix}/bin:"'$PATH' >> ${custom_setting_file}
    fi
    php_sbin_count=`cat ${custom_setting_file} | grep "export PATH=${php_prefix}/sbin:"'$PATH' | wc -l`

    if [ ${php_sbin_count} -le 0 ]; then
        echo "export PATH=${php_prefix}/sbin:"'$PATH' >> ${custom_setting_file}
    fi

    source ${profile_path}
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
    status_php_install='√'
    echo -e "\r\n\E[1;33m ${FUNCNAME} success!\E[0m\r\n";
}

install_php_extend_redis(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r";
    cd ${source_download_path}
    php_redis_dir=`basename ${php_ext_redis_source} | sed -r 's/^(.*)\..*$/\1/g' `

    if [ -f `dirname $0`${local_php_ext_redis_source} ]; then
        echo -e "\r\n\E[1;33m local install...\E[0m\r"
        cp `dirname $0`${local_php_ext_redis_source} php_redis.tar.gz
    else
        `wget -O php_redis.tar.gz ${php_ext_redis_source}`
    fi
    `tar -zvx  -f php_redis.tar.gz`
    cd ${source_download_path}/${php_redis_dir}
    source ${profile_path}
    ${php_prefix}/bin/phpize && ./configure --prefix=${php_prefix} && make && make install

    redis_so_count=`cat /etc/php/php.ini | grep 'extension=redis.so' | wc -l`
    if [ ${redis_so_count} -le 0 ]; then
        echo "extension=redis.so" >> /etc/php/php.ini
    fi

    restart_php_fpm
    status_php_redis_install='√'
    echo -e "\r\n\E[1;33m ${FUNCNAME} success!\E[0m\r\n";
}

install_php_extend_swoole(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r";
    cd ${source_download_path}
    if [ ! -d "${source_download_path}/php_swoole" ]; then
        mkdir ${source_download_path}/php_swoole
    fi
    php_swoole_dir=`basename ${php_ext_swoole_source} | sed -r 's/^(.*)\..*$/\1/g' | sed -r 's/^(.*)\..*$/\1/g' `
    if [ -f `dirname $0`${local_php_ext_swoole_source} ]; then
        echo -e "\r\n\E[1;33m local install...\E[0m\r"
        cp `dirname $0`${local_php_ext_swoole_source} php_swoole.tar.gz
    else
        `wget -O php_swoole.tar.gz ${php_ext_swoole_source}`
    fi

    `tar -zvx -C ${source_download_path}/php_swoole -f php_swoole.tar.gz`
    cd ${source_download_path}/php_swoole
    swoole_src_dir=`ls`
    cd ${source_download_path}/php_swoole/${swoole_src_dir}
    ${php_prefix}/bin/phpize && ./configure --prefix=${php_prefix} && make && make install
    swoole_so_count=`cat /etc/php/php.ini | grep 'extension=swoole.so' | wc -l`
    if [ ${swoole_so_count} -le 0 ]; then
        echo "extension=swoole.so" >> /etc/php/php.ini
    fi
    source ${profile_path}

    restart_php_fpm
    status_php_swoole_install='√'
    echo -e "\r\n\E[1;33m ${FUNCNAME} success!\E[0m\r\n";
}

install_php_extend_igbinary(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r";
    cd ${source_download_path}
    php_igbinary_dir=`basename ${php_ext_igbinary_source} | sed -r 's/^(.*)\..*$/\1/g' `
    if [ -f `dirname $0`${local_php_ext_igbinary_source} ]; then
        echo -e "\r\n\E[1;33m local install...\E[0m\r"
        cp `dirname $0`${local_php_ext_igbinary_source} php_igbinary.tgz
    else
        `wget -O php_igbinary.tgz ${php_ext_igbinary_source}`
    fi
    `tar -zvx  -f php_igbinary.tgz`
    cd ${source_download_path}/${php_igbinary_dir}
    source ${profile_path}
    ${php_prefix}/bin/phpize && ./configure --prefix=${php_prefix} && make && make install

    igbinary_so_count=`cat /etc/php/php.ini | grep 'extension=igbinary.so' | wc -l`
    if [ ${igbinary_so_count} -le 0 ]; then
        echo "extension=igbinary.so" >> /etc/php/php.ini
    fi
    restart_php_fpm
    status_php_igbinary_install='√'
    echo -e "\r\n\E[1;33m ${FUNCNAME} success!\E[0m\r\n";
}

install_php_extend_memcache(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r";
    cd ${source_download_path}
    php_memcache_dir=`basename ${php_ext_memcache_source} | sed -r 's/^(.*)\..*$/\1/g' `
    if [ -f `dirname $0`${local_php_ext_memcache_source} ]; then
        echo -e "\r\n\E[1;33m local install...\E[0m\r"
        cp `dirname $0`${local_php_ext_memcache_source} php_memcache.tgz
    else
        `wget -O php_memcache.tgz ${php_ext_memcache_source}`
    fi
    `tar -zvx  -f php_memcache.tgz`
    cd ${source_download_path}/${php_memcache_dir}
    source ${profile_path}
    ${php_prefix}/bin/phpize && ./configure --prefix=${php_prefix} && make && make install

    memcache_so_count=`cat /etc/php/php.ini | grep 'extension=memcache.so' | wc -l`
    if [ ${memcache_so_count} -le 0 ]; then
        echo "extension=memcache.so" >> /etc/php/php.ini
    fi
    restart_php_fpm
    status_php_memcache_install='√'
    echo -e "\r\n\E[1;33m ${FUNCNAME} success!\E[0m\r\n";
}

install_php_extend_mongo(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r";
    cd ${source_download_path}
    php_mongo_dir=`basename ${php_ext_mongo_source} | sed -r 's/^(.*)\..*$/\1/g' `
    if [ -f `dirname $0`${local_php_ext_mongo_source} ]; then
        echo -e "\r\n\E[1;33m local install...\E[0m\r"
        cp `dirname $0`${local_php_ext_mongo_source} php_mongo.tgz
    else
        `wget -O php_mongo.tgz ${php_ext_mongo_source}`
    fi
    `tar -zvx  -f php_mongo.tgz`
    cd ${source_download_path}/${php_mongo_dir}
    source ${profile_path}
    ${php_prefix}/bin/phpize && ./configure --prefix=${php_prefix} && make && make install

    mongo_so_count=`cat /etc/php/php.ini | grep 'extension=mongo.so' | wc -l`
    if [ ${mongo_so_count} -le 0 ]; then
        echo "extension=mongo.so" >> /etc/php/php.ini
    fi
    restart_php_fpm
    status_php_mongo_install='√'
    echo -e "\r\n\E[1;33m ${FUNCNAME} success!\E[0m\r\n";
}

install_php_extend_mongodb(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r";
    cd ${source_download_path}
    php_mongodb_dir=`basename ${php_ext_mongodb_source} | sed -r 's/^(.*)\..*$/\1/g' `
    if [ -f `dirname $0`${local_php_ext_mongodb_source} ]; then
        echo -e "\r\n\E[1;33m local install...\E[0m\r"
        cp `dirname $0`${local_php_ext_mongodb_source} php_mongodb.tgz
    else
        `wget -O php_mongodb.tgz ${php_ext_mongodb_source}`
    fi
    `tar -zvx  -f php_mongodb.tgz`
    cd ${source_download_path}/${php_mongodb_dir}
    source ${profile_path}
    ${php_prefix}/bin/phpize && ./configure --prefix=${php_prefix} && make && make install

    mongodb_so_count=`cat /etc/php/php.ini | grep 'extension=mongodb.so' | wc -l`
    if [ ${mongodb_so_count} -le 0 ]; then
        echo "extension=mongodb.so" >> /etc/php/php.ini
    fi
    restart_php_fpm
    status_php_mongodb_install='√'
    echo -e "\r\n\E[1;33m ${FUNCNAME} success!\E[0m\r\n";
}

install_mysql(){

    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r";
    `rpm -qa|grep mysql | xargs rpm -e --nodeps`
    if [ -f `dirname $0`${local_mysql_common_source} ] && [ -f `dirname $0`${local_mysql_libs_compat_source} ] && [ -f `dirname $0`${local_mysql_libs_source} ] && [ -f `dirname $0`${local_mysql_server_source} ] && [ -f `dirname $0`${local_mysql_client_source} ] ; then
        echo -e "\r\n\E[1;33m local install...\E[0m\r"
        rpm -ivh `dirname $0`${local_mysql_common_source} && \
        rpm -ivh `dirname $0`${local_mysql_libs_source} && \
        rpm -ivh `dirname $0`${local_mysql_libs_compat_source} && \
        rpm -ivh `dirname $0`${local_mysql_client_source} && \
        rpm -ivh `dirname $0`${local_mysql_server_source} && \
        sudo service mysqld start && \
        sudo service mysqld status
    else
        wget ${mysql_source} \
        && rpm -ivh mysql57-community-release-el6-9.noarch.rpm \
        && yum install -y mysql-community-server \
        && sudo service mysqld start \
        && sudo service mysqld status
    fi
    # 显示初始化密码

    mysql_init_pass_string=`sudo grep 'temporary password' /var/log/mysqld.log`
    mysql_init_pass=${mysql_init_pass_string##*' '}
    echo -e "\r\n\E[1;33m mysql初始密码：${mysql_init_pass} \E[0m\r";

    status_mysql_install='√'
    echo -e "\r\n\E[1;33m ${FUNCNAME} success!\E[0m\r\n";
}

restart_php_fpm(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r";
    php_fpm_count=`ps aux | grep php-fpm | grep -v 'grep' | wc -l`
    if [ ${php_fpm_count} -gt 0 ]; then
        killall php-fpm
    fi
    php-fpm -RD
}

restart_nginx(){
    echo -e "\r\n\E[1;33m ${FUNCNAME}...\E[0m\r";
    nginx_count=`ps aux | grep nginx | grep -v 'grep' | awk '{print $2}' | wc -l`
    if [ ${nginx_count} -gt 0 ]; then
        ps aux | grep nginx | grep -v 'grep' | awk '{print $2}' | xargs kill -9
    fi
    /usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
    /usr/local/nginx/sbin/nginx -s reload
}


installed_list(){
    echo -e "\r\n\E[1;33m=============已安装列表===============\E[1;33m";
    echo -e "\E[1;33m=  nginx          : 1.8.1         ${status_nginx_install} =\E[1;33m";
    echo -e "\E[1;33m=  php            : 5.6.30        ${status_php_install} =\E[1;33m";
    echo -e "\E[1;33m=  php-redis      : 2.2.7         ${status_php_redis_install} =\E[1;33m";
    echo -e "\E[1;33m=  php-memcache   : 2.2.7         ${status_php_memcache_install} =\E[1;33m";
    echo -e "\E[1;33m=  php-igbinary   : 1.2.1         ${status_php_igbinary_install} =\E[1;33m";
    echo -e "\E[1;33m=  php-swoole     : v1.9.2-stable ${status_php_swoole_install} =\E[1;33m";
    echo -e "\E[1;33m=  php-mongo      : 1.6.13        ${status_php_mongo_install} =\E[1;33m";
    echo -e "\E[1;33m=  php-mongodb    : 1.1.5         ${status_php_mongodb_install} =\E[1;33m";
    echo -e "\E[1;33m=  mysql          : 5.7           ${status_mysql_install} =\E[1;33m";
    echo -e "\E[1;33m======================================\r\n\E[1;33m";
    echo "运行时间：${start_time} - `date +'%Y-%m-%d %H:%M:%S'`"
}

######### 执行列表 ############
# 安装前变量初始化
install_var_init
# 安装软件列表说明
install_info
# 安装前系统初始化更新
install_yum_init
# 安装nginx
install_nginx
# 安装php
install_php
# 安装php扩展：redis
install_php_extend_redis
# 安装php扩展：swoole
install_php_extend_swoole
# 安装php扩展：igbinary
install_php_extend_igbinary
# 安装php扩展：memcache
install_php_extend_memcache
# 安装php扩展：mongo
install_php_extend_mongo
# 安装php扩展：mongodb
install_php_extend_mongodb
# 安装mysql
install_mysql
# 安装结束清单
installed_list