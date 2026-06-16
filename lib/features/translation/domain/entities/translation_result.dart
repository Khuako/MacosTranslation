class TranslationResult {
  const TranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.providerId,
    this.alternatives = const [],
    this.contextNotes = const [],
    this.partOfSpeech,
    this.tone,
  });

  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final String providerId;
  final List<String> alternatives;
  final List<String> contextNotes;
  final String? partOfSpeech;
  final String? tone;
}
