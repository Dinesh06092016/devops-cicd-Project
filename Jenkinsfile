pipeline {
    agent any

    environment {
        AWS_CREDENTIALS = credentials('aws-credentials-id')
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials-id')
    }

    options {
        skipDefaultCheckout(true)  // We'll handle SCM checkout explicitly
        timestamps()
    }

    stages {

        stage('Clean Workspace') {
            steps {
                deleteDir() // Wipe out workspace to remove old repo/cache
            }
        }

        stage('Checkout SCM') {
            steps {
                git(
                    url: 'https://github.com/Dinesh06092016/devops-cicd-Project.git',
                    branch: 'main'
                )
            }
        }

        stage('Build Docker Image') {
            dir('app') {
                steps {
                    sh '''
                        docker build -t dinesh06092016/flask-app:latest .
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([string(credentialsId: 'docker-hub-credentials-id', variable: 'DOCKER_HUB_PASSWORD')]) {
                    sh '''
                        echo $DOCKER_HUB_PASSWORD | docker login -u dinesh06092016 --password-stdin
                        docker push dinesh06092016/flask-app:latest
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            dir('terraform') {
                steps {
                    withCredentials([[
                        $class: 'UsernamePasswordMultiBinding',
                        credentialsId: 'aws-credentials-id',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                            terraform init
                            terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Deploy with Ansible') {
            dir('ansible') {
                steps {
                    sh '''
                        ansible-playbook -i hosts.ini setup.yml --private-key /var/lib/jenkins/.ssh/22nd-Sep.pem
                    '''
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
