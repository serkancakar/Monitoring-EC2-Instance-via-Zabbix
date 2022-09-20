# Monitoring-EC2-Instance-via-Zabbix

## Project Objective

We are going to create three EC2 instances with Terraform. These will be Zabbix agent, Zabbix proxy and Zabbix server instances. The packages and requirements for each machine will be downloaded using bash scripts. After the packages are downloaded, we are going to  monitor Zabbix agent instance via proxy. Note: Zabbix agent will also installed on proxy and server instances.

## Used Technologies

+ **AWS** → Public cloud to be used
+ **Terraform** → Used to build infrastructure of EC2 instances
+ **Zabbix** → Used for monitoring EC2 instances

## Need to Know

+ SSH access to the instances
+ Knowing how to use at least one text editor

## Prerequireties

+ Download Terraform on your computer
+ Create an AWS account

## Getting Started

+ Create a new directory.
+ Clone the repository to that directory.
+ Run
  ```terraform init```
- and after that
 ```terraform apply```

## Usage

+ Connect Zabbix_agent instance via SSH
+ Change host name by running

    ```sudo hostnamectl set-hostname ZabbixAgent```

+ Add ZabbixAgent to the etc/hosts file
  
    ```sudo vi etc/hosts```

+ Configure Server, ServerActive and Hostname on zabbix_agend.conf file based on your informations. Server and ServerActive have to be given the IP of the proxy instance. You can check that from AWS.
+ After that, connect Zabbix_proxy instance via SSH
+ Change the host name by following the steps above.
+ The IP of the zabbix server instance has to be written at the Server. Other arguments DBName, DBUser and DBPassword should be set as;

```
  DBName= zabbix_proxy_db
  DBUser= zabbix_proxy
  DBPassword= proxypass
```

+ Then, the information in the configuration file of the agent inside the proxy machine need to be changed. The IP of the server machine is written to the Server and ServerActive.
+ Zabbix prxy service is started.

  ```sudo systemctl start zabbix-proxy.service```

+ Connect to server instance via SSH.
+ Change server configuration file as follows;

```	
  DBName= zabbix_server_db
  DBUser= zabbix_server
  DBPassword= serverpass
```

+ Only the host name part is changed in the agent config file on the server instance.
+ AllowOverride part of Apache's configuration file is being changed from denied to All.
+ Zabbix server service is started.

  ```sudo systemctl start zabbix-server.service```

## Further Information

For detailed information see the link below

[Monitoring EC2 Instance via Zabbix Using Terraform](https://www.serkancakar.com/articles/monitoring-ec2-instance-via-zabbix-using-terraform/ "title text!")
