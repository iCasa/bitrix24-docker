FROM centos:7

# Add basics first
RUN yum -y install epel-release \
    https://rpms.remirepo.net/enterprise/remi-release-7.rpm \
    yum-utils && \
    yum-config-manager --enable remi-php72

RUN yum update -y && yum upgrade -y && yum install -y initscripts \
    wget \
    httpd \
    curl \
    cronie \
    ca-certificates \
    openssl \
    openssh \
    git \
    nano \
    curl-devel \
    expat-devel \
    gettext-devel \
    openssl-devel \
    zlib-devel \
    pcre-devel \
    gcc \
    gcc-c++ \
    kernel-devel \
    bind \
    bind bind-utils \
    && yum clean -y all \
    && rm -rf -- /var/cache/yum/*

ENV container docker

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*; \
    rm -f /etc/systemd/system/*.wants/*; \
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*; \
    rm -f /lib/systemd/system/anaconda.target.wants/*;

# get desired nginx version (works with 1.6.2+)
ENV NGINX_PUSH_STREAM_MODULE_PATH=$PWD/nginx-push-stream-module
RUN git clone https://github.com/wandenberg/nginx-push-stream-module.git && \
    wget https://nginx.org/download/nginx-1.16.1.tar.gz && tar xzvf nginx-1.16.1.tar.gz && \
    cd nginx-1.16.1 && \
    ./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --add-module=../nginx-push-stream-module --with-http_gzip_static_module --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module \
    && make \
    && make install \
    && cd .. && rm -rf -- nginx-push-stream-module nginx-1.16.1 nginx-1.16.1.tar.gz

RUN ln -fs /usr/share/zoneinfo/Europe/Moscow /etc/localtime

RUN useradd -ms /bin/bash bitrix

# Configure version constraints
ENV PHP_ENABLE_XDEBUG=0 \
    PATH=/app:/app/vendor/bin:/root/.composer/vendor/bin:$PATH \
    TERM=linux \
    VERSION_PRESTISSIMO_PLUGIN=^0.3.7 \
    COMPOSER_ALLOW_SUPERUSER=1


# Setup apache and php
RUN yum install -y php \
    php-cli \
    php-json \
    php-iconv \
    php-intl \
    php-ftp \
    php-xdebug \
    php-mcrypt \
    php-mbstring \
    php-soap \
    php-gmp \
    php-pdo_odbc \
    php-dom \
    php-pdo \
    php-zip \
    php-mysqli \
    php-bcmath \
    php-gd \
    php-odbc \
    php-pdo_mysql \
    php-gettext \
    php-xmlreader \
    php-xmlwriter \
    php-tokenizer \
    php-xmlrpc \
    php-bz2 \
    php-curl \
    php-ctype \
    php-session \
    php-exif \
    php-opcache \
    php-ldap \
    # Create pid dir and send logs to stderr for Nginx
    && mkdir /run/nginx \
    && mkdir /var/log/nginx \
    && mkdir /home/bitrix/www \
    && yum clean -y all \
    && rm -rf -- /var/cache/yum/*


# Install composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && \
    composer clear-cache


# Nginx default server and PHP defaults
COPY ./etc /etc
COPY ./usr /usr

WORKDIR /home/bitrix/www

COPY ./www /home/bitrix/www

# Get the latest version of bitrix scripts
ADD https://www.1c-bitrix.ru/download/files/scripts/bitrixsetup.php /home/bitrix/www/
ADD https://www.1c-bitrix.ru/download/files/scripts/restore.php /home/bitrix/www/

RUN chown -R bitrix:bitrix /home/bitrix /usr/share/bitrix
RUN chmod -R 777 /tmp && \
    mkdir -p -m 777 /home/bitrix/www/bitrix/tmp && \
    chmod -R 777 /home/bitrix/www/bitrix/tmp

EXPOSE 80
EXPOSE 443

# named (dns server) service
RUN systemctl enable named.service && \
    systemctl enable nginx.service && \
    systemctl enable httpd.service && \
    systemctl enable crond.service

CMD ["/usr/sbin/init"]
