#!/bin/sh

if [ ! -d /home/bitrix/www/bitrix/php_interface/ ] || [ ! -f /home/bitrix/www/bitrix/php_interface/dbconn.php ]; then
    cp -na /usr/share/bitrix/. /home/bitrix/www/bitrix/
fi

if [ -d /home/bitrix/www/local/www/ ]; then
    cp -a /home/bitrix/www/local/www/. /home/bitrix/www/
fi

if [ -n "$MYSQL_DATABASE" ]; then echo "MYSQL_DATABASE='$MYSQL_DATABASE'" >> /etc/sysconfig/httpd; fi
if [ -n "$MYSQL_USER" ];     then echo "MYSQL_USER='$MYSQL_USER'" >> /etc/sysconfig/httpd; fi
if [ -n "$MYSQL_PASSWORD" ]; then echo "MYSQL_PASSWORD='$MYSQL_PASSWORD'" >> /etc/sysconfig/httpd; fi

exec /usr/sbin/init
