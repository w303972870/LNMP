# LNMP
为了方便，形成一个自动安装PHP7+Nginx(openresty)+Mysql（mariadb）的脚本


## PHP_ROOT_PATH和NGINX_ROOT_PATH、MYSQL_ROOT_PATH是安装后运行的配置文件和数据、日志目录，不是安装目录
## mysql安装完成后，安装路径：/usr/local/mysql，sock文件:$MYSQL_ROOT_PATH/database/
## mysql安装后通过sock文件连接数据库进行配置用户和访问
