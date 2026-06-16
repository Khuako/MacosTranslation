import 'dart:convert';
import 'dart:io';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/translation_result.dart';
import 'translation_provider.dart';

class OpenRouterConfig {
  const OpenRouterConfig({
    required this.apiKey,
    required this.model,
    this.maxTokens = 350,
    this.temperature = 0.2,
  });

  static const defaultModel = 'qwen/qwen3.7-plus';

  final String apiKey;
  final String model;
  final int maxTokens;
  final double temperature;

  bool get hasApiKey => apiKey.trim().isNotEmpty;

  static Future<OpenRouterConfig> load() async {
    final values = <String, String>{};
    values.addAll(await _loadEnvFile());

    const dartDefineApiKey = String.fromEnvironment('OPENROUTER_API_KEY');
    const dartDefineModel = String.fromEnvironment('OPENROUTER_MODEL');
    const dartDefineMaxTokens = String.fromEnvironment('OPENROUTER_MAX_TOKENS');
    const dartDefineTemperature =
        String.fromEnvironment('OPENROUTER_TEMPERATURE');

    if (dartDefineApiKey.isNotEmpty) {
      values['OPENROUTER_API_KEY'] = dartDefineApiKey;
    }
    if (dartDefineModel.isNotEmpty) {
      values['OPENROUTER_MODEL'] = dartDefineModel;
    }
    if (dartDefineMaxTokens.isNotEmpty) {
      values['OPENROUTER_MAX_TOKENS'] = dartDefineMaxTokens;
    }
    if (dartDefineTemperature.isNotEmpty) {
      values['OPENROUTER_TEMPERATURE'] = dartDefineTemperature;
    }

    return OpenRouterConfig(
      apiKey: values['OPENROUTER_API_KEY'] ?? '',
      model: values['OPENROUTER_MODEL'] ?? defaultModel,
      maxTokens: int.tryParse(values['OPENROUTER_MAX_TOKENS'] ?? '') ?? 350,
      temperature:
          double.tryParse(values['OPENROUTER_TEMPERATURE'] ?? '') ?? 0.2,
    );
  }

  static Future<Map<String, String>> _loadEnvFile() async {
    const dartDefineEnvFile = String.fromEnvironment('OPENROUTER_ENV_FILE');
    final candidates = <String>[
      if (dartDefineEnvFile.isNotEmpty) dartDefineEnvFile,
      ..._envFileCandidates(Directory.current),
      ..._envFileCandidates(File(Platform.resolvedExecutable).parent),
    ];

    for (final path in candidates) {
      final file = File(path);
      try {
        if (!await file.exists()) {
          continue;
        }
        return _parseEnv(await file.readAsLines());
      } on FileSystemException {
        continue;
      }
    }

    return const {};
  }

  static Iterable<String> _envFileCandidates(Directory startDirectory) sync* {
    var directory = startDirectory.absolute;
    while (true) {
      yield '${directory.path}/.env';
      yield '${directory.path}/.env.local';

      final parent = directory.parent.absolute;
      if (parent.path == directory.path) {
        break;
      }
      directory = parent;
    }
  }

  static Map<String, String> _parseEnv(List<String> lines) {
    final values = <String, String>{};
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }
      final separator = trimmed.indexOf('=');
      if (separator <= 0) {
        continue;
      }
      final key = trimmed.substring(0, separator).trim();
      var value = trimmed.substring(separator + 1).trim();
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      values[key] = value;
    }
    return values;
  }
}

abstract class OpenRouterClient {
  Future<Map<String, Object?>> createChatCompletion({
    required String apiKey,
    required Map<String, Object?> body,
  });
}

class HttpOpenRouterClient implements OpenRouterClient {
  HttpOpenRouterClient({HttpClient? httpClient})
      : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

