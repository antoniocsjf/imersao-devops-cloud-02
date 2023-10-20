terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.22.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

    tags = {
        Name = "minha-vpc"
  }

}

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "minha-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "meu-internet-gw"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "minha-rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_key_pair" "deployer" {
  key_name   = "video-imersao-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDkFrpzSOqCa2dtlMx1vC1tbkTOPG9BLVLg1Z4prnpFZvS6LLRikKo774zdgXX/HFZMrBYkzskUXzeaDijQH8lcsDIz5jaQe2m6u6G6QkMn19V19QoW1qosrJL5QyUm8vxLKkJziILO2BMACJYGRENuGFAQGdnDxvmHXNU0/xJrEeJh+jkKqafd24aWM+ilMzpG/mQIRWaA/6mEilyRVX/QTa3qEohhlX0yny26uWCZjXdWvB2xA+f+3JqBtD8SGuZcUWjOm4YdXfl9FxSQfyt/AtFTp3nwvBiM1LKEbiSYOj7wPlENFd+C85cYa7wFmAxTbBkWHoC2Lyu3Y85W1Oyr toninho@SRV-CASA"
}


resource "aws_instance" "ec2" {
  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"
  subnet_id      = aws_subnet.subnet.id
  associate_public_ip_address = true
  key_name = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.aws_security_group.id]
  tags = {
    Name = "minha-ec2"
  }
}

resource "aws_security_group" "aws_security_group" {
  name        = "imersao-security-group"
  description = "SG Liberado"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Liberacao de portas"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "imersao-security-group"
  }
}

output "ip_ec2" {
    value = aws_instance.ec2.public_ip
 
}