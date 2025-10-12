pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-id')
        AWS_CREDENTIALS = credentials('aws-id')
        SSH_KEY_ID = 'aws-ssh-key' // Jenkins secret file ID
    }
    stages {
        stage('Prepare SSH') {
            steps {
                // Copy the PEM file from Jenkins credentials to a temp directory
                withCredentials([file(credentialsId: SSH_KEY_ID, variable: 'SSH_KEY')]) {
                    sh """
                        mkdir -p \$WORKSPACE/.ssh
                        cp \$SSH_KEY \$WORKSPACE/.ssh/22nd-Sep.pem
                        chmod 400 \$WORKSPACE/.ssh/22nd-Sep.pem
                        
                        # Add EC2 hosts to known_hosts in workspace
                        touch \$WORKSPACE/.ssh/known_hosts
                        ssh-keyscan -H 3.111.32.154 >> \$WORKSPACE/.ssh/known_hosts
                        ssh-keyscan -H 13.232.255.82 >> \$WORKSPACE/.ssh/known_hosts
                        chmod 644 \$WORKSPACE/.ssh/known_hosts
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
                    // Use workspace SSH folder for Ansible
                    sh """
                        ansible-playbook -i hosts.ini -e "ansible_ssh_private_key_file=$WORKSPACE/.ssh/22nd-Sep.pem" setup.yml
                    """
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
