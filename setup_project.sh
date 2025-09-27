#!/bin/bash

# Go to your repo (adjust if needed)
cd ~/devops-cicd-project || exit

echo "📂 Creating folders..."
mkdir -p app k8s terraform ansible

echo "📝 Creating Flask app..."
cat > app/app.py <<'EOF'
from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello from Flask App - Deployed via CI/CD Pipeline!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

cat > app/requirements.txt <<'EOF'
flask
EOF

cat > app/Dockerfile <<'EOF'
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
CMD ["python", "app.py"]
EOF

echo "📝 Creating Kubernetes manifests..."
cat > k8s/deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      containers:
      - name: flask-app
        image: your-dockerhub-username/flask-app:latest
        ports:
        - containerPort: 5000
EOF

cat > k8s/service.yaml <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: flask-service
spec:
  type: NodePort
  selector:
    app: flask-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
      nodePort: 30007
EOF

echo "📝 Creating Terraform files..."
cat > terraform/main.tf <<'EOF'
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
EOF

cat > terraform/variables.tf <<'EOF'
variable "region" {
  default = "us-east-1"
}
EOF

cat > terraform/outputs.tf <<'EOF'
output "master_ip" {
  value = aws_instance.k8s_master.public_ip
}

output "worker_ips" {
  value = [for instance in aws_instance.k8s_worker : instance.public_ip]
}
EOF

echo "📝 Creating Ansible files..."
cat > ansible/hosts.ini <<'EOF'
[master]
<master-public-ip>

[workers]
<worker1-public-ip>
<worker2-public-ip>
EOF

cat > ansible/setup.yml <<'EOF'
- hosts: all
  become: yes
  tasks:
    - name: Install dependencies
      apt:
        name: "{{ item }}"
        state: present
        update_cache: yes
      loop:
        - docker.io
        - apt-transport-https
        - curl

    - name: Install Kubernetes packages
      shell: |
        curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
        echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
        apt-get update
        apt-get install -y kubelet kubeadm kubectl
EOF

echo "📝 Creating Jenkinsfile..."
cat > Jenkinsfile <<'EOF'
pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "your-dockerhub-username/flask-app"
        DOCKER_TAG = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Dinesh06092016/devops-cicd-project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:$DOCKER_TAG ./app'
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker push $DOCKER_IMAGE:$DOCKER_TAG'
                }
            }
        }

        stage('Provision Infra with Terraform') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Configure with Ansible') {
            steps {
                dir('ansible') {
                    sh 'ansible-playbook -i hosts.ini setup.yml'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                dir('k8s') {
                    sh 'kubectl apply -f deployment.yaml'
                    sh 'kubectl apply -f service.yaml'
                }
            }
        }
    }
}
EOF

echo "✅ Project structure and files created successfully!"
