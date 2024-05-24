# Use an official lightweight Scala and SBT image as a parent image
FROM hseeberger/scala-sbt:11.0.13_1.6.1_2.13.7 as build

# Set the working directory in the container
WORKDIR app

# Copy the current directory contents into the container at /app
COPY . .

# Compile and package the application
RUN sbt clean compile stage

# Use the OpenJDK image for running the application
FROM openjdk:11-jre-slim

# Copy the binary files from the previous stage
COPY --from=build /app/target/universal/stage /app

# Set the working directory in the container
WORKDIR /app

ENV DB_DRIVER = defaultDriver
ENV DB_URL = defaultUrl
ENV DB_USER = defaultUser
ENV DB_PASSWORD = defaultPassword

RUN sed -i 's/${DB_DRIVER}/'"$DB_DRIVER"'/' conf/application.conf && \
    sed -i 's/${DB_URL}/'"$DB_URL"'/' conf/application.conf && \
    sed -i 's/${DB_USERNAME}/'"$DB_USERNAME"'/' conf/application.conf && \
    sed -i 's/${DB_PASSWORD}/'"$DB_PASSWORD"'/' conf/application.conf
# Make port 9000 available to the world outside this container
EXPOSE 9000

# Define environment variable
ENV PLAY_HTTP_SECRET=thisisanapplicationsecretdonebyusingscala

# Run the binary script when the container launches
CMD ./bin/play-service-n-play -Dplay.http.secret.key=$PLAY_HTTP_SECRET