  @override
  Future<Map<String, Object?>> createChatCompletion({
    required String apiKey,
    required Map<String, Object?> body,
  }) async {
    final request = await _httpClient.postUrl(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
    );
    request.headers.contentType = ContentType.json;
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
    request.headers.set('X-OpenRouter-Title', 'Menu Translator');
    request.write(jsonEncode(body));

    final response = await request.close();
    final responseBody = await utf8.decoder.bind(response).join();
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, Object?>) {
      throw const AppException('OpenRouter returned an invalid response.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _errorMessage(decoded) ?? 'OpenRouter request failed.';
      throw AppException(message);
    }
    return decoded;
  }

  String? _errorMessage(Map<String, Object?> body) {
    final error = body['error'];
    if (error is Map<String, Object?>) {
      final message = error['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    return null;
  }
}

class OpenRouterTranslationProvider implements TranslationProvider {
  OpenRouterTranslationProvider({
    required OpenRouterConfig config,
    OpenRouterClient? client,
  })  : _config = config,
        _client = client ?? HttpOpenRouterClient();

  final OpenRouterConfig _config;
  final OpenRouterClient _client;

  @override
  String get displayName => 'OpenRouter';

  @override
  String get id => 'openrouter';

  @override
  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    if (!_config.hasApiKey) {
      throw const AppException(
        'OpenRouter API key is missing. Add OPENROUTER_API_KEY to .env.',
      );
    }

    final response = await _client.createChatCompletion(
      apiKey: _config.apiKey,
      body: {
        'model': _config.model,
        'temperature': _config.temperature,
        'max_tokens': _config.maxTokens,
        'response_format': {'type': 'json_object'},
        'messages': [
          {
            'role': 'system',
            'content': _systemPrompt,
          },
          {
            'role': 'user',
            'content': jsonEncode({
              'text': text,
              'source_language': sourceLanguage ?? 'auto',
              'target_language': targetLanguage,
            }),
          },
        ],
      },
    );

    final content = _firstMessageContent(response);
    final parsed = _parseStructuredContent(content);
    final best = _stringValue(parsed, 'best');
    if (best == null || best.isEmpty) {
      throw const AppException('OpenRouter did not return a translation.');
    }

    return TranslationResult(
      originalText: text,
      translatedText: best,
      sourceLanguage: sourceLanguage ?? 'auto',
      targetLanguage: targetLanguage,
      providerId: id,
      alternatives: _stringList(parsed, 'alternatives'),
      contextNotes: _stringList(parsed, 'context_notes'),
      partOfSpeech: _stringValue(parsed, 'part_of_speech'),
      tone: _stringValue(parsed, 'tone'),
    );
  }

  static const _systemPrompt = '''
Translate between Russian and English.
Return only valid JSON with this shape:
{
  "best": "short best translation",
  "alternatives": ["alternative 1", "alternative 2"],
  "context_notes": ["brief usage note"],
  "part_of_speech": "noun/verb/adjective/phrase/unknown",
  "tone": "neutral/formal/informal/slang/technical/unknown"
}
If the source is a single ambiguous word, include context-specific alternatives.
Keep notes short and practical.
''';

  String _firstMessageContent(Map<String, Object?> response) {
    final choices = response['choices'];
    if (choices is! List || choices.isEmpty) {
      throw const AppException('OpenRouter returned no choices.');
    }
    final first = choices.first;
    if (first is! Map<String, Object?>) {
      throw const AppException('OpenRouter returned an invalid choice.');
    }
    final message = first['message'];
    if (message is! Map<String, Object?>) {
      throw const AppException('OpenRouter returned an invalid message.');
    }
    final content = message['content'];
    if (content is String && content.trim().isNotEmpty) {
      return content;
    }
    throw const AppException('OpenRouter returned an empty message.');
  }

  Map<String, Object?> _parseStructuredContent(String content) {
    final decoded = jsonDecode(content);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    throw const AppException('OpenRouter returned invalid translation JSON.');
  }

  String? _stringValue(Map<String, Object?> body, String key) {
    final value = body[key];
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }

  List<String> _stringList(Map<String, Object?> body, String key) {
    final value = body[key];
    if (value is! List) {
      return const [];
    }
    return [
      for (final item in value)
        if (item is String && item.trim().isNotEmpty) item.trim(),
    ];
  }
}
