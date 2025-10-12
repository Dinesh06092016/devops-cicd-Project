pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-cred') // DockerHub credentials ID
        AWS_CREDENTIALS = credentials('aws-cred')             // AWS credentials ID in Jenkins
        IMAGE_NAME = 'dinesh06092016/flask-app'
        IMAGE_TAG = 'latest'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git url: 'https://github.com/Dinesh06092016/devops-cicd-Project.git', branch: 'main'
            }
        }

        stage('Workspace Debug') {
            steps {
                sh 'pwd && ls -l'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -f app/Dockerfile app"
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    sh """
                        echo $DOCKER_HUB_CREDENTIALS_PSW | docker login -u $DOCKER_HUB_CREDENTIALS_USR --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    withEnv([
                        "AWS_ACCESS_KEY_ID=${AWS_CREDENTIALS_USR}",
                        "AWS_SECRET_ACCESS_KEY=${AWS_CREDENTIALS_PSW}"
                    ]) {
                        sh 'terraform init'
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Deploy with Ansible') {
            steps {
                dir('ansible') {
                   script {
                // List files to make sure deploy.yml and hosts.ini exist
                sh 'echo "Listing Ansible directory:"'
                sh 'ls -l'

                // Run Ansible playbook
                sh 'ansible-playbook -i hosts.ini deploy.yml'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Please check logs.'
        }
    }
}
