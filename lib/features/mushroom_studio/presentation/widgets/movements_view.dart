import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/core/services/animation_catalog_service.dart';

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
  final AnimationCatalogService _catalogService = AnimationCatalogService();

  final List<String> _animLibraries = [
    'Всички',
    'Mixamo (2000+)',
    'ActorCore MoCap',
    'CMU Database',
    'Unity Free',
  ];

  final List<String> _categories = [
    'Всички',
    '🏃 Локомоция',
    '⚔️ Бойни & Оръжия',
    '🤸 Паркур & Скокове',
    '💃 Танци & Емоути',
    '🧟 Чудовища & Мех',
    '💥 Реакции & Смърт',
    '⚽ Спорт & Екшън',
  ];

  String _selectedLibrary = 'Всички';
  String _selectedCategory = 'Всички';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _catalogService.search(
      query: _searchQuery,
      category: _selectedCategory,
      library: _selectedLibrary,
    );

    return Column(
      children: [
        // 1. Библиотека селектор (Mixamo, ActorCore, CMU)
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

        // 2. Търсачка с динамичен брояч
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
            child: Row(
              children: [
                const Icon(Icons.search, size: 16, color: AppTheme.laserPink),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Търси сред ${filtered.length} налични движения...',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 11),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _searchQuery = ''),
                    child: const Icon(Icons.clear, size: 14, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ),

        // 3. Категории
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

        // 4. Списък с хиляди индексирани движения
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final move = filtered[index];
              final Color glow = move.color;

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
                      child: Icon(move.icon, color: glow, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            move.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${move.category} • ${move.frames} • ${move.library}',
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
                        widget.onSelectAnimation?.call(move.name, move.category);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('▶ Заредено движение: ${move.name}')),
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
