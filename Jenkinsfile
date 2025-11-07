pipeline {
    agent any 

    parameters {
        choice choices: ['master', 'develop', 'feature'], description: 'Please select branch for build', name: 'Branch'
        choice choices: ['1.0.1', '1.0.2'], description: 'Select the Version', name: 'Build_Version'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: params.Branch]],
                    userRemoteConfigs: [[
                        credentialsId: 'github_cred',
                        url: 'https://github.com/vivek-infra-automation/java-hello-world-with-maven.git'
                    ]]
                ])
            }
        }

        stage('Set Environment Variables') {
            steps {
                script {
                    env.GIT_COMMIT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    env.DOCKER_IMAGE = 'cloud2help/cicd-projects'
                    env.JAR_NAME = "jb-${params.Build_Version}-${BUILD_NUMBER}-${env.GIT_COMMIT}.jar"
                    env.DOCKER_TAG = "java-hello-world-${BUILD_NUMBER}-${env.GIT_COMMIT}"
                    env.DOCKER_FULL_IMAGE = "${env.DOCKER_IMAGE}:${env.DOCKER_TAG}"
                }
            }
        }

        stage('Build with Maven Docker') {
            steps {
                script {
                    docker.image('maven:3.9.9-eclipse-temurin-17').inside('-v /root/.m2:/root/.m2') {
                        sh """
                            mvn -B -DskipTests clean package \
                            -Drevision=${BUILD_NUMBER}-${GIT_COMMIT}
                        """
                    }

                    def jarFile = sh(script: 'ls target/*.jar | head -1', returnStdout: true).trim()
                    sh "cp ${jarFile} ${JAR_NAME}"
                    archiveArtifacts artifacts: "${JAR_NAME}", fingerprint: true
                    echo "✅ Maven build completed: ${JAR_NAME}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def appImage = docker.build("${DOCKER_FULL_IMAGE}", ".")
                    echo "✅ Docker image ${DOCKER_FULL_IMAGE} built successfully."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'Docker_Cred') {
                        docker.image("${DOCKER_FULL_IMAGE}").push()
                        sh "docker tag ${DOCKER_FULL_IMAGE} ${DOCKER_IMAGE}:latest"
                        docker.image("${DOCKER_IMAGE}:latest").push()
                    }
                    echo "🚀 Pushed ${DOCKER_FULL_IMAGE} and latest tag to Docker Hub."
                }
            }
        }
    }

    post {
        always {
            script {
                sh "docker system prune -af || true"
                cleanWs()
            }
        }
    }
}
