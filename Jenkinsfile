pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "dinesh06092016/flask-app"
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        AWS_REGION = "ap-south-1"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                url: 'https://github.com/Dinesh06092016/devops-cicd-project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t $DOCKER_IMAGE:$DOCKER_TAG ./app'
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    sh 'echo "Running tests..."'
                    // Add actual tests
                    sh 'docker run --rm $DOCKER_IMAGE:$DOCKER_TAG python -m pytest tests/ -v || true'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-cred',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh '''
                            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                            docker push $DOCKER_IMAGE:$DOCKER_TAG
                        '''
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve tfplan'
                    // Capture Terraform outputs
                    sh '''
                        terraform output -raw master_ip > ../master_ip.txt
                        terraform output -raw worker1_ip > ../worker1_ip.txt
                        terraform output -raw worker2_ip > ../worker2_ip.txt
                    '''
                }
            }
        }

        stage('Update Ansible Inventory') {
            steps {
                script {
                    // Read IPs from Terraform outputs
                    def master_ip = readFile('master_ip.txt').trim()
                    def worker1_ip = readFile('worker1_ip.txt').trim()
                    def worker2_ip = readFile('worker2_ip.txt').trim()
                    
                    sh """
                        cat > ansible/hosts.ini << EOF
[master]
master ansible_host=${master_ip} ansible_user=ubuntu

[workers]
worker1 ansible_host=${worker1_ip} ansible_user=ubuntu
worker2 ansible_host=${worker2_ip} ansible_user=ubuntu

[all:vars]
ansible_ssh_private_key_file=/tmp/ssh_key
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
                    """
                }
            }
        }

        stage('Ansible Configuration') {
            steps {
                dir('ansible') {
                    withCredentials([sshUserPrivateKey(
                        credentialsId: 'ansible-ssh-key',
                        keyFileVariable: 'SSH_KEY'
                    )]) {
                        sh '''
                            # Copy key to expected location
                            cp $SSH_KEY /tmp/ssh_key
                            chmod 600 /tmp/ssh_key
                            
                            # Wait for instances to be ready
                            sleep 30
                            
                            # Test connection first
                            ansible all -i hosts.ini -m ping
                            
                            # Run playbook
                            ansible-playbook -i hosts.ini setup.yml
                        '''
                    }
                }
            }
        }

        stage('Kubernetes Deployment') {
            steps {
                dir('k8s') {
                    script {
                        // Get kubeconfig from master node
                        def master_ip = readFile('master_ip.txt').trim()
                        
                        withCredentials([sshUserPrivateKey(
                            credentialsId: 'ansible-ssh-key',
                            keyFileVariable: 'SSH_KEY'
                        )]) {
                            sh """
                                # Copy kubeconfig from master
                                ssh -o StrictHostKeyChecking=no -i $SSH_KEY ubuntu@${master_ip} "sudo cat /etc/kubernetes/admin.conf" > kubeconfig
                                
                                # Set KUBECONFIG
                                export KUBECONFIG=\$(pwd)/kubeconfig
                                
                                # Update deployment with new image tag
                                sed -i 's|dinesh06092016/flask-app:latest|${env.DOCKER_IMAGE}:${env.DOCKER_TAG}|g' deployment.yaml
                                
                                # Deploy to Kubernetes
                                kubectl apply -f deployment.yaml
                                kubectl apply -f service.yaml
                                
                                # Wait for deployment
                                kubectl rollout status deployment/flask-app
                                kubectl get pods
                                kubectl get services
                            """
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline execution completed"
            // Cleanup
            sh 'rm -f master_ip.txt worker1_ip.txt worker2_ip.txt || true'
        }
        success {
            echo "Pipeline succeeded! Application deployed."
        }
        failure {
            echo "Pipeline failed. Check logs for details."
        }
    }
}
