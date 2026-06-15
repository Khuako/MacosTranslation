import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_translation/app/app.dart';
import 'package:macos_translation/features/settings/app_settings.dart';
import 'package:macos_translation/features/settings/settings_service.dart';
import 'package:macos_translation/features/translation/domain/entities/translation_result.dart';
import 'package:macos_translation/features/translation/domain/services/translation_service.dart';
import 'package:macos_translation/features/translation/presentation/translator_controller.dart';
import 'package:macos_translation/features/translation/presentation/translator_window.dart';

class FakeTranslationService implements TranslationService {
  @override
  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    required String providerId,
    String? sourceLanguage,
  }) async {
    return TranslationResult(
      originalText: text,
      translatedText: text.toUpperCase(),
      sourceLanguage: sourceLanguage ?? 'auto',
      targetLanguage: targetLanguage,
      providerId: providerId,
    );
  }
}

void main() {
  testWidgets('renders language rail and translator states', (tester) async {
    final controller = TranslatorController(
      translationService: FakeTranslationService(),
      initialSettings: const AppSettings(),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: TranslatorWindow(
          controller: controller,
          settingsService: SettingsService(),
          windowMode: ValueNotifier(TranslatorWindowMode.translate),
          onHideWindow: () async {},
        ),
      ),
    );

    expect(find.text('From'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);
    expect(find.text('RU'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
    expect(find.text('Translation appears here'), findsOneWidget);
  });
}
