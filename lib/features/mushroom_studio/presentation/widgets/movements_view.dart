import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';

class MovementsView extends StatefulWidget {
  final Function(String name, String category)? onSelectAnimation;

  const MovementsView({
    Key? key,
    this.onSelectAnimation,
  }) : super(key: key);

  @override
  State<MovementsView> createState() => _MovementsViewState();
}

class _MovementsViewState extends State<MovementsView> {
  final List<String> _animLibraries = [
    'Mixamo (2000+)',
    'ActorCore MoCap',
    'CMU Database',
    'Unity Free',
  ];

  final List<String> _categories = [
    'Всички',
    '🏃 Локомоция',
    '⚔️ Бойни & Меч',
    '🤸 Паркур',
    '💃 Танци & Емоути',
    '🧟 Чудовища & Мех',
    '⚽ Спорт & Екшън',
  ];

  String _selectedLibrary = 'Mixamo (2000+)';
  String _selectedCategory = 'Всички';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _movementsDatabase = [
    // 🏃 Локомоция
    {'name': 'Cyber Sprint Run', 'cat': '🏃 Локомоция', 'frames': '24 fr', 'lib': 'Mixamo', 'color': AppTheme.sciFiCyan, 'icon': Icons.directions_run},
    {'name': 'Casual Walk Cycle', 'cat': '🏃 Локомоция', 'frames': '32 fr', 'lib': 'ActorCore', 'color': const Color(0xFF00E676), 'icon': Icons.directions_walk},
    {'name': 'Stealth Crouch Walk', 'cat': '🏃 Локомоция', 'frames': '40 fr', 'lib': 'Mixamo', 'color': const Color(0xFFFFD600), 'icon': Icons.airline_seat_recline_extra},
    {'name': 'Tactical Strafe Left/Right', 'cat': '🏃 Локомоция', 'frames': '28 fr', 'lib': 'Mixamo', 'color': AppTheme.sciFiCyan, 'icon': Icons.compare_arrows},
    {'name': 'Ledge Climb & Pull Up', 'cat': '🏃 Локомоция', 'frames': '45 fr', 'lib': 'CMU Database', 'color': const Color(0xFFFF9100), 'icon': Icons.vertical_align_top},

    // ⚔️ Бойни
    {'name': 'Ninja Katana Slash 3-Hit', 'cat': '⚔️ Бойни & Меч', 'frames': '48 fr', 'lib': 'ActorCore', 'color': const Color(0xFFFF1744), 'icon': Icons.flash_on},
    {'name': 'Heavy Greatsword Spin', 'cat': '⚔️ Бойни & Меч', 'frames': '64 fr', 'lib': 'Mixamo', 'color': const Color(0xFFFF3D00), 'icon': Icons.shield},
    {'name': 'Boxing 1-2 Combo & Hook', 'cat': '⚔️ Бойни & Меч', 'frames': '36 fr', 'lib': 'Mixamo', 'color': const Color(0xFFFF1744), 'icon': Icons.sports_mma},
    {'name': 'Dual Pistol Aim & Fire', 'cat': '⚔️ Бойни & Меч', 'frames': '22 fr', 'lib': 'ActorCore', 'color': AppTheme.laserPink, 'icon': Icons.gps_fixed},
    {'name': 'Magic Spell Cast Arcane', 'cat': '⚔️ Бойни & Меч', 'frames': '55 fr', 'lib': 'Unity Free', 'color': const Color(0xFFD500F9), 'icon': Icons.auto_awesome},

    // 🤸 Паркур
    {'name': 'Super Hero Jump & Slam', 'cat': '🤸 Паркур', 'frames': '38 fr', 'lib': 'Mixamo', 'color': const Color(0xFF00E676), 'icon': Icons.flight_takeoff},
    {'name': 'Backflip Somersault', 'cat': '🤸 Паркур', 'frames': '42 fr', 'lib': 'ActorCore', 'color': const Color(0xFFFFD600), 'icon': Icons.cached},
    {'name': 'Wall Run & Kick Off', 'cat': '🤸 Паркур', 'frames': '35 fr', 'lib': 'Mixamo', 'color': AppTheme.sciFiCyan, 'icon': Icons.directions_run},
    {'name': 'Combat Slide & Roll', 'cat': '🤸 Паркур', 'frames': '30 fr', 'lib': 'Mixamo', 'color': const Color(0xFFFF9100), 'icon': Icons.replay},

    // 💃 Танци & Емоути
    {'name': 'Hip Hop Dance Battle', 'cat': '💃 Танци & Емоути', 'frames': '120 fr', 'lib': 'Mixamo', 'color': AppTheme.laserPink, 'icon': Icons.music_note},
    {'name': 'Breakdance Windmill', 'cat': '💃 Танци & Емоути', 'frames': '90 fr', 'lib': 'ActorCore', 'color': const Color(0xFFD500F9), 'icon': Icons.cyclone},
    {'name': 'Cyber Robot Pop Dance', 'cat': '💃 Танци & Емоути', 'frames': '85 fr', 'lib': 'Mixamo', 'color': AppTheme.sciFiCyan, 'icon': Icons.smart_toy},
    {'name': 'Victory Flip & Flex Emote', 'cat': '💃 Танци & Емоути', 'frames': '60 fr', 'lib': 'Mixamo Free', 'color': const Color(0xFF00E676), 'icon': Icons.celebration},

    // 🧟 Чудовища & Мех
    {'name': 'Zombie Horde Shambler', 'cat': '🧟 Чудовища & Мех', 'frames': '80 fr', 'lib': 'Mixamo', 'color': const Color(0xFFFF9100), 'icon': Icons.coronavirus},
    {'name': 'Titan Mech Stomp Walk', 'cat': '🧟 Чудовища & Мех', 'frames': '50 fr', 'lib': 'ActorCore', 'color': const Color(0xFFFF1744), 'icon': Icons.precision_manufacturing},
    {'name': 'Dragon Roar & Wing Beat', 'cat': '🧟 Чудовища & Мех', 'frames': '75 fr', 'lib': 'CMU Database', 'color': const Color(0xFFFF3D00), 'icon': Icons.whatshot},

    // ⚽ Спорт
    {'name': 'Cyber Drift Bike Ride', 'cat': '⚽ Спорт & Екшън', 'frames': '60 fr', 'lib': 'Mixamo', 'color': const Color(0xFF00E676), 'icon': Icons.two_wheeler},
    {'name': 'Skateboard 360 Kickflip', 'cat': '⚽ Спорт & Екшън', 'frames': '45 fr', 'lib': 'ActorCore', 'color': const Color(0xFFFFD600), 'icon': Icons.skateboarding},
    {'name': 'Soccer Bicycle Kick', 'cat': '⚽ Спорт & Екшън', 'frames': '40 fr', 'lib': 'Mixamo', 'color': AppTheme.sciFiCyan, 'icon': Icons.sports_soccer},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _movementsDatabase.where((m) {
      final matchesLib = _selectedLibrary == 'Mixamo (2000+)' || m['lib'].toString().contains(_selectedLibrary.split(' ')[0]);
      final matchesCat = _selectedCategory == 'Всички' || m['cat'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          m['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m['cat'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesLib && matchesCat && matchesSearch;
    }).toList();

    return Column(
      children: [
        // 1. Избор на MoCap библиотека
        Container(
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _animLibraries.length,
            itemBuilder: (context, index) {
              final lib = _animLibraries[index];
              final isSel = lib == _selectedLibrary;
              return GestureDetector(
                onTap: () => setState(() => _selectedLibrary = lib),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF00E676) : const Color(0xFF141724),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSel ? const Color(0xFF00E676) : Colors.white12),
                  ),
                  child: Center(
                    child: Text(
                      lib,
                      style: TextStyle(
                        color: isSel ? Colors.black : Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // 2. Търсачка
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF141724),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Търси сред 2000+ движения (скок, бягане, нинджа)...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 11),
                icon: Icon(Icons.search, size: 16, color: AppTheme.laserPink),
                border: InputBorder.none,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
        ),

        // 3. Категории лента
        SizedBox(
          height: 32,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSel = cat == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSel ? AppTheme.laserPink : const Color(0xFF161824),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSel ? AppTheme.sciFiCyan : Colors.white12),
                  ),
                  child: Center(
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSel ? Colors.white : Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // 4. Списък с движения
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final move = filtered[index];
              final Color glow = move['color'] as Color? ?? AppTheme.laserPink;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF141724),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: glow.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: glow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(move['icon'] as IconData? ?? Icons.directions_run, color: glow, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            move['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${move['cat']} • ${move['frames']} • ${move['lib']}',
                            style: const TextStyle(color: Colors.grey, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: glow,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                        widget.onSelectAnimation?.call(move['name'] as String, move['cat'] as String);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('▶ Зареждане в Анимационния Плейър: ${move['name']}')),
                        );
                      },
                      child: const Text(
                        'ПРЕГЛЕД ▶',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
