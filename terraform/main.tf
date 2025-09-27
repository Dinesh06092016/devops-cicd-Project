provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "k8s_master" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.medium"
  key_name      = "my-key"
  tags = {
    Name = "k8s-master"
  }
}

resource "aws_instance" "k8s_worker" {
  count         = 2
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.medium"
  key_name      = "my-key"
  tags = {
    Name = "k8s-worker-${count.index}"
  }
}
