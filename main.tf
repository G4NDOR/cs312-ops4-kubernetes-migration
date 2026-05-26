terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.41.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# --- DATA SOURCES ---
data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# --- SECURITY GROUP ---
resource "aws_security_group" "k3s_sg" {
  name        = "ops4-k3s-sg-${var.onid}"
  description = "Security group for single-node k3s cluster"
  vpc_id      = data.aws_vpc.default.id

  # SSH Access - Single rule restricted to your exact laptop IPv4
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"] # /32 locks it strictly to your laptop address
  }

  # Minecraft Game Traffic - Single rule open to all standard players
  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 0.0.0.0/0 opens it to the internet
  }

  # Outbound Traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- EC2 INSTANCE ---
resource "aws_instance" "k3s_node" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]
  iam_instance_profile   = "LabInstanceProfile"

  root_block_device {
    volume_size = 20 # Upgraded to 20GB to hold k3s data, logs, and container images safely
    volume_type = "gp3"
  }

  tags = {
    Name  = "ops4-k3s-${var.onid}"
    Owner = var.onid
  }
}

# --- OUTPUTS ---
output "k3s_public_ip" {
  value       = aws_instance.k3s_node.public_ip
  description = "Use this Public IP to SSH into your k3s node and connect to Minecraft"
}