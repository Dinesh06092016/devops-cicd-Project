pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'dinesh06092016'
        DOCKER_HUB_PASSWORD = credentials('docker-hub-password') // Jenkins credential ID
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')        // Jenkins credential ID
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')    // Jenkins credential ID
        PEM_PATH = '/var/lib/jenkins/.ssh/22nd-Sep.pem'          // Correct PEM filename
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: 'main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/Dinesh06092016/devops-cicd-Project.git'
                    ]]
                ])
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
                sh '''
                echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USER --password-stdin
                docker push dinesh06092016/flask-app:latest
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    terraform init
                    terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Deploy with Ansible') {
            steps {
                dir('ansible') {
                    sh "ansible-playbook -i hosts.ini setup.yml --private-key ${PEM_PATH}"
                }
            }
        }
    }

    post {
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
