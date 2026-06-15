import '../../../../core/errors/app_exception.dart';
import '../entities/translation_result.dart';
import '../repositories/translation_repository.dart';

class TranslationService {
  const TranslationService({required TranslationRepository repository})
      : _repository = repository;

  final TranslationRepository _repository;

  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    required String providerId,
    String? sourceLanguage,
  }) {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) {
      throw const AppException('Type a word or phrase to translate.');
    }

    return _repository.translate(
      text: normalizedText,
      targetLanguage: targetLanguage,
      providerId: providerId,
      sourceLanguage: sourceLanguage,
    );
  }
}
