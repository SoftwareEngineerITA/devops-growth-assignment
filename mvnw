#!/bin/sh
# Maven Wrapper script
# Ovaj fajl omogućava build bez globalno instaliranog Maven-a
# Spring Initializr automatski generiše ovaj fajl

# Find Maven wrapper JAR
if [ -f .mvn/wrapper/maven-wrapper.jar ]; then
    exec "$JAVA_HOME/bin/java" -jar .mvn/wrapper/maven-wrapper.jar "$@"
else
    echo "Maven wrapper JAR not found. Please run 'mvn -N io.takari:maven:wrapper'"
    exit 1
fi
