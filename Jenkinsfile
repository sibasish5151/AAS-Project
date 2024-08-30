pipeline {
    agent any

    environment {
        // Define environment variables
        EC2_USER = 'ubuntu' // Replace with the appropriate user (e.g., 'ec2-user' for Amazon Linux)
        EC2_IP = '13.235.113.220' // Replace with the public IP of your EC2 instance
        PRIVATE_KEY_PATH = '/opt/new-aws-key.pem' // Path to your private SSH key
        TOMCAT_WEBAPPS_DIR = '/opt/tomcat/webapps/' // Tomcat webapps directory on the EC2 instance
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
                // Define the path to the .war file
                script {
                    def warFile = "/var/lib/jenkins/workspace/new-pipeline/target/*.war" // Update with the correct path

                    // Use scp to copy the .war file to the Tomcat server
                    sh """
                    scp -i ${PRIVATE_KEY_PATH} ${warFile} ${EC2_USER}@${EC2_IP}:${TOMCAT_WEBAPPS_DIR}
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
