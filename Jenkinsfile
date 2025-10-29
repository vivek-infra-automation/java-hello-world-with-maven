pipeline{
    agent any

    parameters {
        choice choices: ['master', 'develop', 'feature'], description: 'Please select branch  for build', name: 'Branch'
    }

    environment {
        MAVEN_HOME = '/opt/maven-mvnd-1.0.3-linux-amd64'
        PATH = "${MAVEN_HOME}/bin:${env.PATH}"
    }

    stages{
        stage('checkout'){
            steps{
                checkout([$class: 'GitSCM', branches: [[name: params.Branch]], extensions: [], userRemoteConfigs: [[credentialsId: 'github_id', url: 'https://github.com/vivek-infra-automation/java-hello-world-with-maven.git']]])
            }
        }
        stage('build'){
            steps{
               sh '${MAVEN_HOME}/bin/mvnd -B -DskipTests clean package'
            }
        }

        stage('run jar'){
            steps{
               sh 'java -jar target/*.jar'
            }
        }

        stage('archive artifact'){
            input {
                message "Do you want to archive the artifact?"
                ok "Yes, archive it"
            }
            steps{
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true, onlyIfSuccessful: true
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}