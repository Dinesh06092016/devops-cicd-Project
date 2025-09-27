terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14.1"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
  
  # Default tags for all resources
  default_tags {
    tags = {
      Project     = "devops-cicd-project"
      Environment = "production"
      ManagedBy   = "terraform"
      Owner       = "devops-team"
      Cluster     = "kubernetes-cluster"
    }
  }
}

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
    description = "Kubernetes API Server"
    from_port   = 6443
    to_port     = 6443
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
    description = "NodePort Services"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Flask App Port"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes Node Communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
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

# K8s Master Node
resource "aws_instance" "k8s_master" {
  ami                    = "ami-0c55b159cbfafe1f0" # Ubuntu 22.04
  instance_type          = "t2.medium"
  key_name               = "22nd Sep"
  vpc_security_group_ids = [aws_security_group.k8s_cluster_sg.id]
  
  # User data to install Kubernetes components
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io
              
              # Install kubeadm, kubelet, kubectl
              curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
              echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
              apt-get update
              apt-get install -y kubeadm kubelet kubectl
              apt-mark hold kubeadm kubelet kubectl
              
              # Initialize Kubernetes master (this would be done manually or via more sophisticated provisioning)
              echo "Kubernetes master node ready for initialization"
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

# K8s Worker Nodes
resource "aws_instance" "k8s_worker" {
  count                  = 2
  ami                    = "ami-0c55b159cbfafe1f0" # Ubuntu 22.04
  instance_type          = "t2.medium"
  key_name               = "22nd Sep"
  vpc_security_group_ids = [aws_security_group.k8s_cluster_sg.id]
  
  # User data to install Kubernetes components on workers
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io
              
              # Install kubeadm, kubelet, kubectl
              curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
              echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
              apt-get update
              apt-get install -y kubeadm kubelet kubectl
              apt-mark hold kubeadm kubelet kubectl
              
              echo "Kubernetes worker node ready to join cluster"
              EOF

  tags = {
    Name = "k8s-worker-${count.index}"
    Role = "worker"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  depends_on = [aws_instance.k8s_master]
}

# Elastic IP for Master Node (optional but recommended)
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

output "k8s_master_public_dns" {
  description = "Public DNS of the Kubernetes master node"
  value       = aws_eip.k8s_master_eip.public_dns
}

output "k8s_worker_public_ips" {
  description = "Public IP addresses of Kubernetes worker nodes"
  value       = aws_instance.k8s_worker[*].public_ip
}

output "ssh_master_command" {
  description = "SSH command to connect to master node"
  value       = "ssh -i ~/.ssh/22nd-Sep.pem ubuntu@${aws_eip.k8s_master_eip.public_dns}"
}

output "ssh_worker_commands" {
  description = "SSH commands to connect to worker nodes"
  value       = [for i, worker in aws_instance.k8s_worker : "ssh -i ~/.ssh/22nd-Sep.pem ubuntu@${worker.public_dns}"]
}

output "kubernetes_cluster_info" {
  description = "Kubernetes cluster connection information"
  value       = <<EOT
  
  Kubernetes Cluster Created Successfully!
  
  Master Node:
    Public IP: ${aws_eip.k8s_master_eip.public_ip}
    SSH: ssh -i ~/.ssh/22nd-Sep.pem ubuntu@${aws_eip.k8s_master_eip.public_dns}
  
  Worker Nodes:
    %{for i, ip in aws_instance.k8s_worker[*].public_ip}
    Worker ${i}: ${ip} (ssh -i ~/.ssh/22nd-Sep.pem ubuntu@${ip})%{endfor}
  
  Next Steps:
  1. SSH into master node and initialize the cluster:
     kubeadm init --pod-network-cidr=10.244.0.0/16
     
  2. Set up kubectl on master:
     mkdir -p $HOME/.kube
     sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
     sudo chown $(id -u):$(id -g) $HOME/.kube/config
     
  3. Install network plugin (e.g., Flannel):
     kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
     
  4. Get join command for workers:
     kubeadm token create --print-join-command
     
  EOT
}
