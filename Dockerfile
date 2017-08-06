FROM easypi/alpine-arm

# INSTALL THE DEPENDENCIES
RUN apk update && apk add lighttpd php5-common php5-iconv php5-json php5-gd php5-curl php5-xml \
php5-mysql php5-pgsql php5-mysqli php5-imap php5-cgi fcgi php5-pdo php5-pdo_pgsql php5-pdo_mysql \
php5-soap php5-xmlrpc php5-posix php5-mcrypt php5-gettext php5-ldap php5-ctype php5-dom \
zabbix zabbix-mysql zabbix-webif zabbix-setup zabbix-utils zabbix-agent curl bash nmap net-snmp net-snmp-tools zabbix-agent mysql mysql-client && \
rm -rf /var/cache/apk/*

# MAKE THE RECOMMANDED PHP CONFIGURATIONS FOR ZABBIX
RUN sed -i 's/#   include "mod_fastcgi.conf"/   include "mod_fastcgi.conf"/g' /etc/lighttpd/lighttpd.conf && \
sed -i 's/max_execution_time = 30/max_execution_time = 600/g' /etc/php5/php.ini && \
sed -i 's/expose_php = On/expose_php = Off/g' /etc/php5/php.ini && \
sed -i 's/date.timezone = UTC/date.timezone = Europe\/Brussels/g' /etc/php5/php.ini && \
sed -i 's/post_max_size = 8M/post_max_size = 32M/g' /etc/php5/php.ini && \
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 16M/g' /etc/php5/php.ini && \
sed -i 's/memory_limit = 128M/memory_limit = 256M/g' /etc/php5/php.ini && \
sed -i 's/max_input_time = 60/max_input_time = 300/g' /etc/php5/php.ini && \
sed -i '/;always_populate_raw_post_data = -1/a\always_populate_raw_post_data = -1' /etc/php5/php.ini && \
sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf && \
sed -i '/FpingLocation=/a\FpingLocation=/usr/sbin/fping' /etc/zabbix/zabbix_server.conf && \
# ENTER ZABBIX DB PASSWORD IN THE LINE BELOW, OTHERWISE ZABBIX SERVER WON'T START
sed -i '/DBPassword=/a\DBPassword=123456' /etc/zabbix/zabbix_server.conf && \
sed -i '/AlertScriptsPath=/a\AlertScriptsPath=/usr/lib/zabbix/alertscripts' /etc/zabbix/zabbix_server.conf

# PERMISSIONS AND WEB ALIAS
RUN mkdir -p /run/lighttpd && chown -R lighttpd /run/lighttpd && \
echo "<h3>It's Working!</h3>" > /var/www/localhost/htdocs/index.html && \
ln -s /usr/share/webapps/zabbix /var/www/localhost/htdocs/zabbix && \
chown -R lighttpd /usr/share/webapps/zabbix/conf && \
addgroup zabbix readproc && chown -R zabbix /var/log/zabbix && \
chown -R zabbix /var/run/zabbix && \
chown root:zabbix /etc/zabbix/zabbix_server.conf && \
chmod 4710 /etc/zabbix/zabbix_server.conf && \
chown root:zabbix /usr/sbin/fping && \
chmod 4710 /usr/sbin/fping && \
chown root:zabbix /usr/bin/nmap && \
chmod 4710 /usr/bin/nmap

# COPY THE NEEDED SCRIPTS TO SETUP MYSQL AND RUN ZABBIX AND ITS DEPENDENCIES
COPY zabbix.conf.php /usr/share/webapps/zabbix/conf/zabbix.conf.php
COPY zabbix-slack-alertscript.sh /usr/lib/zabbix/alertscripts/zabbix-slack-alertscript.sh 
COPY run-zabbix.sh /usr/bin/run-zabbix.sh
RUN chmod +x /usr/bin/run-zabbix.sh && chmod +x /usr/share/webapps/zabbix/conf/zabbix.conf.php

EXPOSE 80 443 10051 10050 3306

VOLUME ["/var/lib/mysql"]

ENTRYPOINT ["/usr/bin/run-zabbix.sh"]
