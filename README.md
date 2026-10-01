# Safe QR Scanner

Минимальный QR-сканер для Android 16.

## Безопасность

- приложение не запрашивает разрешение CAMERA;
- сканирование выполняет Google Code Scanner через Google Play services;
- распознаются только QR-коды;
- QR-контент всегда сначала показывается как текст;
- никакие URI/ссылки не открываются автоматически;
- кнопка открытия появляется только для http/https URL с корректным host;
- URL с userinfo намеренно не предлагаются к открытию;
- javascript:, file:, content:, intent: и другие схемы не открываются;
- переход выполняется через системный chooser.

## Сборка

Требования: JDK 17, Gradle 8.13, Android SDK 36.

    gradle testDebugUnitTest assembleDebug

## Windows: обновить, собрать, установить и запустить

Для настроенного рабочего ПК достаточно из папки репозитория выполнить:

    .\run-phone.bat

Скрипт сам:

1. делает `git pull --ff-only`;
2. использует проектный `gradlew.bat`, если он есть;
3. для этого старого проекта при отсутствии wrapper временно создаёт Gradle 8.13 через локальный кэш Gradle 9.4;
4. собирает `:app:assembleDebug`;
5. устанавливает APK через `adb install -r`;
6. запускает `dev.devinson.safeqr/.MainActivity`.

Локальное окружение скрипта рассчитано на:

- JDK: `D:\TOOLS\andrstdio\jbr`;
- Android SDK: `%LOCALAPPDATA%\Android\Sdk`.
