pipeline {
    agent any

    environment {
        // Define environment variables
        SSH_USER = 'ubuntu' // Replace with the appropriate user (e.g., 'ec2-user' for Amazon Linux)
        EC2_IP = '13.235.113.220' // Replace with the public IP of your EC2 instance
        SSH_KEY_PATH = '/root/.ssh/id_ed25519' // Path to your private SSH key
        TOMCAT_WEBAPPS_DIR = '/opt/tomcat/webapps/' // Tomcat webapps directory on the EC2 instance
        SSH_CREDENTIALS_ID = 'Prod-server-cred' // Define your credential ID as an environment variable
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout code from your repository
                git branch: 'main', url: 'https://github.com/sibasish5151/AAS-Project.git'
            }
        }

        stage('Build') {
            steps {
                // Build the application (example for a Maven project)
                sh '/opt/maven/bin/mvn clean package'
            }
        }
        stage('Test') {
            steps {
                // Run the unit test of the application
                sh '/opt/maven/bin/mvn test'
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                // Use the credential ID in the withCredentials block
                withCredentials([sshUserPrivateKey(credentialsId: "${SSH_CREDENTIALS_ID}", keyFileVariable: 'SSH_KEY_PATH', usernameVariable: 'SSH_USER')]) {
                    def warFile = "/var/lib/jenkins/workspace/AAS-pipeline/target/*.war"
                    sh """
                    scp -i ${SSH_KEY_PATH} ${warFile} ${SSH_USER}@${EC2_IP}:${TOMCAT_WEBAPPS_DIR}
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
