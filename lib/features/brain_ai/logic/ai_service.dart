import 'dart:convert';
import 'dart:io';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  String apiKey = '';
  String provider = 'OpenAI';
  String model = 'gpt-4o';

  void configure({
    required String key,
    required String selectedProvider,
    required String selectedModel,
  }) {
    apiKey = key.trim();
    provider = selectedProvider;
    model = selectedModel;
  }

  // 1. Download & Fetch real models list from Provider API
  Future<List<String>> fetchAvailableModels() async {
    if (apiKey.isEmpty) {
      throw Exception('Please enter an API Key first.');
    }

    final client = HttpClient();
    Uri url;

    if (provider == 'Groq (Fast)') {
      url = Uri.parse('https://api.groq.com/openai/v1/models');
    } else if (provider == 'OpenRouter (Free/All)') {
      url = Uri.parse('https://openrouter.ai/api/v1/models');
    } else {
      url = Uri.parse('https://api.openai.com/v1/models');
    }

    try {
      final request = await client.getUrl(url);
      request.headers.set('Authorization', 'Bearer $apiKey');
      request.headers.set('Content-Type', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final List<dynamic> rawList = data['data'] ?? [];
        List<String> models = rawList.map((m) => m['id'].toString()).toList();

        // Sort: Put free / mini / flash models at the top
        models.sort((a, b) {
          bool aFree = a.contains('free') || a.contains('mini') || a.contains('flash');
          bool bFree = b.contains('free') || b.contains('mini') || b.contains('flash');
          if (aFree && !bFree) return -1;
          if (!aFree && bFree) return 1;
          return a.compareTo(b);
        });

        return models;
      } else {
        throw Exception('API Error (${response.statusCode}): $responseBody');
      }
    } finally {
      client.close();
    }
  }

  // 2. Real Connection Test
  Future<String> testConnection() async {
    if (apiKey.isEmpty) {
      return 'Error: API Key is empty!';
    }

    final stopwatch = Stopwatch()..start();
    try {
      final models = await fetchAvailableModels();
      stopwatch.stop();
      return 'Success! Connected in ${stopwatch.elapsedMilliseconds}ms (${models.length} models fetched)';
    } catch (e) {
      return 'Connection Failed: ${e.toString()}';
    }
  }

  // 3. Send Prompt for Chat or Builder Agent
  Future<String> sendPrompt(String prompt, {bool isBuilderMode = true}) async {
    if (apiKey.isEmpty) {
      return 'Error: Please set and save your API key in the API Manager tab first.';
    }

    final client = HttpClient();
    Uri url;

    if (provider == 'Groq (Fast)') {
      url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    } else if (provider == 'OpenRouter (Free/All)') {
      url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    } else {
      url = Uri.parse('https://api.openai.com/v1/chat/completions');
    }

    try {
      final request = await client.postUrl(url);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $apiKey');

      String systemInstruction = isBuilderMode
          ? 'You are an expert AI Game Engine Architect for Google Filament. Output short, actionable game construction commands or JSON scene descriptions.'
          : 'You are a friendly, helpful gaming AI assistant.';

      String actualModel = model;
      if (model == 'Free Auto-Tier') {
        actualModel = (provider == 'Groq (Fast)') ? 'llama-3.1-8b-instant' : 'gpt-4o-mini';
      }

      final body = {
        'model': actualModel,
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
        return data['choices'][0]['message']['content'] ?? 'Empty response from AI';
      } else {
        return 'API Error (${response.statusCode}): $responseBody';
      }
    } catch (e) {
      return 'Network Error: $e';
    } finally {
      client.close();
    }
  }
}
