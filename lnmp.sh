
PHP_VERSION="7.3.3"
PHP_ROOT_PATH="/data/php/"

NGINX_VERSION="1.13.6.2"
NGINX_ROOT_PATH="/data/nginx/"

MYSQL_VERSION="10.3.13"
MYSQL_ROOT_PATH="/data/mariadb/"

TMP_SOFT_DIR="/usr/src/"
mkdir -p $TMP_SOFT_DIR
cd $TMP_SOFT_DIR
rm -rf $TMP_SOFT_DIR/*

yum install epel-release -y && yum update -y && yum -y groupinstall Development tools
yum -y install libcurl-devel libXpm-devel perl perl-devel libaio libaio-devel perl-DBD-MySQL which bison kernel-devel libjpeg-devel openssl-devel perl-Time-HiRes perl-Digest-MD5 libev-devel numactl-libs openssl libxml2-devel gcc-c++ lsof  rsync socat nc boost-program-options ncurses-devel cmake gcc g++ make iproute ncompress glibc-devel glibc-utils glibc blis-threads openblas-threads openblas-threads64 python2-bz2file postgresql-libs unixODBC gd gd-devel jpeginfo openjpeg openjpeg-devel  libwebp libwebp-devel perl-Image-Xpm libXpm icu libicu libicu-devel libxml++ libxml++-devel libxml++-doc libxml2 libpng-devel bzip2-devel libdb4-devel libdb4* enchant-devel gmp-devel libc-client-devel php-imap  openldap-devel unixODBC-devel freetds-devel libpqxx-devel aspell-devel libedit-devel  recode-devel net-snmp-devel freetype-devel libsodium-devel libtidy-devel libxslt-devel pcre pcre2 pcre-devel pcre2-devel  pcre2* pcre* memcached-devel memcached mlocate libmemcached GeoIP-devel zlib-devel perl-ExtUtils-Embed libatomic_ops-devel

mkdir -p ${PHP_ROOT_PATH}/etc/php-fpm.d/
mkdir -p ${PHP_ROOT_PATH}/{tmp,logs,session}/
mkdir -p ${NGINX_ROOT_PATH}/{logs,conf} ${NGINX_ROOT_PATH}/conf/conf.d ${NGINX_ROOT_PATH}/tmp/{uwsgi,client_temp,proxy_temp,fastcgi_temp,uwsgi_temp,scgi_temp,proxy,scgi} /data/htdocs /var/run/nginx/
mkdir -p ${MYSQL_ROOT_PATH}/bin-logs ${MYSQL_ROOT_PATH}/database ${MYSQL_ROOT_PATH}/etc ${MYSQL_ROOT_PATH}/logs

groupadd nginx && useradd -s /sbin/nologin -g nginx nginx
groupadd mysql && useradd -s /sbin/nologin -g mysql mysql
groupadd php && useradd -s /sbin/nologin -g php php

ln -s /usr/lib64/libssl.so /usr/lib/
ln -s /usr/include /opt/include
ln -s /usr/lib64 /opt/lib
ln -s /usr/lib64/libc-client.so /usr/lib/libc-client.so
ln -s /usr/bin/icu-config /bin/
ln -s /usr/lib64/libldap.so /usr/lib/
ln -s /usr/lib64/libsybdb.so /usr/lib/
ln -s /usr/lib64/liblber* /usr/lib/

echo "LANG=\"zh_CN\"" > /etc/locale.conf && source /etc/locale.conf

curl "https://mirrors.tuna.tsinghua.edu.cn/mariadb//mariadb-${MYSQL_VERSION}/source/mariadb-${MYSQL_VERSION}.tar.gz" -o mariadb-${MYSQL_VERSION}.tar.gz
curl "https://openresty.org/download/openresty-$NGINX_VERSION.tar.gz" -o openresty-$NGINX_VERSION.tar.gz
curl "ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre2-10.32.tar.gz" -o pcre2-10.32.tar.gz
wget https://nih.at/libzip/libzip-1.2.0.tar.gz
wget https://www.php.net/distributions/php-$PHP_VERSION.tar.gz

tar zxf pcre2-10.32.tar.gz
cd pcre2-10.32 
./configure
make && make install 
cd ..

yum remove libzip* -y 
rm -f /usr/local/lib/libzip*
tar zxf libzip-1.2.0.tar.gz  
cd libzip-1.2.0 
./configure 
make && make install 
ln -s /usr/local/lib/libzip/include/zipconf.h /usr/local/include/zipconf.h
cd ..

DATA_DIR=$MYSQL_ROOT_PATH/database/ 
LOGS_DIR=$MYSQL_ROOT_PATH/logs/ 
ETC_DIR=$MYSQL_ROOT_PATH/etc/

tar zxf mariadb-$MYSQL_VERSION.tar.gz 
cd mariadb-$MYSQL_VERSION
sed -i "s|Welcome to the MariaDB monitor|欢迎进入王殿臣的数据库|" client/mysql.cc
sed -i "s|Oracle, MariaDB Corporation Ab and others|Oracle, MariaDB版权信息声明|" include/welcome_copyright_notice.h

mkdir build && cd build
chown -R mysql: "$DATA_DIR"

cmake .. -DDEFAULT_CHARSET=utf8 \
 -DDEFAULT_COLLATION=utf8_general_ci \
 -DENABLED_LOCAL_INFILE=ON \
 -DWITH_FEDERATED_STORAGE_ENGINE=1 \
 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
 -DWITHOUT_EXAMPLE_STORAGE_ENGINE=1 \
 -DWITH_PARTITION_STORAGE_ENGINE=1 \
 -DWITH_PERFSCHEMA_STORAGE_ENGINE=1 \
 -DWITH_XTRADB_STORAGE_ENGINE=1 \
 -DWITH_ARCHIVE_STPRAGE_ENGINE=1 \
 -DWITH_MYISAM_STORAGE_ENGINE=1 \
 -DWITH_FEDERATEDX_STORAGE_ENGINE=1 \
 -DWITH_ARCHIVE_STORAGE_ENGINE=1 \
 -DCOMPILATION_COMMENT='【EricWang·Compiled·Database】' \
 -DWITH_READLINE=ON \
 -DEXTRA_CHARSETS=all \
 -DWITH_SSL=system \
 -DWITH_ZLIB=system \
 -DWITH_LIBEDIT=0 \
 -DWITH_LIBWRAP=1 \
 -DWITH_WSREP=ON \
 -DWITH_INNODB_DISALLOW_WRITES=ON \
 -DSYSCONFDIR=$ETC_DIR \
 -DMYSQL_DATADIR=$DATA_DIR \
 -DMYSQL_UNIX_ADDR=$DATA_DIR/mysql.sock \
 -DWITH_EMBEDDED_SERVER=OFF \
 -DFEATURE_SET=community \
 -DENABLE_DTRACE=OFF \
 -DMYSQL_SERVER_SUFFIX='【EricWang】' \
 -DWITH_UNIT_TESTS=0 \
 -DWITHOUT_TOKUDB=ON \
 -DWITHOUT_ROCKSDB=ON \
 -DWITH_PAM=ON \
 -DWITH_INNODB_MEMCACHED=ON \
 -DDOWNLOAD_BOOST=1 \
 -DWITH_BOOST=/usr/ \
 -DWITH_SCALABILITY_METRICS=ON

make && make install
curl "http://yum.mariadb.org/10.3.10/centos/7.4/x86_64/rpms/galera-25.3.24-1.rhel7.el7.centos.x86_64.rpm" -o ./galera-25.3.24-1.rhel7.el7.centos.x86_64.rpm
rpm -ivh galera-25.3.24-1.rhel7.el7.centos.x86_64.rpm --nosignature
rm -rf /usr/local/mysql/mysql-test /usr/local/mysql/COPYING* /usr/local/mysql/README* /usr/local/mysql/CREDITS /usr/local/mysql/EXCEPTIONS-CLIENT /usr/local/mysql/INSTALL-BINARY
export PATH=$PATH:/usr/local/mysql/bin/:/usr/sbin/

MYSQL_ETC_CONF=<<SQL
    [client]
    port= 3306
    socket = $DATA_DIR/mysql.sock
    default-character-set = utf8mb4
     
    [mysqld]
    port= 3306
    socket = $DATA_DIR/mysql.sock
    tmpdir = /tmp/
    basedir=/usr/
    datadir = $DATA_DIR
    pid-file = $DATA_DIR/mysql.pid
    user = mysql
    server-id = 1
    bind-address=0.0.0.0 
    init-connect = 'SET NAMES utf8mb4'
    character-set-server = utf8mb4
    skip-name-resolve
    #skip-networking
     
    max_connections= 16384
    open_files_limit = 65535
    table_open_cache = 1024
    max_allowed_packet= 100M
    binlog_cache_size = 1M
    max_heap_table_size = 8M
    tmp_table_size = 128M
     
    read_buffer_size = 2M
    read_rnd_buffer_size = 8M
    sort_buffer_size = 8M
    join_buffer_size = 8M
      
    query_cache_limit = 2M
     
    ft_min_word_len = 4
     
    log_bin = $MYSQL_ROOT_PATH/bin-logs/mysql-bin
    binlog_format = ROW
    expire_logs_days = 30
     
    log_error = $LOGS_DIR/mysql-error.log
    slow_query_log = 1
    long_query_time = 1
    slow_query_log_file = $LOGS_DIR/mysql-slow.log
    general_log = 1
    log_output = FILE
    general_log_file =  $LOGS_DIR/general.log
     
    performance_schema = 0
     
    #lower_case_table_names = 1
     
    skip-external-locking
     
    default_storage_engine=innodb
    #default-storage-engine = MyISAM
    innodb_open_files = 500
    innodb_write_io_threads = 4

     
    #####################################################################33

    skip_external_locking
    lower_case_table_names=1
    event_scheduler=0
    back_log=512
    default-time-zone='+8:00'
    max_connect_errors=99999
    max_length_for_sort_data = 16k
    wait_timeout=172800
    interactive_timeout=172800
    net_buffer_length = 8K
    table_open_cache_instances = 2
    table_definition_cache = 4096
    thread_cache_size = 512
    explicit_defaults_for_timestamp=ON

    #******************************* MyISAM Specific options ****************************
    key_buffer_size = 256M
    bulk_insert_buffer_size = 8M
    myisam_sort_buffer_size = 64M
    myisam_max_sort_file_size = 10G
    myisam_repair_threads = 1
    myisam_recover_options=force

    # ***************************** INNODB Specific options ****************************
    innodb_file_per_table = 1
    innodb_strict_mode = 1
    innodb_flush_method = O_DIRECT
    innodb_checksum_algorithm=crc32
    innodb_autoinc_lock_mode=2
    innodb_flush_log_at_trx_commit=0
    #### Buffer Pool options
    innodb_buffer_pool_size = 4G
    innodb_buffer_pool_instances = 2
    innodb_max_dirty_pages_pct = 90
    innodb_adaptive_flushing = ON
    innodb_flush_neighbors = 0
    innodb_lru_scan_depth = 4096
    #innodb_change_buffering = inserts
    innodb_old_blocks_time = 1000

    [mysqldump]
    quick
    max_allowed_packet = 2G
    default-character-set = utf8mb4
     
    [myisamchk]
    key_buffer = 512M
    sort_buffer_size = 512M
    read_buffer = 8M
    write_buffer = 8M

    [mysqlhotcopy]
    interactive-timeout

    [mysqld_safe]
    open-files-limit = 65535

    [mysql]
    no-auto-rehash
    show-warnings
    prompt="\\u@\\h : \\d \\r:\\m:\\s> "
    default-character-set = utf8mb4
SQL

echo $MYSQL_ETC_CONF > $ETC_DIR/my.cnf
/usr/local/mysql/scripts/mysql_install_db --user=mysql --datadir="$DATA_DIR" --skip-name-resolve --force --basedir=/usr/local/mysql/ --rpm
/usr/local/mysql/bin/mysqld_safe --defaults-file=$ETC_DIR/my.cnf --user=mysql --datadir="$DATA_DIR" --skip-name-resolve --basedir=/usr/local/mysql/ --skip-networking --nowatch

echo "/usr/local/mysql/bin/mysqld_safe --defaults-file=$ETC_DIR/my.cnf --user=mysql --datadir=$DATA_DIR --skip-name-resolve --basedir=/usr/local/mysql/ --skip-networking --nowatch" >> /etc/rc.local

cd $TMP_SOFT_DIR
tar zxf php-$PHP_VERSION.tar.gz && cd php-$PHP_VERSION
./configure --prefix=/usr/local/php/ \
 --with-pic \
 --with-config-file-path=${PHP_ROOT_PATH}/etc/ \
 --with-config-file-scan-dir=${PHP_ROOT_PATH}/etc/conf.d/ \
 --disable-short-tags \
 --enable-bcmath \
 --with-bz2 \
 --enable-calendar \
 --enable-ctype \
 --with-curl \
 --enable-dba \
 --with-db4=/opt \
 --with-dbmaker \
 --with-gdbm \
 --enable-dom \
 --with-enchant \
 --enable-exif \
 --enable-fileinfo \
 --enable-ftp \
 --with-gd \
 --with-freetype-dir \
 --disable-gd-jis-conv \
 --with-jpeg-dir \
 --with-png-dir \
 --with-webp-dir \
 --with-xpm-dir \
 --with-gettext \
 --with-gmp \
 --with-iconv \
 --with-icu-dir=/usr/ \
 --enable-intl \
 --enable-json \
 --with-kerberos \
 --with-ldap=shared \
 --with-ldap-sasl \
 --with-libedit \
 --enable-libxml \
 --with-libxml-dir \
 --enable-mbstring \
 --with-mysqli \
 --with-mysql-sock=$DATA_DIR/mysqld.sock \
 --enable-mysqlnd \
 --enable-opcache \
 --with-openssl \
 --with-system-ciphers \
 --enable-pcntl \
 --with-pcre-regex \
 --enable-pdo \
 --with-pdo-dblib \
 --with-pdo-mysql \
 --with-unixODBC=shared,/usr \
 --with-pdo-odbc=shared,unixODBC,/usr \
 --with-pdo-pgsql \
 --with-pdo-sqlite \
 --with-pgsql \
 --enable-phar \
 --enable-posix \
 --with-pspell \
 --without-readline \
 --with-recode \
 --enable-session \
 --enable-shmop \
 --enable-simplexml \
 --with-snmp \
 --enable-soap \
 --with-sodium \
 --enable-sockets \
 --with-sqlite3 \
 --enable-sysvmsg \
 --enable-sysvsem \
 --enable-sysvshm \
 --with-tidy \
 --enable-tokenizer \
 --enable-wddx \
 --enable-xml \
 --enable-xmlreader \
 --with-xmlrpc \
 --enable-xmlwriter \
 --with-xsl \
 --enable-zip \
 --with-libzip \
 --with-zlib  \
 --with-zlib-dir \
 --disable-phpdbg \
 --enable-fpm  \
 --enable-embed \
 --with-fpm-user=nginx \
 --with-fpm-group=nginx \
 --with-readline \
 --with-pear \
 --enable-inline-optimization \
 --enable-mbregex \
 --with-mhash \
 --enable-shared \
 --with-litespeed

make && make install 
cd $TMP_SOFT_DIR

git clone https://github.com/phpredis/phpredis.git
cd phpredis/
/usr/local/php/bin/phpize && ./configure --with-php-config=/usr/local/php/bin/php-config 
make  && make install 
cd $TMP_SOFT_DIR

git clone https://github.com/php-memcached-dev/php-memcached.git
cd php-memcached/ && /usr/local/php/bin/phpize 
wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
tar zxf libmemcached-1.0.18.tar.gz && cd libmemcached-1.0.18 && ./configure --prefix=/usr/local/libmemcached && make && make install && cd ..
./configure --with-php-config=/usr/local/php/bin/php-config --with-libmemcached-dir=/usr/local/libmemcached
make && make install 
cd $TMP_SOFT_DIR

wget http://pecl.php.net/get/mongodb-1.6.0alpha1.tgz
tar zxf mongodb-1.6.0alpha1.tgz && cd mongodb-1.6.0alpha1
/usr/local/php/bin/phpize 
./configure --with-php-config=/usr/local/php/bin/php-config 
make  && make install 
cd $TMP_SOFT_DIR

wget https://imagemagick.org/download/ImageMagick.tar.gz
tar zxf ImageMagick.tar.gz  && cd `ls | grep ImageMagick | grep -v ImageMagick.tar.gz`
./configure && make && make install 
cd $TMP_SOFT_DIR

wget http://pecl.php.net/get/imagick-3.4.3.tgz
tar zxf imagick-3.4.3.tgz && cd imagick-3.4.3 && /usr/local/php/bin/phpize && ./configure --with-php-config=/usr/local/php/bin/php-config 
make && make install
cd $TMP_SOFT_DIR

mkdir -p /data/jieba/dict
git clone https://github.com/jonnywang/phpjieba.git 
cd phpjieba/
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config 
cd cjieba
make
cd ..
make  && make install
cp cjieba/dict/* /data/jieba/dict/ 
cd $TMP_SOFT_DIR

mkdir -p /data/scws/etc
wget http://www.xunsearch.com/scws/down/scws-1.2.3.tar.bz2 && tar jxf scws-1.2.3.tar.bz2 && cd scws-1.2.3
./configure --sysconfdir=/data/scws/etc && make && make install
cd phpext/ && /usr/local/php/bin/phpize && ./configure --with-php-config=/usr/local/php/bin/php-config 
make  && make install 
cd $TMP_SOFT_DIR

PHP_INI=<<PHPINI
 [PHP]
 engine = On
 short_open_tag = On
 precision = 14
 output_buffering = 4096
 zlib.output_compression = Off
 implicit_flush = Off
 unserialize_callback_func =
 serialize_precision = -1
 disable_functions =
 disable_classes =
 zend.enable_gc = On
 expose_php = On
 max_execution_time = 40
 max_input_time = 60
 memory_limit = 128M
 error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
 display_errors = Off
 display_startup_errors = Off
 log_errors = On
 log_errors_max_len = 1024
 ignore_repeated_errors = Off
 ignore_repeated_source = Off
 report_memleaks = On
 html_errors = On
 error_log = ${PHP_ROOT_PATH}/logs/php_errors.log
 variables_order = "GPCS"
 request_order = "GP"
 register_argc_argv = Off
 auto_globals_jit = On
 post_max_size = 100M
 auto_prepend_file =
 auto_append_file =
 default_mimetype = "text/html"
 default_charset = "UTF-8"
 include_path = ".:/usr/local/php"
 doc_root =
 user_dir =
 enable_dl = Off
 file_uploads = On
 upload_max_filesize = 50M
 max_file_uploads = 200
 allow_url_fopen = On
 allow_url_include = Off
 default_socket_timeout = 60
 
 
 extension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20180731/jieba.so
 jieba.enable=1
 jieba.dict_path=/data/jieba/dict
 
 extension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20180731/imagick.so
 extension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20180731/memcached.so
 extension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20180731/mongodb.so
 extension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20180731/redis.so
 
 
 
 [CLI Server]
 cli_server.color = On
 [Date]
 date.timezone = Asia/Shanghai
 [filter]
 [iconv]
 [intl]
 [sqlite3]
 [Pcre]
 [Pdo]
 [Pdo_mysql]
 pdo_mysql.cache_size = 2000
 pdo_mysql.default_socket=
 [Phar]
 [mail function]
 SMTP = localhost
 smtp_port = 25
 mail.add_x_header = Off
 [ODBC]
 odbc.allow_persistent = On
 odbc.check_persistent = On
 odbc.max_persistent = -1
 odbc.max_links = -1
 odbc.defaultlrl = 4096
 odbc.defaultbinmode = 1
 [Interbase]
 ibase.allow_persistent = 1
 ibase.max_persistent = -1
 ibase.max_links = -1
 ibase.timestampformat = "%Y-%m-%d %H:%M:%S"
 ibase.dateformat = "%Y-%m-%d"
 ibase.timeformat = "%H:%M:%S"
 [MySQLi]
 mysqli.max_persistent = -1
 mysqli.allow_persistent = On
 mysqli.max_links = -1
 mysqli.cache_size = 2000
 mysqli.default_port = 3306
 mysqli.default_socket =
 mysqli.default_host =
 mysqli.default_user =
 mysqli.default_pw =
 mysqli.reconnect = Off
 [mysqlnd]
 mysqlnd.collect_statistics = On
 mysqlnd.collect_memory_statistics = Off
 [OCI8]
 [PostgreSQL]
 pgsql.allow_persistent = On
 pgsql.auto_reset_persistent = Off
 pgsql.max_persistent = -1
 pgsql.max_links = -1
 pgsql.ignore_notice = 0
 pgsql.log_notice = 0
 [bcmath]
 bcmath.scale = 0
 [browscap]
 [Session]
 session.save_handler = files
 session.use_strict_mode = 0
 session.use_cookies = 1
 session.use_only_cookies = 1
 session.name = PHPSESSID
 session.auto_start = 0
 session.cookie_lifetime = 0
 session.cookie_path = ${PHP_ROOT_PATH}/session/
 session.cookie_domain =
 session.cookie_httponly =
 session.serialize_handler = php
 session.gc_probability = 1
 session.gc_divisor = 1000
 session.gc_maxlifetime = 1440
 session.referer_check =
 session.cache_limiter = nocache
 session.cache_expire = 180
 session.use_trans_sid = 0
 session.sid_length = 26
 session.trans_sid_tags = "a=href,area=href,frame=src,form="
 session.sid_bits_per_character = 5
 [Assertion]
 zend.assertions = -1
 [COM]
 [mbstring]
 [gd]
 [exif]
 [Tidy]
 tidy.clean_output = Off
 [soap]
 soap.wsdl_cache_enabled=1
 soap.wsdl_cache_dir="${PHP_ROOT_PATH}/tmp"
 soap.wsdl_cache_ttl=86400
 soap.wsdl_cache_limit = 5
 [sysvshm]
 [ldap]
 ldap.max_links = -1
 [dba]
 [opcache]
 opcache.enable_cli=1
 opcache.file_cache=${PHP_ROOT_PATH}/tmp/
 [curl]
 [openssl]
 
 [scws] 
 extension = /usr/local/php/lib/php/extensions/no-debug-non-zts-20180731/scws.so 
 scws.default.charset = utf8 
 scws.default.fpath = /data/scws/etc 
PHPINI
echo $PHP_INI > ${PHP_ROOT_PATH}/etc/php.ini

PHP_FPM=<<PHPFPM
 [global]
 pid = ${PHP_ROOT_PATH}/etc/php-fpm7.pid
 error_log = ${PHP_ROOT_PATH}/logs/error.log
 daemonize = yes
 include=${PHP_ROOT_PATH}/etc/php-fpm.d/*.conf
PHPFPM
echo $PHP_FPM > ${PHP_ROOT_PATH}/etc/php-fpm.conf

PHP_FPM_WWW=<<PHPFPMWWW
 [www]
 user = nobody
 group = nobody
 listen = /dev/shm/php.sock
 listen.owner = nobody
 listen.group = nobody
 listen.mode = 0660
 pm = dynamic
 pm.max_children = 36 
 pm.start_servers = 12
 pm.min_spare_servers = 12
 pm.max_spare_servers = 24
PHPFPMWWW
echo $PHP_FPM_WWW > ${PHP_ROOT_PATH}/etc/php-fpm.d/www.conf

/usr/local/php/sbin/php-fpm -y /data/php/etc/php-fpm.conf 
echo "/usr/local/php/sbin/php-fpm -y /data/php/etc/php-fpm.conf" >> /etc/rc.local

tar -zxf openresty-$NGINX_VERSION.tar.gz && cd openresty-$NGINX_VERSION
curl "http://labs.frickle.com/files/ngx_cache_purge-2.3.tar.gz" -o bundle/ngx_cache_purge-2.3.tar.gz
wget https://github.com/yaoweibin/nginx_upstream_check_module/archive/v0.3.0.tar.gz -O bundle/v0.3.0.tar.gz 
git clone git://github.com/aszxqw/ngx_http_cppjieba_module.git bundle/ngx_http_cppjieba_module/
tar zxf bundle/ngx_cache_purge-2.3.tar.gz -C bundle/ 
tar zxf bundle/v0.3.0.tar.gz -C bundle/
./configure --prefix=/usr/local/nginx/ \
 --sbin-path=/usr/local/nginx/sbin/nginx \
 --conf-path=${NGINX_ROOT_PATH}/conf/nginx.conf \
 --error-log-path=${NGINX_ROOT_PATH}/logs/error.log \
 --http-log-path=${NGINX_ROOT_PATH}/logs/access.log \
 --pid-path=/var/run/nginx.pid \
 --lock-path=/var/run/nginx.lock \
 --http-client-body-temp-path=${NGINX_ROOT_PATH}/tmp//client_temp \
 --http-proxy-temp-path=${NGINX_ROOT_PATH}/tmp//proxy_temp \
 --http-fastcgi-temp-path=${NGINX_ROOT_PATH}/tmp//fastcgi_temp \
 --http-uwsgi-temp-path=${NGINX_ROOT_PATH}/tmp//uwsgi_temp \
 --http-scgi-temp-path=${NGINX_ROOT_PATH}/tmp//scgi_temp \
 --with-cpp_test_module \
 --with-http_addition_module \
 --with-http_auth_request_module \
 --with-http_dav_module \
 --with-http_degradation_module \
 --with-http_flv_module \
 --with-http_geoip_module \
 --with-http_gunzip_module \
 --with-http_gzip_static_module \
 --with-http_iconv_module \
 --with-http_image_filter_module \
 --with-http_mp4_module \
 --with-http_perl_module \
 --with-http_postgres_module \
 --with-http_random_index_module \
 --with-http_realip_module \
 --with-http_secure_link_module \
 --with-http_slice_module \
 --with-http_ssl_module \
 --with-http_stub_status_module \
 --with-http_sub_module \
 --with-http_v2_module \
 --with-http_xslt_module \
 --with-libatomic \
 --with-luajit \
 --with-mail \
 --with-mail_ssl_module \
 --with-pcre \
 --with-pcre-jit \
 --with-poll_module \
 --with-select_module \
 --with-stream \
 --with-stream_geoip_module \
 --with-stream_realip_module \
 --with-stream_ssl_module \
 --with-stream_ssl_preread_module \
 --with-threads \
 --without-http_redis2_module \
 --without-mail_imap_module \
 --without-mail_pop3_module \
 --without-mail_smtp_module \
 --add-module=/usr/src/openresty-$NGINX_VERSION/bundle/ngx_cache_purge-2.3 \
 --add-module=/usr/src/openresty-$NGINX_VERSION/bundle/nginx_upstream_check_module-0.3.0 \
 --add-module=/usr/src/openresty-$NGINX_VERSION/bundle/ngx_http_cppjieba_module/src
gmake && gmake install && cd $TMP_SOFT_DIR

NGINX_CONF=<<NGNIXCONF
 worker_processes 2;
 worker_cpu_affinity auto;
 worker_rlimit_nofile 65530;
 error_log  ${NGINX_ROOT_PATH}/logs/nginx_error.log  crit;
 
 events
 {
   use epoll;
   worker_connections 65530;
 }
 
 http {
     include       mime.types;
     default_type  application/octet-stream;
     sendfile on;
     tcp_nopush on;
     keepalive_timeout 60;
     tcp_nodelay on;
     server_tokens off;
     server_names_hash_bucket_size 128;
     client_header_buffer_size 32k;
     large_client_header_buffers 4 32k;
     client_max_body_size 8m;
 
     log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                       '$status $body_bytes_sent "$http_referer" '
                       '"$http_user_agent" "$http_x_forwarded_for" "$request_time"';
 
     log_format  post  '$remote_addr - $remote_user [$time_local] "$request" '
                       '$status $body_bytes_sent "$http_referer" '
                       '"$http_user_agent" "$http_x_forwarded_for" "$request_time" "$request_body"';
 
     access_log  ${NGINX_ROOT_PATH}/logs/access.log  main;
 
 
     gzip  on;
     gzip_min_length 1k;
     gzip_buffers 16 64k;
     gzip_http_version 1.1;
     gzip_comp_level 6;
     gzip_types text/plain application/x-javascript text/css application/xml;
     gzip_vary on;
 
     include ${NGINX_ROOT_PATH}/conf/conf.d/*.conf;
 }
NGNIXCONF
echo $NGINX_CONF > ${NGINX_ROOT_PATH}/conf/nginx.conf


NGINX_CONF_WEB=<<NGINXCONFWEB
 server {
     listen 80;
     server_name web.com www.web.com; 
     root "/data/htdocs/www.web.com";
     index index.php index.html index.htm ;
 
     charset utf-8;
 
     add_header Strict-Transport-Security max-age=63072000;
     add_header X-Frame-Options DENY;
     add_header X-Content-Type-Options nosniff;
 
     gzip on;
     gzip_min_length 1k;
     gzip_comp_level 2;
     gzip_types application/json text/plain application/javascript application/x-javascript text/css application/xml text/javascript application/x-httpd-php image/jpeg image/gif image/png;
     gzip_vary on;
 
     if  ( $uri ~* "^/favicon\.ico" ) {
         break;
     }
 
     location / {
         try_files $uri $uri/ /index.php?$query_string;
     }
 
     location = /favicon.ico { access_log off; log_not_found off; }
     location = /robots.txt  { access_log off; log_not_found off; }
 
     access_log ${NGINX_ROOT_PATH}/logs/web-access.log main;
     error_log  ${NGINX_ROOT_PATH}/logs/web-error.log error;
 
     sendfile off;
 
     client_max_body_size 100m;
 
     location ~ \.php$ {
         fastcgi_split_path_info ^(.+\.php)(/.+)$;
         fastcgi_pass unix:/dev/shm/php.sock;
         include fastcgi_params;
         fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
         fastcgi_param DOCUMENT_ROOT $realpath_root;
         fastcgi_intercept_errors off;
         fastcgi_buffer_size 16k;
         fastcgi_buffers 4 16k;
         fastcgi_connect_timeout 300;
         fastcgi_send_timeout 300;
         fastcgi_read_timeout 300;
     }
 
     location ~ /\.ht {
         deny all;
     }
 }
NGINXCONFWEB
echo $NGINX_CONF_WEB > ${NGINX_ROOT_PATH}/conf/conf.d/web.conf
/usr/local/nginx/sbin/nginx
echo "/usr/local/nginx/sbin/nginx" >> /etc/rc.local

rm -rf /usr/src

echo "ALL DONE."
