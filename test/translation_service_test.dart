import 'package:flutter_test/flutter_test.dart';
import 'package:macos_translation/core/errors/app_exception.dart';
import 'package:macos_translation/features/translation/data/repositories/translation_repository_impl.dart';
import 'package:macos_translation/features/translation/domain/entities/translation_result.dart';
import 'package:macos_translation/features/translation/domain/services/translation_service.dart';
import 'package:macos_translation/features/translation/data/providers/translation_provider.dart';

class FakeTranslationProvider implements TranslationProvider {
  FakeTranslationProvider({this.failure});

  final Object? failure;
  final List<String> calls = [];
  final List<String?> sourceLanguages = [];

  @override
  String get displayName => 'Fake';

  @override
  String get id => 'fake';

  @override
  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    calls.add(text);
    sourceLanguages.add(sourceLanguage);
    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
    return TranslationResult(
      originalText: text,
      translatedText: '$text:$targetLanguage',
      sourceLanguage: sourceLanguage ?? 'auto',
      targetLanguage: targetLanguage,
      providerId: id,
    );
  }
}

void main() {
  group('TranslationService', () {
    test('returns translated text from the selected provider', () async {
      final provider = FakeTranslationProvider();
      final repository = TranslationRepositoryImpl(providers: [provider]);
      final service = TranslationService(repository: repository);

      final result = await service.translate(
        text: 'bonjour',
        targetLanguage: 'en',
        providerId: 'fake',
      );

      expect(result.translatedText, 'bonjour:en');
      expect(result.originalText, 'bonjour');
      expect(result.providerId, 'fake');
      expect(provider.calls, ['bonjour']);
    });

    test('passes source language to the selected provider', () async {
      final provider = FakeTranslationProvider();
      final repository = TranslationRepositoryImpl(providers: [provider]);
      final service = TranslationService(repository: repository);

      final result = await service.translate(
        text: 'привет',
        sourceLanguage: 'ru',
        targetLanguage: 'en',
        providerId: 'fake',
      );

      expect(result.sourceLanguage, 'ru');
      expect(provider.sourceLanguages, ['ru']);
    });

    test('rejects blank text before calling a provider', () async {
      final provider = FakeTranslationProvider();
      final repository = TranslationRepositoryImpl(providers: [provider]);
      final service = TranslationService(repository: repository);

      expect(
        () => service.translate(
          text: '   ',
          targetLanguage: 'en',
          providerId: 'fake',
        ),
        throwsA(isA<AppException>()),
      );
      expect(provider.calls, isEmpty);
    });

    test('wraps provider failures as app exceptions', () async {
      final provider = FakeTranslationProvider(failure: Exception('network'));
      final repository = TranslationRepositoryImpl(providers: [provider]);
      final service = TranslationService(repository: repository);

      expect(
        () => service.translate(
          text: 'hola',
          targetLanguage: 'en',
          providerId: 'fake',
        ),
        throwsA(isA<AppException>()),
      );
    });
  });
}
