FROM maven:3.9.9-eclipse-temurin-17 AS builder
WORKDIR /app
ARG BUILD_NUMBER=local
ARG GIT_COMMIT=dev
COPY pom.xml .
COPY src ./src
RUN mvn clean package -Drevision=${BUILD_NUMBER}-${GIT_COMMIT}

FROM amazoncorretto:11-alpine3.18
WORKDIR /app
COPY --from=builder /app/target/jb-hello-world-maven-*.jar app.jar
CMD ["java", "-jar", "app.jar"]