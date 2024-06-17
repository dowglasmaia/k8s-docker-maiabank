# Fase 1: Build
FROM maven:3.8.4-openjdk-17-slim AS build

WORKDIR /maiabank
COPY pom.xml .
RUN mvn dependency:resolve
COPY src ./src
RUN mvn clean install


# Fase 2: Runtime
FROM amazoncorretto:17-alpine3.16
LABEL MAINTAINER="Dowglas Maia"
ENV SPRING_LOGGING_LEVEL=INFO
ENV ACTUATOR_PORT=8089
ENV PORT=8089

WORKDIR /usr/src/app
RUN rm -f /etc/localtime && ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

COPY --from=build /maiabank/target/*.jar /usr/src/app/maiabank-api.jar

ENTRYPOINT ["java", "-noverify", "-Dfile.encoding=UTF-8", "-Dlogging.level.root=${SPRING_LOGGING_LEVEL}", "-Dmanagement.server.port=${ACTUATOR_PORT}", "-jar", "/usr/src/app/maiabank-api.jar", "--server.port=${PORT}"]

EXPOSE ${PORT} ${ACTUATOR_PORT}