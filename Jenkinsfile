pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "dinesh06092016/flask-app"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Dinesh06092016/devops-cicd-project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = "${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                    sh "docker build -t ${imageTag} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        def imageTag = "${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker push ${imageTag}"
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh """
                        terraform init
                        terraform apply -auto-approve
                    """
                }
            }
        }

        stage('Ansible Deploy') {
            steps {
                dir('ansible') {
                    sh """
                        ansible-playbook -i inventory.ini playbook.yml
                    """
                }
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                dir('k8s') {
                    sh """
                        kubectl apply -f deployment.yaml
                        kubectl apply -f service.yaml
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline executed successfully!"
        }
        failure {
            echo "Pipeline failed. Please check logs."
        }
    }
}
