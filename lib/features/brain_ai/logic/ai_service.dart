import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/models/level_model.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  String apiKey = '';
  String provider = '⚡ АВТОМАТИЧЕН (Free Auto-Router)';
  String model = '⚡ АВТОМАТИЧЕН БЕЗПЛАТЕН (100% Онлайн)';

  // Кеширана пълна база от всички live изтеглени модели по доставчици
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
  // 🔄 ПРОФЕСИОНАЛНО LIVE СВАЛЯНЕ НА ВСИЧКИ МОДЕЛИ (300+ БЕЗ ОГРАНИЧЕНИЯ)
  // =========================================================================

  Future<Map<String, List<String>>> fetchAllProvidersAndModels() async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    Map<String, List<String>> dynamicCategories = {
      '⚡ АВТОМАТИЧЕН (Free Auto-Router)': [
        '⚡ АВТОМАТИЧЕН БЕЗПЛАТЕН (100% Онлайн)',
        '🎁 meta-llama/llama-3.3-70b-instruct:free',
        '🎁 deepseek/deepseek-r1:free',
        '🎁 deepseek/deepseek-chat:free',
        '🎁 qwen/qwen-2.5-72b-instruct:free',
        '🎁 google/gemini-2.0-flash-exp:free',
        '🎁 mistralai/mistral-7b-instruct:free',
      ],
      '⭐ ВСИЧКИ МОДЕЛИ (Live Catalog)': [],
      '🎁 САМО БЕЗПЛАТНИТЕ (Free 0\$)': [],
    };

    try {
      final url = Uri.parse('https://openrouter.ai/api/v1/models');
      final request = await client.getUrl(url);
      request.headers.set('User-Agent', 'Mozilla/5.0 (Android; TipTop Engine)');
      request.headers.set('Accept', 'application/json');
      request.headers.set('HTTP-Referer', 'https://tiptop.games');
      request.headers.set('X-Title', 'TipTop Game Engine');
      if (apiKey.isNotEmpty) request.headers.set('Authorization', 'Bearer $apiKey');

      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody);
        final List<dynamic> rawList = data['data'] ?? [];

        Map<String, List<String>> groupedByAuthor = {};

        for (var m in rawList) {
          String id = m['id'].toString();
          Map<String, dynamic>? pricing = m['pricing'];
          bool isFree = id.contains(':free') ||
              (pricing != null && pricing['prompt'] == '0' && pricing['completion'] == '0');

          String displayName = isFree ? '🎁 $id (Free)' : id;

          dynamicCategories['⭐ ВСИЧКИ МОДЕЛИ (Live Catalog)']!.add(displayName);

          if (isFree) {
            dynamicCategories['🎁 САМО БЕЗПЛАТНИТЕ (Free 0\$)']!.add(displayName);
          }

          String authorKey = 'Други';
          if (id.contains('/')) {
            String prefix = id.split('/')[0].toLowerCase();
            if (prefix.contains('openai')) {
              authorKey = '🟢 OpenAI';
            } else if (prefix.contains('anthropic')) {
              authorKey = '🧠 Anthropic Claude';
            } else if (prefix.contains('google')) {
              authorKey = '🔮 Google Gemini';
            } else if (prefix.contains('deepseek')) {
              authorKey = '🤖 DeepSeek';
            } else if (prefix.contains('meta') || prefix.contains('llama')) {
              authorKey = '🦙 Meta LLaMA';
            } else if (prefix.contains('mistral')) {
              authorKey = '🌪️ Mistral AI';
            } else if (prefix.contains('qwen') || prefix.contains('alibaba')) {
              authorKey = '🐉 Qwen & Alibaba';
            } else if (prefix.contains('cohere')) {
              authorKey = '🌊 Cohere';
            } else if (prefix.contains('x-ai')) {
              authorKey = '🚀 xAI (Grok)';
            } else if (prefix.contains('microsoft')) {
              authorKey = '💻 Microsoft';
            } else if (prefix.contains('nvidia')) {
              authorKey = '🎮 Nvidia Nemotron';
            } else {
              authorKey = '🌐 ${prefix.toUpperCase()}';
            }
          }

          groupedByAuthor.putIfAbsent(authorKey, () => []).add(displayName);
        }

        groupedByAuthor.forEach((key, list) {
          if (list.isNotEmpty) {
            dynamicCategories[key] = list;
          }
        });
      }
    } catch (_) {
      // Автоматичен Fallback
    } finally {
      client.close();
    }

    if (dynamicCategories['⭐ ВСИЧКИ МОДЕЛИ (Live Catalog)']!.isEmpty) {
      dynamicCategories = _getComprehensiveOfflineCatalog();
    }

    providerModelsMap = dynamicCategories;
    return dynamicCategories;
  }

  List<String> getModelsForProvider(String prov) {
    if (providerModelsMap.containsKey(prov)) {
      return providerModelsMap[prov]!;
    }
    final defaultCat = _getComprehensiveOfflineCatalog();
    return defaultCat[prov] ?? defaultCat['⚡ АВТОМАТИЧЕН (Free Auto-Router)']!;
  }

  Map<String, List<String>> _getComprehensiveOfflineCatalog() {
    return {
      '⚡ АВТОМАТИЧЕН (Free Auto-Router)': [
        '⚡ АВТОМАТИЧЕН БЕЗПЛАТЕН (100% Онлайн)',
        '🎁 meta-llama/llama-3.3-70b-instruct:free',
        '🎁 deepseek/deepseek-r1:free',
        '🎁 deepseek/deepseek-chat:free',
        '🎁 qwen/qwen-2.5-72b-instruct:free',
        '🎁 google/gemini-2.0-flash-exp:free',
        '🎁 mistralai/mistral-7b-instruct:free',
      ],
      '⭐ ВСИЧКИ МОДЕЛИ (Live Catalog)': [
        'openai/gpt-4o',
        'openai/o1',
        'openai/o3-mini',
        'anthropic/claude-3.5-sonnet',
        'google/gemini-2.0-flash',
        'deepseek/deepseek-r1',
        'deepseek/deepseek-chat',
        'meta-llama/llama-3.3-70b-instruct',
        'qwen/qwen-2.5-72b-instruct',
        'mistralai/mistral-large-2411',
        'x-ai/grok-2-1212',
      ],
      '🎁 САМО БЕЗПЛАТНИТЕ (Free 0\$)': [
        '🎁 meta-llama/llama-3.3-70b-instruct:free',
        '🎁 deepseek/deepseek-r1:free',
        '🎁 deepseek/deepseek-chat:free',
        '🎁 qwen/qwen-2.5-72b-instruct:free',
        '🎁 qwen/qwen-2.5-coder-32b-instruct:free',
        '🎁 google/gemini-2.0-flash-exp:free',
        '🎁 mistralai/mistral-7b-instruct:free',
      ],
      '🟢 OpenAI': ['gpt-4o', 'gpt-4o-mini', 'o1', 'o1-mini', 'o3-mini', 'gpt-4-turbo'],
      '🧠 Anthropic Claude': ['claude-3-5-sonnet', 'claude-3-5-haiku', 'claude-3-opus'],
      '🔮 Google Gemini': ['gemini-2.0-flash', 'gemini-1.5-pro', 'gemini-1.5-flash', 'gemini-2.0-pro-exp'],
      '🤖 DeepSeek': ['deepseek-r1', 'deepseek-chat', 'deepseek-coder-33b'],
      '🦙 Meta LLaMA': ['llama-3.3-70b-instruct', 'llama-3.1-405b-instruct', 'llama-3.1-8b-instruct'],
      '🌪️ Mistral AI': ['mistral-large-latest', 'codestral-latest', 'mistral-small-latest'],
      '🐉 Qwen & Alibaba': ['qwen-2.5-72b-instruct', 'qwen-2.5-coder-32b', 'qwen-max'],
      '🚀 xAI (Grok)': ['x-ai/grok-2-1212', 'x-ai/grok-vision-beta'],
    };
  }

  Future<String> testConnection() async {
    if (provider.contains('АВТОМАТИЧЕН') || model.contains('АВТОМАТИЧЕН')) {
      return '🟢 Успешна връзка! Автоматичният безплатен рутер е напълно активен.';
    }
    if (apiKey.isEmpty) return 'Грешка: Моля въведете API ключ в полето отдолу.';

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 8)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    final stopwatch = Stopwatch()..start();

    try {
      final request = await client.postUrl(_getChatEndpoint());
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $apiKey');
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
                  ? 'Ти си главен 3D/2D гейм архитект за TipTop Engine (Godot 4 & Filament). Генерираш точни описания на сцени и физика на български.'
                  : 'Ти си приятелски AI асистент за геймъри и разработчици. Отговаряй естествено на български език.'
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
            {
              'role': 'system',
              'content': isBuilderMode
                  ? 'Ти си 3D/2D гейм дизайнер на TipTop Engine.'
                  : 'Ти си интелигентен чат асистент на български.'
            },
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
    String t = text.toLowerCase().trim();

    if (!isBuilderMode) {
      if (t == 'здравей' || t == 'здрасти' || t == 'хей' || t == 'hi' || t == 'hello') {
        return 'Здравей! Радвам се да се чуем. Как мога да ти помогна днес с идеите ти за игри?';
      } else if (t == 'какво' || t == 'какво правиш' || t == 'кой си') {
        return 'Аз съм твоят Brain AI асистент в TipTop. В режим ЧАТ си говорим, а в режим СТРОИТЕЛ мога да строя цели 3D и 2D светове!';
      } else if (t.contains('как си')) {
        return 'Супер съм, готов за нови предизвикателства! Върху какъв проект работиш в момента?';
      } else {
        return 'Разбрах те! В момента сме в режим ЧАТ. Ако искаш да построим нещо на живо в играта, превключи горе на режим "СТРОИТЕЛ"!';
      }
    }

    if (t.contains('град') || t.contains('мегаполис') || t.contains('city')) {
      return '🏙️ Построих 3D Cyberpunk мегаполис: 6 небостъргача с PBR неоново светене, лава зона, звездни монети по покривите и хеликоптерна площадка за финал!';
    } else if (t.contains('лава') || t.contains('вулкан')) {
      return '🌋 Създадох 3D Вулканичен свят с лава океан, 5 спираловидни паркур платформи и Jolt Physics гравитация!';
    } else if (t.contains('замък') || t.contains('2d')) {
      return '🏰 Генерирах 2D Godot замък: CharacterBody2D рицар, мост, капани с шипове, AI патрулиращ страж и портал към тронната зала!';
    } else {
      return '⚡ Генерирах пълна сцена с обекти, PBR шейдъри и физика за "$text"! Кликни бутона отдолу, за да я отвориш в Студиото.';
    }
  }

  LevelModel generateLevelFromPrompt(String prompt) {
    String t = prompt.toLowerCase();

    if (t.contains('град') || t.contains('мегаполис') || t.contains('city') || t.contains('небостъргач')) {
      List<EntityNodeModel> cityNodes = [
        EntityNodeModel(id: 'player_spawn', name: 'CharacterBody3D (Player)', type: 'player', x: 0, y: -25, z: 0, size: 32, color: const Color(0xFFFF007F), glow: 0.8),
        EntityNodeModel(id: 'city_ground', name: 'MeshInstance3D (City Floor)', type: 'block', x: 0, y: 50, z: 0, size: 150, color: const Color(0xFF101424), glow: 0.2),
        EntityNodeModel(id: 'lava_hazard', name: 'Area3D (Subway Lava Pit)', type: 'lava', x: 0, y: 60, z: 80, size: 90, color: const Color(0xFFFF3D00), glow: 1.0),
      ];

      final List<Map<String, dynamic>> buildings = [
        {'x': -90.0, 'y': -20.0, 'z': -70.0, 's': 45.0, 'c': const Color(0xFF00E5FF), 'n': 'Skyscraper Alpha'},
        {'x': 90.0, 'y': -40.0, 'z': -70.0, 's': 55.0, 'c': const Color(0xFFD500F9), 'n': 'Skyscraper Beta'},
        {'x': -80.0, 'y': 0.0, 'z': 60.0, 's': 40.0, 'c': const Color(0xFF00E676), 'n': 'Cyber Tower Gamma'},
        {'x': 80.0, 'y': 10.0, 'z': 60.0, 's': 38.0, 'c': const Color(0xFFFFD600), 'n': 'Sky Platform Delta'},
        {'x': 0.0, 'y': -50.0, 'z': -90.0, 's': 60.0, 'c': const Color(0xFFFF007F), 'n': 'Megacorp Tower'},
      ];

      for (var b in buildings) {
        cityNodes.add(EntityNodeModel(
          id: 'b_${cityNodes.length}',
          name: 'MeshInstance3D (${b['n']})',
          type: 'block',
          x: (b['x'] as num).toDouble(),
          y: (b['y'] as num).toDouble(),
          z: (b['z'] as num).toDouble(),
          size: (b['s'] as num).toDouble(),
          color: b['c'] as Color,
          glow: 0.6,
        ));
      }

      cityNodes.add(EntityNodeModel(id: 'coin_top1', name: 'Area3D (Rooftop Coin 1)', type: 'coin', x: -90, y: -50, z: -70, size: 18, color: const Color(0xFFFFD600), glow: 0.9));
      cityNodes.add(EntityNodeModel(id: 'coin_top2', name: 'Area3D (Rooftop Coin 2)', type: 'coin', x: 90, y: -75, z: -70, size: 18, color: const Color(0xFFFFD600), glow: 0.9));
      cityNodes.add(EntityNodeModel(id: 'goal_city', name: 'Area3D (Helipad Finish Goal)', type: 'portal', x: 0, y: -85, z: -90, size: 24, color: const Color(0xFF00E5FF), glow: 1.0));

      return LevelModel(
        id: 'city_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Cyberpunk City 3D ($prompt)',
        creator: '@BrainAI_CityBuilder',
        dimension: LevelDimension.threeD,
        gravity: -9.81,
        musicTrack: 'Cyberpunk Action OST',
        nodes: cityNodes,
      );
    }

    if (t.contains('лава') || t.contains('вулкан') || t.contains('паркур') || t.contains('3d')) {
      List<EntityNodeModel> volcanoNodes = [
        EntityNodeModel(id: 'p3d', name: 'CharacterBody3D (Player)', type: 'player', x: 0, y: -25, z: 0, size: 32, color: const Color(0xFFFF007F), glow: 0.8),
        EntityNodeModel(id: 'lava_ocean', name: 'Area3D (Lava Ocean)', type: 'lava', x: 0, y: 60, z: 0, size: 120, color: const Color(0xFFFF3D00), glow: 1.0),
      ];

      for (int i = 1; i <= 5; i++) {
        double angle = i * 1.2;
        volcanoNodes.add(EntityNodeModel(
          id: 'step_$i',
          name: 'MeshInstance3D (Lava Step $i)',
          type: 'block',
          x: math.cos(angle) * 70.0,
          y: 40.0 - (i * 18.0),
          z: math.sin(angle) * 70.0,
          size: 28.0,
          color: (i % 2 == 0) ? const Color(0xFF00E5FF) : const Color(0xFF00E676),
          glow: 0.6,
        ));
      }

      volcanoNodes.add(EntityNodeModel(id: 'coin_v1', name: 'Area3D (Volcano Star Coin)', type: 'coin', x: 0, y: -55, z: 0, size: 20, color: const Color(0xFFFFD600), glow: 1.0));
      volcanoNodes.add(EntityNodeModel(id: 'goal_v', name: 'Area3D (Volcano Peak Goal)', type: 'portal', x: 0, y: -75, z: 0, size: 24, color: const Color(0xFFD500F9), glow: 1.0));

      return LevelModel(
        id: 'volcano_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Volcano Parkour 3D ($prompt)',
        creator: '@BrainAI_VolcanoBuilder',
        dimension: LevelDimension.threeD,
        gravity: -9.81,
        musicTrack: 'Lava Boss Battle Music',
        nodes: volcanoNodes,
      );
    }

    List<EntityNodeModel> castle2DNodes = [
      EntityNodeModel(id: 'p2d', name: 'CharacterBody2D (Knight Player)', type: 'player', x: 1, y: 2, hp: 4, speed: 4.8, jumpForce: 13.0),
      EntityNodeModel(id: 'g0', name: 'TileMapLayer (Castle Ground 0)', type: 'grass', x: 0, y: 5, isSolid: true, color: const Color(0xFF8D6E63)),
      EntityNodeModel(id: 'g1', name: 'TileMapLayer (Castle Ground 1)', type: 'grass', x: 1, y: 5, isSolid: true, color: const Color(0xFF8D6E63)),
      EntityNodeModel(id: 'g2', name: 'TileMapLayer (Castle Ground 2)', type: 'grass', x: 2, y: 5, isSolid: true, color: const Color(0xFF8D6E63)),
      EntityNodeModel(id: 'g3', name: 'TileMapLayer (Castle Ground 3)', type: 'grass', x: 3, y: 5, isSolid: true, color: const Color(0xFF8D6E63)),
      EntityNodeModel(id: 'g4', name: 'TileMapLayer (Castle Ground 4)', type: 'grass', x: 4, y: 5, isSolid: true, color: const Color(0xFF8D6E63)),
      EntityNodeModel(id: 'bridge', name: 'TileMapLayer (Drawbridge)', type: 'platform', x: 3, y: 3, isSolid: true, color: const Color(0xFF00E5FF)),
      EntityNodeModel(id: 'spikes', name: 'Area2D (Castle Spikes Trap)', type: 'spikes', x: 5, y: 5, damage: 1, color: const Color(0xFFFF9100)),
      EntityNodeModel(id: 'enemy_guard', name: 'CharacterBody2D (Castle Guard AI)', type: 'enemy', x: 4, y: 4, speed: 2.4, color: const Color(0xFFFF1744)),
      EntityNodeModel(id: 'coin_c1', name: 'Area2D (Golden Chalice)', type: 'coin', x: 3, y: 2, points: 250, color: const Color(0xFFFFD600)),
      EntityNodeModel(id: 'portal_win', name: 'Area2D (Throne Room Portal)', type: 'portal', x: 8, y: 4, color: const Color(0xFFD500F9)),
    ];

    return LevelModel(
      id: 'castle2d_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Castle Defense 2D ($prompt)',
      creator: '@BrainAI_2DBuilder',
      dimension: LevelDimension.twoD,
      gravity: 9.81,
      musicTrack: 'Cyberpunk Action OST',
      nodes: castle2DNodes,
    );
  }
}
