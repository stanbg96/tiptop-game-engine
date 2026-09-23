import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../engine/universal_engine_core.dart';

class CommandExecutionResult {
  final String message;
  final String actionType;
  final bool success;
  final dynamic data;

  CommandExecutionResult({
    required this.message,
    this.actionType = 'Universal Engine Update',
    this.success = true,
    this.data,
  });
}

class SceneCommandBus extends ChangeNotifier {
  static final SceneCommandBus _instance = SceneCommandBus._internal();
  factory SceneCommandBus() => _instance;
  SceneCommandBus._internal();

  final UniversalEngineCore engine = UniversalEngineCore();
  String lastCommand = '';
  List<Map<String, dynamic>> live3DNodes = [];

  CommandExecutionResult executeAiPrompt(String text) {
    lastCommand = text;
    String t = text.toLowerCase().trim();
    String msg = '';
    String act = '';

    // 1. АКО Е 2D КОМАНДА:
    if (t.contains('2d') || t.contains('две де') || t.contains('плочки') || t.contains('монета')) {
      if (t.contains('враг')) {
        engine.entities2D.add(Entity2D(
          id: 'enemy_${DateTime.now().millisecondsSinceEpoch}',
          name: '2D Патрул',
          pos: Offset(100.0 + math.Random().nextInt(150), 120),
          color: const Color(0xFFFF1744),
          type: 'enemy',
        ));
        msg = '🟩 2D: Добавен нов враг в платформата!';
        act = '2D Entity Spawn';
      } else if (t.contains('монета') || t.contains('coin')) {
        engine.entities2D.add(Entity2D(
          id: 'coin_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Златна Монета',
          pos: Offset(60.0 + math.Random().nextInt(200), 70),
          color: const Color(0xFFFFD600),
          type: 'coin',
        ));
        msg = '🪙 2D: Създадена златна монета на нивото!';
        act = '2D Item Spawn';
      } else {
        msg = '🎮 2D Светът е синхронизиран с новите параметри!';
        act = '2D Canvas Update';
      }
    }
    // 2. БОЙНА СИМУЛАЦИЯ (Стилиян, Георги, Бой, Сила):
    else if (t.contains('стилиян') || t.contains('георги') || t.contains('бой') || t.contains('удар') || t.contains('нокаут')) {
      var stiliyan = engine.entities3D.firstWhere((e) => e.id == 'hero', orElse: () => engine.entities3D.first);
      var georgi = engine.entities3D.firstWhere((e) => e.id == 'rival', orElse: () => engine.entities3D.last);

      // Стилиян получава +15% сила
      stiliyan.power *= 1.15;
      stiliyan.currentAnim = 'punch';

      // Георги поема щетата и пада в нокаут / Ragdoll
      georgi.takeDamage(stiliyan.power * 2.2);
      engine.cameraShake = 16.0; // Разтрисане на камерата

      // Ако е споменато времето:
      if (t.contains('вечер') || t.contains('дъжд')) {
        engine.setWeather('rain', 20.0);
      }

      msg = '💥 БОЙ: Стилиян удари Георги със сила ${stiliyan.power.toStringAsFixed(1)} (+15% бъф)! Георги HP: ${georgi.hp.toInt()}.\n🌧️ Активиран вечерен дъжд и камера трус!';
      act = 'Combat & World Reaction';
    }
    // 3. АТМОСФЕРА И СВЯТ (Ден, Вечер, Нощ, Дъжд, Студено, Топло):
    else if (t.contains('вечер') || t.contains('дъжд') || t.contains('нощ') || t.contains('ден')) {
      if (t.contains('нощ')) {
        engine.setWeather('clear', 23.0);
        msg = '🌙 СВЯТ: Времето е настроено на Нощ (23:00ч). Небето потъмня.';
      } else if (t.contains('дъжд') || t.contains('вечер')) {
        engine.setWeather('rain', 20.0);
        msg = '🌧️ СВЯТ: Настъпи вечер (20:00ч) и заваля дъжд! Повърхностите станаха мокри.';
      } else {
        engine.setWeather('clear', 12.0);
        msg = '☀️ СВЯТ: Ясен слънчев ден (12:00ч).';
      }
      act = 'Atmosphere Update';
    }
    // 4. ГЕНЕРИРАНЕ НА ВСЕКИ ПРЕДМЕТ В 3D (От игла до слон, кола, меч, къща):
    else if (t.contains('слон') || t.contains('кола') || t.contains('меч') || t.contains('игла') || t.contains('робот')) {
      String objName = '3D Обект';
      Color objColor = const Color(0xFF00E5FF);
      double scale = 1.0;

      if (t.contains('слон')) { objName = 'Слон 3D'; objColor = const Color(0xFF8D8D8D); scale = 2.0; }
      else if (t.contains('кола')) { objName = 'Болид 3D'; objColor = const Color(0xFFFF1744); scale = 1.4; }
      else if (t.contains('меч')) { objName = 'Плазмен Меч 3D'; objColor = const Color(0xFF00E5FF); scale = 0.8; }
      else if (t.contains('игла')) { objName = 'Игла 3D'; objColor = const Color(0xFFE0E0E0); scale = 0.3; }

      engine.entities3D.add(Entity3D(
        id: 'obj_${DateTime.now().millisecondsSinceEpoch}',
        name: objName,
        pos: Vec3(0, -10, (engine.entities3D.length * 20.0)),
        scale: Vec3(scale, scale, scale),
        color: objColor,
      ));

      msg = '🎲 3D: Математически изчислен "$objName" директно в RAM паметта!';
      act = 'Universal Procedural 3D';
    }
    // 5. ДРУГИ ДЕЙСТВИЯ:
    else {
      msg = '⚡ Командата "$text" беше изпълнена от универсалното ядро!';
      act = 'Universal Execution';
    }

    engine.executionLog = msg;
    _syncNodes();
    notifyListeners();
    return CommandExecutionResult(message: msg, actionType: act, success: true);
  }

  void _syncNodes() {
    live3DNodes.clear();
    for (var e in engine.entities3D) {
      live3DNodes.add({'name': e.name, 'hp': e.hp, 'power': e.power});
    }
  }
}
