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
                        git branch: 'main', url: 'https://github.com/Dinesh06092016/devops-cicd-project.git'
                    }
                }
            }
        }
        
        // Rest of your stages remain the same...
        stage('Push Docker Image') {
    steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh """
              echo "$DOCKER_PASS" | docker login -u "$Dinesh06092016" --password-Ruksana@2016
              docker push dinesh06092016/flask-app:5
            """
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
