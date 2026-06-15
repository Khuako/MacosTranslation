import 'package:flutter/material.dart';

import '../features/settings/settings_service.dart';
import '../features/translation/presentation/translator_controller.dart';
import '../features/translation/presentation/translator_window.dart';
import 'macos_translator_theme.dart';

enum TranslatorWindowMode { translate, settings }

class TranslatorApp extends StatelessWidget {
  const TranslatorApp({
    super.key,
    required this.controller,
    required this.settingsService,
    required this.windowMode,
    required this.onHideWindow,
  });

  final TranslatorController controller;
  final SettingsService settingsService;
  final ValueNotifier<TranslatorWindowMode> windowMode;
  final Future<void> Function() onHideWindow;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Menu Translator',
      theme: MacTranslatorKit.theme(),
      home: TranslatorWindow(
        controller: controller,
        settingsService: settingsService,
        windowMode: windowMode,
        onHideWindow: onHideWindow,
      ),
    );
  }
}
