import 'dart:math' as math;
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

  // Чиста сцена само с 3D играч (БЕЗ гигантски черни блокове пред камерата!)
  final List<Map<String, dynamic>> _live3DNodes = [
    {
      'id': 'player_spawn',
      'name': 'CharacterBody3D (Player)',
      'x': 0.0,
      'y': -25.0,
      'z': 0.0,
      'size': 28.0,
      'color': const Color(0xFFFF007F),
      'type': 'player',
      'glow': 0.8,
    },
  ];

  List<Map<String, dynamic>> get live3DNodes => _live3DNodes;

  // =========================================================================
  // ⚡ ИНТЕЛИГЕНТЕН ПАРСЕР НА БЪЛГАРСКИ КОМАНДИ (С ТОЛЕРАНТНОСТ КЪМ ПРАВОПИС)
  // =========================================================================

  CommandExecutionResult executeAiPrompt(String prompt) {
    String p = prompt.toLowerCase().trim()
        .replaceAll('създаи', 'създай')
        .replaceAll('построи', 'построй');

    // 1. ИЗЧИСТВАНЕ НА СЦЕНАТА
    if (p.contains('изчисти') || p.contains('изтрий') || p.contains('изтрии') || 
        p.contains('махни') || p.contains('clear') || p.contains('reset')) {
      _live3DNodes.clear();
      _live3DNodes.add({
        'id': 'player_spawn',
        'name': 'CharacterBody3D (Player)',
        'x': 0.0,
        'y': -25.0,
        'z': 0.0,
        'size': 28.0,
        'color': const Color(0xFFFF007F),
        'type': 'player',
        'glow': 0.8,
      });
      notifyListeners();
      return CommandExecutionResult(
        isSuccess: true,
        message: '🧹 Сцената е напълно изчистена! Остана само спаун точката на героя.',
        nodesAffected: 1,
        actionType: 'CLEAR_SCENE',
      );
    }

    // 2. СЪЗДАВАНЕ НА КЪЩА (С ПОКРИВ, СТЕНИ И ВРАТА)
    if (p.contains('къща') || p.contains('house') || p.contains('хижа') || p.contains('дом')) {
      final id = 'house_${DateTime.now().millisecondsSinceEpoch}';
      _live3DNodes.add({
        'id': id,
        'name': 'MeshInstance3D (3D House)',
        'x': 0.0,
        'y': 15.0,
        'z': 0.0,
        'size': 42.0,
        'color': const Color(0xFFFF9100),
        'type': 'house',
        'glow': 0.4,
      });
      notifyListeners();
      return CommandExecutionResult(
        isSuccess: true,
        message: '🏡 Построена 3D Къща с покрив, врата и осветени прозорци в центъра (0, 0)!',
        nodesAffected: 1,
        actionType: 'BUILD_HOUSE',
      );
    }

    // 3. СЪЗДАВАНЕ НА КОЛА / БОЛИД
    if (p.contains('кола') || p.contains('болид') || p.contains('car') || p.contains('возило')) {
      final id = 'car_${DateTime.now().millisecondsSinceEpoch}';
      _live3DNodes.add({
        'id': id,
        'name': 'CharacterBody3D (Cyber Car)',
        'x': 25.0,
        'y': 38.0,
        'z': 0.0,
        'size': 36.0,
        'color': const Color(0xFF00E5FF),
        'type': 'car',
        'glow': 0.7,
      });
      notifyListeners();
      return CommandExecutionResult(
        isSuccess: true,
        message: '🏎️ Създаден 3D Неонов Болид с кабина и колела!',
        nodesAffected: 1,
        actionType: 'BUILD_CAR',
      );
    }

    // 4. СЪЗДАВАНЕ НА ДЪРВО / ГОРА
    if (p.contains('дърво') || p.contains('гора') || p.contains('tree') || p.contains('природа')) {
      final id = 'tree_${DateTime.now().millisecondsSinceEpoch}';
      _live3DNodes.add({
        'id': id,
        'name': 'MeshInstance3D (3D Tree)',
        'x': -30.0,
        'y': 15.0,
        'z': 20.0,
        'size': 38.0,
        'color': const Color(0xFF00E676),
        'type': 'tree',
        'glow': 0.3,
      });
      notifyListeners();
      return CommandExecutionResult(
        isSuccess: true,
        message: '🌲 Засадено 3D Дърво със ствол и зелена корона!',
        nodesAffected: 1,
        actionType: 'BUILD_TREE',
      );
    }

    // 5. ПОСТРОЙ ЦЯЛ CYBERPUNK ГРАД
    if (p.contains('град') || p.contains('мегаполис') || p.contains('city') || p.contains('небостъргач')) {
      return buildCyberCity(prompt);
    }

    // 6. ПОСТРОЙ ЛАВА ПАРКУР
    if (p.contains('вулкан') || p.contains('паркур') || p.contains('лава')) {
      return buildVolcanoWorld();
    }

    // 7. МОНЕТА
    if (p.contains('монета') || p.contains('злато') || p.contains('coin')) {
      final id = 'coin_${DateTime.now().millisecondsSinceEpoch}';
      _live3DNodes.add({
        'id': id,
        'name': 'Area3D (Star Coin)',
        'x': 0.0,
        'y': -10.0,
        'z': 0.0,
        'size': 18.0,
        'color': const Color(0xFFFFD600),
        'type': 'coin',
        'glow': 0.9,
      });
      notifyListeners();
      return CommandExecutionResult(
        isSuccess: true,
        message: '🪙 Добавена светеща златна монета във въздуха!',
        nodesAffected: 1,
        actionType: 'ADD_COIN',
      );
    }

    // 8. ПРЕМЕСТВАНЕ
    if (p.contains('премести') || p.contains('мести') || p.contains('move')) {
      if (_live3DNodes.isNotEmpty) {
        _live3DNodes.last['x'] = (_live3DNodes.last['x'] as num).toDouble() + 30.0;
        notifyListeners();
        return CommandExecutionResult(
          isSuccess: true,
          message: '🎯 Обектът "${_live3DNodes.last['name']}" беше преместен с +30 по X.',
          nodesAffected: 1,
          actionType: 'MOVE_NODE',
        );
      }
    }

    // 9. ДЕФОЛТ: ДОБАВЯНЕ НА 3D НЕОНОВА ПЛАТФОРМА
    final id = 'platform_${DateTime.now().millisecondsSinceEpoch}';
    _live3DNodes.add({
      'id': id,
      'name': 'MeshInstance3D ($prompt)',
      'x': (math.Random().nextInt(60) - 30).toDouble(),
      'y': 25.0,
      'z': (math.Random().nextInt(60) - 30).toDouble(),
      'size': 32.0,
      'color': const Color(0xFF00E5FF),
      'type': 'block',
      'glow': 0.5,
    });
    notifyListeners();

    return CommandExecutionResult(
      isSuccess: true,
      message: '✅ Добавен 3D неонов обект за команда: "$prompt".',
      nodesAffected: 1,
      actionType: 'CREATE_NODE',
    );
  }

  // =========================================================================
  // 🏙️ ПОСТРОЯВАНЕ НА ЦЯЛ CYBERPUNK ГРАД
  // =========================================================================

  CommandExecutionResult buildCyberCity(String query) {
    _live3DNodes.clear();

    _live3DNodes.add({
      'id': 'p_spawn',
      'name': 'CharacterBody3D (Player)',
      'x': 0.0,
      'y': -25.0,
      'z': 0.0,
      'size': 28.0,
      'color': const Color(0xFFFF007F),
      'type': 'player',
      'glow': 0.8,
    });

    final buildings = [
      {'n': 'Skyscraper Alpha', 'x': -70.0, 'y': -15.0, 'z': -60.0, 's': 42.0, 'c': const Color(0xFF00E5FF)},
      {'n': 'Skyscraper Beta', 'x': 70.0, 'y': -30.0, 'z': -60.0, 's': 48.0, 'c': const Color(0xFFD500F9)},
      {'n': 'Neon Tower Gamma', 'x': -65.0, 'y': 5.0, 'z': 55.0, 's': 38.0, 'c': const Color(0xFF00E676)},
      {'n': 'Sky Platform Delta', 'x': 65.0, 'y': 10.0, 'z': 55.0, 's': 36.0, 'c': const Color(0xFFFFD600)},
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
        'type': 'skyscraper',
        'glow': 0.6,
      });
    }

    _live3DNodes.add({
      'id': 'cyber_car',
      'name': 'CharacterBody3D (Patrol Car)',
      'x': 0.0,
      'y': 38.0,
      'z': 30.0,
      'size': 32.0,
      'color': const Color(0xFF00E5FF),
      'type': 'car',
      'glow': 0.8,
    });

    _live3DNodes.add({
      'id': 'c_roof_1',
      'name': 'Area3D (Rooftop Coin)',
      'x': -70.0,
      'y': -45.0,
      'z': -60.0,
      'size': 18.0,
      'color': const Color(0xFFFFD600),
      'type': 'coin',
      'glow': 1.0,
    });

    notifyListeners();

    return CommandExecutionResult(
      isSuccess: true,
      message: '🏙️ Построен Cyberpunk град: 4 небостъргача с прозорци, патрулна кола и покривна монета!',
      nodesAffected: _live3DNodes.length,
      actionType: 'BUILD_CITY',
    );
  }

  // =========================================================================
  // 🌋 ПОСТРОЯВАНЕ НА ВУЛКАНИЧЕН СВЯТ
  // =========================================================================

  CommandExecutionResult buildVolcanoWorld() {
    _live3DNodes.clear();

    _live3DNodes.add({
      'id': 'p_spawn',
      'name': 'CharacterBody3D (Player)',
      'x': 0.0,
      'y': -25.0,
      'z': 0.0,
      'size': 28.0,
      'color': const Color(0xFFFF007F),
      'type': 'player',
      'glow': 0.8,
    });

    _live3DNodes.add({
      'id': 'lava_lake',
      'name': 'Area3D (Lava Ocean Hazard)',
      'x': 0.0,
      'y': 48.0,
      'z': 0.0,
      'size': 90.0,
      'color': const Color(0xFFFF3D00),
      'type': 'lava',
      'glow': 1.0,
    });

    for (int i = 1; i <= 4; i++) {
      double angle = i * 1.3;
      _live3DNodes.add({
        'id': 'lava_step_$i',
        'name': 'MeshInstance3D (Volcano Step $i)',
        'x': math.cos(angle) * 60.0,
        'y': 35.0 - (i * 16.0),
        'z': math.sin(angle) * 60.0,
        'size': 26.0,
        'color': (i % 2 == 0) ? const Color(0xFF00E5FF) : const Color(0xFF00E676),
        'type': 'block',
        'glow': 0.6,
      });
    }

    _live3DNodes.add({
      'id': 'coin_volcano',
      'name': 'Area3D (Volcano Star Coin)',
      'x': 0.0,
      'y': -45.0,
      'z': 0.0,
      'size': 20.0,
      'color': const Color(0xFFFFD600),
      'type': 'coin',
      'glow': 1.0,
    });

    notifyListeners();

    return CommandExecutionResult(
      isSuccess: true,
      message: '🌋 Построен 3D Лава свят: врящ лава океан, 4 спирални платформи и звездна монета!',
      nodesAffected: _live3DNodes.length,
      actionType: 'BUILD_VOLCANO',
    );
  }
}
