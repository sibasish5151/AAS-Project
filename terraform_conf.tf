terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider aws {
    region = "ap-south-1"
    access_key = ""
    secret_key = ""
}

# Created my own VPC
resource "aws_vpc" "myvpc" {
    cidr_block = "192.168.0.0/16"
    tags = {
      Name = "myvpc"
    }
}

# Created a public subnet
resource "aws_subnet" "public_subnet1" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "ap-south-1a"
  cidr_block = "192.168.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet1"
  }
}

# Created another public subnet in different AZ for high availability
resource "aws_subnet" "public_subnet2" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "ap-south-1b"
  cidr_block = "192.168.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet2"
  }
}

# Created internet gateway to give the resource internet access
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "myigw"
  }
}

# Here's the route table to route the traffic among the subntes and instances
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
}

# Created the route table association to associate the subnet1 with the route table
resource "aws_route_table_association" "rt_association1" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id = aws_subnet.public_subnet1.id
}

# Created the route table association to associate the subnet2 with the route table
resource "aws_route_table_association" "rt_association2" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id = aws_subnet.public_subnet2.id
}

# Created security group to secure the instances from unexpected traffic by giving limited inbounds
resource "aws_security_group" "security" {
  vpc_id = aws_vpc.myvpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "security"
  }
}

# Created the below instance to access the Jenkins services
resource "aws_instance" "Jenkins_server" {
  ami = "ami-0522ab6e1ddcc7055"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet1.id
  vpc_security_group_ids = [aws_security_group.security.id]
  key_name = "new-aws-key.pem"
  tags = {
    Name = "Jenkins_server"
  }
}

# This is the Production environment server 
resource "aws_instance" "Production_server" {
  ami = "ami-0522ab6e1ddcc7055"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet1.id
  vpc_security_group_ids = [aws_security_group.security.id]
  key_name = "new-aws-key.pem"
  tags = {
    Name = "Production_server"
  }
}

# This is the Staging environment server
resource "aws_instance" "SIT_server" {
  ami = "ami-0522ab6e1ddcc7055"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet2.id
  vpc_security_group_ids = [aws_security_group.security.id]
  key_name = "new-aws-key.pem"
  tags = {
    Name = "SIT_server"
  }
}