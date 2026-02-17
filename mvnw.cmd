@REM Maven Wrapper script for Windows
@REM Omogućava build bez globalno instaliranog Maven-a

@echo off
set MAVEN_PROJECTBASEDIR=%~dp0
set WRAPPER_JAR="%MAVEN_PROJECTBASEDIR%.mvn\wrapper\maven-wrapper.jar"

if exist %WRAPPER_JAR% (
    java -jar %WRAPPER_JAR% %*
) else (
    echo Maven wrapper JAR not found
    exit /B 1
)
