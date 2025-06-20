#--------------------------
# 1) Build Stage
#--------------------------
FROM maven:3.8.8-jdk-21 AS builder

# Set working directory
WORKDIR /app

# Cache Maven dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and package the app (skip tests for speed)
COPY src ./src
RUN mvn package -DskipTests -B

#--------------------------
# 2) Run Stage
#--------------------------
FROM eclipse-temurin:21-jre-jammy

# Create a non-root user for security
RUN addgroup --system spring && \
    adduser --system --ingroup spring spring

# Copy the jar from the builder stage
ARG JAR_NAME=SeatBook-0.0.1-SNAPSHOT.jar
COPY --from=builder /app/target/${JAR_NAME} /opt/app/app.jar

# Grant permissions
RUN chown -R spring:spring /opt/app

# Switch to the non-root user
USER spring

# Expose default Spring Boot port
EXPOSE 8080

# Set Spring profile & JVM options via environment vars if needed
ENV JAVA_OPTS=""
ENV SPRING_PROFILES_ACTIVE=prod

# Entrypoint
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar /opt/app/app.jar"]
