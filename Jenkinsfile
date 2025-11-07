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
                    def appImage = docker.image('maven:3.9.9-eclipse-temurin-17').inside('-v /root/.m2:/root/.m2') {
                    sh """
                        mvn -B -DskipTests clean package \
                        -Drevision=${BUILD_NUMBER}-${GIT_COMMIT}
                    """
                    }
                    sh "cp target/java-hello-world-${BUILD_NUMBER}-${GIT_COMMIT}.jar ${JAR_NAME}"
                    echo "Build successful: ${JAR_NAME} created."
                    archiveArtifacts artifacts: "${JAR_NAME}", fingerprint: true
                    echo "Maven build and packaging completed."

                    // List Docker images for verification
                    sh "docker images"
                    return appImage

                }
            }
        }

        // stage('Build Docker Image') {
        //     steps {
        //         script {
        //             def appImage = docker.build("${DOCKER_FULL_IMAGE}", "-f Dockerfile .")
        //             echo "Docker Image ${appImage} built successfully."
        //             docker.image("${DOCKER_FULL_IMAGE}").run()
        //         }
        //     }
        // }      

        // stage('Push Docker Image'){
        //     steps {
        //         script {
        //             withDocker.withRegistry('https://index.docker.io/v1/', 'Docker_Cred') {
        //                 def appImage = docker.image("${DOCKER_FULL_IMAGE}")
        //                 appImage.push()
        //                 echo "Docker Image ${DOCKER_FULL_IMAGE} pushed successfully to Docker Hub."
        //             }
        //         }
        //     }
        // }
    }

    // post {
    //     always {
    //         script {
    //             // Clean up Docker resources
    //             sh "docker stop ${DOCKER_IMAGE} || true"
    //             sh "docker rm ${DOCKER_IMAGE} || true"
    //             sh "docker rmi ${DOCKER_FULL_IMAGE} || true"
    //         }
    //         cleanWs()
    //     }
    // }
}