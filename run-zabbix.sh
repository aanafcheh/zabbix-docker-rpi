#!/bin/sh
if [ ! -f "/var/lib/mysql/zabbix/users.frm" ]; then
 # SETUP MYSQL, PERMISSIONS AND DIRECTORIES
 echo "Creating initial DBs..."
 /usr/bin/mysql_install_db --user=mysql
 if [ ! -d "/run/mysqld" ]; then
  mkdir -p /run/mysqld
 fi
 chown mysql:mysql /run/mysqld/
 chown -R mysql:mysql /var/lib/mysql/
 cp /usr/share/mysql/mysql.server /etc/init.d/mysql
 chmod +x /etc/init.d/mysql
 # START MYSQL AND MAKE THE BASIC CONFIGS
 echo "Starting MySQL service..."
 service mysql start
 echo "Setting MySQL root password..."
 /usr/bin/mysqladmin -u root password '789gdbgdf%'
 # CREATE A DATABASE FOR ZABBIX SPECIFICALLY
 echo "Creating Zabbix database..."
 mysql -u root -p"optmysqlnot7our$" -e "CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'zabbix';"
 mysql -u root -p"optmysqlnot7our$" -e "create database zabbix charset utf8;"
 mysql -u root -p"optmysqlnot7our$" -e "grant all privileges on zabbix.* to 'zabbix'@'localhost' identified by '123456';"
 mysql -u root -p"optmysqlnot7our$" -e "flush privileges;"
 # THESE ARE EXECUTED AT RUNTIME SO THAT THE DATA IS IMPORTED AFTER THE VOLUME IS MOUNTED 
 # OTHERWISE THE MOUNTED CONTAINER DIRECTORY WILL BECOME EMPTY
 echo "Importing schema.sql..."
 mysql -u zabbix -p123456 zabbix < /usr/share/zabbix/database/mysql/schema.sql
 echo "Importing images.sql..."
 mysql -u zabbix -p123456 zabbix < /usr/share/zabbix/database/mysql/images.sql
 echo "Importing data.sql..."
 mysql -u zabbix -p123456 zabbix < /usr/share/zabbix/database/mysql/data.sql 
fi
# IF THE VOLUME IS HEALTHY AND THE IMAGE IS RUN FOR THE FIRST TIME, THEN CREATE MYSQL SERVICE 
if [ ! -d "/run/mysqld" ]; then
 mkdir -p /run/mysqld
 chown mysql:mysql /run/mysqld/
 chown -R mysql:mysql /var/lib/mysql/
 cp /usr/share/mysql/mysql.server /etc/init.d/mysql
 chmod +x /etc/init.d/mysql
fi
echo "Running Zabbix, Lighttpd and MySQL..."
service mysql start
/usr/sbin/zabbix_server -c /etc/zabbix/zabbix_server.conf
/usr/sbin/zabbix_agentd -c /etc/zabbix/zabbix_agentd.conf
/usr/sbin/lighttpd -D -f /etc/lighttpd/lighttpd.conf
echo "Done!"
