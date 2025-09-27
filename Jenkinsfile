pipeline {
    agent any

    environment {
        DOCKER_USER = credentials('docker-username')   // Jenkins credential ID for DockerHub username
        DOCKER_PASS = credentials('docker-password')   // Jenkins credential ID for DockerHub password
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = "dinesh06092016/devops-cicd-project:${env.BUILD_NUMBER}"
                    sh "docker build -t ${imageTag} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    def imageTag = "dinesh06092016/devops-cicd-project:${env.BUILD_NUMBER}"
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    sh "docker push ${imageTag}"
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline execution completed"
        }
    }
}
