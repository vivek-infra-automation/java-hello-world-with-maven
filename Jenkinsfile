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
                    env.GIT_COMMIT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()[0..6]
                    env.DOCKER_IMAGE = '150916258276.dkr.ecr.eu-north-1.amazonaws.com/cicd-project/java-helloworld'
                    env.JAR_NAME = "jb-${params.Build_Version}-${BUILD_NUMBER}-${env.GIT_COMMIT}.jar"
                    env.DOCKER_TAG = "${BUILD_NUMBER}-${env.GIT_COMMIT}"
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
                    echo "Maven build completed: ${JAR_NAME}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def appImage = docker.build("${DOCKER_FULL_IMAGE}", ".")
                    echo "Docker image ${DOCKER_FULL_IMAGE} built successfully."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('150916258276.dkr.ecr.eu-north-1.amazonaws.com', 'AWS_Cred') {
                        docker.image("${DOCKER_FULL_IMAGE}").push()
                    }
                    echo "Pushed ${DOCKER_FULL_IMAGE} to ECR."
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
