pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-id')
        AWS_CREDENTIALS = credentials('aws-id')
        SSH_KEY_ID = 'aws-ssh-key' // PEM key stored in Jenkins credentials
    }
    stages {
        stage('Prepare SSH') {
            steps {
                script {
                    // Copy PEM key to Jenkins .ssh directory
                    sh """
                        mkdir -p ~/.ssh
                        cp \$SSH_KEY_ID ~/.ssh/22nd-Sep.pem
                        chmod 400 ~/.ssh/22nd-Sep.pem
                        
                        # Add EC2 hosts to known_hosts
                        touch ~/.ssh/known_hosts
                        ssh-keyscan -H 3.111.32.154 >> ~/.ssh/known_hosts
                        ssh-keyscan -H 13.232.255.82 >> ~/.ssh/known_hosts
                        chmod 644 ~/.ssh/known_hosts
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t dinesh06092016/flask-app:latest -f app/Dockerfile app'
            }
        }

        stage('Push to DockerHub') {
            steps {
                sh """
                    echo \$DOCKER_HUB_CREDENTIALS_PSW | docker login -u \$DOCKER_HUB_CREDENTIALS_USR --password-stdin
                    docker push dinesh06092016/flask-app:latest
                """
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Deploy with Ansible') {
            steps {
                dir('ansible') {
                    sh 'ansible-playbook -i hosts.ini setup.yml'
                }
            }
        }
    }
    post {
        failure {
            echo "Pipeline failed. Check logs!"
        }
    }
}
