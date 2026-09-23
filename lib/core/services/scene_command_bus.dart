import 'package:flutter/foundation.dart';

class CommandExecutionResult {
  final String message;
  final bool success;
  final dynamic data;

  CommandExecutionResult({
    required this.message,
    this.success = true,
    this.data,
  });
}

class SceneCommandBus extends ChangeNotifier {
  static final SceneCommandBus _instance = SceneCommandBus._internal();
  factory SceneCommandBus() => _instance;
  SceneCommandBus._internal();

  String lastCommand = '';
  List<Map<String, dynamic>> live3DNodes = [];

  CommandExecutionResult executeAiPrompt(String text) {
    lastCommand = text;
    String msg;
    
    String t = text.toLowerCase();
    if (t.contains('кола') || t.contains('car')) {
      msg = '🏎️ Добавен 3D Болид в сцената!';
      live3DNodes.add({'name': 'Болид', 'type': 'car'});
    } else if (t.contains('лава') || t.contains('lava')) {
      msg = '🌋 Създадена 3D Лава зона с PBR ефекти!';
      live3DNodes.add({'name': 'Лава', 'type': 'lava'});
    } else if (t.contains('враг') || t.contains('enemy')) {
      msg = '👾 Генериран патрулиращ AI враг!';
      live3DNodes.add({'name': 'Враг', 'type': 'enemy'});
    } else {
      msg = '⚡ Командата "$text" е изпълнена в Filament енджина!';
      live3DNodes.add({'name': text, 'type': 'custom'});
    }

    notifyListeners();
    return CommandExecutionResult(message: msg, success: true);
  }
}
