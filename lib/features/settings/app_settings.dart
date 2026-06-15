class AppSettings {
  const AppSettings({
    this.sourceLanguage = 'ru',
    this.targetLanguage = 'en',
    this.selectedProviderId = 'google_translator',
    this.shortcutDescription = 'Control + Option + Space',
  });

  final String sourceLanguage;
  final String targetLanguage;
  final String selectedProviderId;
  final String shortcutDescription;

  AppSettings copyWith({
    String? sourceLanguage,
    String? targetLanguage,
    String? selectedProviderId,
    String? shortcutDescription,
  }) {
    return AppSettings(
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      selectedProviderId: selectedProviderId ?? this.selectedProviderId,
      shortcutDescription: shortcutDescription ?? this.shortcutDescription,
    );
  }
}
