import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';

class SettingsService {
  static const _sourceLanguageKey = 'source_language';
  static const _targetLanguageKey = 'target_language';
  static const _selectedProviderIdKey = 'selected_provider_id';
  static const _shortcutDescriptionKey = 'shortcut_description';

  Future<AppSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    final storedSourceLanguage = preferences.getString(_sourceLanguageKey);
    final storedTargetLanguage = preferences.getString(_targetLanguageKey);
    final sourceLanguage = storedSourceLanguage ??
        _pairedSourceForTarget(storedTargetLanguage) ??
        'ru';
    final targetLanguage =
        storedTargetLanguage ?? _oppositeLanguage(sourceLanguage);

    return AppSettings(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      selectedProviderId:
          preferences.getString(_selectedProviderIdKey) ?? 'google_translator',
      shortcutDescription: _normalizedShortcutDescription(
        preferences.getString(_shortcutDescriptionKey),
      ),
    );
  }

  Future<AppSettings> save(AppSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_sourceLanguageKey, settings.sourceLanguage);
    await preferences.setString(_targetLanguageKey, settings.targetLanguage);
    await preferences.setString(
      _selectedProviderIdKey,
      settings.selectedProviderId,
    );
    await preferences.setString(
      _shortcutDescriptionKey,
      settings.shortcutDescription,
    );
    return settings;
  }

  String? _pairedSourceForTarget(String? targetLanguage) {
    if (targetLanguage == null) {
      return null;
    }
    return _oppositeLanguage(targetLanguage);
  }

  String _oppositeLanguage(String language) {
    return language == 'ru' ? 'en' : 'ru';
  }

  String _normalizedShortcutDescription(String? description) {
    if (description == null || description == 'Option + Space') {
      return 'Control + Option + Space';
    }
    return description;
  }
}
