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
                    // Add your tests here
                    sh 'echo "Running tests..."'
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
                    sh 'terraform plan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Update Ansible Inventory') {
            steps {
                script {
                    // This would be enhanced to dynamically get Terraform outputs
                    sh '''
                        echo "[master]" > ansible/hosts.ini
                        echo "master ansible_host=<MASTER_IP> ansible_user=ubuntu" >> ansible/hosts.ini
                        echo "" >> ansible/hosts.ini
                        echo "[workers]" >> ansible/hosts.ini
                        echo "worker1 ansible_host=<WORKER1_IP> ansible_user=ubuntu" >> ansible/hosts.ini
                        echo "worker2 ansible_host=<WORKER2_IP> ansible_user=ubuntu" >> ansible/hosts.ini
                    '''
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
                            ansible-playbook -i hosts.ini setup.yml \
                            --private-key $SSH_KEY \
                            --ssh-common-args="-o StrictHostKeyChecking=no"
                        '''
                    }
                }
            }
        }

        stage('Kubernetes Deployment') {
            steps {
                dir('k8s') {
                    // Update deployment with new image tag
                    sh "sed -i 's|your-dockerhub-username/flask-app:latest|${env.DOCKER_IMAGE}:${env.DOCKER_TAG}|g' deployment.yaml"
                    
                    sh '''
                        kubectl apply -f deployment.yaml
                        kubectl apply -f service.yaml
                        kubectl get pods
                        kubectl get services
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline execution completed"
        }
        success {
            echo "Pipeline succeeded! Application deployed."
        }
        failure {
            echo "Pipeline failed. Check logs for details."
        }
    }
}
