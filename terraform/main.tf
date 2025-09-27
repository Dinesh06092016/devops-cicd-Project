terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14.1"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# Get the latest Ubuntu 22.04 AMI for ap-south-1 - FIXED FILTER
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Alternative: Use a specific known AMI ID for ap-south-1 if data source fails
# ami = "ami-0f5ee92e2d63afc18"  # Ubuntu 22.04 LTS in ap-south-1

# Security Group for Kubernetes Cluster
resource "aws_security_group" "k8s_cluster_sg" {
  name        = "k8s-cluster-sg"
  description = "Security group for Kubernetes cluster nodes"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Flask App"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-cluster-sg"
  }
}

# K8s Master Node - Using t2.micro for Free Tier
resource "aws_instance" "k8s_master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "22nd Sep"
  vpc_security_group_ids = [aws_security_group.k8s_cluster_sg.id]
  
  # Simplified user data for basic setup
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "k8s-master"
    Role = "master"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }
}

# K8s Worker Nodes - Using t2.micro for Free Tier
resource "aws_instance" "k8s_worker" {
  count                  = 2
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "22nd Sep"
  vpc_security_group_ids = [aws_security_group.k8s_cluster_sg.id]
  
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "k8s-worker-${count.index}"
    Role = "worker"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }
}

# Elastic IP for Master Node
resource "aws_eip" "k8s_master_eip" {
  instance = aws_instance.k8s_master.id
  domain   = "vpc"
  
  tags = {
    Name = "k8s-master-eip"
  }
}

# Output values
output "k8s_master_public_ip" {
  description = "Public IP address of the Kubernetes master node"
  value       = aws_eip.k8s_master_eip.public_ip
}

output "k8s_worker_public_ips" {
  description = "Public IP addresses of Kubernetes worker nodes"
  value       = aws_instance.k8s_worker[*].public_ip
}

output "ssh_master_command" {
  description = "SSH command to connect to master node"
  value       = "ssh -i '22nd-Sep.pem' ubuntu@${aws_eip.k8s_master_eip.public_ip}"
}

output "cluster_info" {
  description = "Kubernetes cluster connection information"
  value = <<EOT
Kubernetes Cluster Created Successfully!

Master Node: ${aws_eip.k8s_master_eip.public_ip}
Worker Nodes: ${join(", ", aws_instance.k8s_worker[*].public_ip)}

SSH to master: ssh -i "22nd-Sep.pem" ubuntu@${aws_eip.k8s_master_eip.public_ip}

Note: Using t2.micro instances for Free Tier compatibility.
EOT
}
