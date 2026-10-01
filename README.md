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
