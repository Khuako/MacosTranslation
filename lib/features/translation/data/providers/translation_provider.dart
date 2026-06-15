import '../../domain/entities/translation_result.dart';

abstract class TranslationProvider {
  String get id;
  String get displayName;

  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  });
}
