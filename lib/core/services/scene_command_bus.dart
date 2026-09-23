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

  CommandExecutionResult executeAiPrompt(String prompt) {
    final lower = prompt.toLowerCase();

    if (lower.contains('изчисти') || lower.contains('изтрий')) {
      _live3DNodes.clear();
      _live3DNodes.add({
        'id': 'player_spawn', 'name': 'Player Spawn', 'x': 0.0, 'y': -25.0, 'z': 0.0,
        'size': 24.0, 'color': const Color(0xFFFF007F), 'type': 'player',
      });
      notifyListeners();
      return CommandExecutionResult(
        isSuccess: true,
        message: '🧹 Сцената е изчистена успешно.',
        nodesAffected: 1,
        actionType: 'CLEAR',
      );
    }

    if (lower.contains('град') || lower.contains('небостъргач')) {
      _live3DNodes.clear();
      _live3DNodes.addAll([
        {'id': 'player_spawn', 'name': 'Player Spawn', 'x': 0.0, 'y': -25.0, 'z': 0.0, 'size': 24.0, 'color': const Color(0xFFFF007F), 'type': 'player'},
        {'id': 'sky_1', 'name': 'Tower Alpha', 'x': -70.0, 'y': -15.0, 'z': -60.0, 'size': 45.0, 'color': const Color(0xFF00E5FF), 'type': 'skyscraper'},
        {'id': 'sky_2', 'name': 'Tower Beta', 'x': 70.0, 'y': -15.0, 'z': -60.0, 'size': 45.0, 'color': const Color(0xFFD500F9), 'type': 'skyscraper'},
        {'id': 'car_1', 'name': 'Cyber Car', 'x': 0.0, 'y': 36.0, 'z': 20.0, 'size': 36.0, 'color': const Color(0xFFFFD600), 'type': 'car'},
      ]);
      notifyListeners();
      return CommandExecutionResult(
        isSuccess: true,
        message: '🏙️ Построен е Cyberpunk мегаполис с 3 сгради и кола!',
        nodesAffected: 4,
        actionType: 'BUILD_CITY',
      );
    }

    if (lower.contains('къща') || lower.contains('house')) {
      _live3DNodes.add({
        'id': 'house_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Solid House',
        'x': 0.0, 'y': 15.0, 'z': 0.0,
        'size': 45.0, 'color': const Color(0xFFFF9100), 'type': 'house',
      });
      notifyListeners();
      return CommandExecutionResult(
        isSuccess: true,
        message: '🏡 Създадена е 3D къща с Backface Culling.',
        nodesAffected: 1,
        actionType: 'ADD_HOUSE',
      );
    }

    if (lower.contains('кола') || lower.contains('car')) {
      _live3DNodes.add({
        'id': 'car_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Sport Car',
        'x': 10.0, 'y': 36.0, 'z': 15.0,
        'size': 36.0, 'color': const Color(0xFF00E5FF), 'type': 'car',
      });
      notifyListeners();
      return CommandExecutionResult(
        isSuccess: true,
        message: '🏎️ Създадена е 3D кола.',
        nodesAffected: 1,
        actionType: 'ADD_CAR',
      );
    }

    // По подразбиране добавяме куб
    _live3DNodes.add({
      'id': 'block_${DateTime.now().millisecondsSinceEpoch}',
      'name': 'Block ($prompt)',
      'x': 0.0, 'y': 25.0, 'z': 0.0,
      'size': 30.0, 'color': const Color(0xFF00E676), 'type': 'block',
    });
    notifyListeners();
    return CommandExecutionResult(
      isSuccess: true,
      message: '📦 Обектът за "$prompt" е генериран в сцената.',
      nodesAffected: 1,
      actionType: 'ADD_BLOCK',
    );
  }

  CommandExecutionResult executeAiJsonResponse(String aiResponse) {
    try {
      String jsonStr = aiResponse;
      int startIndex = aiResponse.indexOf('{');
      int endIndex = aiResponse.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1) {
        jsonStr = aiResponse.substring(startIndex, endIndex + 1);
      }

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

      for (var obj in objects) {
        String simpleId = obj['id'].toString().toLowerCase();
        double x = (obj['x'] as num).toDouble();
        double y = (obj['y'] as num?)?.toDouble() ?? 0.0;
        double z = (obj['z'] as num).toDouble();

        _live3DNodes.add({
          'id': '${simpleId}_${DateTime.now().microsecondsSinceEpoch}',
          'name': 'Local Model: $simpleId.glb',
          'x': x,
          'y': _getYOffsetForType(simpleId) + y,
          'z': z,
          'size': _getSizeForType(simpleId),
          'color': _getColorForType(simpleId),
          'type': simpleId,
        });
      }

      notifyListeners();
      return CommandExecutionResult(isSuccess: true, message: msg, nodesAffected: objects.length, actionType: 'BUILD');
    } catch (e) {
      return CommandExecutionResult(isSuccess: false, message: 'AI не върна валидна JSON рецепта.', nodesAffected: 0, actionType: 'ERROR');
    }
  }

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
    return 30.0;
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
