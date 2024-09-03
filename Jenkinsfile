pipeline {
    agent any

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
            post {
                success {
                    echo "Archiving the Artifacts"
                    archiveArtifacts artifacts: '**/target/*.war'
                }
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
                deploy adapters: [tomcat9(credentialsId: 'tomcat-cred', path: '', url: 'http://13.233.99.75:8080/')], contextPath: null, war: '**/*.war'
            }
        }
    }
}
