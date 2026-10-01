@echo off
setlocal EnableExtensions

cd /d "%~dp0"

set "JAVA_HOME=D:\TOOLS\andrstdio\jbr"
set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
set "PATH=%JAVA_HOME%\bin;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\cmdline-tools\latest\bin;%PATH%"

set "APP_ID=dev.devinson.safeqr"
set "ACTIVITY=.MainActivity"
set "APK=%CD%\app\build\outputs\apk\debug\app-debug.apk"

echo.
echo [1/5] Updating repository...
git pull --ff-only
if errorlevel 1 goto :fail

echo.
echo [2/5] Preparing Gradle...
if exist "%CD%\gradlew.bat" (
    set "GRADLE_CMD=%CD%\gradlew.bat"
    goto :gradle_ready
)

set "BOOTSTRAP_GRADLE="
for /r "%USERPROFILE%\.gradle\wrapper\dists\gradle-9.4.0-bin" %%F in (gradle.bat) do (
    if not defined BOOTSTRAP_GRADLE set "BOOTSTRAP_GRADLE=%%F"
)

if not defined BOOTSTRAP_GRADLE (
    echo ERROR: gradlew.bat is missing and cached Gradle 9.4.0 was not found.
    echo Expected under: %USERPROFILE%\.gradle\wrapper\dists\gradle-9.4.0-bin
    goto :fail
)

set "TMP_WRAPPER=%TEMP%\androidQRScanner-gradle-wrapper"
if exist "%TMP_WRAPPER%" rmdir /s /q "%TMP_WRAPPER%"
mkdir "%TMP_WRAPPER%"
> "%TMP_WRAPPER%\settings.gradle.kts" echo rootProject.name = "bootstrap"

call "%BOOTSTRAP_GRADLE%" -p "%TMP_WRAPPER%" wrapper --gradle-version 8.13
if errorlevel 1 goto :fail

set "GRADLE_CMD=%TMP_WRAPPER%\gradlew.bat"

:gradle_ready
echo.
echo [3/5] Building debug APK...
call "%GRADLE_CMD%" -p "%CD%" :app:assembleDebug
if errorlevel 1 goto :fail

if not exist "%APK%" (
    echo ERROR: Build finished but APK was not found:
    echo %APK%
    goto :fail
)

echo.
echo [4/5] Installing on connected Android device...
adb get-state >nul 2>&1
if errorlevel 1 (
    echo ERROR: No single authorized Android device is available through ADB.
    echo Check: adb devices
    goto :fail
)

adb install -r "%APK%"
if errorlevel 1 goto :fail

echo.
echo [5/5] Launching app...
adb shell am force-stop %APP_ID% >nul 2>&1
adb shell am start -n %APP_ID%/%ACTIVITY%
if errorlevel 1 goto :fail

echo.
echo SUCCESS
echo APK: %APK%
echo APP: %APP_ID%
exit /b 0

:fail
echo.
echo FAILED
exit /b 1
