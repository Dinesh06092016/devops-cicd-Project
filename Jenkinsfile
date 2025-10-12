pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_CREDENTIALS')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_CREDENTIALS_PSW')
        DOCKER_HUB_USERNAME = credentials('DOCKER_HUB_CREDENTIALS')
        DOCKER_HUB_PASSWORD = credentials('DOCKER_HUB_CREDENTIALS_PSW')
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'main', url: 'https://github.com/Dinesh06092016/devops-cicd-Project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('app') {
                    sh 'docker build -t dinesh06092016/flask-app:latest .'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh """
                        echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME --password-stdin
                        docker push dinesh06092016/flask-app:latest
                    """
                }
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
                    sh 'ansible-playbook -i hosts.ini setup.yml --private-key /var/lib/jenkins/.ssh/22nd-Sep.pem'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
