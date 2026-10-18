@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "JAVA_HOME=D:\TOOLS\andrstdio\jbr"
set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
set "PATH=%JAVA_HOME%\bin;%ANDROID_HOME%\platform-tools;%PATH%"

if not exist "%CD%\gradlew.bat" (
    echo ERROR: Project Gradle Wrapper is missing.
    exit /b 1
)
if not exist "%CD%\gradle\wrapper\gradle-wrapper.jar" (
    echo ERROR: Project Gradle Wrapper JAR is missing.
    exit /b 1
)

echo.
echo WARNING: This regenerates trusted dependency checksums.
echo Run only when intentionally updating dependencies, and REVIEW ALL CHANGES.
set "ANSWER="
set /p "ANSWER=Type YES to generate new metadata: "
if /I not "%ANSWER%"=="YES" exit /b 1

call "%CD%\gradlew.bat" --write-verification-metadata sha256 :app:assembleDebug
if errorlevel 1 exit /b 1

echo.
echo Review: git diff -- gradle/verification-metadata.xml
echo Only commit hashes after verifying their origin.
exit /b 0
