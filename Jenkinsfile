pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "dinesh06092016/flask-app"
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        AWS_REGION = "ap-south-1"
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    // Try to checkout without specifying branch first
                    try {
                        checkout scm
                    } catch (Exception e) {
                        echo "Default checkout failed, trying main branch..."
                        git branch: 'main', 
                        url: 'https://github.com/Dinesh06092016/devops-cicd-project.git'
                    }
                }
            }
        }
        
        // Rest of your stages remain the same...
        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t $DOCKER_IMAGE:$DOCKER_TAG ./app'
                }
            }
        }
        
        // ... other stages
    }
    
    post {
        always {
            echo "Pipeline execution completed"
        }
    }
}
