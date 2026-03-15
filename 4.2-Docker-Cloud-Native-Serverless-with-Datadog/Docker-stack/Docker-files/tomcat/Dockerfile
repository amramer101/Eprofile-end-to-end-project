## Dockerfile for Tomcat application container
FROM maven:3.9.9-eclipse-temurin-21-jammy AS builder

## Metadata
LABEL project="vprofile-Strata-Ops"
LABEL Author="Amr M. Amer"

## Set the working directory for the builder stage
WORKDIR /app

COPY pom.xml .
## Download dependencies to cache them in the builder stage (This speeds up subsequent builds if dependencies haven't changed)
RUN mvn dependency:go-offline

## Copy the source code to the builder stage
COPY src ./src

## Build the application and skip tests to speed up the build process
RUN mvn clean package -DskipTests

# ---------------------------------------------------
## Final stage: Use Tomcat base image and copy the built WAR file

FROM tomcat:10-jdk21

## Metadata
LABEL project="vprofile-Strata-Ops"
LABEL Author="Amr M. Amer"

## Remove default Tomcat web applications and copy the built WAR file to the webapps directory
RUN rm -rf /usr/local/tomcat/webapps/* 

COPY --from=builder /app/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

## Expose Tomcat default port
EXPOSE 8080

## Start Tomcat server
CMD ["catalina.sh", "run"]