import 'package:flutter/material.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/utils/debounce.dart';
import '../../settings/app_settings.dart';
import '../domain/entities/translation_result.dart';
import '../domain/services/translation_service.dart';

class TranslatorController extends ChangeNotifier {
  TranslatorController({
    required TranslationService translationService,
    required AppSettings initialSettings,
    Duration debounceDuration = const Duration(milliseconds: 400),
  })  : _translationService = translationService,
        _settings = initialSettings,
        _debounce = Debounce(debounceDuration);

  final TranslationService _translationService;
  final Debounce _debounce;
  final TextEditingController inputController = TextEditingController();

  AppSettings _settings;
  bool _isLoading = false;
  TranslationResult? _result;
  String? _errorMessage;
  int _requestVersion = 0;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  TranslationResult? get result => _result;
  String? get errorMessage => _errorMessage;

  void updateSettings(AppSettings settings) {
    _applySettings(settings);
  }

  void _applySettings(AppSettings settings, {bool translateIfNeeded = true}) {
    _settings = settings;
    notifyListeners();
    if (translateIfNeeded && inputController.text.trim().isNotEmpty) {
      translateNow();
    }
  }

  void setSourceLanguage(String language) {
    updateSettings(
      _settings.copyWith(
        sourceLanguage: language,
        targetLanguage: _oppositeLanguage(language),
      ),
    );
  }

  void setTargetLanguage(String language) {
    updateSettings(
      _settings.copyWith(
        sourceLanguage: _oppositeLanguage(language),
        targetLanguage: language,
      ),
    );
  }

  void swapLanguages() {
    updateSettings(
      _settings.copyWith(
        sourceLanguage: _settings.targetLanguage,
        targetLanguage: _settings.sourceLanguage,
      ),
    );
  }

  void onInputChanged() {
    final text = inputController.text.trim();
    if (text.isEmpty) {
      clearResult();
      return;
    }

    _syncLanguagePairWithText(text);
    _debounce(translateNow);
  }

  Future<void> translateNow() async {
    final text = inputController.text.trim();
    if (text.isEmpty) {
      clearResult();
      return;
    }

    _syncLanguagePairWithText(text);
    final requestVersion = ++_requestVersion;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final translation = await _translationService.translate(
        text: text,
        sourceLanguage: _settings.sourceLanguage,
        targetLanguage: _settings.targetLanguage,
        providerId: _settings.selectedProviderId,
      );
      if (requestVersion != _requestVersion) {
        return;
      }
      _result = translation;
      _errorMessage = null;
    } on AppException catch (error) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _result = null;
      _errorMessage = error.message;
    } catch (_) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _result = null;
      _errorMessage = 'Translation failed. Please try again.';
    } finally {
      if (requestVersion == _requestVersion) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clearResult() {
    _debounce.cancel();
    _requestVersion++;
    _isLoading = false;
    _result = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clear() {
    inputController.clear();
    clearResult();
  }

  @override
  void dispose() {
    _debounce.cancel();
    inputController.dispose();
    super.dispose();
  }

  String _oppositeLanguage(String language) {
    return language == 'ru' ? 'en' : 'ru';
  }

  void _syncLanguagePairWithText(String text) {
    final detectedSource = _detectSourceLanguage(text);
    if (detectedSource == null || detectedSource == _settings.sourceLanguage) {
      return;
    }
    _applySettings(
      _settings.copyWith(
        sourceLanguage: detectedSource,
        targetLanguage: _oppositeLanguage(detectedSource),
      ),
      translateIfNeeded: false,
    );
  }

  String? _detectSourceLanguage(String text) {
    if (RegExp(r'[\u0400-\u04FF]').hasMatch(text)) {
      return 'ru';
    }
    if (RegExp('[A-Za-z]').hasMatch(text)) {
      return 'en';
    }
    return null;
  }
}
