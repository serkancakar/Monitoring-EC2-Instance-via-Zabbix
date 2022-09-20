terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region     = "eu-central-1"
}

# Internet VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "main"
  }
}

# Subnet
resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-central-1a"

  tags = {
    Name = "instance_subnet"
  }
}

# Internet GW
resource "aws_internet_gateway" "Gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

# route table
resource "aws_route_table" "Route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Gw.id
  }

  tags = {
    Name = "main-public-1"
  }
}

# route associations public
resource "aws_route_table_association" "main-public-1-a" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.Route_table.id
}


resource "aws_security_group" "for-ssh" {
  vpc_id      = aws_vpc.main.id
  name        = "for-ssh"
  description = "security group that allows ssh and all egress traffic"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "for-ssh"
  }
  ingress {
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  ingress {
    from_port         = 10050
    to_port           = 10050
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  ingress {
    from_port         = 10051
    to_port           = 10051
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "aws_instance" "Zabbix_agent"{
  ami           = "ami-06cac34c3836ff90b"
  instance_type = "t2.micro"

  tags = {
    Name = "Zabbix_agent"
  }

  connection {
    type     = "ssh"
    user     = "ubuntu"
    host     = self.public_ip
    private_key = file(var.PATH_TO_PRIVATE_KEY)
    timeout = "4m"
    agent = false
   }

  provisioner "file" {
   source = "zabbix-agent.sh"
   destination = "/tmp/zabbix-agent.sh"
 }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/zabbix-agent.sh",
    ]    
 }
  provisioner "remote-exec" {
    inline = [
      "/bin/bash /tmp/zabbix-agent.sh",
    ]    
 }


# the VPC Subnet

subnet_id = aws_subnet.main_subnet.id

# the Security Group

vpc_security_group_ids = [aws_security_group.for-ssh.id]
    
# the public SSH key

key_name = aws_key_pair.mykey.key_name
 
}

resource "aws_instance" "Zabbix_proxy"{
  ami           = "ami-06cac34c3836ff90b"
  instance_type = "t2.micro"
  private_ip = "10.0.1.118"

  tags = {
    Name = "Zabbix_proxy"
  }
  connection {
    type     = "ssh"
    user     = "ubuntu"
    host     = self.public_ip
    private_key = file(var.PATH_TO_PRIVATE_KEY)
    timeout = "4m"
    agent = false
    }
  provisioner "file" {
    source = "zabbix-proxy.sh"
    destination = "/tmp/zabbix-proxy.sh"
     }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/zabbix-proxy.sh",
     ]    
   }

  provisioner "remote-exec" {
    inline = [
      "/bin/bash /tmp/zabbix-proxy.sh",
    ]    
   }


# the VPC subnet
subnet_id = aws_subnet.main_subnet.id

 # the security group
vpc_security_group_ids = [aws_security_group.for-ssh.id]

# the public SSH key
key_name = aws_key_pair.mykey.key_name
 
}

resource "aws_instance" "Zabbix_server"{
  ami           = "ami-06cac34c3836ff90b"
  instance_type = "t2.micro"
  private_ip = "10.0.1.148"

  tags = {
    Name = "Zabbix_server"
  }
  connection {
    type     = "ssh"
    user     = "ubuntu"
    host     = self.public_ip
    private_key = file(var.PATH_TO_PRIVATE_KEY)
    timeout = "4m"
    agent = false
    }

  provisioner "file" {
    source = "zabbix-server.sh"
    destination = "/tmp/zabbix-server.sh"
     }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/zabbix-server.sh",
     ]    
   }

  provisioner "remote-exec" {
    inline = [
      "/bin/bash /tmp/zabbix-server.sh",
    ]    
   }

# the VPC subnet
subnet_id = aws_subnet.main_subnet.id

 # the security group
vpc_security_group_ids = [aws_security_group.for-ssh.id]

# the public SSH key
key_name = aws_key_pair.mykey.key_name
 
}