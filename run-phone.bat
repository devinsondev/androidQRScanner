@echo off
setlocal EnableExtensions

cd /d "%~dp0"

set "JAVA_HOME=D:\TOOLS\andrstdio\jbr"
set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
set "PATH=%JAVA_HOME%\bin;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\cmdline-tools\latest\bin;%PATH%"

set "APP_ID=dev.devinson.safeqr"
set "ACTIVITY=.MainActivity"
set "APK=%CD%\app\build\outputs\apk\debug\app-debug.apk"
set "GRADLE_VERSION=8.13"
set "GRADLE_SHA256=20f1b1176237254a6fc204d8434196fa11a4cfb387567519c61556e8710aed78"

echo.
echo [1/6] Updating repository...
git pull --ff-only
if errorlevel 1 goto :fail

echo.
echo [2/6] Preparing verified Gradle...
if exist "%CD%\gradlew.bat" (
    set "GRADLE_CMD=%CD%\gradlew.bat"
    set "WRAPPER_PROPS=%CD%\gradle\wrapper\gradle-wrapper.properties"
    if not exist "%WRAPPER_PROPS%" (
        echo ERROR: gradlew.bat exists but gradle-wrapper.properties is missing.
        goto :fail
    )
    findstr /b /c:"distributionSha256Sum=" "%WRAPPER_PROPS%" >nul
    if errorlevel 1 (
        echo ERROR: Wrapper has no distributionSha256Sum. Refusing unverified Gradle download.
        goto :fail
    )
    goto :gradle_ready
)

set "BOOTSTRAP_GRADLE="
for /f "delims=" %%F in ('dir /s /b "%USERPROFILE%\.gradle\wrapper\dists\gradle-9.4.0-bin\gradle.bat" 2^>nul') do (
    if not defined BOOTSTRAP_GRADLE set "BOOTSTRAP_GRADLE=%%F"
)

if not defined BOOTSTRAP_GRADLE (
    echo ERROR: gradlew.bat is missing and cached Gradle 9.4.0 was not found.
    goto :fail
)

echo Bootstrap Gradle: %BOOTSTRAP_GRADLE%

set "TMP_WRAPPER=%TEMP%\androidQRScanner-gradle-wrapper"
if exist "%TMP_WRAPPER%" rmdir /s /q "%TMP_WRAPPER%"
mkdir "%TMP_WRAPPER%"
> "%TMP_WRAPPER%\settings.gradle.kts" echo rootProject.name = "bootstrap"

call "%BOOTSTRAP_GRADLE%" -p "%TMP_WRAPPER%" wrapper --gradle-version %GRADLE_VERSION% --distribution-type bin --gradle-distribution-sha256-sum %GRADLE_SHA256%
if errorlevel 1 goto :fail

set "WRAPPER_PROPS=%TMP_WRAPPER%\gradle\wrapper\gradle-wrapper.properties"
findstr /c:"distributionUrl=https\://services.gradle.org/distributions/gradle-%GRADLE_VERSION%-bin.zip" "%WRAPPER_PROPS%" >nul
if errorlevel 1 (
    echo ERROR: Unexpected Gradle distribution URL.
    goto :fail
)
findstr /c:"distributionSha256Sum=%GRADLE_SHA256%" "%WRAPPER_PROPS%" >nul
if errorlevel 1 (
    echo ERROR: Gradle SHA-256 was not written correctly.
    goto :fail
)

set "GRADLE_CMD=%TMP_WRAPPER%\gradlew.bat"

:gradle_ready
echo.
echo [3/6] Building debug APK...
call "%GRADLE_CMD%" -p "%CD%" :app:assembleDebug
if errorlevel 1 goto :fail

if not exist "%APK%" (
    echo ERROR: Build finished but APK was not found:
    echo %APK%
    goto :fail
)

echo.
echo [4/6] Checking ADB device...
adb get-state >nul 2>&1
if errorlevel 1 (
    echo ERROR: No single authorized Android device is available through ADB.
    echo Check: adb devices
    goto :fail
)

echo.
echo [5/6] Installing APK...
adb install -r "%APK%"
if errorlevel 1 goto :fail

echo.
echo [6/6] Launching app...
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
