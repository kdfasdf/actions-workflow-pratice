# 1. JDK 이미지를 베이스로 사용
#FROM openjdk:17-jdk-slim

# 2. 애플리케이션 JAR 파일을 컨테이너로 복사
#ARG JAR_FILE=build/libs/*.jar
#COPY ${JAR_FILE} app.jar

# 3. 컨테이너가 실행될 때 실행할 명령어
#ENTRYPOINT ["java","-jar","/app.jar"]

# 4. 서비스 포트 노출 (Spring Boot 기본 8080)
#EXPOSE 8080


# ====== build args는 반드시 FROM보다 위에 선언 ======
ARG BUILDER_IMAGE=gradle:7.6.0-jdk17
ARG RUNTIME_IMAGE=amazoncorretto:17.0.7-alpine

# ============ (1) Builder ============
FROM ${BUILDER_IMAGE} AS builder

USER root
WORKDIR /app
ENV GRADLE_USER_HOME=/home/gradle/.gradle
RUN mkdir -p $GRADLE_USER_HOME && chown -R gradle:gradle /home/gradle /app
USER gradle

COPY --chown=gradle:gradle gradlew ./
COPY --chown=gradle:gradle gradle ./gradle
COPY --chown=gradle:gradle build.gradle settings.gradle ./
RUN chmod +x ./gradlew
RUN ./gradlew --no-daemon --refresh-dependencies dependencies || true

COPY --chown=gradle:gradle src ./src
RUN ./gradlew clean build --no-daemon --no-parallel -x test

# ============ (2) Runtime ============
FROM ${RUNTIME_IMAGE}
WORKDIR /app

COPY --from=builder /app/build/libs/*.jar app.jar
EXPOSE 8080
ENV SPRING_PROFILES_ACTIVE=prod
ENTRYPOINT ["java","-jar","app.jar"]
