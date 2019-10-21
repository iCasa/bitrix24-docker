#!/bin/sh

# Make sure the working folder is not empty: by default copy bitrix install scripts and default settings to it
if [ ! -f /home/bitrix/www/index.php ] || [ ! -f /home/bitrix/www/bitrix/.settings.php ]; then
    cp -na /usr/share/bitrix/. /home/bitrix/www/
    chown -R bitrix:bitrix /home/bitrix
fi

# Make sure the tmp folder is writeable
if [ ! -d /home/bitrix/www/bitrix/tmp ]; then
    mkdir -p -m 777 /home/bitrix/www/bitrix/tmp
else
    chmod -R 777 /home/bitrix/www/bitrix/tmp
fi

# Take care of environment variables to be passed to Apache
if [ -n "$MYSQL_DATABASE" ]; then echo "MYSQL_DATABASE='$MYSQL_DATABASE'" >> /etc/sysconfig/httpd; fi
if [ -n "$MYSQL_USER" ];     then echo "MYSQL_USER='$MYSQL_USER'" >> /etc/sysconfig/httpd; fi
if [ -n "$MYSQL_PASSWORD" ]; then echo "MYSQL_PASSWORD='$MYSQL_PASSWORD'" >> /etc/sysconfig/httpd; fi


exec /usr/sbin/init
