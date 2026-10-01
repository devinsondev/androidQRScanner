@echo off
setlocal EnableExtensions

cd /d "%~dp0"

set "JAVA_HOME=D:\TOOLS\andrstdio\jbr"
set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
set "PATH=%JAVA_HOME%\bin;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\cmdline-tools\latest\bin;%PATH%"

set "GRADLE_VERSION=8.13"
set "GRADLE_SHA256=20f1b1176237254a6fc204d8434196fa11a4cfb387567519c61556e8710aed78"

echo Preparing verified Gradle %GRADLE_VERSION%...

set "BOOTSTRAP_GRADLE="
for /f "delims=" %%F in ('dir /s /b "%USERPROFILE%\.gradle\wrapper\dists\gradle-9.4.0-bin\gradle.bat" 2^>nul') do (
    if not defined BOOTSTRAP_GRADLE set "BOOTSTRAP_GRADLE=%%F"
)

if not defined BOOTSTRAP_GRADLE (
    echo ERROR: cached Gradle 9.4.0 was not found.
    exit /b 1
)

set "TMP_WRAPPER=%TEMP%\androidQRScanner-gradle-wrapper"
if exist "%TMP_WRAPPER%" rmdir /s /q "%TMP_WRAPPER%"
mkdir "%TMP_WRAPPER%"
> "%TMP_WRAPPER%\settings.gradle.kts" echo rootProject.name = "bootstrap"

call "%BOOTSTRAP_GRADLE%" -p "%TMP_WRAPPER%" wrapper --gradle-version %GRADLE_VERSION% --distribution-type bin --gradle-distribution-sha256-sum %GRADLE_SHA256%
if errorlevel 1 exit /b 1

set "GRADLE_CMD=%TMP_WRAPPER%\gradlew.bat"

echo.
echo Generating dependency verification metadata from the current trusted dependency set...
call "%GRADLE_CMD%" -p "%CD%" --write-verification-metadata sha256 :app:assembleDebug
if errorlevel 1 exit /b 1

if not exist "%CD%\gradle\verification-metadata.xml" (
    echo ERROR: verification-metadata.xml was not created.
    exit /b 1
)

echo.
echo CREATED: %CD%\gradle\verification-metadata.xml
echo Review this file, then commit it:
echo git add gradle\verification-metadata.xml
echo git commit -m "Add dependency verification metadata"
echo git push
exit /b 0
