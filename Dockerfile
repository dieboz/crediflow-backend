# ---- Etapa 1: compilar ----
FROM maven:3.9.9-eclipse-temurin-25 AS build
WORKDIR /workspace
COPY store-credit-management/pom.xml ./
RUN mvn -B -q dependency:go-offline
COPY store-credit-management/src src
RUN mvn -B -q -DskipTests package && cp target/*.jar app.jar

# ---- Etapa 2: ejecutar ----
FROM eclipse-temurin:25-jre
RUN useradd --system --uid 1001 app
WORKDIR /app
COPY --from=build /workspace/app.jar app.jar

# prod por defecto: si falta la variable, nunca arranca con las credenciales de desarrollo.
ENV SPRING_PROFILES_ACTIVE=prod \
    TZ=America/Lima \
    JAVA_TOOL_OPTIONS="-Duser.timezone=America/Lima -XX:MaxRAMPercentage=70 -XX:+UseSerialGC -Xss512k"

USER app
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
