import 'dart:convert';
import 'dart:io';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  String apiKey = '';
  String provider = '🌐 OpenRouter (Всички)';
  String model = 'meta-llama/llama-3.3-70b-instruct:free';

  void configure({
    required String key,
    required String selectedProvider,
    required String selectedModel,
  }) {
    apiKey = key.trim();
    provider = selectedProvider;
    model = selectedModel.replaceAll('🎁 ', '').replaceAll(' (Free)', '').trim();
  }

  Uri _getModelsEndpoint() {
    if (provider.contains('OpenRouter')) {
      return Uri.parse('https://openrouter.ai/api/v1/models');
    } else if (provider.contains('Groq')) {
      return Uri.parse('https://api.groq.com/openai/v1/models');
    } else if (provider.contains('DeepSeek')) {
      return Uri.parse('https://api.deepseek.com/models');
    } else {
      return Uri.parse('https://api.openai.com/v1/models');
    }
  }

  Uri _getChatEndpoint() {
    if (provider.contains('OpenRouter')) {
      return Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    } else if (provider.contains('Groq')) {
      return Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    } else if (provider.contains('DeepSeek')) {
      return Uri.parse('https://api.deepseek.com/chat/completions');
    } else {
      return Uri.parse('https://api.openai.com/v1/chat/completions');
    }
  }

  Future<List<String>> fetchAvailableModels() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    final url = _getModelsEndpoint();

    try {
      final request = await client.getUrl(url);
      if (apiKey.isNotEmpty) {
        request.headers.set('Authorization', 'Bearer $apiKey');
      }
      request.headers.set('Content-Type', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final List<dynamic> rawList = data['data'] ?? [];
        List<String> models = [];

        for (var m in rawList) {
          String id = m['id'].toString();
          if (id.contains(':free') || id.contains('free') || id.contains('flash') || id.contains('mini')) {
            models.add('🎁 $id (Free)');
          } else {
            models.add(id);
          }
        }

        models.sort((a, b) {
          bool aFree = a.startsWith('🎁');
          bool bFree = b.startsWith('🎁');
          if (aFree && !bFree) return -1;
          if (!aFree && bFree) return 1;
          return a.compareTo(b);
        });

        return models.isNotEmpty ? models : getDefaultModelsFor(provider);
      } else {
        return getDefaultModelsFor(provider);
      }
    } catch (e) {
      return getDefaultModelsFor(provider);
    } finally {
      client.close();
    }
  }

  List<String> getDefaultModelsFor(String prov) {
    if (prov.contains('OpenRouter')) {
      return [
        '🎁 meta-llama/llama-3.3-70b-instruct:free',
        '🎁 deepseek/deepseek-r1:free',
        '🎁 qwen/qwen-2.5-72b-instruct:free',
        '🎁 google/gemini-2.0-flash-exp:free',
        '🎁 mistralai/mistral-7b-instruct:free',
        'openai/gpt-4o',
        'anthropic/claude-3.5-sonnet',
      ];
    } else if (prov.contains('Groq')) {
      return [
        '🎁 llama-3.3-70b-versatile (Free)',
        '🎁 llama-3.1-8b-instant (Free)',
        '🎁 mixtral-8x7b-32768 (Free)',
        '🎁 gemma2-9b-it (Free)',
      ];
    } else if (prov.contains('DeepSeek')) {
      return ['deepseek-chat', 'deepseek-reasoner'];
    } else {
      return ['gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo'];
    }
  }

  Future<String> testConnection() async {
    if (apiKey.isEmpty) {
      return 'Грешка: Моля въведете API ключ в полето отдолу.';
    }

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    final stopwatch = Stopwatch()..start();

    try {
      final request = await client.postUrl(_getChatEndpoint());
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $apiKey');

      final body = {
        'model': model,
        'messages': [
          {'role': 'user', 'content': 'Ping'}
        ],
        'max_tokens': 5,
      };

      request.write(jsonEncode(body));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      stopwatch.stop();

      if (response.statusCode == 200) {
        return 'Успешна връзка! Пинг: ${stopwatch.elapsedMilliseconds}ms\nМоделът $model е напълно активен.';
      } else {
        final err = jsonDecode(responseBody);
        String msg = err['error']?['message'] ?? responseBody;
        return 'Грешка от сървъра: $msg';
      }
    } catch (e) {
      return 'Грешка при връзка: Проверете дали ключът е правилен за $provider.';
    } finally {
      client.close();
    }
  }

  Future<String> sendPrompt(String prompt, {bool isBuilderMode = true}) async {
    if (apiKey.isEmpty) {
      return 'Грешка: Моля първо въведете и свържете вашия API ключ в таб "API Manager".';
    }

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 25);
    final url = _getChatEndpoint();

    try {
      final request = await client.postUrl(url);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $apiKey');

      String systemInstruction = isBuilderMode
          ? 'You are an expert AI Game Engine Architect for Google Filament. Output short, actionable game construction commands or JSON.'
          : 'You are a helpful gaming AI assistant.';

      final body = {
        'model': model,
        'messages': [
          {'role': 'system', 'content': systemInstruction},
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
      };

      request.write(jsonEncode(body));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['choices'][0]['message']['content'] ?? 'Няма отговор от AI';
      } else {
        final err = jsonDecode(responseBody);
        return 'API Грешка: ${err['error']?['message'] ?? responseBody}';
      }
    } catch (e) {
      return 'Мрежова грешка: $e';
    } finally {
      client.close();
    }
  }
}
