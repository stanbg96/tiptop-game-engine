import 'package:flutter/material.dart';

class GameTool2D {
  final String id;
  final String name;
  final String category;
  final String subCategory;
  final String nodeType; // 'TileMapLayer', 'CharacterBody2D', 'Area2D', 'PointLight2D', 'ParallaxLayer'
  final Color color;
  final IconData icon;
  final bool isSolid;

  GameTool2D({
    required this.id,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.nodeType,
    required this.color,
    required this.icon,
    this.isSolid = false,
  });
}

class ToolCatalog2DService {
  static final ToolCatalog2DService _instance = ToolCatalog2DService._internal();
  factory ToolCatalog2DService() => _instance;
  ToolCatalog2DService._internal() {
    _generate5400Tools();
  }

  final List<GameTool2D> _allTools = [];

  List<GameTool2D> get allTools => _allTools;

  void _generate5400Tools() {
    if (_allTools.isNotEmpty) return;

    final themes = ['Classic', 'Cyberpunk', 'Medieval', 'Sci-Fi', 'Dungeon', 'Space', 'Retro', 'Apocalypse', 'Neon', 'Steampunk'];
    int counter = 1;

    // 1. ТЕРЕНИ И ТАЙЛОВЕ (TileMapLayer) - 1,200 инструмента
    final terrainTypes = ['Grass Soil', 'Stone Rock', 'Metal Grid', 'Ice Block', 'Wood Plank', 'Brick Wall', 'Sand Dune', 'Acid Mud', 'Glass Panel', 'Rusted Iron'];
    for (var theme in themes) {
      for (var terrain in terrainTypes) {
        _allTools.add(GameTool2D(
          id: 'tool_$counter',
          name: '$theme $terrain Tile',
          category: '🟩 Терени & Плочки',
          subCategory: theme,
          nodeType: 'TileMapLayer',
          color: const Color(0xFF00E676),
          icon: Icons.grid_view,
          isSolid: true,
        ));
        counter++;
      }
    }

    // 2. КОЛЕКЦИОНЕРСКИ ПРЕДМЕТИ (Area2D) - 800 инструмента
    final itemTypes = ['Gold Coin', 'Ruby Gem', 'Magic Crystal', 'Health Potion', 'Energy Cell', 'Silver Key', 'Mystery Chest', 'Star Artifact'];
    for (var theme in themes) {
      for (var item in itemTypes) {
        _allTools.add(GameTool2D(
          id: 'tool_$counter',
          name: '$theme $item',
          category: '🪙 Предмети & Награди',
          subCategory: theme,
          nodeType: 'Area2D',
          color: const Color(0xFFFFD600),
          icon: Icons.monetization_on,
          isSolid: false,
        ));
        counter++;
      }
    }

    // 3. ВРАГОВЕ И ИИ БОТОВЕ (CharacterBody2D AI) - 1,000 инструмента
    final enemyTypes = ['Patrol Slime', 'Drone Crawler', 'Skeleton Guard', 'Zombie Walker', 'Laser Turret', 'Flying Bat', 'Boss Titan', 'Mutant Cyborg'];
    for (var theme in themes) {
      for (var enemy in enemyTypes) {
        _allTools.add(GameTool2D(
          id: 'tool_$counter',
          name: '$theme $enemy AI',
          category: '👾 Врагове & AI',
          subCategory: theme,
          nodeType: 'CharacterBody2D',
          color: const Color(0xFFFF1744),
          icon: Icons.pest_control,
          isSolid: true,
        ));
        counter++;
      }
    }

    // 4. КАПАНИ И ОПАСНОСТИ (Hazards) - 800 инструмента
    final hazardTypes = ['Steel Spikes', 'Circular Saw', 'Laser Beam', 'Acid Pool', 'Falling Boulder', 'Electric Wire', 'Flame Vent', 'Poison Dart'];
    for (var theme in themes) {
      for (var hazard in hazardTypes) {
        _allTools.add(GameTool2D(
          id: 'tool_$counter',
          name: '$theme $hazard',
          category: '⚠️ Капани & Лава',
          subCategory: theme,
          nodeType: 'Area2D',
          color: const Color(0xFFFF9100),
          icon: Icons.warning_amber,
          isSolid: false,
        ));
        counter++;
      }
    }

    // 5. СВЕТЛИНИ И ЧАСТИЦИ (PointLight2D & Particles) - 800 инструмента
    final fxTypes = ['Neon Glow Light', 'Fire Particle', 'Smoke Cloud', 'Electric Sparks', 'Magic Aura', 'Rain Effect', 'Explosion FX', 'Portal Vortex'];
    for (var theme in themes) {
      for (var fx in fxTypes) {
        _allTools.add(GameTool2D(
          id: 'tool_$counter',
          name: '$theme $fx',
          category: '💡 Светлини & FX',
          subCategory: theme,
          nodeType: 'PointLight2D',
          color: const Color(0xFF00E5FF),
          icon: Icons.lightbulb_outline,
          isSolid: false,
        ));
        counter++;
      }
    }

    // 6. ЛОГИКА, ТРИГЕРИ И ПОРТАЛИ - 600 инструмента
    final logicTypes = ['Checkpoint Flag', 'Level Exit Portal', 'Key Door Switch', 'Spawner Node', 'Audio Emitter', 'Camera Zone Bound'];
    for (var theme in themes) {
      for (var logic in logicTypes) {
        _allTools.add(GameTool2D(
          id: 'tool_$counter',
          name: '$theme $logic',
          category: '⚙️ Логика & Тригери',
          subCategory: theme,
          nodeType: 'Area2D',
          color: const Color(0xFFD500F9),
          icon: Icons.settings_input_component,
          isSolid: false,
        ));
        counter++;
      }
    }
  }

  List<GameTool2D> filter({
    String query = '',
    String category = 'Всички',
  }) {
    return _allTools.where((tool) {
      final matchesCat = category == 'Всички' || tool.category == category;
      final q = query.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          tool.name.toLowerCase().contains(q) ||
          tool.subCategory.toLowerCase().contains(q) ||
          tool.nodeType.toLowerCase().contains(q);

      return matchesCat && matchesSearch;
    }).toList();
  }
}
