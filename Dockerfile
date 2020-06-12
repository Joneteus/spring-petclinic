# --------------------
# First stage for Maven build
FROM alpine:3 as maven_builder

# Install openjdk11 with Alpine package manager apk
RUN apk --no-cache add openjdk11

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
FROM alpine:3
RUN apk --no-cache add openjdk11

# Copy .jar artefact from build container
COPY --from=maven_builder /app/target/*.jar /app/petclinic-app.jar

EXPOSE 8080
CMD java -jar "/app/petclinic-app.jar"
