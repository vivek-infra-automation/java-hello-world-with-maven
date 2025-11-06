pipeline{
    agent {
        docker {
            image 'maven:3.8-amazoncorretto-11'
            args '-v $HOME/.m2:/root/.m2'  // Cache Maven dependencies
        }
    }

    parameters {
        choice choices: ['master', 'develop', 'feature'], description: 'Please select branch  for build', name: 'Branch'
    }

    environment {
        DOCKER_IMAGE = 'java-hello-world'
        DOCKER_TAG = "${BUILD_NUMBER}"
        DOCKER_FULL_IMAGE = "${DOCKER_IMAGE}:${DOCKER_TAG}"
        GIT_COMMIT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
        JAR_NAME = "jb-hello-world-maven-${BUILD_NUMBER}-${GIT_COMMIT}.jar"
    }

    stages{
        stage('checkout'){
            steps{
                checkout([$class: 'GitSCM', branches: [[name: params.Branch]], extensions: [], userRemoteConfigs: [[credentialsId: 'github_id', url: 'https://github.com/vivek-infra-automation/java-hello-world-with-maven.git']]])
            }
        }
        stage('build'){
            steps{
                script {
                    sh """
                        mvn -B -DskipTests clean package \
                        -Drevision=${BUILD_NUMBER}-${GIT_COMMIT}
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build \
                        --build-arg BUILD_NUMBER=${BUILD_NUMBER} \
                        --build-arg GIT_COMMIT=${GIT_COMMIT} \
                        -t ${DOCKER_FULL_IMAGE} .
                    """
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    sh "docker stop ${DOCKER_IMAGE} || true"
                    sh "docker rm ${DOCKER_IMAGE} || true"
                    sh "docker run -d --name ${DOCKER_IMAGE} ${DOCKER_FULL_IMAGE}"
                }
            }
        }

        stage('archive artifact'){
            input {
                message "Do you want to archive the artifact?"
                ok "Yes, archive it"
            }
            steps{
                script {
                    def jarPath = sh(script: 'find target -name "*.jar"', returnStdout: true).trim()
                    archiveArtifacts artifacts: jarPath, fingerprint: true, onlyIfSuccessful: true
                    echo "Archived JAR file: ${jarPath}"
                }
        }
    }

    post {
        always {
            script {
                // Clean up Docker resources
                sh "docker stop ${DOCKER_IMAGE} || true"
                sh "docker rm ${DOCKER_IMAGE} || true"
                sh "docker rmi ${DOCKER_FULL_IMAGE} || true"
            }
            cleanWs()
        }
    }
}