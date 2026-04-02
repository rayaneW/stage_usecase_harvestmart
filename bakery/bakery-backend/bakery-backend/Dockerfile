# ── Stage 1: Build ──────────────────────────────────────────────
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app

# Cache dependencies first
COPY pom.xml .
RUN mvn dependency:go-offline -q

COPY src ./src
RUN mvn clean package -DskipTests -q

# Download Instana agent
RUN mkdir -p agent && \
    cd agent && \
    wget -q https://artifact-public.instana.io/artifactory/release/com/instana/instana-java-agent/1.2.52/instana-java-agent-1.2.52.jar -O agent.jar

# ── Stage 2: Runtime ─────────────────────────────────────────────
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

COPY --from=build /app/target/*.jar app.jar
COPY --from=build /app/agent/agent.jar /app/agent.jar

EXPOSE 8080
ENTRYPOINT ["java", "-javaagent:/app/agent.jar", "-jar", "app.jar"]
