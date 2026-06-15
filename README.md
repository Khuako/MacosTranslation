# Menu Translator

A lightweight Flutter macOS menu-bar translator. Press the global shortcut,
type a word or short phrase, and the translation appears in the same compact
floating window.

## Run

```sh
flutter pub get
flutter run -d macos
```

## Current behavior

- macOS-first menu-bar app.
- Floating translator window, roughly Spotlight/Raycast sized.
- Default shortcut: Control + Option + Space.
- Source and target languages are selected directly in the floating window.
- Default language pair: Russian to English.
- The swap button flips Russian and English.
- Settings are available from the tray menu and open inside the same floating
  window.

## Translation providers

The UI depends on `TranslationService`, which uses `TranslationRepository` and
the `TranslationProvider` interface. The first provider is
`GoogleTranslatorProvider`, backed by the `translator` package.

To replace the backend later, add another `TranslationProvider` implementation
and register it in `lib/app/bootstrap.dart`; the UI does not need to import or
know about the concrete translation package.

## Known limitations

- The first provider uses an unofficial Google Translate-style package intended
  for lightweight use.
- Shortcut recording is not implemented yet; the MVP stores a display string.
- Dock/taskbar hiding depends on macOS and plugin behavior.
