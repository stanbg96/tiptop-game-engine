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

  // Чиста сцена: Героят е позициониран пред сградите, за да не се блъскат!
  final List<Map<String, dynamic>> _live3DNodes = [
    {
      'id': 'player_spawn',
      'name': 'CharacterBody3D (Player)',
      'x': 0.0,
      'y': 25.0,
      'z': 55.0,
      'size': 24.0,
      'color': const Color(0xFFFF007F),
      'type': 'player',
      'glow': 0.8,
    },
  ];

  List<Map<String, dynamic>> get live3DNodes => _live3DNodes;

  CommandExecutionResult executeAiPrompt(String prompt) {
    String p = prompt.toLowerCase().trim()
        .replaceAll('създаи', 'създай')
        .replaceAll('построи', 'построй');

    // 1. ИЗЧИСТВАНЕ
    if (p.contains('изчисти') || p.contains('изтрий') || p.contains('изтрии') || 
        p.contains('махни') || p.contains('clear') || p.contains('reset')) {
      _live3DNodes.clear();
      _live3DNodes.add({
        'id': 'player_spawn',
        'name': 'CharacterBody3D (Player)',
        'x': 0.0,
        'y': 25.0,
        'z': 55.0,
        'size': 24.0,
        'color': const Color(0xFFFF007F),
        'type': 'player',
        'glow': 0.8,
      });
      notifyListeners();
      return CommandExecutionResult(
        isSuccess: true,
        message: '🧹 Сцената е напълно изчистена!',
        nodesAffected: 1,
        actionType: 'CLEAR_SCENE',
      );
    }

    // 2. КЪЩА (С ПОКРИВ, СТЕНИ И ЗАКРЕПЕНА ВРАТА)
    if (p.contains('къща') || p.contains('house') || p.contains('дом')) {
      final id = 'house_${DateTime.now().millisecondsSinceEpoch}';
      _live3DNodes.add({
        'id': id,
        'name': 'MeshInstance3D (3D House)',
        'x': 0.0,
        'y': 15.0,
        'z': 0.0,
        'size': 44.0,
        'color': const Color(0xFFFF9100),
        'type': 'house',
        'glow': 0.4,
      });
      notifyListeners();
      return CommandExecutionResult(
        isSuccess: true,
        message: '🏡 Построена солидна 3D Къща с 4-скатен покрив и закрепена врата!',
        nodesAffected: 1,
        actionType: 'BUILD_HOUSE',
      );
    }

    // 3. КОЛА
    if (p.contains('кола') || p.contains('болид') || p.contains('car')) {
      final id = 'car_${DateTime.now().millisecondsSinceEpoch}';
      _live3DNodes.add({
        'id': id,
        'name': 'CharacterBody3D (Cyber Car)',
        'x': 35.0,
        'y': 36.0,
        'z': 25.0,
        'size': 34.0,
        'color': const Color(0xFF00E5FF),
        'type': 'car',
        'glow': 0.7,
      });
      notifyListeners();
      return CommandExecutionResult(
        isSuccess: true,
        message: '🏎️ Добавен 3D Cyber Car с колела и кабина!',
        nodesAffected: 1,
        actionType: 'BUILD_CAR',
      );
    }

    // 4. ДЪРВО
    if (p.contains('дърво') || p.contains('гора') || p.contains('tree')) {
      final id = 'tree_${DateTime.now().millisecondsSinceEpoch}';
      _live3DNodes.add({
        'id': id,
        'name': 'MeshInstance3D (3D Tree)',
        'x': -35.0,
        'y': 15.0,
        'z': 15.0,
        'size': 38.0,
        'color': const Color(0xFF2E7D32),
        'type': 'tree',
        'glow': 0.3,
      });
      notifyListeners();
      return CommandExecutionResult(
        isSuccess: true,
        message: '🌲 Засадено 3D Дърво с пирамидална корона!',
        nodesAffected: 1,
        actionType: 'BUILD_TREE',
      );
    }

    // 5. ДЕФОЛТ БЛОК
    final id = 'block_${DateTime.now().millisecondsSinceEpoch}';
    _live3DNodes.add({
      'id': id,
      'name': 'MeshInstance3D ($prompt)',
      'x': (math.Random().nextInt(60) - 30).toDouble(),
      'y': 25.0,
      'z': (math.Random().nextInt(60) - 30).toDouble(),
      'size': 30.0,
      'color': const Color(0xFF00E5FF),
      'type': 'block',
      'glow': 0.5,
    });
    notifyListeners();

    return CommandExecutionResult(
      isSuccess: true,
      message: '✅ Добавен 3D PBR обект за: "$prompt".',
      nodesAffected: 1,
      actionType: 'CREATE_NODE',
    );
  }
}
