pipeline {
    agent any

    environment {
        // Fetch AWS credentials stored in Jenkins with ID 'aws-id'
        AWS_CREDENTIALS = credentials('aws-cred')
        // Fetch DockerHub credentials stored in Jenkins with ID 'docker-hub-id'
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-cred')
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git url: 'https://github.com/Dinesh06092016/devops-cicd-Project.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('app') {
                    sh """
                        docker build -t dinesh06092016/flask-app:latest .
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh """
                    echo $DOCKER_HUB_CREDENTIALS_PSW | docker login -u $DOCKER_HUB_CREDENTIALS_USR --password-stdin
                    docker push dinesh06092016/flask-app:latest
                """
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh """
                        export AWS_ACCESS_KEY_ID=$AWS_CREDENTIALS_USR
                        export AWS_SECRET_ACCESS_KEY=$AWS_CREDENTIALS_PSW
                        terraform init
                        terraform apply -auto-approve
                    """
                }
            }
        }

        stage('Deploy with Ansible') {
            steps {
                dir('ansible') {
                    sh """
                       ansible-playbook -i hosts.ini setup.yml --private-key /var/lib/jenkins/.ssh/22nd-sep.pem
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs for details."
        }
    }
}
