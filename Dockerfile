# Build stage with Maven
FROM eclipse-temurin:17-jdk-jammy AS builder

WORKDIR /app

# Install Maven
RUN apt-get update && \
    apt-get install -y maven && \
    rm -rf /var/lib/apt/lists/*

# Copy pom.xml for dependency resolution
COPY pom.xml .

# Copy source code
COPY src src

# Build application
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Create non-root user
RUN groupadd -r spring && useradd -r -g spring spring

# Copy JAR from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Set proper ownership
RUN chown spring:spring /app/app.jar

USER spring

HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8081/api/health || exit 1

EXPOSE 8081

ENTRYPOINT ["java", "-jar", "app.jar"]
