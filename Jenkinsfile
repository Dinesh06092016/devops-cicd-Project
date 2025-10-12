pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-cred') // Your DockerHub credentials ID
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
                    script {
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
                        sh 'ansible-playbook -i hosts.ini setup.yml'
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
            echo 'Pipeline failed. Please check logs.'
        }
    }
}
