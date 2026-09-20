import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';

class AnimationItem {
  final String name;
  final String category;
  final String subCategory;
  final String frames;
  final String library;
  final Color color;
  final IconData icon;

  AnimationItem({
    required this.name,
    required this.category,
    required this.subCategory,
    required this.frames,
    required this.library,
    required this.color,
    required this.icon,
  });
}

class AnimationCatalogService {
  static final AnimationCatalogService _instance = AnimationCatalogService._internal();
  factory AnimationCatalogService() => _instance;
  AnimationCatalogService._internal() {
    _initMassiveCatalog();
  }

  final List<AnimationItem> _allAnimations = [];

  List<AnimationItem> get allAnimations => _allAnimations;

  void _initMassiveCatalog() {
    if (_allAnimations.isNotEmpty) return;

    // 1. 🏃 ЛОКОМОЦИЯ (ХОДЕНЕ, БЯГАНЕ, СПРИНТ, СТРАНИЧНО)
    final locomotionStyles = [
      'Normal', 'Casual', 'Injured', 'Drunk', 'Zombie', 'Stealth', 'Tactical',
      'Fierce', 'Soldier Rifle', 'Ninja Low', 'Happy', 'Sad', 'Elderly', 'Scared'
    ];
    for (var style in locomotionStyles) {
      _allAnimations.add(AnimationItem(name: 'Walk $style Cycle', category: '🏃 Локомоция', subCategory: 'Ходене', frames: '32 fr', library: 'Mixamo', color: const Color(0xFF00E676), icon: Icons.directions_walk));
      _allAnimations.add(AnimationItem(name: 'Run $style Forward', category: '🏃 Локомоция', subCategory: 'Бягане', frames: '22 fr', library: 'Mixamo', color: AppTheme.sciFiCyan, icon: Icons.directions_run));
      _allAnimations.add(AnimationItem(name: 'Sprint $style Fast 60FPS', category: '🏃 Локомоция', subCategory: 'Спринт', frames: '18 fr', library: 'ActorCore', color: AppTheme.laserPink, icon: Icons.bolt));
      _allAnimations.add(AnimationItem(name: 'Strafe $style Left', category: '🏃 Локомоция', subCategory: 'Странично', frames: '26 fr', library: 'Mixamo', color: AppTheme.sciFiCyan, icon: Icons.arrow_back));
      _allAnimations.add(AnimationItem(name: 'Strafe $style Right', category: '🏃 Локомоция', subCategory: 'Странично', frames: '26 fr', library: 'Mixamo', color: AppTheme.sciFiCyan, icon: Icons.arrow_forward));
      _allAnimations.add(AnimationItem(name: 'Crouch $style Walk', category: '🏃 Локомоция', subCategory: 'Пълзене', frames: '40 fr', library: 'CMU Database', color: const Color(0xFFFFD600), icon: Icons.airline_seat_recline_extra));
      _allAnimations.add(AnimationItem(name: 'Turn 180 $style Quick', category: '🏃 Локомоция', subCategory: 'Завой', frames: '20 fr', library: 'Mixamo', color: const Color(0xFF00E676), icon: Icons.replay));
    }

    // 2. ⚔️ БОЙНИ & ОРЪЖИЯ (КАТАНА, МЕЧ, БОКС, ОГНЕСТРЕЛНИ, МАГИЯ)
    final combatWeapons = ['Katana', 'Greatsword', 'Dual Daggers', 'Spear', 'Axe', 'Warhammer', 'Fists Boxing', 'Shield'];
    for (var w in combatWeapons) {
      for (int combo = 1; combo <= 4; combo++) {
        _allAnimations.add(AnimationItem(name: '$w Attack Combo 0$combo', category: '⚔️ Бойни & Оръжия', subCategory: w, frames: '${30 + combo * 8} fr', library: 'ActorCore', color: const Color(0xFFFF1744), icon: Icons.flash_on));
        _allAnimations.add(AnimationItem(name: '$w Heavy Finisher Slash $combo', category: '⚔️ Бойни & Оръжия', subCategory: w, frames: '${40 + combo * 10} fr', library: 'Mixamo', color: const Color(0xFFFF3D00), icon: Icons.sports_mma));
        _allAnimations.add(AnimationItem(name: '$w Guard Block & Deflect $combo', category: '⚔️ Бойни & Оръжия', subCategory: w, frames: '22 fr', library: 'Mixamo', color: const Color(0xFFFF9100), icon: Icons.shield));
      }
    }

    // Стрелба и пистолети
    final gunTypes = ['Pistol', 'Rifle Assault', 'Shotgun', 'Sniper Aim', 'Dual Uzis'];
    for (var g in gunTypes) {
      _allAnimations.add(AnimationItem(name: '$g Fire & Recoil', category: '⚔️ Бойни & Оръжия', subCategory: 'Стрелба', frames: '16 fr', library: 'Mixamo', color: AppTheme.sciFiCyan, icon: Icons.gps_fixed));
      _allAnimations.add(AnimationItem(name: '$g Tactical Reload', category: '⚔️ Бойни & Оръжия', subCategory: 'Стрелба', frames: '45 fr', library: 'Mixamo', color: Colors.grey, icon: Icons.autorenew));
      _allAnimations.add(AnimationItem(name: '$g Cover Peek Left/Right', category: '⚔️ Бойни & Оръжия', subCategory: 'Стрелба', frames: '32 fr', library: 'ActorCore', color: const Color(0xFF00E676), icon: Icons.shield));
    }

    // 3. 🤸 ПАРКУР, СКОКОВЕ & АКРОБАТИКА
    final parkourMoves = [
      'Front Flip', 'Backflip Somersault', 'Wall Run Left', 'Wall Run Right', 'Ledge Climb & Pull Up',
      'Cat Leap Grab', 'Slide Under Obstacle', 'Vault Low Fence', 'Roll On Landing', 'Rope Swing Release',
      'Balance Beam Walk', 'Double Jump Mid-Air', 'Dive Roll Forward', 'High Drop Soft Land'
    ];
    for (var p in parkourMoves) {
      _allAnimations.add(AnimationItem(name: 'Parkour $p', category: '🤸 Паркур & Скокове', subCategory: 'Акробатика', frames: '38 fr', library: 'Mixamo', color: const Color(0xFF00E676), icon: Icons.flight_takeoff));
      _allAnimations.add(AnimationItem(name: 'Action $p Pro Mocap', category: '🤸 Паркур & Скокове', subCategory: 'Акробатика', frames: '42 fr', library: 'CMU Database', color: const Color(0xFFFFD600), icon: Icons.cached));
    }

    // 4. 💃 ТАНЦИ & ЕМОУТИ (MIXAMO & MOCAP BATTLE)
    final dances = [
      'Hip Hop Battle', 'Breakdance Windmill', 'Breakdance Headspin', 'Robot Pop Lock', 'Salsa Duo',
      'Gangnam Style', 'Macarena Classic', 'Victory Flex Pose', 'Floss Emote', 'Belly Dance',
      'Rock Guitar Solo', 'Tap Dance Shuffler', 'Cheerleader Jump', 'Disco Fever', 'Thriller Dance'
    ];
    for (var d in dances) {
      _allAnimations.add(AnimationItem(name: '$d (Mixamo)', category: '💃 Танци & Емоути', subCategory: 'Танци', frames: '95 fr', library: 'Mixamo', color: AppTheme.laserPink, icon: Icons.music_note));
      _allAnimations.add(AnimationItem(name: '$d Freestyle V2', category: '💃 Танци & Емоути', subCategory: 'Танци', frames: '120 fr', library: 'ActorCore', color: const Color(0xFFD500F9), icon: Icons.celebration));
    }

    // Емоути
    final emotes = ['Laugh Out Loud', 'Angry Shout', 'Crying Sad', 'Wave Greeting', 'Salute Soldier', 'Facepalm', 'Taunt Point Finger'];
    for (var e in emotes) {
      _allAnimations.add(AnimationItem(name: 'Emote $e', category: '💃 Танци & Емоути', subCategory: 'Емоути', frames: '48 fr', library: 'Mixamo Free', color: AppTheme.sciFiCyan, icon: Icons.sentiment_satisfied));
    }

    // 5. 🧟 ЧУДОВИЩА, ЗОМБИТА & МЕХОВЕ
    final creatures = ['Zombie Shambler', 'Zombie Runner', 'Zombie Crawler', 'Titan Mech Stomp', 'Dragon Flight Loop', 'Dragon Roar & Fire', 'Werewolf Prowl', 'Alien Slink', 'Giant Boss Slam'];
    for (var c in creatures) {
      _allAnimations.add(AnimationItem(name: '$c Movement', category: '🧟 Чудовища & Мех', subCategory: 'Монстри', frames: '65 fr', library: 'Mixamo', color: const Color(0xFFFF9100), icon: Icons.coronavirus));
      _allAnimations.add(AnimationItem(name: '$c Attack Phase', category: '🧟 Чудовища & Мех', subCategory: 'Монстри', frames: '45 fr', library: 'ActorCore', color: const Color(0xFFFF1744), icon: Icons.whatshot));
    }

    // 6. 💥 РЕАКЦИИ, УДАРИ & СМЪРТ (HURT / DEATH)
    final deaths = ['Headshot Fall Back', 'Chest Hit Knockdown', 'Spin Fall Death', 'Gut Hit Collapse', 'Lava Burn Dissolve', 'Electric Shock Stun', 'Revive Stand Up'];
    for (var dt in deaths) {
      _allAnimations.add(AnimationItem(name: 'Reaction $dt', category: '💥 Реакции & Смърт', subCategory: 'Поражения', frames: '36 fr', library: 'Mixamo', color: const Color(0xFFFF1744), icon: Icons.heart_broken));
    }

    // 7. ⚽ СПОРТ, ТРАНСПОРТ & ЕКШЪН
    final sports = ['Soccer Shoot Penalty', 'Basketball Slam Dunk', 'Baseball Bat Swing', 'Motorcycle Drift Drive', 'Skateboard Ollie 360', 'Swimming Freestyle', 'Boxing Jab Right'];
    for (var sp in sports) {
      _allAnimations.add(AnimationItem(name: 'Sport $sp', category: '⚽ Спорт & Екшън', subCategory: 'Спорт', frames: '50 fr', library: 'CMU Database', color: const Color(0xFF00B0FF), icon: Icons.sports_soccer));
    }
  }

  // Търсене с филтри
  List<AnimationItem> search({
    String query = '',
    String category = 'Всички',
    String library = 'Всички',
  }) {
    return _allAnimations.where((item) {
      final matchesCat = category == 'Всички' || item.category == category;
      final matchesLib = library == 'Всички' || library == 'Mixamo (2000+)' || item.library.contains(library.split(' ')[0]);
      final q = query.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          item.name.toLowerCase().contains(q) ||
          item.subCategory.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q);

      return matchesCat && matchesLib && matchesSearch;
    }).toList();
  }
}
