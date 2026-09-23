import 'dart:convert';
import 'package:flutter/material.dart';

enum LevelDimension { twoD, threeD }

class EntityNodeModel {
  final String id;
  final String name;
  final String type; // 'player', 'grass', 'platform', 'coin', 'enemy', 'lava', 'spikes', 'portal'
  double x;
  double y;
  double z;
  double size;
  Color color;
  double glow;
  bool isSolid;

  // Геймплей свойства
  int hp;
  double speed;
  double jumpForce;
  int points;
  int damage;
  int patrolRadius;
  bool collected;

  EntityNodeModel({
    required this.id,
    required this.name,
    required this.type,
    this.x = 0.0,
    this.y = 0.0,
    this.z = 0.0,
    this.size = 32.0,
    this.color = Colors.white,
    this.glow = 0.0,
    this.isSolid = false,
    this.hp = 3,
    this.speed = 4.5,
    this.jumpForce = 12.5,
    this.points = 100,
    this.damage = 1,
    this.patrolRadius = 3,
    this.collected = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'x': x,
      'y': y,
      'z': z,
      'size': size,
      'color': color.toARGB32(),
      'glow': glow,
      'isSolid': isSolid,
      'hp': hp,
      'speed': speed,
      'jumpForce': jumpForce,
      'points': points,
      'damage': damage,
      'patrolRadius': patrolRadius,
      'collected': collected,
    };
  }

  factory EntityNodeModel.fromMap(Map<String, dynamic> map) {
    return EntityNodeModel(
      id: map['id']?.toString() ?? 'node_${DateTime.now().millisecondsSinceEpoch}',
      name: map['name']?.toString() ?? 'Node',
      type: map['type']?.toString() ?? 'grass',
      x: (map['x'] as num?)?.toDouble() ?? 0.0,
      y: (map['y'] as num?)?.toDouble() ?? 0.0,
      z: (map['z'] as num?)?.toDouble() ?? 0.0,
      size: (map['size'] as num?)?.toDouble() ?? 32.0,
      color: map['color'] != null ? Color(map['color'] as int) : Colors.white,
      glow: (map['glow'] as num?)?.toDouble() ?? 0.0,
      isSolid: map['isSolid'] as bool? ?? false,
      hp: (map['hp'] as num?)?.toInt() ?? 3,
      speed: (map['speed'] as num?)?.toDouble() ?? 4.5,
      jumpForce: (map['jumpForce'] as num?)?.toDouble() ?? 12.5,
      points: (map['points'] as num?)?.toInt() ?? 100,
      damage: (map['damage'] as num?)?.toInt() ?? 1,
      patrolRadius: (map['patrolRadius'] as num?)?.toInt() ?? 3,
      collected: map['collected'] as bool? ?? false,
    );
  }
}

class LevelModel {
  final String id;
  final String title;
  final String creator;
  final LevelDimension dimension;
  final double gravity;
  final String musicTrack;
  final int version;
  final List<EntityNodeModel> nodes;

  LevelModel({
    required this.id,
    required this.title,
    required this.creator,
    required this.dimension,
    this.gravity = 9.81,
    this.musicTrack = 'Cyberpunk OST',
    this.version = 1,
    required this.nodes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'creator': creator,
      'dimension': dimension == LevelDimension.twoD ? '2D' : '3D',
      'gravity': gravity,
      'musicTrack': musicTrack,
      'version': version,
      'nodes': nodes.map((n) => n.toMap()).toList(),
    };
  }

  String toJson() => jsonEncode(toMap());

  factory LevelModel.fromMap(Map<String, dynamic> map) {
    var rawNodes = map['nodes'] as List<dynamic>? ?? [];
    List<EntityNodeModel> parsedNodes = rawNodes.map((n) => EntityNodeModel.fromMap(n as Map<String, dynamic>)).toList();

    return LevelModel(
      id: map['id']?.toString() ?? 'lvl_${DateTime.now().millisecondsSinceEpoch}',
      title: map['title']?.toString() ?? 'Untitled Game',
      creator: map['creator']?.toString() ?? '@cyber_creator',
      dimension: (map['dimension']?.toString() == '3D') ? LevelDimension.threeD : LevelDimension.twoD,
      gravity: (map['gravity'] as num?)?.toDouble() ?? 9.81,
      musicTrack: map['musicTrack']?.toString() ?? 'Cyberpunk OST',
      version: (map['version'] as num?)?.toInt() ?? 1,
      nodes: parsedNodes,
    );
  }

  factory LevelModel.fromJson(String source) => LevelModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  // Готови шаблони (Presets)
  static LevelModel default2DLevel() {
    return LevelModel(
      id: 'default_2d',
      title: 'Neon Platformer 2D',
      creator: '@TipTopDev',
      dimension: LevelDimension.twoD,
      gravity: 9.81,
      nodes: [
        EntityNodeModel(id: 'p1', name: 'Player Spawn', type: 'player', x: 1, y: 2, hp: 3),
        EntityNodeModel(id: 'g0', name: 'Ground 0', type: 'grass', x: 0, y: 5, isSolid: true, color: const Color(0xFF00E676)),
        EntityNodeModel(id: 'g1', name: 'Ground 1', type: 'grass', x: 1, y: 5, isSolid: true, color: const Color(0xFF00E676)),
        EntityNodeModel(id: 'g2', name: 'Ground 2', type: 'grass', x: 2, y: 5, isSolid: true, color: const Color(0xFF00E676)),
        EntityNodeModel(id: 'c1', name: 'Coin', type: 'coin', x: 2, y: 3, points: 100, color: const Color(0xFFFFD600)),
        EntityNodeModel(id: 'e1', name: 'Enemy', type: 'enemy', x: 4, y: 4, speed: 2.0, color: const Color(0xFFFF1744)),
        EntityNodeModel(id: 'win', name: 'Goal', type: 'portal', x: 7, y: 4, color: const Color(0xFFD500F9)),
      ],
    );
  }

  static LevelModel default3DLevel() {
    return LevelModel(
      id: 'default_3d',
      title: 'Cyber Volcano 3D',
      creator: '@TipTopDev',
      dimension: LevelDimension.threeD,
      gravity: -9.81,
      nodes: [
        EntityNodeModel(id: 'p3d', name: 'Player 3D', type: 'player', x: 0, y: -25, z: 0, size: 32, color: const Color(0xFFFF007F), glow: 0.8),
        EntityNodeModel(id: 'lava', name: 'Lava Lake', type: 'lava', x: 0, y: 60, z: 0, size: 100, color: const Color(0xFFFF3D00), glow: 1.0),
        EntityNodeModel(id: 'b1', name: 'Neon Block Alpha', type: 'block', x: -65, y: 15, z: -30, size: 32, color: const Color(0xFF00E5FF), glow: 0.4),
        EntityNodeModel(id: 'b2', name: 'Neon Block Beta', type: 'block', x: 65, y: -15, z: 30, size: 32, color: const Color(0xFF00E676), glow: 0.4),
      ],
    );
  }
}
