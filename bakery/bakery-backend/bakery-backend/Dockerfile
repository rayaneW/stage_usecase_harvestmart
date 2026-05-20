# ── Stage 1: Build ──────────────────────────────────────────────
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app

# Cache dependencies first
COPY pom.xml .
RUN mvn dependency:go-offline -q

COPY src ./src
RUN mvn clean package -DskipTests -q

# ── Stage 2: Runtime ─────────────────────────────────────────────
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Install curl for downloading Instana agent
RUN apk add --no-cache curl

# Download Instana Java agent
RUN curl -sSfL -o instana-agent.jar \
  https://artifact-public.instana.io/artifactory/release/com/instana/instana-java/latest/instana-java-latest.jar

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENV INSTANA_AGENT_HOST=instana-agent.instana-agent.svc
ENV INSTANA_AGENT_PORT=42699

ENTRYPOINT ["java", \
  "-javaagent:/app/instana-agent.jar", \
  "-jar", "app.jar"]
