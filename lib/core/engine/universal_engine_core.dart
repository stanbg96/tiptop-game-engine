import 'dart:math' as math;
import 'package:flutter/material.dart';

class Vec3 {
  final double x, y, z;
  const Vec3(this.x, this.y, this.z);
  Vec3 operator +(Vec3 o) => Vec3(x + o.x, y + o.y, z + o.z);
  Vec3 operator -(Vec3 o) => Vec3(x - o.x, y - o.y, z - o.z);
  Vec3 operator *(double s) => Vec3(x * s, y * s, z * s);

  Vec3 cross(Vec3 o) => Vec3(
    y * o.z - z * o.y,
    z * o.x - x * o.z,
    x * o.y - y * o.x,
  );

  Vec3 normalized() {
    double l = math.sqrt(x * x + y * y + z * z);
    return l > 0.0001 ? Vec3(x / l, y / l, z / l) : const Vec3(0, 1, 0);
  }
}

// 3D ПОЛИГОН С ДЪЛБОЧИНА И СВЕТЛОСЯНКА
class Poly3D {
  final List<Vec3> v;
  final Color baseColor;
  double depth = 0.0;
  Color litColor = Colors.white;

  Poly3D(this.v, this.baseColor);

  void computeLighting(Vec3 lightDir) {
    if (v.length < 3) return;
    Vec3 e1 = v[1] - v[0];
    Vec3 e2 = v[2] - v[0];
    Vec3 normal = e1.cross(e2).normalized();

    // Пресмятане на ъгъла към слънцето (Directional Lighting)
    double dot = -(normal.x * lightDir.x + normal.y * lightDir.y + normal.z * lightDir.z);
    double intensity = (dot * 0.5 + 0.5).clamp(0.25, 1.0);

    litColor = Color.fromARGB(
      baseColor.alpha,
      (baseColor.red * intensity).toInt(),
      (baseColor.green * intensity).toInt(),
      (baseColor.blue * intensity).toInt(),
    );
  }
}

// 3D МОДЕЛ (СГЛОБЕН ОТ МНОЖЕСТВО ПОЛИГОНИ)
class Model3D {
  final String id;
  final String name;
  Vec3 pos;
  Vec3 scale;
  List<Poly3D> polys = [];
  double hp;
  double maxHp;
  double power;
  String animState; // 'idle', 'punch', 'knockout'
  double animTime = 0.0;

  Model3D({
    required this.id,
    required this.name,
    this.pos = const Vec3(0, 0, 0),
    this.scale = const Vec3(1, 1, 1),
    this.hp = 100,
    this.maxHp = 100,
    this.power = 30,
    this.animState = 'idle',
  });

  static Model3D createDogHouse(Vec3 offset) {
    final m = Model3D(id: 'dog_house_${DateTime.now().millisecondsSinceEpoch}', name: 'Къща за куче', pos: offset);
    double w = 22, h = 20, d = 26;

    // 1. Дървени стени на къщичката (Кафяв куб)
    Color wall = const Color(0xFF8D6E63);
    Color darkWall = const Color(0xFF5D4037);
    Color roof = const Color(0xFFD32F2F); // Червен покрив

    // Основа (Стени)
    m.polys.add(Poly3D([Vec3(-w, 0, -d), Vec3(w, 0, -d), Vec3(w, h, -d), Vec3(-w, h, -d)], wall)); // Задна
    m.polys.add(Poly3D([Vec3(-w, 0, -d), Vec3(-w, 0, d), Vec3(-w, h, d), Vec3(-w, h, -d)], darkWall)); // Лява
    m.polys.add(Poly3D([Vec3(w, 0, -d), Vec3(w, h, -d), Vec3(w, h, d), Vec3(w, 0, d)], darkWall)); // Дясна

    // Предна стена с вход за кучето
    m.polys.add(Poly3D([Vec3(-w, 0, d), Vec3(-w * 0.3, 0, d), Vec3(-w * 0.3, h, d), Vec3(-w, h, d)], wall));
    m.polys.add(Poly3D([Vec3(w * 0.3, 0, d), Vec3(w, 0, d), Vec3(w, h, d), Vec3(w * 0.3, h, d)], wall));
    m.polys.add(Poly3D([Vec3(-w, h * 0.6, d), Vec3(w, h * 0.6, d), Vec3(w, h, d), Vec3(-w, h, d)], wall));
    // Тъмен вход (Врата)
    m.polys.add(Poly3D([Vec3(-w * 0.3, 0, d), Vec3(w * 0.3, 0, d), Vec3(w * 0.3, h * 0.6, d), Vec3(-w * 0.3, h * 0.6, d)], const Color(0xFF1B1B1B)));

    // 2. Двускатен 3D Покрив
    double roofPeak = h + 15;
    m.polys.add(Poly3D([Vec3(-w, h, -d), Vec3(0, roofPeak, -d), Vec3(w, h, -d)], darkWall)); // Заден триъгълник
    m.polys.add(Poly3D([Vec3(-w, h, d), Vec3(w, h, d), Vec3(0, roofPeak, d)], wall)); // Преден триъгълник
    m.polys.add(Poly3D([Vec3(-w - 2, h, -d), Vec3(-w - 2, h, d), Vec3(0, roofPeak, d), Vec3(0, roofPeak, -d)], roof)); // Ляв скат
    m.polys.add(Poly3D([Vec3(w + 2, h, -d), Vec3(0, roofPeak, -d), Vec3(0, roofPeak, d), Vec3(w + 2, h, d)], roof)); // Десен скат

    return m;
  }

