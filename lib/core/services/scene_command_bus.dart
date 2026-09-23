import 'package:flutter/foundation.dart';

class SceneCommandBus extends ChangeNotifier {
  static final SceneCommandBus _instance = SceneCommandBus._internal();
  factory SceneCommandBus() => _instance;
  SceneCommandBus._internal();

  String lastCommand = '';

  String executeAiPrompt(String text) {
    lastCommand = text;
    notifyListeners();
    
    String t = text.toLowerCase();
    if (t.contains('кола') || t.contains('car')) {
      return '🏎️ Добавен 3D Болид в сцената!';
    } else if (t.contains('лава') || t.contains('lava')) {
      return '🌋 Създадена 3D Лава зона с PBR ефекти!';
    } else if (t.contains('враг') || t.contains('enemy')) {
      return '👾 Генериран патрулиращ AI враг!';
    } else {
      return '⚡ Командата "$text" е изпълнена в Filament енджина!';
    }
  }
}
