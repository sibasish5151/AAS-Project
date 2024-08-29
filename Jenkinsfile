pipeline {
    agent any

    environment {
        EC2_USER = 'ubuntu'                   // EC2 instance username
        EC2_IP = '13.201.120.222'         // EC2 instance IP
        SSH_CREDENTIALS_ID = 'Prod-server-cred' // Jenkins credentials ID for SSH key
        TOMCAT_WEBAPPS_DIR = '/opt/tomcat/webapps/' // Path to Tomcat webapps directory
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/sibasish5151/AAS-Project.git'
            }
        }

        stage('Build') {
            steps {
                sh '/opt/maven/bin/mvn clean package'
            }
        }

        stage('Test') {
            steps {
                sh '/opt/maven/bin/mvn test'
            }
        }

        stage('Checkstyle') {
            steps {
                sh '/opt/maven/bin/mvn checkstyle:check'
            }
        }

        stage('Dependency Check') {
            steps {
                sh '/opt/maven/bin/mvn dependency-check:check'
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                sshagent([SSH_CREDENTIALS_ID]) {
                    sh """
                        scp -o StrictHostKeyChecking=no target/*.war ${EC2_USER}@${EC2_IP}:${TOMCAT_WEBAPPS_DIR}
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_IP} 'sudo systemctl restart tomcat'
                    """
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: '**/target/*.war', allowEmptyArchive: true
        }
        failure {
            mail to: 'sibasish5151@gmail.com',
                 subject: "Build failed in Jenkins: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                 body: "Please check the Jenkins console output for more details."
        }
    }
}
