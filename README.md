# Safe QR Scanner

Минимальный безопасный QR-сканер для Android 16.

## Безопасность

- приложение не запрашивает разрешение CAMERA;
- сканирование выполняет Google Code Scanner через Google Play services;
- QR-содержимое сначала показывается обычным текстом;
- кнопки «Копировать» и «Поделиться» передают исходный текст без изменения пробелов и переносов;
- Android Share Sheet появляется только после нажатия «Поделиться»;
- ничего из QR-кода не запускается и не открывается автоматически;
- кнопка перехода доступна только для http/https URL с корректным host;
- URL с userinfo не предлагаются к открытию;
- схемы javascript:, file:, content:, intent: и другие не открываются;
- переход по ссылке выполняется через системное меню выбора приложения;
- Gradle Wrapper и его дистрибутив защищены проверкой SHA-256;
- зависимости проверяются в строгом режиме по gradle/verification-metadata.xml.

## Android Studio на Windows

1. В корне проекта выполните git pull --ff-only.
2. Откройте Settings → Build, Execution, Deployment → Build Tools → Gradle.
3. В Gradle Distribution выберите Wrapper (файл gradle/wrapper/gradle-wrapper.properties).
4. Установите Gradle JDK на JDK 17; при подходящей версии можно использовать встроенный JBR Android Studio.
5. Выполните Sync Project with Gradle Files.

Используется Gradle 8.13 с архивом -all (включает исходники), НЕ Gradle 9.0 milestone.
Проверенные суммы версий 8.13 опубликованы на https://gradle.org/release-checksums/.

## Сборка

Требования: Android SDK 36, JDK 17 и доступ к Gradle distributions и Google Maven.

Windows PowerShell:

    .\gradlew.bat --dependency-verification strict testDebugUnitTest :app:assembleDebug

Linux/macOS:

    ./gradlew --dependency-verification strict testDebugUnitTest :app:assembleDebug

## Windows: обновить, собрать, установить и запустить

Для настроенного рабочего ПК достаточно из папки репозитория:

    .\run-phone.bat

Скрипт обновляет репозиторий, проверяет Gradle Wrapper и SHA-256 дистрибутива,
собирает APK с проверкой зависимостей, устанавливает и запускает на телефоне.

Локальное окружение скрипта:
- JDK: D:\TOOLS\andrstdio\jbr;
- Android SDK: %LOCALAPPDATA%\Android\Sdk.

Файл gradle/verification-metadata.xml содержит только проверенные зависимости.
При необходимости обновлять зависимости используйте setup-dependency-verification.bat
только с последующей ручной проверкой новых SHA-256.
