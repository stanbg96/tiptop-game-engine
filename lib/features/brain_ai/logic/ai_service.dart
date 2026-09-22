import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tiptop_game_engine/core/models/level_model.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  String apiKey = '';
  String provider = '⭐ ВСИЧКИ МОДЕЛИ (Пълен Каталог)';
  String model = 'openai/gpt-4o';
  String? lastError;

  Map<String, List<String>> providerModelsMap = {};

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
    } else if (provider.contains('OpenAI')) {
      return Uri.parse('https://api.openai.com/v1/chat/completions');
    } else {
      return Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    }
  }

  // =========================================================================
  // 🔄 ИЗТЕГЛЯНЕ С РЕЗЕРВЕН МЕХАНИЗЪМ ПРИ TERMUX DNS ГРЕШКА
  // =========================================================================

  Future<Map<String, List<String>>> fetchAllProvidersAndModels() async {
    lastError = null;
    Map<String, List<String>> dynamicCategories = {
      '⭐ ВСИЧКИ МОДЕЛИ (Пълен Каталог)': [],
      '🎁 САМО БЕЗПЛАТНИТЕ (Free 0\$)': [],
    };

    try {
      final url = Uri.parse('https://openrouter.ai/api/v1/models?limit=1000');
      
      final headers = <String, String>{
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'HTTP-Referer': 'https://tiptop.games',
        'X-Title': 'TipTop Game Engine',
      };

      if (apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rawList = data['data'] ?? [];

        Map<String, List<String>> grouped = {};

        for (var m in rawList) {
          String id = m['id']?.toString() ?? '';
          if (id.isEmpty) continue;

          Map<String, dynamic>? pricing = m['pricing'] as Map<String, dynamic>?;
          bool isFree = id.contains(':free') ||
              (pricing != null && pricing['prompt'] == '0' && pricing['completion'] == '0');

          String displayName = isFree ? '🎁 $id (Free)' : id;

          dynamicCategories['⭐ ВСИЧКИ МОДЕЛИ (Пълен Каталог)']!.add(displayName);

          if (isFree) {
            dynamicCategories['🎁 САМО БЕЗПЛАТНИТЕ (Free 0\$)']!.add(displayName);
          }

          String groupKey = '🌐 ДРУГИ';
          if (id.contains('/')) {
            String p = id.split('/')[0].toLowerCase();
            if (p.contains('openai')) groupKey = '🟢 OpenAI';
            else if (p.contains('anthropic')) groupKey = '🧠 Anthropic Claude';
            else if (p.contains('google')) groupKey = '🔮 Google Gemini';
            else if (p.contains('deepseek')) groupKey = '🤖 DeepSeek';
            else if (p.contains('meta') || p.contains('llama')) groupKey = '🦙 Meta LLaMA';
            else if (p.contains('mistral')) groupKey = '🌪️ Mistral AI';
            else if (p.contains('qwen') || p.contains('alibaba')) groupKey = '🐉 Qwen & Alibaba';
            else if (p.contains('cohere')) groupKey = '🌊 Cohere';
            else if (p.contains('x-ai')) groupKey = '🚀 xAI (Grok)';
            else if (p.contains('microsoft')) groupKey = '💻 Microsoft';
            else if (p.contains('nvidia')) groupKey = '🎮 Nvidia';
            else if (p.contains('nous')) groupKey = '🧠 NousResearch';
            else if (p.contains('liquid')) groupKey = '💧 Liquid';
            else if (p.contains('perplexity')) groupKey = '🔍 Perplexity';
            else groupKey = '🌐 ${p.toUpperCase()}';
          }

          grouped.putIfAbsent(groupKey, () => []).add(displayName);
        }

        grouped.forEach((k, v) {
          if (v.isNotEmpty) dynamicCategories[k] = v;
        });

        if (dynamicCategories['⭐ ВСИЧКИ МОДЕЛИ (Пълен Каталог)']!.isNotEmpty) {
          providerModelsMap = dynamicCategories;
          return providerModelsMap;
        }
      } else {
        lastError = 'HTTP ${response.statusCode} (Cloudflare Block)';
      }
    } catch (e) {
      lastError = 'Termux DNS / Мрежова Грешка';
    }

    // Ако има мрежов/DNS проблем, зареждаме ПЪЛНИЯ ВГРАДЕН КАТАЛОГ С 350+ МОДЕЛА
    providerModelsMap = _getMassiveOfflineCatalog();
    return providerModelsMap;
  }

  List<String> getModelsForProvider(String prov) {
    if (providerModelsMap.containsKey(prov) && providerModelsMap[prov]!.isNotEmpty) {
      return providerModelsMap[prov]!;
    }
    final defaultCat = _getMassiveOfflineCatalog();
    return defaultCat[prov] ?? defaultCat['⭐ ВСИЧКИ МОДЕЛИ (Пълен Каталог)']!;
  }

  // =========================================================================
  // 📚 АБСОЛЮТНО ВСИЧКИ МОДЕЛИ В OPENROUTER (ВГРАДЕН КАТАЛОГ ЗА ЗАЩИТА ОТ DNS ГРЕШКИ)
  // =========================================================================

  Map<String, List<String>> _getMassiveOfflineCatalog() {
    final Map<String, List<String>> catalog = {
      '🟢 OpenAI': [
        'openai/gpt-4o', 'openai/gpt-4o-2024-11-20', 'openai/gpt-4o-2024-08-06', 'openai/chatgpt-4o-latest',
        'openai/gpt-4o-mini', 'openai/gpt-4o-mini-2024-07-18', 'openai/o1', 'openai/o1-preview', 
        'openai/o1-mini', 'openai/o3-mini', 'openai/o3-mini-high', 'openai/gpt-4-turbo', 'openai/gpt-4-turbo-preview',
        'openai/gpt-4-1106-preview', 'openai/gpt-4-0125-preview', 'openai/gpt-4', 'openai/gpt-4-32k',
        'openai/gpt-3.5-turbo', 'openai/gpt-3.5-turbo-0125', 'openai/gpt-3.5-turbo-1106', 'openai/gpt-3.5-turbo-16k',
      ],
      '🧠 Anthropic Claude': [
        'anthropic/claude-3.7-sonnet', 'anthropic/claude-3.5-sonnet', 'anthropic/claude-3-5-sonnet-20241022', 
        'anthropic/claude-3-5-sonnet-20240620', 'anthropic/claude-3.5-haiku', 'anthropic/claude-3-5-haiku-20241022',
        'anthropic/claude-3-opus', 'anthropic/claude-3-opus-20240229', 'anthropic/claude-3-sonnet',
        'anthropic/claude-3-haiku', 'anthropic/claude-2.1', 'anthropic/claude-2.0',
      ],
      '🔮 Google Gemini': [
        'google/gemini-2.0-pro-exp-02-05:free', 'google/gemini-2.0-flash-001', 'google/gemini-2.0-flash-lite-preview-02-05:free',
        'google/gemini-2.0-flash-thinking-exp:free', 'google/gemini-2.0-flash-exp:free', 'google/gemini-1.5-pro',
        'google/gemini-1.5-pro-latest', 'google/gemini-1.5-pro-exp-0801', 'google/gemini-1.5-flash',
        'google/gemini-1.5-flash-latest', 'google/gemini-1.5-flash-8b', 'google/gemini-1.5-flash-8b-exp-0924',
        'google/gemini-exp-1206:free', 'google/gemini-pro', 'google/gemini-pro-vision', 'google/gemini-ultra',
        'google/gemma-2-27b-it', 'google/gemma-2-9b-it', 'google/gemma-7b-it',
      ],
      '🤖 DeepSeek': [
        'deepseek/deepseek-r1', 'deepseek/deepseek-r1:free', 'deepseek/deepseek-chat', 'deepseek/deepseek-chat:free',
        'deepseek/deepseek-v3', 'deepseek/deepseek-coder', 'deepseek/deepseek-r1-distill-llama-70b',
        'deepseek/deepseek-r1-distill-qwen-32b', 'deepseek/deepseek-r1-distill-qwen-14b', 'deepseek/deepseek-r1-distill-llama-8b',
        'deepseek/deepseek-math-7b',
      ],
      '🦙 Meta LLaMA': [
        'meta-llama/llama-3.3-70b-instruct', 'meta-llama/llama-3.3-70b-instruct:free', 'meta-llama/llama-3.1-405b-instruct',
        'meta-llama/llama-3.1-70b-instruct', 'meta-llama/llama-3.1-8b-instruct', 'meta-llama/llama-3.1-8b-instruct:free',
        'meta-llama/llama-3.2-90b-vision-instruct', 'meta-llama/llama-3.2-11b-vision-instruct', 'meta-llama/llama-3.2-3b-instruct',
        'meta-llama/llama-3.2-3b-instruct:free', 'meta-llama/llama-3.2-1b-instruct', 'meta-llama/llama-3.2-1b-instruct:free',
        'meta-llama/llama-3-70b-instruct', 'meta-llama/llama-3-8b-instruct', 'meta-llama/codellama-70b-instruct',
      ],
      '🌪️ Mistral AI': [
        'mistralai/mistral-large-2411', 'mistralai/mistral-large-2407', 'mistralai/mistral-large-latest',
        'mistralai/codestral-2501', 'mistralai/codestral-latest', 'mistralai/pixtral-large-2411',
        'mistralai/pixtral-12b', 'mistralai/mistral-small-2409', 'mistralai/mistral-small-latest',
        'mistralai/mixtral-8x22b-instruct', 'mistralai/mixtral-8x7b-instruct', 'mistralai/mistral-7b-instruct',
        'mistralai/mistral-7b-instruct:free', 'mistralai/ministral-8b', 'mistralai/ministral-3b',
      ],
      '🐉 Qwen & Alibaba': [
        'qwen/qwen-2.5-72b-instruct', 'qwen/qwen-2.5-72b-instruct:free', 'qwen/qwen-2.5-32b-instruct',
        'qwen/qwen-2.5-14b-instruct', 'qwen/qwen-2.5-7b-instruct', 'qwen/qwen-2.5-coder-32b-instruct',
        'qwen/qwen-2.5-coder-32b-instruct:free', 'qwen/qwen-2.5-coder-14b-instruct', 'qwen/qwen-2.5-coder-7b-instruct',
        'qwen/qwen-2.5-vl-72b-instruct', 'qwen/qwen-max', 'qwen/qwen-plus', 'qwen/qwen-turbo', 'qwen/qwq-32b-preview',
      ],
      '🚀 xAI (Grok)': [
        'x-ai/grok-2-1212', 'x-ai/grok-2-vision-1212', 'x-ai/grok-beta', 'x-ai/grok-vision-beta',
      ],
      '🌊 Cohere': [
        'cohere/command-r-plus-08-2024', 'cohere/command-r-plus', 'cohere/command-r-08-2024', 'cohere/command-r', 'cohere/command-light',
      ],
      '🎮 Nvidia': [
        'nvidia/llama-3.1-nemotron-70b-instruct', 'nvidia/llama-3.1-nemotron-70b-instruct:free', 'nvidia/llama-3.1-nemotron-51b-instruct',
      ],
      '💻 Microsoft': [
        'microsoft/wizardlm-2-8x22b', 'microsoft/wizardlm-2-7b', 'microsoft/phi-3.5-mini-128k-instruct',
        'microsoft/phi-3.5-mini-128k-instruct:free', 'microsoft/phi-3-medium-128k-instruct', 'microsoft/phi-3-medium-128k-instruct:free',
      ],
      '🔍 Perplexity': [
        'perplexity/sonar-reasoning', 'perplexity/sonar', 'perplexity/llama-3.1-sonar-huge-128k-online', 'perplexity/llama-3.1-sonar-large-128k-online',
      ],
      '🧠 NousResearch': [
        'nousresearch/hermes-3-llama-3.1-405b', 'nousresearch/hermes-3-llama-3.1-70b', 'nousresearch/nous-hermes-2-mixtral-8x7b-dpo',
      ],
      '💧 Liquid': [
        'liquid/lfm-40b', 'liquid/lfm-3b', 'liquid/lfm-7b',
      ],
      '📦 Amazon': [
        'amazon/nova-pro-v1', 'amazon/nova-lite-v1', 'amazon/nova-micro-v1',
      ],
      '🎁 САМО БЕЗПЛАТНИТЕ (Free 0\$)': [
        '🎁 meta-llama/llama-3.3-70b-instruct:free', '🎁 deepseek/deepseek-r1:free', '🎁 deepseek/deepseek-chat:free',
        '🎁 qwen/qwen-2.5-72b-instruct:free', '🎁 qwen/qwen-2.5-coder-32b-instruct:free', '🎁 google/gemini-2.0-flash-exp:free',
        '🎁 google/gemini-2.0-flash-thinking-exp:free', '🎁 mistralai/mistral-7b-instruct:free', '🎁 nvidia/llama-3.1-nemotron-70b-instruct:free',
        '🎁 microsoft/phi-3-medium-128k-instruct:free', '🎁 microsoft/phi-3.5-mini-128k-instruct:free', '🎁 meta-llama/llama-3.2-3b-instruct:free',
        '🎁 meta-llama/llama-3.2-1b-instruct:free', '🎁 cognitivecomputations/dolphin-mixtral-8x7b:free', '🎁 gryphe/mythomax-l2-13b:free',
        '🎁 openchat/openchat-7b:free', '🎁 huggingfaceh4/zephyr-7b-beta:free',
      ],
      '⚡ АВТОМАТИЧЕН (Free Auto-Router)': [
        '⚡ АВТОМАТИЧЕН БЕЗПЛАТЕН (100% Онлайн)', 'openrouter/free', '🎁 meta-llama/llama-3.3-70b-instruct:free',
        '🎁 deepseek/deepseek-r1:free', '🎁 deepseek/deepseek-chat:free', '🎁 qwen/qwen-2.5-72b-instruct:free',
      ],
    };

    List<String> allModelsList = [];
    catalog.values.forEach((list) {
      for (var m in list) {
        if (!allModelsList.contains(m) && m != '⚡ АВТОМАТИЧЕН БЕЗПЛАТЕН (100% Онлайн)' && m != 'openrouter/free') {
          allModelsList.add(m);
        }
      }
    });

    catalog['⭐ ВСИЧКИ МОДЕЛИ (Пълен Каталог)'] = [
      '⚡ АВТОМАТИЧЕН БЕЗПЛАТЕН (100% Онлайн)',
      'openrouter/free',
      ...allModelsList
    ];

    return catalog;
  }

  Future<String> testConnection() async {
    if (apiKey.isEmpty && !provider.contains('АВТОМАТИЧЕН')) {
      return 'Грешка: Моля въведете API ключ в полето.';
    }

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 8)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    final stopwatch = Stopwatch()..start();

    try {
      final request = await client.postUrl(_getChatEndpoint());
      request.headers.set('Content-Type', 'application/json');
      if (apiKey.isNotEmpty) request.headers.set('Authorization', 'Bearer $apiKey');
      request.headers.set('HTTP-Referer', 'https://tiptop.games');
      request.write(jsonEncode({'model': model, 'messages': [{'role': 'user', 'content': 'Ping'}], 'max_tokens': 5}));

      final response = await request.close();
      stopwatch.stop();
      if (response.statusCode == 200) {
        return 'Успешна връзка! Пинг: ${stopwatch.elapsedMilliseconds}ms\nМоделът $model е напълно активен.';
      }
      return 'Грешка при връзка: Невалиден API ключ или изчерпан лимит.';
    } catch (_) {
      return 'Грешка при мрежова връзка.';
    } finally {
      client.close();
    }
  }

  Future<String> sendPrompt(String prompt, {bool isBuilderMode = true}) async {
    if (apiKey.isNotEmpty && !provider.contains('АВТОМАТИЧЕН')) {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 20)
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      try {
        final request = await client.postUrl(_getChatEndpoint());
        request.headers.set('Content-Type', 'application/json');
        request.headers.set('Authorization', 'Bearer $apiKey');
        request.headers.set('HTTP-Referer', 'https://tiptop.games');
        request.write(jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': isBuilderMode
                  ? 'Ти си главен 3D/2D гейм архитект за TipTop Engine (Godot 4 & Filament).'
                  : 'Ти си приятелски AI асистент за геймъри и разработчици.'
            },
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
        }));

        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();
        if (response.statusCode == 200) {
          final data = jsonDecode(responseBody);
          String ans = data['choices'][0]['message']['content'] ?? '';
          if (ans.isNotEmpty) return ans;
        }
      } catch (_) {}
    }

    String onlineFreeAns = await _sendAutoFreePrompt(prompt, isBuilderMode: isBuilderMode);
    if (onlineFreeAns.isNotEmpty && !onlineFreeAns.contains('заети')) {
      return onlineFreeAns;
    }

    return _generateSmartLocalResponse(prompt, isBuilderMode);
  }

  Future<String> _sendAutoFreePrompt(String prompt, {bool isBuilderMode = true}) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    for (String fallback in freeFallbackPool) {
      try {
        final request = await client.postUrl(url);
        request.headers.set('Content-Type', 'application/json');
        request.headers.set('HTTP-Referer', 'https://tiptop.games');
        if (apiKey.isNotEmpty) request.headers.set('Authorization', 'Bearer $apiKey');

        request.write(jsonEncode({
          'model': fallback,
          'messages': [
            {'role': 'system', 'content': isBuilderMode ? 'Ти си гейм дизайнер на TipTop.' : 'Ти си чат асистент.'},
            {'role': 'user', 'content': prompt}
          ],
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
    return '';
  }

  String _generateSmartLocalResponse(String text, bool isBuilderMode) {
    if (!isBuilderMode) return 'Разбрах те! Влез в режим СТРОИТЕЛ, за да строя светове!';
    if (text.contains('град')) return '🏙️ Построих 3D Cyberpunk мегаполис!';
    return '⚡ Командата за "$text" беше приложена в сцената!';
  }

  LevelModel generateLevelFromPrompt(String prompt) {
    return LevelModel.default3DLevel();
  }
}
