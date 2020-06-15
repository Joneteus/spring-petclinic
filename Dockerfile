# --------------------
# First stage for Maven build
FROM openjdk:8-jdk-alpine as maven_builder

# Copy necessary files into container image
COPY mvnw pom.xml /app/
COPY .mvn/ /app/.mvn/
COPY src/ /app/src/

# Set working directory and run Maven wrapper with "package" command
# Wrapper contains Maven binary, no need to install Maven
WORKDIR /app/
RUN ./mvnw package


# --------------------
# Second stage for creating Docker image for running the application
FROM openjdk:8-jre-alpine

# Copy .jar artefact from build container
COPY --from=maven_builder /app/target/*.jar /app/petclinic-app.jar

EXPOSE 8080
CMD java -jar "/app/petclinic-app.jar"
