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
    {'name': 'Itch.io Free Assets', 'type': '2D & 3D Kits', 'license': 'CC0 / Free', 'desc': 'Инди колекции от създатели от цял свят.'},
    {'name': 'Game-Icons.net', 'type': 'Vector 2D Icons', 'license': 'CC-BY 3.0', 'desc': 'Над 4000 чисти векторни гейм и RPG икони.'},
    {'name': 'FreeSound.org', 'type': 'Audio & SFX', 'license': 'CC0 / CC-BY', 'desc': 'Стотици хиляди реални звукови ефекти и ембиент звуци.'},
    {'name': 'Incompetech', 'type': 'Music Soundtracks', 'license': 'CC-BY', 'desc': 'Легендарните гейм саундтраци на Kevin MacLeod.'},
    {'name': 'Bensound Free', 'type': 'Cinematic Music', 'license': 'Free License', 'desc': 'Кинематографична, екшън и рок фонова музика.'},
    {'name': 'Sonniss GDC Archive', 'type': 'Studio Sound FX', 'license': 'Royalty-Free GDC', 'desc': 'Десетки гигабайти професионално студийно гейм аудио.'},
    {'name': 'Poly Haven', 'type': 'PBR & HDRIs', 'license': 'CC0 Public Domain', 'desc': '100% безплатни фотореалистични PBR материали и небеса.'},
    {'name': 'AmbientCG', 'type': 'PBR Textures', 'license': 'CC0 Public Domain', 'desc': 'Хиляди сканирани текстури за камък, асфалт, лава и метал.'},
    {'name': 'GodotShaders', 'type': 'Shaders & VFX', 'license': 'CC0 / MIT', 'desc': 'Отворени шейдъри за лава, вода, мъгла, неон и разпад.'},
    {'name': 'Superpowers Packs', 'type': 'Retro 2D & 3D', 'license': 'CC0 Public Domain', 'desc': 'Ретро пакети за космически кораби, нинджи и сайд-скролъри.'},
    {'name': 'Kenney Audio', 'type': 'UI & Game SFX', 'license': 'CC0 Public Domain', 'desc': 'Звуци за скокове, лазери, бутони и експлозии.'},
    {'name': 'Lospec Archive', 'type': 'Pixel Palettes', 'license': 'CC0', 'desc': 'Пиксел арт ресурси и палитри за ретро игри.'},
    {'name': 'FreeGameAssets GUI', 'type': 'Game UI & HUD', 'license': 'Free License', 'desc': 'Животи, инвентари, бутони и диалогови прозорци.'},
  ];

  late List<Map<String, dynamic>> _catalog;

  @override
  void initState() {
    super.initState();
    _catalog = _buildCatalog();
  }

  static List<Map<String, dynamic>> _buildCatalog() {
    return [
      {
        'name': 'Кибер Самурай Y-Bot 3D',
        'type': '3D Герой (Rigged)',
        'media': '3D',
        'shape': 'humanoid',
        'cat': '🤖 Герои & Мехове',
        'color': const Color(0xFFD500F9),
        'poly': '4.2k Poly',
        'lib': 'Mixamo',
        'img': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=300&q=80',
        'icon': Icons.accessibility_new,
      },
      {
        'name': 'Неонов Болид GT Speed',
        'type': '3D Возило (Physics)',
        'media': '3D',
        'shape': 'vehicle',
        'cat': '🚗 Возила & Коли',
        'color': const Color(0xFF00E5FF),
        'poly': '2.6k Poly',
        'lib': 'Kenney.nl',
        'img': 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=300&q=80',
        'icon': Icons.directions_car,
      },
      {
        'name': 'Вулканичен Замък Крепост',
        'type': '3D Модулна Сграда',
        'media': '3D',
        'shape': 'castle',
        'cat': '🏰 Сгради & Замъци',
        'color': const Color(0xFFFF3D00),
        'poly': '3.1k Poly',
        'lib': 'Quaternius',
        'img': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=300&q=80',
        'icon': Icons.castle,
      },
      {
        'name': 'Плазмен Меч с Енергия',
        'type': '3D Оръжие FX',
        'media': '3D',
        'shape': 'sword',
        'cat': '⚔️ Оръжия',
        'color': const Color(0xFF00E676),
        'poly': '620 Poly',
        'lib': 'Poly Pizza',
        'img': 'https://images.unsplash.com/photo-1589241062272-c0a000072dfa?w=300&q=80',
        'icon': Icons.flash_on,
      },
      {
        'name': 'Орбитална Совалка X-1',
        'type': '3D Космически Кораб',
        'media': '3D',
        'shape': 'shuttle',
        'cat': '🚀 Космос & Sci-Fi',
        'color': const Color(0xFF00B0FF),
        'poly': '5.4k Poly',
        'lib': 'NASA 3D Resources',
        'img': 'https://images.unsplash.com/photo-1517976487588-34861614742f?w=300&q=80',
        'icon': Icons.rocket_launch,
      },
      {
        'name': 'Златен Сандък Проп',
        'type': '3D Проп',
        'media': '3D',
        'shape': 'chest',
        'cat': '📦 Пропове & Сандъци',
        'color': const Color(0xFFFFD600),
        'poly': '840 Poly',
        'lib': 'Kay Lousberg',
        'img': 'https://images.unsplash.com/photo-1512353087810-25dfcd100962?w=300&q=80',
        'icon': Icons.inventory_2,
      },
      {
        'name': 'Пиксел Рицар 2D',
        'type': '2D Герой Спрайт',
        'media': '2D',
        'shape': 'pixel',
        'cat': '🤖 Герои & Мехове',
        'color': const Color(0xFFFFD600),
        'poly': '32x32 Frames',
        'lib': 'CraftPix',
        'img': 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=300&q=80',
        'icon': Icons.shield,
      },
      {
        'name': 'Godot 4 Кибер Платформи',
        'type': '2D Tileset',
        'media': '2D',
        'shape': 'tile',
        'cat': '🏰 Сгради & Замъци',
        'color': const Color(0xFF00E676),
        'poly': '16x16 Tiles',
        'lib': 'Kenney.nl',
        'img': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=300&q=80',
        'icon': Icons.grid_on,
      },
      {
        'name': 'Cyberpunk Action OST',
        'type': 'HQ Музика',
        'media': 'Audio',
        'shape': 'sound',
        'cat': '🌋 Лава & Неон',
        'color': AppTheme.laserPink,
        'poly': '3:10 min • MP3',
        'lib': 'Incompetech',
        'img': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300&q=80',
        'icon': Icons.music_note,
      },
      {
        'name': 'Лазерен Бластер SFX',
        'type': 'Звуков Ефект',
        'media': 'Audio',
        'shape': 'sound',
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
                              ),
                              child: Text('Wireframe', style: TextStyle(color: showWireframe ? Colors.white : Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 10,
                          child: Text('↔ 360° PBR завъртане с пръст', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 9)),
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
                    style: ElevatedButton.styleFrom(backgroundColor: asset['color'] as Color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
        'type': m.isAutoRigged ? '3D Модел (Auto-Rigged)' : '3D Модел',
        'media': '3D',
        'shape': 'humanoid',
        'cat': '🤖 Герои & Мехове',
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
                  decoration: BoxDecoration(color: const Color(0xFF141724), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF242B40))),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: AppTheme.sciFiCyan.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.source, color: AppTheme.sciFiCyan, size: 18),
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
                    hintText: 'Търси в 22 библиотеки (самурай, болид, замък)...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 11),
                    icon: Icon(Icons.search, size: 16, color: AppTheme.sciFiCyan),
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            ),

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
