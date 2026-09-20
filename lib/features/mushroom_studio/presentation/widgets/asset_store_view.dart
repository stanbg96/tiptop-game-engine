import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/core/services/auto_rig_service.dart';
import 'package:tiptop_game_engine/features/mushroom_studio/presentation/widgets/model_upload_modal.dart';

class AssetStoreView extends StatefulWidget {
  final VoidCallback? onInsertTo2D;
  final VoidCallback? onInsertTo3D;

  const AssetStoreView({
    Key? key,
    this.onInsertTo2D,
    this.onInsertTo3D,
  }) : super(key: key);

  @override
  State<AssetStoreView> createState() => _AssetStoreViewState();
}

class _AssetStoreViewState extends State<AssetStoreView> {
  String _selectedMainType = '🎲 3D Модели';
  String _selectedCategory = 'Всички';
  String _searchQuery = '';
  String? _playingAudioTrack;

  final List<String> _mainTypes = [
    '🎲 3D Модели',
    '👑 Моите Модели',
    '🎨 2D Спрайтове',
    '🎵 Музика & SFX',
    '🌋 Шейдъри & FX',
  ];

  final List<String> _categories = [
    'Всички',
    '🏰 Сгради & Замъци',
    '🤖 Герои & Кукли',
    '🌋 Лава & Неон',
    '🚗 Возила & Коли',
    '⚔️ Оръжия',
    '📦 Пропове',
  ];

  late List<Map<String, dynamic>> _catalog;

  @override
  void initState() {
    super.initState();
    _catalog = _buildInitialCatalog();
  }

  static List<Map<String, dynamic>> _buildInitialCatalog() {
    return [
      {
        'name': 'Вулканичен Замък 3D',
        'type': '3D Сграда',
        'media': '3D',
        'cat': '🏰 Сгради & Замъци',
        'color': const Color(0xFFFF3D00),
        'poly': '1.8k Poly',
        'lib': 'Quaternius Free',
        'img': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=300&q=80',
        'icon': Icons.castle,
      },
      {
        'name': 'Кибер Самурай 3D',
        'type': '3D Герой (Rigged)',
        'media': '3D',
        'cat': '🤖 Герои & Кукли',
        'color': const Color(0xFFD500F9),
        'poly': '3.5k Poly',
        'lib': 'Mixamo Rigged',
        'img': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=300&q=80',
        'icon': Icons.accessibility_new,
      },
      {
        'name': 'Неонов Болид GT',
        'type': '3D Возило',
        'media': '3D',
        'cat': '🚗 Возила & Коли',
        'color': const Color(0xFF00E5FF),
        'poly': '2.3k Poly',
        'lib': 'Kenney Cars',
        'img': 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=300&q=80',
        'icon': Icons.directions_car,
      },
      {
        'name': 'Плазмен Меч FX',
        'type': '3D Оръжие',
        'media': '3D',
        'cat': '⚔️ Оръжия',
        'color': const Color(0xFF00E676),
        'poly': '450 Poly',
        'lib': 'PolyPizza',
        'img': 'https://images.unsplash.com/photo-1589241062272-c0a000072dfa?w=300&q=80',
        'icon': Icons.flash_on,
      },
      {
        'name': 'Лава Дракон Бос',
        'type': '3D Бос',
        'media': '3D',
        'cat': '🌋 Лава & Неон',
        'color': const Color(0xFFFF1744),
        'poly': '6.2k Poly',
        'lib': 'Quaternius',
        'img': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=300&q=80',
        'icon': Icons.stream,
      },
      {
        'name': 'Пиксел Рицар 2D',
        'type': '2D Спрайт',
        'media': '2D',
        'cat': '🤖 Герои & Кукли',
        'color': const Color(0xFFFFD600),
        'poly': '32x32 Sheet',
        'lib': 'OpenGameArt',
        'img': 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=300&q=80',
        'icon': Icons.shield,
      },
      {
        'name': 'Платформи Плочки 2D',
        'type': '2D Плочки',
        'media': '2D',
        'cat': '🏰 Сгради & Замъци',
        'color': const Color(0xFF00E676),
        'poly': '16x16 Tileset',
        'lib': 'Kenney 2D',
        'img': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=300&q=80',
        'icon': Icons.grid_on,
      },
      {
        'name': 'Cyberpunk Action OST',
        'type': 'Фонова Музика',
        'media': 'Audio',
        'cat': '🌋 Лава & Неон',
        'color': AppTheme.laserPink,
        'poly': '2:15 min • MP3',
        'lib': 'Incompetech',
        'img': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300&q=80',
        'icon': Icons.music_note,
      },
      {
        'name': 'Лазерен Бластер SFX',
        'type': 'Звуков Ефект',
        'media': 'Audio',
        'cat': '⚔️ Оръжия',
        'color': AppTheme.sciFiCyan,
        'poly': '0:02 sec • WAV',
        'lib': 'Kenney Audio',
        'img': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300&q=80',
        'icon': Icons.volume_up,
      },
    ];
  }

