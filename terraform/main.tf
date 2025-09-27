# Master Node Resource
resource "aws_instance" "k8s_master_node" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.medium"
  key_name      = "your-key-pair"
  subnet_id     = aws_subnet.main.id
  
  tags = {
    Name = "k8s-master"
  }
}

# Worker Nodes Resource
resource "aws_instance" "worker_nodes" {
  count         = 2  # Number of worker nodes
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  key_name      = "your-key-pair"
  subnet_id     = aws_subnet.main.id
  
  tags = {
    Name = "k8s-worker-${count.index}"
  }
}
