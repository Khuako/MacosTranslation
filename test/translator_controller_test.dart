import 'package:flutter_test/flutter_test.dart';
import 'package:macos_translation/features/settings/app_settings.dart';
import 'package:macos_translation/features/translation/domain/entities/translation_result.dart';
import 'package:macos_translation/features/translation/domain/services/translation_service.dart';
import 'package:macos_translation/features/translation/presentation/translator_controller.dart';

class FakeTranslationService implements TranslationService {
  final List<String> calls = [];
  final List<String?> sourceLanguages = [];
  final List<String> targetLanguages = [];

  @override
  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    required String providerId,
    String? sourceLanguage,
  }) async {
    calls.add(text);
    sourceLanguages.add(sourceLanguage);
    targetLanguages.add(targetLanguage);
    return TranslationResult(
      originalText: text,
      translatedText: text.toUpperCase(),
      sourceLanguage: sourceLanguage ?? 'auto',
      targetLanguage: targetLanguage,
      providerId: providerId,
      alternatives: const [],
      contextNotes: const [],
    );
  }
}

void main() {
  group('TranslatorController', () {
    test('debounces rapid input changes into one translation', () async {
      final service = FakeTranslationService();
      final controller = TranslatorController(
        translationService: service,
        initialSettings: const AppSettings(),
        debounceDuration: const Duration(milliseconds: 20),
      );
      addTearDown(controller.dispose);

      controller.inputController.text = 'h';
      controller.onInputChanged();
      controller.inputController.text = 'hello';
      controller.onInputChanged();

      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(service.calls, ['hello']);
      expect(controller.result?.translatedText, 'HELLO');
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
    });

    test('latin input switches direction to English to Russian', () async {
      final service = FakeTranslationService();
      final controller = TranslatorController(
        translationService: service,
        initialSettings: const AppSettings(
          sourceLanguage: 'ru',
          targetLanguage: 'en',
        ),
        debounceDuration: const Duration(milliseconds: 20),
      );
      addTearDown(controller.dispose);

      controller.inputController.text = 'hello';
      controller.onInputChanged();
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(controller.settings.sourceLanguage, 'en');
      expect(controller.settings.targetLanguage, 'ru');
      expect(service.sourceLanguages, ['en']);
      expect(service.targetLanguages, ['ru']);
    });

    test('cyrillic input switches direction to Russian to English', () async {
      final service = FakeTranslationService();
      final controller = TranslatorController(
        translationService: service,
        initialSettings: const AppSettings(
          sourceLanguage: 'en',
          targetLanguage: 'ru',
        ),
        debounceDuration: const Duration(milliseconds: 20),
      );
      addTearDown(controller.dispose);

      controller.inputController.text = 'привет';
      controller.onInputChanged();
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(controller.settings.sourceLanguage, 'ru');
      expect(controller.settings.targetLanguage, 'en');
      expect(service.sourceLanguages, ['ru']);
      expect(service.targetLanguages, ['en']);
    });

    test('clear resets input and visible state', () async {
      final service = FakeTranslationService();
      final controller = TranslatorController(
        translationService: service,
        initialSettings: const AppSettings(),
        debounceDuration: const Duration(milliseconds: 20),
      );
      addTearDown(controller.dispose);

      controller.inputController.text = 'hello';
      controller.onInputChanged();
      await Future<void>.delayed(const Duration(milliseconds: 60));

      controller.clear();

      expect(controller.inputController.text, isEmpty);
      expect(controller.result, isNull);
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, isFalse);
    });

    test('passes source and target language to translation service', () async {
      final service = FakeTranslationService();
      final controller = TranslatorController(
        translationService: service,
        initialSettings: const AppSettings(
          sourceLanguage: 'ru',
          targetLanguage: 'en',
        ),
        debounceDuration: const Duration(milliseconds: 20),
      );
      addTearDown(controller.dispose);

      controller.inputController.text = 'привет';
      controller.onInputChanged();
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(service.sourceLanguages, ['ru']);
      expect(service.targetLanguages, ['en']);
      expect(controller.result?.sourceLanguage, 'ru');
      expect(controller.result?.targetLanguage, 'en');
    });

    test('swapLanguages flips Russian and English pair', () {
      final service = FakeTranslationService();
      final controller = TranslatorController(
        translationService: service,
        initialSettings: const AppSettings(
          sourceLanguage: 'ru',
          targetLanguage: 'en',
        ),
      );
      addTearDown(controller.dispose);

      controller.swapLanguages();

      expect(controller.settings.sourceLanguage, 'en');
      expect(controller.settings.targetLanguage, 'ru');
    });

    test('setSourceLanguage keeps the opposite language paired', () {
      final service = FakeTranslationService();
      final controller = TranslatorController(
        translationService: service,
        initialSettings: const AppSettings(),
      );
      addTearDown(controller.dispose);

      controller.setSourceLanguage('en');

      expect(controller.settings.sourceLanguage, 'en');
      expect(controller.settings.targetLanguage, 'ru');
    });

    test('setTargetLanguage keeps the opposite language paired', () {
      final service = FakeTranslationService();
      final controller = TranslatorController(
        translationService: service,
        initialSettings: const AppSettings(),
      );
      addTearDown(controller.dispose);

      controller.setTargetLanguage('ru');

      expect(controller.settings.sourceLanguage, 'en');
      expect(controller.settings.targetLanguage, 'ru');
    });
  });
}
