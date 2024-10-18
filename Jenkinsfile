pipeline {  
    agent any   

    environment {  
        DOCKER_IMAGE = 'nginx:latest'  
        IMAGE_NAME = 'my-nginx-app'  
        CONTAINER_NAME = 'nginx-container'  
        // DEPLOY_DIR = '/path/to/deploy' // Update this to your deployment path  
    }  

    stages {  
        stage('Checkout') {  
            steps {  
                // Checkout the source code from the repository  
                git 'https://github.com/AWS-STUDY-73/AWS-INFRA-DEPL.git'  
            }  
        }  

        stage('Build Docker Image') {  
            steps {  
                script {  
                    // Build the Docker image  
                    sh "docker build -t ${IMAGE_NAME} ."  
                }  
            }  
        }  

        stage('Run Tests') {  
            steps {  
                script {  
                     sh "docker run -d -p 8000:8000 ${IMAGE_NAME}"  
                }  
            }  
        }  

        stage('Deploy') {  
            steps {  
                script {  
                    // Stop and remove any existing container  
                    sh "docker stop ${CONTAINER_NAME} || true"  
                    sh "docker rm ${CONTAINER_NAME} || true"  

                    // Run the new container  
                    sh "docker run -d --name ${CONTAINER_NAME} -p 80:80 ${IMAGE_NAME}"  
                }  
            }  
        }  
    }  

    post {  
        always {  
            // Always clean up resources  
            script {  
                // Optionally remove old images if you want  
                sh "docker rmi ${IMAGE_NAME} || true"   
            }  
        }  

        success {  
            echo 'Deployment Successful!'  
        }  

        failure {  
            echo 'Deployment Failed!'  
        }  
    }  
}
