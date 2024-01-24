terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider
provider "aws" {
  region = "ap-southeast-1"
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "103.0.0.0/16"

  tags = {
    Name = "vpc"
  }
}

# Internet gateway
resource "aws_internet_gateway" "gw" {
  # Assign to VPC
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "gw"
  }
}

# Route table
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "route-table"
  }
}

# Private subnet
resource "aws_subnet" "private_subnet1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "103.0.1.0/24"

  tags = {
    Name = "subnet-private-1"
  }
}
resource "aws_subnet" "private_subnet2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "103.0.2.0/24"

  tags = {
    Name = "subnet-private-2"
  }
}

# Public subnet
resource "aws_subnet" "public_subnet1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "103.0.3.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-public-1"
  }
}
resource "aws_subnet" "public_subnet2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "103.0.4.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-public-2"
  }
}

# Make public subnet connect to internet
resource "aws_route_table_association" "rtb_1" {
  subnet_id = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.route_table_public.id
}
resource "aws_route_table_association" "rtb_2" {
  subnet_id = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.route_table_public.id
}

# Allow ICMP
resource "aws_security_group" "allow_icmp" {
  name        = "allow_icmp"
  description = "Allow ICMP"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-icmp"
  }
}

# Allow SSH
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow port 80
resource "aws_security_group" "allow_80" {
  name        = "allow_80"
  description = "Allow 80 inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# EC2
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

/*
-----BEGIN RSA PRIVATE KEY-----
MIICXgIBAAKBgQC40hlqGMJeubEivuzydiYej7akq8Mro3o5scP0FEaDjzFb/K0N
6tdL/OfbBVG3PRduozz6gzvFRACIjzk/Wx+rNN9YRXff8ik3wL5V/Myq2LJQtk35
bdSXAh9DUI39Rseh+jt1948r1rx0jPK5Sz64vf4T+he3b9OGj2HVG8RMtQIDAQAB
AoGAGhA22Uloj6csHbRDAeY7de/aV9qJCWxiXiR9d7wsPX1B/rDhTqcheWvO3oof
ffG1jjqi7Mj48tamJJvd/NtC2cqTsmMlF/9mAsWT7Lex6QaMGT+1dALQDdlhlw0y
UKvsfWfw9Jm1N34uEo7q+ZkDhXE1oS2xpCf0etOn5uVLBjkCQQDiHhp6iytILoRm
QR0tYDR+ub47uLGqrJ2KDgFhyZOvUNiF6s7/vcDL923ib3G0cMvpTXvALs2AA8rw
T6bw5TNXAkEA0T7cNhTIe7h+ZzYxHssepEkg3DuKkQSchlIQDTLwCf9dW8NefMgF
u8hGLnyeEVEK5HLsrGW7hfszHSO6BHtk0wJBAJDY8+FYUUuV8N6IC6bLoBUl60Ta
lYVdujV7r0rzFBYUVf/DYQLWjTCbudp5xX7vWtCDACkmUiIVS+URQUHDsVUCQQDQ
CeaZ4on98E3Ewm2OBzd88bQ5Iv2+903EgnyxEs7zsbCZlqIwABMrQ5D7kSz7XI8u
2VCUi0UpjbqhIy9EW4a/AkEA0o4T27CbK6r4p+QtJIk5BAGuwqBbeRciLB3jqF4R
bC2R3sFD9S6dIXgxVN553u2Iug3DNZ/OjQZG21y5NAP/2g==
-----END RSA PRIVATE KEY-----
*/
resource "aws_key_pair" "ssh_key_1" {
  key_name   = "ssh-key-1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQC40hlqGMJeubEivuzydiYej7akq8Mro3o5scP0FEaDjzFb/K0N6tdL/OfbBVG3PRduozz6gzvFRACIjzk/Wx+rNN9YRXff8ik3wL5V/Myq2LJQtk35bdSXAh9DUI39Rseh+jt1948r1rx0jPK5Sz64vf4T+he3b9OGj2HVG8RMtQ=="
}
/*
-----BEGIN RSA PRIVATE KEY-----
MIICXwIBAAKBgQDCX3sO6fvGjz9kM7NajsbmMD8tGt9gjvZkB0HZrwcsRcktsboa
d6cb4ZdBXoCTi80YvvreXdYtOdZnGPYr4L8mvisY62fAzEHkTifURQH+xK0t958o
CmxK5Ny7lUqTt7xPObuix3j8CeFh05t+OYhk/LwuGHRxVmGjiCA7cWZq5QIDAQAB
AoGBAJfEve1zPahYiYLP66c1/JAX8/xgEzLt7e1EzWIPjGZBR0hqkYnBC7Z1ewkL
pRGQA2DjHjcqxeUiWArALtcr8ZQLwx6Zvfjur9BOfvtKPsP6KwDawkrqkLNtbC4S
ulHdcbyDoV+7he9Z1hCUSiPsBkh6NiQV4e3D1fiXZ88kEmGBAkEA/EIal67N69Vq
kzPoP19K27bOz/047Cm7Pba25caLCYfdbC9duXunhRjF0G8nSuXOr+ezlwkZnv6Z
xPl6a2WkaQJBAMVBkfGGoLp6sDViIiAeqNG8Gs8CI2cKrj0xSXf7waSPw8LK6D1J
f1ffOs61/mm2HYL3bRkcuK45IhGXn3xXEx0CQQCTChEoI1uiwRbLUTFqZyhiY++v
KwJYHocnFO8Nhqqa1phJrF5sdNiT63m64l+797J/tIZpXoORuwR03ZrvKSMpAkEA
r0vbJ9ntgms/puFD1GmKu4DADlEnJw4909G2KbOI3faJENYDV1u2mF+gQk1H/6fB
SD8cLCHzGZlaZmnpaLV1HQJBAPBfLDS1RSFq/ynABntucwWF5F/0l6YWKvRISUqt
ZgYDZjGwDIepTWtWHQxy/qr22hUo4NoWjW1hXomCeC5klFA=
-----END RSA PRIVATE KEY-----
*/
resource "aws_key_pair" "ssh_key_2" {
  key_name   = "ssh-key-2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDCX3sO6fvGjz9kM7NajsbmMD8tGt9gjvZkB0HZrwcsRcktsboad6cb4ZdBXoCTi80YvvreXdYtOdZnGPYr4L8mvisY62fAzEHkTifURQH+xK0t958oCmxK5Ny7lUqTt7xPObuix3j8CeFh05t+OYhk/LwuGHRxVmGjiCA7cWZq5Q=="
}

# Private ip
resource "aws_network_interface" "internal_ip_public_subnet" {
  subnet_id   = aws_subnet.public_subnet1.id
  private_ips = ["103.0.3.10"]
  security_groups = [
    aws_security_group.allow_icmp.id,
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_80.id,
  ]

  tags = {
    Name = "public-subnet-interface"
  }
}
resource "aws_network_interface" "internal_ip_private_subnet" {
  subnet_id   = aws_subnet.private_subnet1.id
  private_ips = ["103.0.1.10"]
  security_groups = [
    aws_security_group.allow_icmp.id,
    aws_security_group.allow_ssh.id,
  ]

  tags = {
    Name = "private-subnet-interface"
  }
}

# Public instance
resource "aws_instance" "instance1" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.ssh_key_1.id

  network_interface {
    network_interface_id = aws_network_interface.internal_ip_public_subnet.id
    device_index = 0
  }

  user_data = <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install -y nginx
echo "Hello World" > /var/www/html/index.html
EOF

  tags = {
    Name = "ec2-web-instance"
  }
}
# Private instance
resource "aws_instance" "instance2" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.ssh_key_2.id

  network_interface {
    network_interface_id = aws_network_interface.internal_ip_private_subnet.id
    device_index         = 0
  }

  tags = {
    Name = "ec2-db-instance"
  }
}

# Elastic ip
resource "aws_eip" "eip1" {
  domain = "vpc"
  instance = aws_instance.instance1.id

  tags = {
    Name = "elastic-ip-1"
  }
}
# Elastic ip for NAT Gateway
resource "aws_eip" "eip2" {
  domain = "vpc"

  tags = {
    Name = "elastic-ip-2"
  }
}

# NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip2.id
  subnet_id = aws_subnet.public_subnet1.id
  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = "nat-gateway"
  }
}

# Create route table
resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }
}
resource "aws_route_table_association" "rtb_3" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.route_table_private.id
}
