pipeline {
    agent any

    environment {
        // AWS credentials, but optional
        AWS_CREDENTIALS = credentials('aws-credentials-id')
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t dinesh06092016/flask-app:latest -f app/Dockerfile app'
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-credentials-id',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker push dinesh06092016/flask-app:latest'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    if (env.AWS_CREDENTIALS) {
                        dir('terraform') {
                            withEnv(["AWS_ACCESS_KEY_ID=${env.AWS_CREDENTIALS_USR}", "AWS_SECRET_ACCESS_KEY=${env.AWS_CREDENTIALS_PSW}"]) {
                                sh 'terraform init'
                                sh 'terraform apply -auto-approve'
                            }
                        }
                    } else {
                        echo "AWS credentials not found. Skipping Terraform deployment."
                    }
                }
            }
        }

        stage('Deploy with Ansible') {
            steps {
                dir('ansible') {
                    script {
                        if (fileExists('deploy.yml')) {
                            sh 'ansible-playbook -i hosts.ini deploy.yml'
                        } else {
                            echo "deploy.yml not found. Skipping Ansible deployment."
                        }
                    }
                }
            }
        }
    }

    post {
        failure {
            echo "Pipeline failed. Check the logs for details."
        }
        success {
            echo "Pipeline completed successfully!"
        }
    }
}
