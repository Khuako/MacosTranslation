import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:macos_translation/core/errors/app_exception.dart';
import 'package:macos_translation/features/translation/data/providers/openrouter_translation_provider.dart';

class FakeOpenRouterClient implements OpenRouterClient {
  FakeOpenRouterClient(this.response);

  final Map<String, Object?> response;
  Map<String, Object?>? lastBody;

  @override
  Future<Map<String, Object?>> createChatCompletion({
    required String apiKey,
    required Map<String, Object?> body,
  }) async {
    lastBody = body;
    return response;
  }
}

void main() {
  group('OpenRouterTranslationProvider', () {
    test('returns structured translation variants from JSON content', () async {
      final client = FakeOpenRouterClient({
        'choices': [
          {
            'message': {
              'content': jsonEncode({
                'best': 'claim',
                'alternatives': ['statement', 'demand'],
                'context_notes': ['claim works for assertions and legal demands'],
                'part_of_speech': 'noun',
                'tone': 'neutral',
              }),
            },
          },
        ],
      });
      final provider = OpenRouterTranslationProvider(
        config: const OpenRouterConfig(
          apiKey: 'key',
          model: 'qwen/qwen3.7-plus',
        ),
        client: client,
      );

      final result = await provider.translate(
        text: 'заявление',
        sourceLanguage: 'ru',
        targetLanguage: 'en',
      );

      expect(result.translatedText, 'claim');
      expect(result.alternatives, ['statement', 'demand']);
      expect(result.contextNotes, ['claim works for assertions and legal demands']);
      expect(result.partOfSpeech, 'noun');
      expect(result.tone, 'neutral');
      expect(client.lastBody?['model'], 'qwen/qwen3.7-plus');
    });

    test('rejects calls without an API key', () async {
      final provider = OpenRouterTranslationProvider(
        config: const OpenRouterConfig(apiKey: '', model: 'qwen/qwen3.7-plus'),
        client: FakeOpenRouterClient(const {}),
      );

      expect(
        () => provider.translate(
          text: 'hello',
          sourceLanguage: 'en',
          targetLanguage: 'ru',
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('loads env values from a parent directory', () async {
      final previousDirectory = Directory.current;
      final tempDirectory = await Directory.systemTemp.createTemp(
        'openrouter_config_test_',
      );
      addTearDown(() async {
        Directory.current = previousDirectory;
        await tempDirectory.delete(recursive: true);
      });

      await File('${tempDirectory.path}/.env').writeAsString('''
OPENROUTER_API_KEY=test-key
OPENROUTER_MODEL=test/model
OPENROUTER_MAX_TOKENS=123
OPENROUTER_TEMPERATURE=0.4
''');
      final nestedDirectory = await Directory(
        '${tempDirectory.path}/one/two',
      ).create(recursive: true);

      Directory.current = nestedDirectory;

      final config = await OpenRouterConfig.load();

      expect(config.apiKey, 'test-key');
      expect(config.model, 'test/model');
      expect(config.maxTokens, 123);
      expect(config.temperature, 0.4);
    });
  });
}
