import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/core/services/auto_rig_service.dart';
import 'package:tiptop_game_engine/features/mushroom_studio/presentation/widgets/model_upload_modal.dart';
import 'package:tiptop_game_engine/features/mushroom_studio/presentation/widgets/model_3d_viewer_painter.dart';

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
  String _selectedLibrary = 'Всички';
  String _searchQuery = '';
  String? _playingAudioTrack;

  final List<String> _mainTypes = [
    '🎲 3D Модели',
    '👑 Моите Модели',
    '🎨 2D Спрайтове',
    '🎵 Музика & SFX',
    '🌋 Шейдъри & FX',
    '📚 22 Библиотеки',
  ];

  final List<String> _categories = [
    'Всички',
    '🤖 Герои & Мехове',
    '🏰 Сгради & Замъци',
    '🚗 Возила & Коли',
    '⚔️ Оръжия',
    '🌋 Лава & Неон',
    '🚀 Космос & Sci-Fi',
    '📦 Пропове & Сандъци',
  ];

  final List<String> _librariesFilter = [
    'Всички',
    'Kenney.nl',
    'Quaternius',
    'Poly Pizza',
    'Kay Lousberg',
    'NASA 3D',
    'Mixamo',
    'CraftPix',
    'OpenGameArt',
    'FreeSound.org',
    'Incompetech',
    'GodotShaders',
  ];

  final List<Map<String, dynamic>> _freeLibrariesList = [
    {'name': 'Kenney.nl', 'type': '3D & 2D & Audio', 'license': 'CC0 Public Domain', 'desc': 'Над 20,000 безплатни гейм асета, текстури и коли.'},
    {'name': 'Quaternius', 'type': '3D Models', 'license': 'CC0 Public Domain', 'desc': 'Модулни мехове, средновековни сгради, танкове и герои.'},
    {'name': 'Poly Pizza', 'type': '3D Low-Poly', 'license': 'CC0 / CC-BY', 'desc': 'Хиляди Google Poly 3D модели за бърз прототипинг.'},
    {'name': 'Kay Lousberg', 'type': '3D Modular', 'license': 'CC0 Public Domain', 'desc': 'Модулни подземия, космос, градски улици и герои.'},
    {'name': 'OpenGameArt', 'type': '2D, 3D & Music', 'license': 'GPL / CC0', 'desc': 'Най-голямата отворена гейм общност в света.'},
    {'name': 'Sketchfab Free', 'type': '3D PBR Meshes', 'license': 'CC-BY', 'desc': 'Фотореалистични 3D сканирания и PBR обекти.'},
    {'name': 'Mixamo', 'type': 'Rigged 3D Characters', 'license': 'Royalty-Free', 'desc': 'Готови ригнати хуманоидни герои с 2000+ анимации.'},
    {'name': 'NASA 3D Resources', 'type': '3D Space', 'license': 'Public Domain', 'desc': 'Реални совалки, Марсоходи, ракети и планети.'},
    {'name': 'CraftPix', 'type': '2D Sprites', 'license': 'Free License', 'desc': 'Пиксел арт рицари, чудовища, фонове и UI панели.'},
    {'name': 'FreeSound.org', 'type': 'Audio & SFX', 'license': 'CC0 / CC-BY', 'desc': 'Стотици хиляди реални звукови ефекти и ембиент звуци.'},
    {'name': 'Incompetech', 'type': 'Music Soundtracks', 'license': 'CC-BY', 'desc': 'Легендарните гейм саундтраци на Kevin MacLeod.'},
    {'name': 'GodotShaders', 'type': 'Shaders & VFX', 'license': 'CC0 / MIT', 'desc': 'Отворени шейдъри за лава, вода, мъгла, неон и разпад.'},
  ];

  late List<Map<String, dynamic>> _catalog;

  @override
  void initState() {
    super.initState();
    _catalog = _generateMassiveCatalog();
  }

  // =========================================================================
  // ⚙️ ИНТЕЛИГЕНТЕН ГЕНЕРАТОР НА 500+ АСЕТА (За да е пълен магазинът!)
  // =========================================================================
  static List<Map<String, dynamic>> _generateMassiveCatalog() {
    List<Map<String, dynamic>> list = [];
    final math.Random rng = math.Random(42);

    final List<Color> colors = [AppTheme.sciFiCyan, AppTheme.laserPink, const Color(0xFFFFD600), const Color(0xFF00E676), const Color(0xFFFF3D00), const Color(0xFFD500F9)];
    final List<String> libs3D = ['Kenney.nl', 'Quaternius', 'Poly Pizza', 'Kay Lousberg', 'Sketchfab Free'];

    // 1. Генериране на 150+ 3D Герои & Мехове
    for (int i = 1; i <= 150; i++) {
      list.add({
        'name': 'Mech / Hero Model v$i', 'type': '3D Герой (Rigged)', 'media': '3D', 'shape': 'humanoid',
        'cat': '🤖 Герои & Мехове', 'color': colors[i % colors.length], 'poly': '${1200 + (i * 45)} Poly',
        'lib': i % 3 == 0 ? 'Mixamo' : libs3D[i % libs3D.length], 'img': '', 'icon': Icons.accessibility_new,
      });
    }

    // 2. Генериране на 100+ 3D Возила
    for (int i = 1; i <= 100; i++) {
      list.add({
        'name': 'Cyber Vehicle X-$i', 'type': '3D Возило (Physics)', 'media': '3D', 'shape': 'vehicle',
        'cat': '🚗 Возила & Коли', 'color': colors[rng.nextInt(colors.length)], 'poly': '${800 + (i * 60)} Poly',
        'lib': libs3D[rng.nextInt(libs3D.length)], 'img': '', 'icon': Icons.directions_car,
      });
    }

    // 3. Генериране на 100+ 3D Сгради & Замъци
    for (int i = 1; i <= 100; i++) {
      list.add({
        'name': 'Modular Castle Block $i', 'type': '3D Сграда', 'media': '3D', 'shape': 'castle',
        'cat': '🏰 Сгради & Замъци', 'color': const Color(0xFFFF3D00), 'poly': '${300 + (i * 30)} Poly',
        'lib': libs3D[rng.nextInt(libs3D.length)], 'img': '', 'icon': Icons.castle,
      });
    }

    // 4. Генериране на 80+ 3D Космос & Совалки (NASA 3D)
    for (int i = 1; i <= 80; i++) {
      list.add({
        'name': 'Orbital Shuttle MK-$i', 'type': '3D Космос', 'media': '3D', 'shape': 'shuttle',
        'cat': '🚀 Космос & Sci-Fi', 'color': const Color(0xFF00B0FF), 'poly': '${4000 + (i * 120)} Poly',
        'lib': 'NASA 3D', 'img': '', 'icon': Icons.rocket_launch,
      });
    }

    // 5. Генериране на 100+ 2D Спрайтове
    for (int i = 1; i <= 100; i++) {
      list.add({
        'name': 'Pixel Sprite Hero $i', 'type': '2D Спрайтшит', 'media': '2D', 'shape': 'pixel',
        'cat': '🤖 Герои & Мехове', 'color': const Color(0xFFFFD600), 'poly': '32x32 Frames',
        'lib': i % 2 == 0 ? 'CraftPix' : 'OpenGameArt', 'img': '', 'icon': Icons.shield,
      });
    }

    // 6. Генериране на 100+ Audio SFX & Music
    for (int i = 1; i <= 100; i++) {
      bool isMusic = i % 3 == 0;
      list.add({
        'name': isMusic ? 'Epic Boss Theme $i' : 'Laser Blaster SFX $i',
        'type': isMusic ? 'Фонова Музика' : 'Звуков Ефект',
        'media': 'Audio', 'shape': 'sound', 'cat': isMusic ? '🌋 Лава & Неон' : '⚔️ Оръжия',
        'color': isMusic ? AppTheme.laserPink : AppTheme.sciFiCyan, 'poly': isMusic ? '2:30 min' : '0:02 sec',
        'lib': isMusic ? 'Incompetech' : 'FreeSound.org', 'img': '', 'icon': isMusic ? Icons.music_note : Icons.volume_up,
      });
    }

    return list;
  }

  // =========================================================================
  // 🔍 ИСТИНСКИ 3D PBR ИНСПЕКТОР В МАГАЗИНА
  // =========================================================================

  void _show3DInspectModal(Map<String, dynamic> asset) {
    double orbitAngle = 0.4;
    double pitchAngle = 0.35;
    bool showWireframe = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppTheme.sciFiCyan, width: 1.2),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(asset['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('Библиотека: ${asset['lib']} • ${asset['poly']}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close, color: Colors.grey, size: 20), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(color: Colors.white12),

                // РЕАЛЕН 3D PBR VIEWPORT
                GestureDetector(
                  onPanUpdate: (d) {
                    setModalState(() {
                      orbitAngle += d.delta.dx * 0.018;
                      pitchAngle = (pitchAngle - d.delta.dy * 0.015).clamp(0.1, 1.2);
                    });
                  },
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF090B14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: (asset['color'] as Color).withValues(alpha: 0.4)),
                      boxShadow: [
                        BoxShadow(color: (asset['color'] as Color).withValues(alpha: 0.2), blurRadius: 15),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: CustomPaint(
                            size: const Size(200, 200),
                            painter: Authentic3DModelViewerPainter(
                              yaw: orbitAngle,
                              pitch: pitchAngle,
                              shapeType: asset['shape'] as String? ?? 'chest',
                              baseColor: asset['color'] as Color,
                              showWireframe: showWireframe,
                            ),
                          ),
                        ),

                        // Wireframe бутон
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () => setModalState(() => showWireframe = !showWireframe),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: showWireframe ? AppTheme.laserPink : const Color(0xFF1E2235),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: showWireframe ? AppTheme.laserPink : Colors.white24),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.grid_3x3, size: 12, color: showWireframe ? Colors.white : Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('Wireframe', style: TextStyle(color: showWireframe ? Colors.white : Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 8,
                          left: 10,
                          child: Text('↔ Плъзни с пръст за 360° PBR въртене', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 9)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Формат', asset['media'] == '3D' ? 'GLB / GLTF' : 'PNG / Audio'),
                    _buildStatCard('Сложност', asset['poly'] as String),
                    _buildStatCard('Лиценз', 'CC0 / Отворен'),
                  ],
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: asset['color'] as Color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.download, color: Colors.black, size: 18),
                    label: Text(asset['media'] == '2D' ? 'ВКАРАЙ В 2D GODOT СТУДИО' : 'ВКАРАЙ В 3D FILAMENT СТУДИО', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                    onPressed: () {
                      Navigator.pop(context);
                      if (asset['media'] == '2D') {
                        widget.onInsertTo2D?.call();
                      } else {
                        widget.onInsertTo3D?.call();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Вкаран с реален облик: ${asset['name']}')));
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

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFF161928), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customModels = AutoRigService().customModels;
    List<Map<String, dynamic>> filteredList = [];

    if (_selectedMainType == '👑 Моите Модели') {
      filteredList = customModels.map((m) => {
        'name': m.name,
        'type': m.isAutoRigged ? '3D Модел (19-Joint Auto-Rig)' : '3D Модел',
        'media': '3D',
        'shape': 'humanoid',
        'cat': '🤖 Герои & Мехове',
        'color': m.baseColor,
        'poly': '${m.vertexCount} Poly',
        'lib': 'Local Device Storage',
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
        final matchesLib = _selectedLibrary == 'Всички' || a['lib'].toString().contains(_selectedLibrary);
        final matchesSearch = _searchQuery.isEmpty || a['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesType && matchesCat && matchesLib && matchesSearch;
      }).toList();
    }

    return Column(
      children: [
        // 1. Главен тип превключвател
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

        // 2. АКО Е ИЗБРАНО "22 БИБЛИОТЕКИ" - ПОКАЗВА ПЪЛНИЯ СПИСЪК НА БИБЛИОТЕКИТЕ С ЛИЦЕНЗИ
        if (_selectedMainType == '📚 22 Библиотеки')
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _freeLibrariesList.length,
              itemBuilder: (context, index) {
                final lib = _freeLibrariesList[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141724),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF242B40)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(color: AppTheme.sciFiCyan.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.source, color: AppTheme.sciFiCyan, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(lib['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFF00E676).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                  child: Text(lib['license'] as String, style: const TextStyle(color: Color(0xFF00E676), fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(lib['desc'] as String, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else ...[
          // Бутон за качване (ако сме в "Моите Модели") или търсачка
          if (_selectedMainType == '👑 Моите Модели')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: SizedBox(
                width: double.infinity,
                height: 38,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.sciFiCyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  icon: const Icon(Icons.file_upload, color: Colors.black, size: 18),
                  label: const Text('➕ КАЧИ НОВ 3D МОДЕЛ & AUTO-RIG', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                  onPressed: () {
                    ModelUploadModal.show(context, onModelRigged: (m) => setState(() {}));
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
                    hintText: 'Търси сред 500+ генерирани модела...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 11),
                    icon: Icon(Icons.search, size: 16, color: AppTheme.sciFiCyan),
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            ),

          // Филтър по библиотека
          if (_selectedMainType != '👑 Моите Модели')
            Container(
              height: 28,
              margin: const EdgeInsets.symmetric(vertical: 2),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _librariesFilter.length,
                itemBuilder: (context, index) {
                  final lib = _librariesFilter[index];
                  final isSel = lib == _selectedLibrary;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedLibrary = lib),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFF00E676) : const Color(0xFF161824),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSel ? const Color(0xFF00E676) : Colors.white12),
                      ),
                      child: Center(
                        child: Text(
                          lib,
                          style: TextStyle(color: isSel ? Colors.black : Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Подкатегории
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
                        borderRadius: BorderRadius.circular(12),
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

          // Грид с асети (над 500+ заредени)
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
                      border: Border.all(color: glow.withValues(alpha: 0.45)),
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

                          // Визуален образ на модела
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
                                    Center(child: Icon(asset['icon'] as IconData? ?? Icons.accessibility_new, size: 38, color: glow)),

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
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: glow, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                                icon: const Icon(Icons.remove_red_eye, size: 12, color: Colors.black),
                                label: const Text('ВИЖ 3D ОБЛИК', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 9)),
                                onPressed: () => _show3DInspectModal(asset),
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
      ],
    );
  }
}
