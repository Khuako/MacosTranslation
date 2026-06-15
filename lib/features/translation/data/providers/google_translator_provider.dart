import 'package:translator/translator.dart';

import '../../domain/entities/translation_result.dart';
import 'translation_provider.dart';

class GoogleTranslatorProvider implements TranslationProvider {
  GoogleTranslatorProvider({GoogleTranslator? translator})
      : _translator = translator ?? GoogleTranslator();

  final GoogleTranslator _translator;

  @override
  String get displayName => 'Google Translate';

  @override
  String get id => 'google_translator';

  @override
  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    final translation = await _translator.translate(
      text,
      from: sourceLanguage ?? 'auto',
      to: targetLanguage,
    );

    return TranslationResult(
      originalText: translation.source,
      translatedText: translation.text,
      sourceLanguage: translation.sourceLanguage.code,
      targetLanguage: translation.targetLanguage.code,
      providerId: id,
    );
  }
}
