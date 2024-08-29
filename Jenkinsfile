pipeline {
    agent any

    environment {
        EC2_USER = 'ubuntu'                   // EC2 instance username
        EC2_IP = '192.168.1.203'         // EC2 instance IP
        SSH_CREDENTIALS_ID = 'Prod-server-cred' // Jenkins credentials ID for SSH key
        TOMCAT_WEBAPPS_DIR = '/opt/tomcat/webapps/' // Path to Tomcat webapps directory
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/sibasish5151/AAS-Project.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Checkstyle') {
            steps {
                sh 'mvn checkstyle:check'
            }
        }

        stage('Dependency Check') {
            steps {
                sh 'mvn dependency-check:check'
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
            archiveArtifacts artifacts: '**/target/checkstyle-result.xml', allowEmptyArchive: true
            archiveArtifacts artifacts: '**/target/dependency-check-report.html', allowEmptyArchive: true
        }
        failure {
            mail to: 'sibasish5151@gmail.com',
                 subject: "Build failed in Jenkins: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                 body: "Please check the Jenkins console output for more details."
        }
    }
}
