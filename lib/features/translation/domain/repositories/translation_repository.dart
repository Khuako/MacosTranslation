import '../entities/translation_result.dart';

abstract class TranslationRepository {
  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    required String providerId,
    String? sourceLanguage,
  });
}
