#redis版本
REDIS_VERSION="5.0.5"
#软件下载目录
SOFT_ROOT_PATH="/root/soft/"
#redis工作目录，用于放置配置、日志等
REDIS_CONFIG_PATH="/data/redis/"
#redis安装目录
REDIS_ROOT_PATH="/usr/local/redis/"
#redis端口
REDIS_PORT=6379
REDIS_PASSWD=123456
REDIS_BIND_IP=0.0.0.0

#主从配置
REDIS_MASTERAUTH=
REDIS_SLAVEOF_IP=
REDIS_SLAVEOF_PORT=




CONFIG_DIR=$REDIS_CONFIG_PATH"/conf/"
LOG_DIR=$REDIS_CONFIG_PATH"/logs/"
DB_DIR=$REDIS_CONFIG_PATH"/db/"



mkdir -p $SOFT_ROOT_PATH  $CONFIG_DIR $LOG_DIR $DB_DIR
cd $SOFT_ROOT_PATH
wget http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz
tar zxf redis-$REDIS_VERSION.tar.gz
cd redis-$REDIS_VERSION
make PREFIX=$REDIS_ROOT_PATH install
\cp redis.conf $CONFIG_DIR

sed -i "s:dir .\/:dir $DB_DIR:g" $CONFIG_DIR/redis.conf ;
sed -i "s/always-show-logo yes/always-show-logo no/g" $CONFIG_DIR/redis.conf ;
sed -i "s/daemonize no/daemonize yes/g" $CONFIG_DIR/redis.conf ;
sed -i "s:logfile \"\":logfile \"$LOG_DIR\/redis.log\":g" $CONFIG_DIR/redis.conf ;
sed -i "s:pidfile \/var\/run\/redis_6379.pid:pidfile $DB_DIR\/redis_$REDIS_PORT.pid:g" $CONFIG_DIR/redis.conf ;
sed -i "s/protected-mode yes/protected-mode no/g" $CONFIG_DIR/redis.conf ;

if [ "$REDIS_PASSWD" != "" ]; then
    sed -i "s:\# requirepass foobared:requirepass $REDIS_PASSWD:g" $CONFIG_DIR/redis.conf ;
fi

sed -i "s/unixsocket \/run\/redis\/redis.sock/#unixsocket \/run\/redis\/redis.sock/g" $CONFIG_DIR/redis.conf ;
sed -i "s/unixsocketperm 770/#unixsocketperm 770/g" $CONFIG_DIR/redis.conf ;

sed -i "s/bind 127\.0\.0\.1/bind $REDIS_BIND_IP/g" $CONFIG_DIR/redis.conf ;
sed -i "s/port 6379/port $REDIS_PORT/g" $CONFIG_DIR/redis.conf ;

if [ "$REDIS_SLAVEOF_IP" != "" ]; then
    if [ "$REDIS_SLAVEOF_PORT" != "" ]; then
        sed -i "s/# replicaof <masterip> <masterport>/replicaof $REDIS_SLAVEOF_IP $REDIS_SLAVEOF_PORT/g" $CONFIG_DIR/redis.conf ;
        if [ "$REDIS_MASTERAUTH" != "" ]; then
            sed -i "s/# masterauth <master-password>/masterauth $REDIS_MASTERAUTH/g" $CONFIG_DIR/redis.conf ;
        fi
    fi
fi
${REDIS_ROOT_PATH}bin/redis-server $CONFIG_DIR/redis.conf


echo "ALL DONE."