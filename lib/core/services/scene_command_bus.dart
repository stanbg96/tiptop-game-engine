import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/engine_bridge/filament_bindings.dart';

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

  // Живи 3D възли в сцената
  final List<Map<String, dynamic>> _live3DNodes = [
    {
      'id': 'player_spawn',
      'name': 'CharacterBody3D (Player)',
      'x': 0.0,
      'y': -25.0,
      'z': 0.0,
      'size': 32.0,
      'color': const Color(0xFFFF007F),
      'type': 'player',
      'glow': 0.8,
    },
    {
      'id': 'ground_plane',
      'name': 'MeshInstance3D (World Floor)',
      'x': 0.0,
      'y': 50.0,
      'z': 0.0,
      'size': 140.0,
      'color': const Color(0xFF161A28),
      'type': 'block',
      'glow': 0.2,
    },
  ];

  List<Map<String, dynamic>> get live3DNodes => _live3DNodes;

  // =========================================================================
  // ⚡ ИЗПЪЛНЕНИЕ НА КОМАНДИ ОТ AI ЧАТА
  // =========================================================================

  CommandExecutionResult executeAiPrompt(String prompt) {
    String p = prompt.toLowerCase().trim();

    // 1. ПОСТРОЙ ЦЯЛ ГРАД
    if (p.contains('град') || p.contains('мегаполис') || p.contains('city') || p.contains('небостъргач')) {
      return buildCyberCity(prompt);
    }

    // 2. ПОСТРОЙ ЛАВА ПАРКУР
    if (p.contains('вулкан') || p.contains('паркур') || p.contains('лава свят')) {
      return buildVolcanoWorld();
    }

    // 3. ИЗТРИВАНЕ НА ОБЕКТИ
    if (p.contains('изтрий') || p.contains('магни') || p.contains('delete') || p.contains('махни')) {
      if (p.contains('всичко') || p.contains('сцената')) {
        _live3DNodes.clear();
        _live3DNodes.add({
          'id': 'player_spawn',
          'name': 'CharacterBody3D (Player)',
          'x': 0.0,
          'y': -25.0,
          'z': 0.0,
          'size': 32.0,
          'color': const Color(0xFFFF007F),
          'type': 'player',
          'glow': 0.8,
        });
        notifyListeners();
        return CommandExecutionResult(
          isSuccess: true,
          message: '🧹 Сцената беше изчистена до начален Player Spawn.',
          nodesAffected: 1,
          actionType: 'CLEAR_SCENE',
        );
      } else if (p.contains('лава')) {
        int before = _live3DNodes.length;
        _live3DNodes.removeWhere((n) => n['type'] == 'lava');
        notifyListeners();
        return CommandExecutionResult(
          isSuccess: true,
          message: '🔥 Изтрити ${before - _live3DNodes.length} лава зони от сцената.',
          nodesAffected: before - _live3DNodes.length,
          actionType: 'DELETE_LAVA',
        );
      } else if (p.contains('враг') || p.contains('врагове')) {
        int before = _live3DNodes.length;
        _live3DNodes.removeWhere((n) => n['type'] == 'enemy');
        notifyListeners();
        return CommandExecutionResult(
          isSuccess: true,
          message: '👾 Всички врагове са премахнати от сцената.',
          nodesAffected: before - _live3DNodes.length,
          actionType: 'DELETE_ENEMIES',
        );
      }
    }

    // 4. МЕСТЕНЕ НА ОБЕКТ
    if (p.contains('премести') || p.contains('мести') || p.contains('move')) {
      for (var node in _live3DNodes) {
        if (node['type'] == 'player' || node['name'].toString().toLowerCase().contains('player')) {
          node['x'] = (node['x'] as num).toDouble() + 30.0;
          notifyListeners();
          return CommandExecutionResult(
            isSuccess: true,
            message: '🎯 Играчът беше преместен с +30 по X.',
            nodesAffected: 1,
            actionType: 'MOVE_NODE',
          );
        }
      }
    }

    // 5. ДОБАВЯНЕ НА НОВ 3D ОБЕКТ
    if (p.contains('добави') || p.contains('създай') || p.contains('куб') || p.contains('платформа')) {
      final newId = 'node_${DateTime.now().millisecondsSinceEpoch}';
      _live3DNodes.add({
        'id': newId,
        'name': 'MeshInstance3D (Custom Node)',
        'x': 0.0,
        'y': 0.0,
        'z': 0.0,
        'size': 35.0,
        'color': const Color(0xFF00E5FF),
        'type': 'block',
        'glow': 0.5,
      });
      FilamentEngine().add3DBox(0.0, 0.0, 0.0, 35.0, 35.0, 35.0, 0);
      notifyListeners();
      return CommandExecutionResult(
        isSuccess: true,
        message: '✅ Добавен нов 3D PBR блок в центъра на сцената (0, 0, 0).',
        nodesAffected: 1,
        actionType: 'CREATE_NODE',
      );
    }

    // ДЕФОЛТ: ДОБАВЯНЕ НА ИНТЕЛИГЕНТНА ПЛАТФОРМА
    final id = 'node_${DateTime.now().millisecondsSinceEpoch}';
    _live3DNodes.add({
      'id': id,
      'name': 'MeshInstance3D ($prompt)',
      'x': (math.Random().nextInt(80) - 40).toDouble(),
      'y': (math.Random().nextInt(40) - 20).toDouble(),
      'z': (math.Random().nextInt(80) - 40).toDouble(),
      'size': 30.0,
      'color': const Color(0xFF00E676),
      'type': 'block',
      'glow': 0.6,
    });
    notifyListeners();

    return CommandExecutionResult(
      isSuccess: true,
      message: '⚡ Сцената беше обновена за: "$prompt".',
      nodesAffected: 1,
      actionType: 'MUTATE_SCENE',
    );
  }

  // =========================================================================
  // 🏙️ ПРОЦЕДУРЕН СТРОИТЕЛ НА ГРАД (BUILD CYBER CITY)
  // =========================================================================

  CommandExecutionResult buildCyberCity(String query) {
    _live3DNodes.clear();

    // 1. Играч Spawn & Градска основа
    _live3DNodes.add({
      'id': 'p_spawn',
      'name': 'CharacterBody3D (Player)',
      'x': 0.0,
      'y': -25.0,
      'z': 0.0,
      'size': 32.0,
      'color': const Color(0xFFFF007F),
      'type': 'player',
      'glow': 0.8,
    });

    _live3DNodes.add({
      'id': 'city_asphalt',
      'name': 'MeshInstance3D (City Plaza Asphalt)',
      'x': 0.0,
      'y': 50.0,
      'z': 0.0,
      'size': 160.0,
      'color': const Color(0xFF0F121C),
      'type': 'block',
      'glow': 0.1,
    });

    // 2. Небостъргачи около площада
    final buildings = [
      {'n': 'Skyscraper Alpha', 'x': -85.0, 'y': -20.0, 'z': -75.0, 's': 45.0, 'c': const Color(0xFF00E5FF)},
      {'n': 'Skyscraper Beta', 'x': 85.0, 'y': -40.0, 'z': -75.0, 's': 55.0, 'c': const Color(0xFFD500F9)},
      {'n': 'Neon Tower Gamma', 'x': -80.0, 'y': 5.0, 'z': 65.0, 's': 40.0, 'c': const Color(0xFF00E676)},
      {'n': 'Sky Platform Delta', 'x': 80.0, 'y': 15.0, 'z': 65.0, 's': 38.0, 'c': const Color(0xFFFFD600)},
      {'n': 'Megacorp HQ Center', 'x': 0.0, 'y': -55.0, 'z': -95.0, 's': 60.0, 'c': const Color(0xFFFF007F)},
    ];

    for (var b in buildings) {
      _live3DNodes.add({
        'id': 'b_${_live3DNodes.length}',
        'name': 'MeshInstance3D (${b['n']})',
        'x': b['x'],
        'y': b['y'],
        'z': b['z'],
        'size': b['s'],
        'color': b['c'],
        'type': 'block',
        'glow': 0.6,
      });
    }

    // 3. Звездни монети по покривите и цел
    _live3DNodes.add({
      'id': 'c_roof_1',
      'name': 'Area3D (Rooftop Star Coin 1)',
      'x': -85.0,
      'y': -50.0,
      'z': -75.0,
      'size': 18.0,
      'color': const Color(0xFFFFD600),
      'type': 'coin',
      'glow': 1.0,
    });

    _live3DNodes.add({
      'id': 'c_roof_2',
      'name': 'Area3D (Rooftop Star Coin 2)',
      'x': 85.0,
      'y': -75.0,
      'z': -75.0,
      'size': 18.0,
      'color': const Color(0xFFFFD600),
      'type': 'coin',
      'glow': 1.0,
    });

    _live3DNodes.add({
      'id': 'goal_helipad',
      'name': 'Area3D (Helipad Win Portal)',
      'x': 0.0,
      'y': -90.0,
      'z': -95.0,
      'size': 24.0,
      'color': const Color(0xFF00E5FF),
      'type': 'portal',
      'glow': 1.0,
    });

    notifyListeners();

    return CommandExecutionResult(
      isSuccess: true,
      message: '🏙️ Успешно построен Cyberpunk град: 5 небостъргача, монети по покривите и хеликоптерна площадка!',
      nodesAffected: _live3DNodes.length,
      actionType: 'BUILD_CITY',
    );
  }

  // =========================================================================
  // 🌋 ПРОЦЕДУРЕН СТРОИТЕЛ НА ВУЛКАНИЧЕН СВЯТ
  // =========================================================================

  CommandExecutionResult buildVolcanoWorld() {
    _live3DNodes.clear();

    _live3DNodes.add({
      'id': 'p_spawn',
      'name': 'CharacterBody3D (Player)',
      'x': 0.0,
      'y': -25.0,
      'z': 0.0,
      'size': 32.0,
      'color': const Color(0xFFFF007F),
      'type': 'player',
      'glow': 0.8,
    });

    _live3DNodes.add({
      'id': 'lava_sea',
      'name': 'Area3D (Lava Ocean Hazard)',
      'x': 0.0,
      'y': 60.0,
      'z': 0.0,
      'size': 120.0,
      'color': const Color(0xFFFF3D00),
      'type': 'lava',
      'glow': 1.0,
    });

    for (int i = 1; i <= 5; i++) {
      double angle = i * 1.2;
      _live3DNodes.add({
        'id': 'lava_step_$i',
        'name': 'MeshInstance3D (Volcano Platform $i)',
        'x': math.cos(angle) * 70.0,
        'y': 40.0 - (i * 18.0),
        'z': math.sin(angle) * 70.0,
        'size': 28.0,
        'color': (i % 2 == 0) ? const Color(0xFF00E5FF) : const Color(0xFF00E676),
        'type': 'block',
        'glow': 0.6,
      });
    }

    _live3DNodes.add({
      'id': 'volcano_goal',
      'name': 'Area3D (Volcano Peak Goal)',
      'x': 0.0,
      'y': -70.0,
      'z': 0.0,
      'size': 24.0,
      'color': const Color(0xFFD500F9),
      'type': 'portal',
      'glow': 1.0,
    });

    notifyListeners();

    return CommandExecutionResult(
      isSuccess: true,
      message: '🌋 Построен 3D Вулканичен свят: спираловидни платформи, лава океан и финал на върха!',
      nodesAffected: _live3DNodes.length,
      actionType: 'BUILD_VOLCANO',
    );
  }
}
