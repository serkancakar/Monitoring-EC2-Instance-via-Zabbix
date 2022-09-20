#!/bin/bash

wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-3%2Bubuntu20.04_all.deb
sudo dpkg -i zabbix-release_6.0-3+ubuntu20.04_all.deb
sudo apt-get update
sudo apt-get install zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts -y
sudo apt-get install zabbix-server-mysql -y
sudo apt-get install zabbix-agent -y
sudo apt-get install mysql-server -y


sudo mysql -u root <<EOF
CREATE DATABASE zabbix_server_db; 
ALTER DATABASE zabbix_server_db CHARACTER SET = utf8 COLLATE = utf8_bin;
CREATE USER 'zabbix_server'@'localhost' IDENTIFIED BY 'serverpass';
GRANT ALL PRIVILEGES ON zabbix_server_db.* TO 'zabbix_server'@'localhost';
FLUSH PRIVILEGES;
EOF


# Copying tables to databases

sudo zcat /usr/share/doc/zabbix-sql-scripts/mysql/server.sql.gz | mysql -uzabbix_server -pserverpass -Dzabbix_server_db

# Opening necessary ports for communication

sudo ufw allow 80/tcp
sudo ufw allow 10050/tcp
sudo ufw allow 10051/tcp