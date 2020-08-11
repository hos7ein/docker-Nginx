FROM centos:latest
LABEL maintainer="fedorafans.com <hossein.a97@gmail.com>"

# ---------------------- #
#    Installation        #
# ---------------------- #

RUN dnf update -y                                                           && \
    dnf install -y epel-release dnf-utils                                   && \
    dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm  && \
    echo '[nginx-stable]'                    >> /etc/yum.repos.d/nginx.repo && \
    echo 'name=nginx stable repo'            >> /etc/yum.repos.d/nginx.repo && \
    echo 'baseurl=http://nginx.org/packages/centos/$releasever/$basearch/' >> /etc/yum.repos.d/nginx.repo              && \
    echo 'gpgcheck=1'                        >> /etc/yum.repos.d/nginx.repo && \
    echo 'enabled=1'                         >> /etc/yum.repos.d/nginx.repo && \
    echo 'gpgkey=https://nginx.org/keys/nginx_signing.key' >> /etc/yum.repos.d/nginx.repo                              && \
    echo 'module_hotfixes=true'              >> /etc/yum.repos.d/nginx.repo && \
    echo ' '                                 >> /etc/yum.repos.d/nginx.repo && \
    echo '[nginx-mainline]'                  >> /etc/yum.repos.d/nginx.repo && \
    echo 'name=nginx mainline repo'          >> /etc/yum.repos.d/nginx.repo && \
    echo 'baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/' >> /etc/yum.repos.d/nginx.repo     && \
    echo 'gpgcheck=1'                        >> /etc/yum.repos.d/nginx.repo && \
    echo 'enabled=0'                         >> /etc/yum.repos.d/nginx.repo && \
    echo 'gpgkey=https://nginx.org/keys/nginx_signing.key' >> /etc/yum.repos.d/nginx.repo                              && \
    echo 'module_hotfixes=true'              >> /etc/yum.repos.d/nginx.repo && \
    dnf -y module enable php:remi-7.3                                       && \
    dnf install -y php php-opcache php-gd php-curl php-mysqlnd  php-mysqlnd    \
    php-pgsql php-fpm  php-pdo php-pecl-memcache php-pecl-memcached php-gd     \
    php-xml php-mbstring php-mcrypt php-pecl-apcu php-cli php-pear             \
    php74-php-pecl-mongodb php-zip php-json php-bcmath supervisor nginx     && \
    dnf clean all                                                           && \
    mkdir -p /run/php-fpm                                                   && \
    mkdir -p /run/supervisor                                                && \
    sed -i 's/;listen.mode = 0660/listen.mode = 0660/g' /etc/php-fpm.d/www.conf                                        && \
    sed -i 's/user = apache/user = nginx/g'  /etc/php-fpm.d/www.conf        && \
    sed -i 's/group = apache/group = nginx/g'  /etc/php-fpm.d/www.conf      && \
    sed -i 's/;listen.owner = nobody/listen.owner = nginx/g' /etc/php-fpm.d/www.conf                                   && \
    sed -i 's/;listen.group = nobody/listen.group = nginx/g' /etc/php-fpm.d/www.conf                                   && \
    echo 'daemon off;'                             >> /etc/nginx/nginx.conf && \
    sed -i 's/;user=chrism/user=root/g'            /etc/supervisord.conf    && \
    echo '[program:php-fpm]'                       >> /etc/supervisord.d/php-fpm.ini && \
    echo 'command=/usr/sbin/php-fpm --nodaemonize' >> /etc/supervisord.d/php-fpm.ini && \
    echo 'autostart=true'                          >> /etc/supervisord.d/php-fpm.ini && \
    echo 'autorestart=true'                        >> /etc/supervisord.d/php-fpm.ini && \
    echo 'priority=5'                              >> /etc/supervisord.d/php-fpm.ini && \
    echo 'stdout_events_enabled=true'              >> /etc/supervisord.d/php-fpm.ini && \
    echo 'stderr_events_enabled=true'              >> /etc/supervisord.d/php-fpm.ini && \
    echo '[program:nginx]'                         >> /etc/supervisord.d/nginx.ini && \
    echo 'command=/usr/sbin/nginx'                 >> /etc/supervisord.d/nginx.ini && \
    echo 'autostart=true'                          >> /etc/supervisord.d/nginx.ini && \
    echo 'autorestart=true'                        >> /etc/supervisord.d/nginx.ini && \
    echo 'priority=10'                             >> /etc/supervisord.d/nginx.ini && \
    echo 'stdout_events_enabled=true'              >> /etc/supervisord.d/nginx.ini && \
    echo 'stderr_events_enabled=true'              >> /etc/supervisord.d/nginx.ini



# Expose port
EXPOSE 80 443

# -------- #
#   Run!   #
# -------- #

CMD ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