  void _show3DInspectModal(Map<String, dynamic> asset) {
    double orbitAngle = 0.0;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: AppTheme.sciFiCyan, width: 1.2),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(asset['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(icon: const Icon(Icons.close, color: Colors.grey, size: 20), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(color: Colors.white12),

                // 3D Orbit Canvas
                GestureDetector(
                  onPanUpdate: (d) {
                    setModalState(() => orbitAngle += d.delta.dx * 0.02);
                  },
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF090B14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: (asset['color'] as Color).withValues(alpha: 0.4)),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: CustomPaint(
                            size: const Size(120, 120),
                            painter: Asset3DOrbitPainter(angle: orbitAngle, color: asset['color'] as Color),
                          ),
                        ),
                        Positioned(
                          bottom: 6,
                          right: 8,
                          child: Text('Плъзни за 360° въртене', style: TextStyle(color: Colors.grey.withValues(alpha: 0.7), fontSize: 9)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('Тип', asset['type'] as String),
                    _buildStat('Полигони', asset['poly'] as String),
                    _buildStat('Библиотека', asset['lib'] as String),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: asset['color'] as Color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    icon: const Icon(Icons.download, color: Colors.black, size: 18),
                    label: const Text('ВКАРАЙ В СЦЕНАТА', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () {
                      Navigator.pop(context);
                      if (asset['media'] == '2D') {
                        widget.onInsertTo2D?.call();
                      } else {
                        widget.onInsertTo3D?.call();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Вкаран в сцената: ${asset['name']}')));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final customModels = AutoRigService().customModels;

    List<Map<String, dynamic>> filteredList = [];

    if (_selectedMainType == '👑 Моите Модели') {
      filteredList = customModels.map((m) => {
        'name': m.name,
        'type': m.isAutoRigged ? '3D Модел (Auto-Rigged)' : '3D Модел',
        'media': '3D',
        'cat': '🤖 Герои & Кукли',
        'color': m.baseColor,
        'poly': '${m.vertexCount} Poly',
        'lib': 'Local Storage',
        'img': '',
        'icon': Icons.accessibility_new,
      }).toList();
    } else {
      filteredList = _catalog.where((a) {
        bool matchesType = true;
        if (_selectedMainType == '🎲 3D Модели') matchesType = a['media'] == '3D';
        if (_selectedMainType == '🎨 2D Спрайтове') matchesType = a['media'] == '2D';
        if (_selectedMainType == '🎵 Музика & SFX') matchesType = a['media'] == 'Audio';
        if (_selectedMainType == '🌋 Шейдъри & FX') matchesType = a['media'] == 'Shaders';

        final matchesCat = _selectedCategory == 'Всички' || a['cat'] == _selectedCategory;
        final matchesSearch = _searchQuery.isEmpty || a['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesType && matchesCat && matchesSearch;
      }).toList();
    }

    return Column(
      children: [
        // 1. Избор на основен тип
        Container(
          height: 38,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(color: const Color(0xFF141724), borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: _mainTypes.map((type) {
              final isSel = type == _selectedMainType;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMainType = type),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSel ? AppTheme.laserPink : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        type,
                        style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontSize: 9, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // 2. Бутон за качване на модел (ако сме в "Моите Модели") или търсачка
        if (_selectedMainType == '👑 Моите Модели')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.sciFiCyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                icon: const Icon(Icons.file_upload, color: Colors.black, size: 18),
                label: const Text('➕ КАЧИ 3D МОДЕЛ & AUTO-RIG', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                onPressed: () {
                  ModelUploadModal.show(context, onModelRigged: (model) {
                    setState(() {});
                  });
                },
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: const Color(0xFF141724), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(
                  hintText: 'Търси модели, спрайтове, звуци...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 11),
                  icon: Icon(Icons.search, size: 16, color: AppTheme.sciFiCyan),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),

        // 3. Подкатегории
        if (_selectedMainType != '👑 Моите Модели')
          SizedBox(
            height: 30,
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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

        // 4. Грид с асети
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final asset = filteredList[index];
              final Color glow = asset['color'] as Color? ?? AppTheme.laserPink;
              final bool isAudio = asset['media'] == 'Audio';
              final bool isPlaying = _playingAudioTrack == asset['name'];

              return GestureDetector(
                onTap: () {
                  if (asset['media'] == '3D') {
                    _show3DInspectModal(asset);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF141724),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: glow.withValues(alpha: 0.5)),
                    boxShadow: [BoxShadow(color: glow.withValues(alpha: 0.15), blurRadius: 8)],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(color: glow.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(5)),
                              child: Text(asset['type'] as String, style: TextStyle(color: glow, fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                            Text(asset['poly'] as String, style: const TextStyle(color: Colors.grey, fontSize: 8)),
                          ],
                        ),

                        // Изображение
                        Container(
                          height: 90,
                          width: double.infinity,
                          decoration: BoxDecoration(color: const Color(0xFF0E101A), borderRadius: BorderRadius.circular(10), border: Border.all(color: glow.withValues(alpha: 0.3))),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (asset['img'].toString().isNotEmpty)
                                  Image.network(
                                    asset['img'] as String,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Center(child: Icon(asset['icon'] as IconData? ?? Icons.view_in_ar, size: 36, color: glow)),
                                  )
                                else
                                  Center(child: Icon(asset['icon'] as IconData? ?? Icons.accessibility_new, size: 40, color: glow)),

                                if (isAudio)
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle, border: Border.all(color: glow)),
                                      child: Icon(isPlaying ? Icons.graphic_eq : Icons.play_arrow, size: 22, color: glow),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        Text(asset['name'] as String, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('Библиотека: ${asset['lib']}', style: const TextStyle(color: Colors.white54, fontSize: 8), maxLines: 1),

                        if (isAudio) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 24,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: isPlaying ? Colors.redAccent : glow, padding: EdgeInsets.zero),
                              onPressed: () {
                                setState(() => _playingAudioTrack = isPlaying ? null : asset['name'] as String);
                              },
                              child: Text(isPlaying ? 'СТОП' : 'ПРЕСЛУШАЙ', style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ] else ...[
                          SizedBox(
                            width: double.infinity,
                            height: 24,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: glow, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                              onPressed: () {
                                if (asset['media'] == '2D') {
                                  widget.onInsertTo2D?.call();
                                } else {
                                  widget.onInsertTo3D?.call();
                                }
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Вкаран в сцената: ${asset['name']}')));
                              },
                              child: Text(asset['media'] == '2D' ? 'ВКАРАЙ В 2D' : 'ВКАРАЙ В 3D', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 9)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// 3D Orbit Preview CustomPainter
class Asset3DOrbitPainter extends CustomPainter {
  final double angle;
  final Color color;

  Asset3DOrbitPainter({required this.angle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2.0;
    final double cy = size.height / 2.0;
    const double s = 35.0;

    double cosA = math.cos(angle);
    double sinA = math.sin(angle);

    Offset p(double x, double y, double z) {
      double rx = x * cosA - z * sinA;
      double rz = x * sinA + z * cosA;
      double depth = (rz + 150.0) / 150.0;
      return Offset(cx + (rx * depth), cy + (y * depth));
    }

    List<Offset> v = [
      p(-s, -s, -s), p(s, -s, -s), p(s, -s, s), p(-s, -s, s),
      p(-s, s, -s), p(s, s, -s), p(s, s, s), p(-s, s, s),
    ];

    final fillPaint = Paint()..color = color.withValues(alpha: 0.6)..style = PaintingStyle.fill;
    final edgePaint = Paint()..color = Colors.white..strokeWidth = 1.5..style = PaintingStyle.stroke;

    Path top = Path()..moveTo(v[0].dx, v[0].dy)..lineTo(v[1].dx, v[1].dy)..lineTo(v[2].dx, v[2].dy)..lineTo(v[3].dx, v[3].dy)..close();
    canvas.drawPath(top, fillPaint);
    canvas.drawPath(top, edgePaint);

    Path front = Path()..moveTo(v[3].dx, v[3].dy)..lineTo(v[2].dx, v[2].dy)..lineTo(v[6].dx, v[6].dy)..lineTo(v[7].dx, v[7].dy)..close();
    canvas.drawPath(front, fillPaint);
    canvas.drawPath(front, edgePaint);
  }

  @override
  bool shouldRepaint(covariant Asset3DOrbitPainter oldDelegate) => true;
}
