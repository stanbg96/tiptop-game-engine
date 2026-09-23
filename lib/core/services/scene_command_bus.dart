import 'dart:convert';
import 'package:flutter/material.dart';

class CommandExecutionResult {
  final bool isSuccess;
  final String message;
  final int nodesAffected;
  final String actionType;

  CommandExecutionResult({
    required this.isSuccess,
    required this.message,
    required this.nodesAffected,
    required this.actionType,
  });
}

class SceneCommandBus extends ChangeNotifier {
  static final SceneCommandBus _instance = SceneCommandBus._internal();
  factory SceneCommandBus() => _instance;
  SceneCommandBus._internal();

  final List<Map<String, dynamic>> _live3DNodes = [
    {
      'id': 'player_spawn',
      'name': 'CharacterBody3D (Player)',
      'x': 0.0, 'y': -25.0, 'z': 0.0,
      'size': 24.0, 'color': const Color(0xFFFF007F), 'type': 'player',
    },
  ];

  List<Map<String, dynamic>> get live3DNodes => _live3DNodes;

  // =========================================================================
  // ⚡ JSON ПАРСЕР (ЧЕТЕ РЕЦЕПТАТА ОТ ОБЛАКА И ЗАРЕЖДА ЛОКАЛНИТЕ ФАЙЛОВЕ)
  // =========================================================================

  CommandExecutionResult executeAiJsonResponse(String aiResponse) {
    try {
      // 1. Опитваме се да извадим JSON-а от текста (ако AI-то е сложило Markdown)
      String jsonStr = aiResponse;
      int startIndex = aiResponse.indexOf('{');
      int endIndex = aiResponse.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1) {
        jsonStr = aiResponse.substring(startIndex, endIndex + 1);
      }

      // 2. Декодираме рецептата
      final data = jsonDecode(jsonStr);
      final String action = data['action'] ?? 'build';
      final String msg = data['message'] ?? 'Сцената е обновена.';
      final List<dynamic> objects = data['objects'] ?? [];

      if (action == 'clear') {
        _live3DNodes.clear();
        _live3DNodes.add({
          'id': 'player_spawn', 'name': 'Player Spawn', 'x': 0.0, 'y': -25.0, 'z': 0.0, 
          'size': 24.0, 'color': const Color(0xFFFF007F), 'type': 'player'
        });
        notifyListeners();
        return CommandExecutionResult(isSuccess: true, message: msg, nodesAffected: 1, actionType: 'CLEAR');
      }

      // 3. Зареждане на простите ID-та към локалния рендерер
      for (var obj in objects) {
        String simpleId = obj['id'].toString().toLowerCase(); // напр. "car", "zombie", "house"
        double x = (obj['x'] as num).toDouble();
        double y = (obj['y'] as num?)?.toDouble() ?? 0.0;
        double z = (obj['z'] as num).toDouble();

        // Свързваме ПРОСТОТО ID с параметри за нашия 3D Painter (скоро ще е model_viewer_plus)
        _live3DNodes.add({
          'id': '${simpleId}_${DateTime.now().microsecondsSinceEpoch}',
          'name': 'Local Model: $simpleId.glb',
          'x': x,
          'y': _getYOffsetForType(simpleId) + y,
          'z': z,
          'size': _getSizeForType(simpleId),
          'color': _getColorForType(simpleId),
          'type': simpleId, // Подаваме простото ID към Painter-а!
        });
      }

      notifyListeners();
      return CommandExecutionResult(isSuccess: true, message: msg, nodesAffected: objects.length, actionType: 'BUILD');

    } catch (e) {
      // Ако AI-то се обърка и не върне JSON, връщаме грешка
      return CommandExecutionResult(isSuccess: false, message: 'AI не върна валидна JSON рецепта.', nodesAffected: 0, actionType: 'ERROR');
    }
  }

  // Помощни функции за свързване на простото ID към физични размери
  double _getYOffsetForType(String type) {
    if (type == 'car') return 36.0;
    if (type == 'house') return 15.0;
    if (type == 'tree') return 15.0;
    if (type == 'coin') return -10.0;
    if (type == 'lava') return 48.0;
    if (type == 'skyscraper') return -15.0;
    return 25.0;
  }

  double _getSizeForType(String type) {
    if (type == 'car') return 36.0;
    if (type == 'house') return 45.0;
    if (type == 'tree') return 38.0;
    if (type == 'coin') return 18.0;
    if (type == 'lava') return 90.0;
    if (type == 'skyscraper') return 45.0;
    return 30.0; // Default block
  }

  Color _getColorForType(String type) {
    if (type == 'car') return const Color(0xFF00E5FF);
    if (type == 'house') return const Color(0xFFFF9100);
    if (type == 'tree') return const Color(0xFF00E676);
    if (type == 'coin') return const Color(0xFFFFD600);
    if (type == 'lava') return const Color(0xFFFF3D00);
    if (type == 'skyscraper') return const Color(0xFFD500F9);
    return Colors.grey;
  }
}