  static Model3D createHumanoid(String id, String name, Vec3 offset, Color suitColor) {
    final m = Model3D(id: id, name: name, pos: offset, power: id == 'hero' ? 35 : 25);
    m.rebuildHumanoid(0.0);
    return m;
  }

  void rebuildHumanoid(double punchAnim) {
    polys.clear();
    Color skin = const Color(0xFFFFCC80);
    Color pants = const Color(0xFF1E293B);
    Color suit = name.contains('Стилиян') ? const Color(0xFF00E5FF) : const Color(0xFFFF007F);

    double punchExtend = punchAnim * 24.0;

    // Глава (3D куб с очи)
    _addBox(polys, const Vec3(-6, 26, -6), const Vec3(6, 38, 6), skin);
    // Очи
    _addBox(polys, const Vec3(-4, 32, 6.2), const Vec3(-1, 35, 6.2), Colors.black);
    _addBox(polys, const Vec3(1, 32, 6.2), const Vec3(4, 35, 6.2), Colors.black);

    // Торс (Тяло с броня)
    _addBox(polys, const Vec3(-10, 10, -5), const Vec3(10, 26, 5), suit);

    // Лява ръка
    _addBox(polys, const Vec3(-15, 10, -3), const Vec3(-10, 24, 3), suit);
    // Дясна ръка (Изпъва се напред при удар!)
    _addBox(polys, Vec3(10, 10, -3 + punchExtend), Vec3(15, 24, 3 + punchExtend), suit);

    // Крака
    _addBox(polys, const Vec3(-8, 0, -4), const Vec3(-2, 10, 4), pants);
    _addBox(polys, const Vec3(2, 0, -4), const Vec3(8, 10, 4), pants);
  }

  static void _addBox(List<Poly3D> target, Vec3 min, Vec3 max, Color c) {
    target.add(Poly3D([Vec3(min.x, min.y, max.z), Vec3(max.x, min.y, max.z), Vec3(max.x, max.y, max.z), Vec3(min.x, max.y, max.z)], c)); // Front
    target.add(Poly3D([Vec3(min.x, min.y, min.z), Vec3(min.x, max.y, min.z), Vec3(max.x, max.y, min.z), Vec3(max.x, min.y, min.z)], c)); // Back
    target.add(Poly3D([Vec3(min.x, max.y, min.z), Vec3(min.x, max.y, max.z), Vec3(max.x, max.y, max.z), Vec3(max.x, max.y, min.z)], c)); // Top
    target.add(Poly3D([Vec3(min.x, min.y, min.z), Vec3(max.x, min.y, min.z), Vec3(max.x, min.y, max.z), Vec3(min.x, min.y, max.z)], c)); // Bottom
    target.add(Poly3D([Vec3(min.x, min.y, min.z), Vec3(min.x, min.y, max.z), Vec3(min.x, max.y, max.z), Vec3(min.x, max.y, min.z)], c)); // Left
    target.add(Poly3D([Vec3(max.x, min.y, min.z), Vec3(max.x, max.y, min.z), Vec3(max.x, max.y, max.z), Vec3(max.x, min.y, max.z)], c)); // Right
  }
}

// 2D ЕЛЕМЕНТИ (ИСТИНСКА ТРЕВА, ПЪТЕКА, ГЕРОИ С ОЧИ)
class Tile2D {
  final Offset pos;
  final String type; // 'grass', 'path', 'player', 'enemy', 'coin'
  Tile2D(this.pos, this.type);
}

// ГЛАВНО СЪВМЕСТИМО ЯДРО
class UniversalEngineCore {
  final List<Model3D> models3D = [];
  final List<Tile2D> tiles2D = [];

  double timeOfDay = 14.0;
  String weather = 'clear';
  double cameraShake = 0.0;
  String executionLog = 'Енджинът е зареден. Въведи команда.';

  UniversalEngineCore() {
    initRealWorld();
  }

  void initRealWorld() {
    // 1. Инициализиране на 3D свят: Стилиян, Георги и Къщичка
    models3D.clear();
    models3D.add(Model3D.createHumanoid('hero', 'Стилиян 3D', const Vec3(-30, 0, 0), const Color(0xFF00E5FF)));
    models3D.add(Model3D.createHumanoid('rival', 'Георги 3D', const Vec3(30, 0, 0), const Color(0xFFFF007F)));
    models3D.add(Model3D.createDogHouse(const Vec3(0, 0, 80)));

    // 2. Инициализиране на 2D свят: Зелена трева с каменна пътека
    tiles2D.clear();
    for (int col = 0; col < 10; col++) {
      tiles2D.add(Tile2D(Offset(col.toDouble(), 4), col == 4 || col == 5 ? 'path' : 'grass'));
    }
    tiles2D.add(Tile2D(const Offset(2, 3), 'player'));
    tiles2D.add(Tile2D(const Offset(7, 3), 'enemy'));
  }

  void update(double dt) {
    if (cameraShake > 0) cameraShake = (cameraShake - dt * 25).clamp(0.0, 30.0);
    for (var m in models3D) {
      if (m.animState == 'punch') {
        m.animTime += dt * 8;
        double punch = math.sin(m.animTime).clamp(0.0, 1.0);
        m.rebuildHumanoid(punch);
        if (m.animTime > math.pi) {
          m.animState = 'idle';
          m.animTime = 0.0;
          m.rebuildHumanoid(0.0);
        }
      }
    }
  }

  // За съвместимост със стария код
  List<dynamic> get entities2D => tiles2D;
  List<dynamic> get entities3D => models3D;
}
