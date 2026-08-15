# 适配 JDK21 运行 LS Aegis Server（业务 jar）
# 构建机若无法直连 Docker Hub，可先：
# docker pull docker.m.daocloud.io/library/eclipse-temurin:21-jre-jammy
# docker tag docker.m.daocloud.io/library/eclipse-temurin:21-jre-jammy eclipse-temurin:21-jre-jammy
FROM eclipse-temurin:21-jre-jammy

ARG JAR_FILE=./bin/*.jar
COPY ${JAR_FILE} /app/bin/app.jar
# WORKDIR 必须为 /app，使种子路径 data/file/ 落在挂载卷 /app/data/file/
WORKDIR /app

ENTRYPOINT ["java", \
            "-jar", \
            "-XX:+UseZGC", \
            "-Djava.security.egd=file:/dev/./urandom", \
            "-Dspring.profiles.active=prod", \
            "/app/bin/app.jar"]
