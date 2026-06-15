import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dependencies = await bootstrap();
  final windowMode = ValueNotifier(TranslatorWindowMode.translate);

  await dependencies.hotkeyService.registerToggleHotKey(
    onPressed: dependencies.windowService.toggleTranslator,
  );
  await dependencies.trayService.initialize(
    onShowTranslator: () async {
      windowMode.value = TranslatorWindowMode.translate;
      await dependencies.windowService.showTranslator();
    },
    onShowSettings: () async {
      windowMode.value = TranslatorWindowMode.settings;
      await dependencies.windowService.showTranslator();
    },
    onQuit: dependencies.shutdown,
  );

  runApp(
    TranslatorApp(
      controller: dependencies.translatorController,
      settingsService: dependencies.settingsService,
      windowMode: windowMode,
      onHideWindow: dependencies.windowService.hideTranslator,
    ),
  );
}
