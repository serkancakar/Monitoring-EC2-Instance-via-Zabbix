#!/bin/bash

wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-3+ubuntu20.04_all.deb
sudo dpkg -i zabbix-release_6.0-3+ubuntu20.04_all.deb
sudo apt-get update
sudo apt-get install zabbix-sql-scripts zabbix-proxy-mysql -y
sudo apt-get install zabbix-agent -y
sudo apt-get install mysql-server -y



# Creating zabbix_server_db. Changing character set to utf8 and collate that with utf8_bin. Then, we are creating a user called zabbix_server and its
# hostname is localhost. Hostname defines the location of your MySQL server and database. After that, we are giving priviliges to zabbix_server user to access 
# zabbix_server_db database. zabbix_server_db* means that user will access all of the tables.

sudo mysql -u root <<EOF
CREATE DATABASE zabbix_proxy_db;
ALTER DATABASE zabbix_proxy_db CHARACTER SET = utf8 COLLATE = utf8_bin;
CREATE USER 'zabbix_proxy'@'localhost' IDENTIFIED BY 'proxypass';
GRANT ALL PRIVILEGES ON zabbix_proxy_db.* TO 'zabbix_proxy'@'localhost';
FLUSH PRIVILEGES;
EOF

# Copying tables to databases

sudo cat /usr/share/doc/zabbix-sql-scripts/mysql/proxy.sql | mysql -uzabbix_proxy -pproxypass -Dzabbix_proxy_db

# Opening necessary ports for communication

sudo ufw allow 10050/tcp
sudo ufw allow 10051/tcp