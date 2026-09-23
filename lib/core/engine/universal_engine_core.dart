import 'dart:math' as math;
import 'package:flutter/material.dart';

// --- 3D ВЕКТОР & МАТЕРИАЛ ---
class Vec3 {
  final double x, y, z;
  const Vec3(this.x, this.y, this.z);
  Vec3 operator +(Vec3 o) => Vec3(x + o.x, y + o.y, z + o.z);
  Vec3 operator -(Vec3 o) => Vec3(x - o.x, y - o.y, z - o.z);
  Vec3 operator *(double s) => Vec3(x * s, y * s, z * s);
}

class EngineMaterial {
  final Color color;
  final double metallic;
  final double roughness;
  final bool isEmissive;
  const EngineMaterial({required this.color, this.metallic = 0.2, this.roughness = 0.5, this.isEmissive = false});
}

// --- 2D ЕЛЕМЕНТ (Спрайт, Плочка, Враг) ---
class Entity2D {
  String id;
  String name;
  Offset pos;
  Color color;
  String type;
  double hp;
  double power;

  Entity2D({
    required this.id,
    required this.name,
    required this.pos,
    required this.color,
    required this.type,
    this.hp = 100.0,
    this.power = 25.0,
  });
}

// --- 3D ЕЛЕМЕНТ (Полигони, Скелет, Бойна физика) ---
class Entity3D {
  String id;
  String name;
  Vec3 pos;
  Vec3 scale;
  Color color;
  double hp;
  double maxHp;
  double power;
  String currentAnim;
  bool isRagdoll;
  List<List<Vec3>> customPolygons;

  Entity3D({
    required this.id,
    required this.name,
    this.pos = const Vec3(0, 0, 0),
    this.scale = const Vec3(1, 1, 1),
    required this.color,
    this.hp = 100.0,
    this.maxHp = 100.0,
    this.power = 30.0,
    this.currentAnim = 'idle',
    this.isRagdoll = false,
    List<List<Vec3>>? customPolygons,
  }) : customPolygons = customPolygons ?? [];

  void takeDamage(double dmg) {
    hp = (hp - dmg).clamp(0.0, maxHp);
    if (hp <= 0) {
      isRagdoll = true;
      currentAnim = 'knockout';
    } else {
      currentAnim = 'punch';
    }
  }
}

// --- ГЛАВЕН МЕНИДЖЪР НА СВЕТА (2D, 3D, ВРЕМЕ, ДЪЖД) ---
class UniversalEngineCore {
  final List<Entity2D> entities2D = [];
  final List<Entity3D> entities3D = [];

  double timeOfDay = 14.0;
  String weather = 'clear';
  double temperature = 24.0;
  double cameraShake = 0.0;
  String executionLog = 'Енджинът е в готовност за 2D и 3D команди.';

  UniversalEngineCore() {
    initDefaults();
  }

  void initDefaults() {
    entities2D.clear();
    entities2D.add(Entity2D(id: 'p1', name: '2D Герой', pos: const Offset(40, 120), color: const Color(0xFF00E5FF), type: 'player'));
    entities2D.add(Entity2D(id: 'e1', name: '2D Враг', pos: const Offset(180, 120), color: const Color(0xFFFF1744), type: 'enemy'));

    entities3D.clear();
    entities3D.add(Entity3D(id: 'hero', name: 'Стилиян 3D', pos: const Vec3(-25, 0, 0), color: const Color(0xFF00E5FF), power: 35));
    entities3D.add(Entity3D(id: 'rival', name: 'Георги 3D', pos: const Vec3(25, 0, 0), color: const Color(0xFFFF007F), power: 25));
  }

  void update(double dt) {
    if (cameraShake > 0) {
      cameraShake = (cameraShake - dt * 20).clamp(0.0, 30.0);
    }
  }

  void setWeather(String w, double hour) {
    weather = w;
    timeOfDay = hour;
    if (w == 'rain') temperature = 14.0;
  }
}
