provider "aws" {
  region = var.aws_region  # 替换为你的目标区域
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.tag
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "my-route-table"
  }
}

resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}


resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidr
  # availability_zone = var.availability_zone  # 替换为你的目标可用区

  tags = {
    Name = var.tag
  }
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "mac-mini"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINTXsK5+k8y2H5c/F7OsvKbDKt51v0DJPedV7hOa3R3P wushengguo@wushengguosMini.lan"  # 替换为你的公钥
}

resource "aws_security_group" "my_security_group" {
  name        = "my-security-group"
  description = "My security group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 允许从任何IP地址SSH访问
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 允许从任何IP地址SSH访问
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]  # 允许从任何IP地址SSH访问
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # 允许出站流量到任何IP地址
  }

  tags = {
    Name = var.tag
  }
}

/*  use launch template instead, so can use init script
resource "aws_instance" "my_instance" {
  ami           = var.ami_id  # 替换为你的目标AMI
  instance_type = var.instance_type
  key_name      = aws_key_pair.my_key_pair.key_name
  subnet_id     = aws_subnet.my_subnet.id
  associate_public_ip_address = true  # 启用自动分配公共IP，
  # security_groups = [aws_security_group.my_security_group.id]  # syntax error
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  tags = {
    Name = var.tag
  }
}
*/


# create launch template
resource "aws_launch_template" "my_launch_template" {
  name_prefix   = "my-launch-template"
  image_id      = var.ami_id  
  instance_type = var.instance_type  
  key_name      = aws_key_pair.my_key_pair.key_name 

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = aws_subnet.my_subnet.id
    security_groups = [aws_security_group.my_security_group.id]
  }

  user_data = filebase64("${path.module}/startup.sh")

  tags = {
    Name = "my-launch-template"
  }
}

resource "aws_instance" "my_instance" {
  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "$Latest"
  }

  tags = {
    Name = var.tag
  }
}