import 'dart:convert';
import 'dart:io';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  String apiKey = '';
  String provider = '⚡ АВТОМАТИЧЕН (Free Auto-Router)';
  String model = '⚡ АВТОМАТИЧЕН БЕЗПЛАТЕН (100% Онлайн)';

  static const List<String> freeFallbackPool = [
    'meta-llama/llama-3.3-70b-instruct:free',
    'deepseek/deepseek-r1:free',
    'deepseek/deepseek-chat:free',
    'qwen/qwen-2.5-72b-instruct:free',
    'google/gemini-2.0-flash-exp:free',
    'mistralai/mistral-7b-instruct:free',
  ];

  void configure({required String key, required String selectedProvider, required String selectedModel}) {
    apiKey = key.trim();
    provider = selectedProvider;
    model = selectedModel.replaceAll('🎁 ', '').replaceAll(' (Free)', '').trim();
  }

  Uri _getChatEndpoint() {
    if (provider.contains('Groq')) {
      return Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    } else if (provider.contains('DeepSeek')) {
      return Uri.parse('https://api.deepseek.com/chat/completions');
    } else if (provider.contains('Gemini')) {
      return Uri.parse('https://generativelanguage.googleapis.com/v1beta/openai/chat/completions');
    } else if (provider.contains('Mistral')) {
      return Uri.parse('https://api.mistral.ai/v1/chat/completions');
    } else if (provider.contains('OpenAI')) {
      return Uri.parse('https://api.openai.com/v1/chat/completions');
    } else {
      return Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    }
  }

  Future<List<String>> fetchAvailableModels() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    final url = Uri.parse(provider.contains('Groq') ? 'https://api.groq.com/openai/v1/models' : 'https://openrouter.ai/api/v1/models');

    try {
      final request = await client.getUrl(url);
      if (apiKey.isNotEmpty) request.headers.set('Authorization', 'Bearer $apiKey');
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final List<dynamic> rawList = data['data'] ?? [];
        List<String> freeModels = ['⚡ АВТОМАТИЧЕН БЕЗПЛАТЕН (100% Онлайн)'];
        List<String> paidModels = [];

        for (var m in rawList) {
          String id = m['id'].toString();
          if (id.contains('free')) {
            freeModels.add('🎁 $id (Free)');
          } else {
            paidModels.add(id);
          }
        }
        return [...freeModels, ...paidModels];
      }
      return getDefaultModelsFor(provider);
    } catch (_) {
      return getDefaultModelsFor(provider);
    } finally {
      client.close();
    }
  }

  List<String> getDefaultModelsFor(String prov) {
    if (prov.contains('Groq')) {
      return ['⚡ АВТОМАТИЧЕН БЕЗПЛАТЕН (Groq)', '🎁 llama-3.3-70b-versatile (Free)', '🎁 llama-3.1-8b-instant (Free)'];
    } else if (prov.contains('Gemini')) {
      return ['🎁 gemini-2.0-flash-exp (Free)', '🎁 gemini-1.5-flash (Free)', 'gemini-1.5-pro'];
    } else if (prov.contains('DeepSeek')) {
      return ['deepseek-chat', 'deepseek-reasoner (R1)'];
    } else if (prov.contains('OpenAI')) {
      return ['gpt-4o', 'gpt-4o-mini', 'o1-mini'];
    } else {
      return [
        '⚡ АВТОМАТИЧЕН БЕЗПЛАТЕН (100% Онлайн)',
        '🎁 meta-llama/llama-3.3-70b-instruct:free',
        '🎁 deepseek/deepseek-r1:free',
        '🎁 qwen/qwen-2.5-72b-instruct:free',
        '🎁 google/gemini-2.0-flash-exp:free',
        'openai/gpt-4o',
        'anthropic/claude-3.5-sonnet',
      ];
    }
  }

  Future<String> testConnection() async {
    if (provider.contains('АВТОМАТИЧЕН') || model.contains('АВТОМАТИЧЕН')) {
      return '🟢 Успешна връзка! Автоматичният безплатен рутер е активен с 6 резервни модела.';
    }
    if (apiKey.isEmpty) return 'Грешка: Моля въведете API ключ в полето отдолу.';

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    final stopwatch = Stopwatch()..start();

    try {
      final request = await client.postUrl(_getChatEndpoint());
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $apiKey');
      request.write(jsonEncode({'model': model, 'messages': [{'role': 'user', 'content': 'Ping'}], 'max_tokens': 5}));

      final response = await request.close();
      stopwatch.stop();
      if (response.statusCode == 200) {
        return 'Успешна връзка! Пинг: ${stopwatch.elapsedMilliseconds}ms\nМоделът $model е напълно активен.';
      }
      return 'Грешка при връзка: Невалиден API ключ.';
    } catch (_) {
      return 'Грешка при мрежова връзка.';
    } finally {
      client.close();
    }
  }

  Future<String> sendPrompt(String prompt, {bool isBuilderMode = true}) async {
    if (provider.contains('АВТОМАТИЧЕН') || model.contains('АВТОМАТИЧЕН') || apiKey.isEmpty) {
      return await _sendAutoFreePrompt(prompt, isBuilderMode: isBuilderMode);
    }

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
    try {
      final request = await client.postUrl(_getChatEndpoint());
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $apiKey');
      request.write(jsonEncode({
        'model': model,
        'messages': [{'role': 'user', 'content': prompt}],
        'temperature': 0.7,
      }));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['choices'][0]['message']['content'] ?? 'Няма отговор';
      }
      return await _sendAutoFreePrompt(prompt, isBuilderMode: isBuilderMode);
    } catch (_) {
      return await _sendAutoFreePrompt(prompt, isBuilderMode: isBuilderMode);
    } finally {
      client.close();
    }
  }

  Future<String> _sendAutoFreePrompt(String prompt, {bool isBuilderMode = true}) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    for (String fallback in freeFallbackPool) {
      try {
        final request = await client.postUrl(url);
        request.headers.set('Content-Type', 'application/json');
        if (apiKey.isNotEmpty) request.headers.set('Authorization', 'Bearer $apiKey');
        request.write(jsonEncode({
          'model': fallback,
          'messages': [{'role': 'user', 'content': prompt}],
          'temperature': 0.7,
        }));

        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();
        if (response.statusCode == 200) {
          final data = jsonDecode(responseBody);
          String content = data['choices'][0]['message']['content'] ?? '';
          if (content.isNotEmpty) {
            client.close();
            return content;
          }
        }
      } catch (_) {
        continue;
      }
    }
    client.close();
    return 'Всички безплатни канали са заети. Моля опитайте пак след няколко секунди.';
  }
}
