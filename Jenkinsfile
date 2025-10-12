pipeline {
    agent any

    environment {
        // AWS credentials ID in Jenkins
        AWS_CREDENTIALS = credentials('aws-credentials-id')
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials-id')
    }

    stages {

        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Workspace Debug') {
            steps {
                sh 'pwd'
                sh 'ls -l'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t dinesh06092016/flask-app:latest -f app/Dockerfile app'
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    sh """
                        echo ${DOCKER_HUB_CREDENTIALS_PSW} | docker login -u ${DOCKER_HUB_CREDENTIALS_USR} --password-stdin
                        docker push dinesh06092016/flask-app:latest
                    """
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    if (AWS_CREDENTIALS) {
                        dir('terraform') {
                            withEnv([
                                "AWS_ACCESS_KEY_ID=${AWS_CREDENTIALS_USR}",
                                "AWS_SECRET_ACCESS_KEY=${AWS_CREDENTIALS_PSW}"
                            ]) {
                                sh 'terraform init'
                                sh 'terraform apply -auto-approve'
                            }
                        }
                    } else {
                        echo "AWS credentials not found. Skipping Terraform."
                    }
                }
            }
        }

        stage('Deploy with Ansible') {
            steps {
                script {
                    dir('ansible') {
                        if (fileExists('deploy.yml')) {
                            sh 'ansible-playbook -i hosts.ini deploy.yml'
                        } else {
                            echo "Ansible playbook deploy.yml not found. Skipping Ansible deployment."
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the logs for details.'
        }
    }
}
