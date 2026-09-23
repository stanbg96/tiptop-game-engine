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

  final List<String> _categories = [
    'Всички',
    '🏃 Локомоция',
    '⚔️ Бойни & Оръжия',
    '🤸 Паркур & Скокове',
    '💃 Танци & Емоути',
    '🧟 Чудовища & Мех',
  ];

  String _selectedProvider = 'Всички';
  String _selectedCategory = 'Всички';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _catalogService.search(
      query: _searchQuery,
      category: _selectedCategory,
      provider: _selectedProvider,
    );

    final providers = _catalogService.providersRegistry;

    return Column(
      children: [
        // 1. Брояч и бутон за активиране на всички 10,400+ движения
        Container(
          margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1E2338), Color(0xFF101424)]),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.laserPink.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('6 MoCap Доставчика:', style: TextStyle(color: Colors.white70, fontSize: 9)),
                  Text('10,463 Налични Движения', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.laserPink, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                icon: const Icon(Icons.flash_on, color: Colors.white, size: 13),
                label: const Text('ЗАРЕДИ ВСИЧКИ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9)),
                onPressed: () {
                  setState(() {
                    _selectedProvider = 'Всички';
                    _selectedCategory = 'Всички';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('⚡ Всички 10,463 движения от 6-те доставчика са заредени!')),
                  );
                },
              ),
            ],
          ),
        ),

        // 2. Доставчици с точен брой файлове
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            itemCount: providers.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSel = _selectedProvider == 'Всички';
                return GestureDetector(
                  onTap: () => setState(() => _selectedProvider = 'Всички'),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6, bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF00E676) : const Color(0xFF161824),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSel ? const Color(0xFF00E676) : Colors.white12),
                    ),
                    child: Center(
                      child: Text('Всички (10.4k)', style: TextStyle(color: isSel ? Colors.black : Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              }

              final prov = providers[index - 1];
              final isSel = _selectedProvider.contains(prov.name.split(' ')[0]);

              return GestureDetector(
                onTap: () => setState(() => _selectedProvider = prov.name),
                child: Container(
                  margin: const EdgeInsets.only(right: 6, bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSel ? prov.badgeColor : const Color(0xFF161824),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSel ? Colors.white : Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Text(prov.name.split(' ')[0], style: TextStyle(color: isSel ? Colors.black : Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(4)),
                        child: Text('${prov.countNumber}', style: const TextStyle(color: Colors.white, fontSize: 8)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 3. Търсачка
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: const Color(0xFF141724), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white12)),
            child: Row(
              children: [
                const Icon(Icons.search, size: 14, color: AppTheme.sciFiCyan),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                    decoration: InputDecoration(
                      hintText: 'Търси в ${filtered.length} движения (катана, спринт, салто)...',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 10),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 4. Категории
        SizedBox(
          height: 28,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSel = cat == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSel ? AppTheme.laserPink : const Color(0xFF161824),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSel ? AppTheme.sciFiCyan : Colors.white12),
                  ),
                  child: Center(
                    child: Text(cat, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            },
          ),
        ),

        // 5. Списък с движения
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(6),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final move = filtered[index];
              final Color glow = move.color;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF141724),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: glow.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: glow.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: Icon(move.icon, color: glow, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(move.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          Text('${move.category} • ${move.frames} • ${move.provider}', style: const TextStyle(color: Colors.grey, fontSize: 8)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: glow, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2)),
                      onPressed: () {
                        widget.onSelectAnimation?.call(move.name, move.category);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('▶ Заредено движение: ${move.name}')),
                        );
                      },
                      child: const Text('ПРЕГЛЕД ▶', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 9)),
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
