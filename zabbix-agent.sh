#!/bin/bash

wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-3+ubuntu20.04_all.deb
sudo dpkg -i zabbix-release_6.0-3+ubuntu20.04_all.deb
sudo apt-get update
sudo apt-get install zabbix-agent -y

# Opening necessary ports for communication

sudo ufw allow 10050/tcp
sudo ufw allow 10051/tcp