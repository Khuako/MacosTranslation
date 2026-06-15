import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/translation_result.dart';
import '../../domain/repositories/translation_repository.dart';
import '../providers/translation_provider.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  TranslationRepositoryImpl({required List<TranslationProvider> providers})
      : _providers = {
          for (final provider in providers) provider.id: provider,
        };

  final Map<String, TranslationProvider> _providers;

  @override
  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    required String providerId,
    String? sourceLanguage,
  }) async {
    final provider = _providers[providerId];
    if (provider == null) {
      throw AppException('Translation provider "$providerId" is not available.');
    }

    try {
      return await provider.translate(
        text: text,
        targetLanguage: targetLanguage,
        sourceLanguage: sourceLanguage,
      );
    } on AppException {
      rethrow;
    } catch (error) {
      throw AppException('Translation failed. Please try again.', cause: error);
    }
  }
}
