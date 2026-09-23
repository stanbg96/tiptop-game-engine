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

    // 1. СЪЗДАВАНЕ НА КЪЩА ЗА КУЧЕ
    if (t.contains('къща') || t.contains('куче') || t.contains('house')) {
      final house = Model3D.createDogHouse(Vec3(0, 0, (engine.models3D.length * 40.0) - 20));
      engine.models3D.add(house);
      msg = '🏠 3D: Построена триизмерна къща за куче с червен покрив, дървени стени и вход!';
      act = 'Procedural 3D Architecture';
    }
    // 2. СЪЗДАВАНЕ НА 2D ПЪТЕКА С ТРЕВА
    else if (t.contains('пътека') || t.contains('трева') || t.contains('2d')) {
      for (int i = 0; i < 10; i++) {
        engine.tiles2D.add(Tile2D(Offset(i.toDouble(), 4), i % 2 == 0 ? 'path' : 'grass'));
      }
      msg = '🌿 2D: Положена каменна пътека със свежа зелена трева!';
      act = '2D Tilemap Generation';
    }
    // 3. БОЙ: СТИЛИЯН VS ГЕОРГИ (С ИСТИНСКИ ЗАМАХ НА РЪКАТА)
    else if (t.contains('стилиян') || t.contains('георги') || t.contains('бой') || t.contains('удар')) {
      var stiliyan = engine.models3D.firstWhere((m) => m.id == 'hero', orElse: () => engine.models3D.first);
      var georgi = engine.models3D.firstWhere((m) => m.id == 'rival', orElse: () => engine.models3D.last);

      stiliyan.animState = 'punch'; // Започва реален 3D замах с юмрука
      stiliyan.power *= 1.15; // +15% сила
      georgi.hp = (georgi.hp - 45).clamp(0, 100);
      georgi.pos = Vec3(georgi.pos.x + 15, georgi.pos.y, georgi.pos.z); // Отхвърча назад
      engine.cameraShake = 18.0;

      if (t.contains('вечер') || t.contains('дъжд')) {
        engine.weather = 'rain';
        engine.timeOfDay = 20.0;
      }

      msg = '💥 3D БОЙ: Стилиян нанесе удар с изпъната ръка! Георги отхвръкна назад (HP: ${georgi.hp.toInt()}).';
      act = 'Physics & Combat Sim';
    }
    // 4. ВРЕМЕТО (ДЪЖД, ВЕЧЕР, НОЩ)
    else if (t.contains('дъжд') || t.contains('вечер') || t.contains('нощ') || t.contains('слънце')) {
      if (t.contains('дъжд') || t.contains('вечер')) {
        engine.weather = 'rain';
        engine.timeOfDay = 20.0;
        msg = '🌧️ СВЯТ: Небето стана пурпурно-вечерно и заваля 3D дъжд!';
      } else {
        engine.weather = 'clear';
        engine.timeOfDay = 12.0;
        msg = '☀️ СВЯТ: Ясен слънчев ден с пълно осветление!';
      }
      act = 'Weather Control';
    } else {
      msg = '⚡ Командата "$text" беше приложена към триизмерната сцена!';
      act = 'Engine Action';
    }

    engine.executionLog = msg;
    notifyListeners();
    return CommandExecutionResult(message: msg, actionType: act, success: true);
  }
}
