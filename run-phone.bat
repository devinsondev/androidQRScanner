@echo off
setlocal EnableExtensions

cd /d "%~dp0"

set "JAVA_HOME=D:\TOOLS\andrstdio\jbr"
set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
set "PATH=%JAVA_HOME%\bin;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\cmdline-tools\latest\bin;%SystemRoot%\System32;%SystemRoot%\System32\WindowsPowerShell\v1.0;%PATH%"

set "APP_ID=dev.devinson.safeqr"
set "ACTIVITY=.MainActivity"
set "APK=%CD%\app\build\outputs\apk\debug\app-debug.apk"
set "WRAPPER_JAR=%CD%\gradle\wrapper\gradle-wrapper.jar"
set "WRAPPER_PROPS=%CD%\gradle\wrapper\gradle-wrapper.properties"
set "WRAPPER_SHA256=81a82aaea5abcc8ff68b3dfcb58b3c3c429378efd98e7433460610fecd7ae45f"
set "DISTRIBUTION_SHA256=fba8464465835e74f7270bbf43d6d8a8d7709ab0a43ce1aa3323f73e9aa0c612"

echo.
echo [1/7] Updating repository...
git pull --ff-only
if errorlevel 1 goto :fail

echo.
echo [2/7] Verifying Gradle Wrapper 8.13...
if not exist "%CD%\gradlew.bat" goto :wrapper_missing
if not exist "%WRAPPER_JAR%" goto :wrapper_missing
if not exist "%WRAPPER_PROPS%" goto :wrapper_missing
set "POWERSHELL_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%POWERSHELL_EXE%" (
    set "POWERSHELL_EXE=%ProgramFiles%\PowerShell\7\pwsh.exe"
)
if not exist "%POWERSHELL_EXE%" (
    echo ERROR: Windows PowerShell or PowerShell 7 is required to verify the wrapper JAR.
    goto :fail
)
"%POWERSHELL_EXE%" -NoProfile -NonInteractive -Command "$actual = (Get-FileHash -LiteralPath $env:WRAPPER_JAR -Algorithm SHA256).Hash.ToLower(); if ($actual -ne $env:WRAPPER_SHA256) { Write-Error ('Invalid wrapper JAR checksum: ' + $actual); exit 1 }"
if errorlevel 1 goto :fail
findstr /b /c:"distributionUrl=https\://services.gradle.org/distributions/gradle-8.13-all.zip" "%WRAPPER_PROPS%" >nul
if errorlevel 1 goto :distribution_invalid
findstr /b /c:"distributionSha256Sum=%DISTRIBUTION_SHA256%" "%WRAPPER_PROPS%" >nul
if errorlevel 1 goto :distribution_invalid

echo.
echo [3/7] Checking strict dependency verification metadata...
if not exist "%CD%\gradle\verification-metadata.xml" (
    echo ERROR: gradle\verification-metadata.xml is missing.
    goto :fail
)

echo.
echo [4/7] Building debug APK...
call "%CD%\gradlew.bat" --dependency-verification strict :app:assembleDebug
if errorlevel 1 goto :fail

if not exist "%APK%" (
    echo ERROR: APK not found: %APK%
    goto :fail
)

echo.
echo [5/7] Checking ADB device...
adb get-state >nul 2>&1
if errorlevel 1 (
    echo ERROR: No authorized Android device connected.
    echo Run: adb devices
    goto :fail
)

echo.
echo [6/7] Installing APK...
adb install -r "%APK%"
if errorlevel 1 goto :fail

echo.
echo [7/7] Launching application...
adb shell am force-stop %APP_ID% >nul 2>&1
adb shell am start -n %APP_ID%/%ACTIVITY%
if errorlevel 1 goto :fail

echo.
echo SUCCESS
echo APK: %APK%
exit /b 0

:wrapper_missing
echo ERROR: Project Gradle Wrapper files are missing.
goto :fail

:distribution_invalid
echo ERROR: Gradle distribution URL or SHA-256 differs from the pinned version.
goto :fail

:fail
echo.
echo FAILED
exit /b 1
