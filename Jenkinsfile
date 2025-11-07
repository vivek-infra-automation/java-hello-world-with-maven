pipeline {
    agent any 

    parameters {
        choice choices: ['master', 'develop', 'feature'], description: 'Please select branch  for build', name: 'Branch'
        choice choices: ['1.0.1', '1.0.2'], description: 'Select the Version', name: 'Build_Version'
    }

    environment {
        DOCKER_IMAGE = 'cloud2help/cicd-projects'
        GIT_COMMIT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
        JAR_NAME = "jb-${params.Build_Version}-${BUILD_NUMBER}-${GIT_COMMIT}.jar"
        DOCKER_TAG = "java-hello-world-${BUILD_NUMBER}-${GIT_COMMIT}"
        DOCKER_FULL_IMAGE = "${DOCKER_IMAGE}:${DOCKER_TAG}"
    }

    stages{
        stage('checkout'){
            steps{
                checkout([$class: 'GitSCM', branches: [[name: params.Branch]], extensions: [], userRemoteConfigs: [[credentialsId: 'github_cred', url: 'https://github.com/vivek-infra-automation/java-hello-world-with-maven.git']]])
            }
        }
        stage('build'){
            steps{
                script {
                    docker.image('maven:3.9.9-eclipse-temurin-17').inside('-v /root/.m2:/root/.m2') {
                    sh """
                        mvn -B -DskipTests clean package \
                        -Drevision=${BUILD_NUMBER}-${GIT_COMMIT}
                    """
                    }
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
                    sh "docker run --name ${DOCKER_IMAGE} ${DOCKER_FULL_IMAGE}"
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
        

        stage('Push Docker Image'){
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'Docker_Cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh """
                            docker login -u ${DOCKER_USER} -p ${DOCKER_PASSWORD}
                            docker push ${DOCKER_FULL_IMAGE}
                        """
                    }
                }
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