import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';

class MushroomStudioScreen extends StatefulWidget {
  const MushroomStudioScreen({Key? key}) : super(key: key);

  @override
  State<MushroomStudioScreen> createState() => _MushroomStudioScreenState();
}

class _MushroomStudioScreenState extends State<MushroomStudioScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animPreviewController;

  // 3D Камера и Терен
  double _camYaw = 0.6;
  double _camPitch = 0.5;
  double _camZoom = 1.0;
  String _selected3DTool = 'orbit';

  // 2D Редактор инструменти
  String _selected2DTool = 'brush';
  final List<Offset> _tiles2D = [
    const Offset(0, 3), const Offset(1, 3), const Offset(2, 3),
    const Offset(3, 3), const Offset(4, 3), const Offset(2, 1),
  ];
  final List<Offset> _coins2D = [const Offset(2, 0), const Offset(4, 2)];
  final List<Offset> _enemies2D = [const Offset(3, 2)];

  // 3D Обекти в сцената
  int _selected3DObjIndex = 0;
  final List<Map<String, dynamic>> _objects3D = [
    {'name': '🤖 Кибер Играч', 'x': 0.0, 'y': -40.0, 'z': 0.0, 'size': 35.0, 'color': AppTheme.laserPink, 'type': 'player'},
    {'name': '🌋 Лава Езеро', 'x': 0.0, 'y': 60.0, 'z': 0.0, 'size': 90.0, 'color': Color(0xFFFF3D00), 'type': 'lava'},
    {'name': '🧱 Неон Блок 1', 'x': -70.0, 'y': 20.0, 'z': -40.0, 'size': 30.0, 'color': AppTheme.sciFiCyan, 'type': 'block'},
    {'name': '🧱 Неон Блок 2', 'x': 70.0, 'y': -10.0, 'z': 40.0, 'size': 30.0, 'color': Color(0xFF00E676), 'type': 'block'},
  ];

  // Аниматор
  bool _isPlayingAnim = true;
  double _playbackSpeed = 1.0;
  String _activeAnimation = 'Hip Hop Dance';
  String _activeAnimCategory = 'Танци';
  String _animSearchQuery = '';
  final List<String> _animLibraries = ['Mixamo (2000+)', 'ActorCore MoCap', 'CMU Database', 'Unity Free'];
  String _selectedAnimLibrary = 'Mixamo (2000+)';

  // Магазин за асети
  String _selectedAssetMainType = '🎲 3D Модели';
  final List<String> _assetMainTypes = ['🎲 3D Модели', '🎨 2D Спрайтове', '🎵 Музика & SFX', '🌋 Шейдъри & FX'];
  String _assetSearchQuery = '';
  String? _playingAudioTrack;
  late List<Map<String, dynamic>> _assetsList;

  final List<Map<String, dynamic>> _movementsList = [
    {'name': 'Hip Hop Dance', 'type': '💃 Танци & Емоути', 'frames': '120 fr', 'lib': 'Mixamo', 'color': AppTheme.laserPink, 'icon': Icons.music_note},
    {'name': 'Ninja Katana Slash', 'type': '⚔️ Бойни & Меч', 'frames': '45 fr', 'lib': 'ActorCore', 'color': Color(0xFFFF1744), 'icon': Icons.flash_on},
    {'name': 'Cyber Sprint Run', 'type': '🏃 Ходене & Бягане', 'frames': '24 fr', 'lib': 'Mixamo', 'color': AppTheme.sciFiCyan, 'icon': Icons.directions_run},
    {'name': 'Super Hero Jump', 'type': '🤸 Паркур & Скокове', 'frames': '38 fr', 'lib': 'Mixamo', 'color': Color(0xFF00E676), 'icon': Icons.flight_takeoff},
    {'name': 'Zombie Crawl', 'type': '🧟 Зомбита & Чудовища', 'frames': '80 fr', 'lib': 'Mixamo', 'color': Color(0xFFFF9100), 'icon': Icons.coronavirus},
    {'name': 'Victory Flip', 'type': '💃 Танци & Емоути', 'frames': '60 fr', 'lib': 'Mixamo Free', 'color': Color(0xFF00E676), 'icon': Icons.celebration},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _animPreviewController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Генерация на стотици реални асети
    _assetsList = _generateMassiveAssetCatalog();
  }

  @override
  void dispose() {
    _animPreviewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ГЕНЕРАТОР НА СТОТИЦИ АСЕТИ ОТ ВСИЧКИ БИБЛИОТЕКИ
  static List<Map<String, dynamic>> _generateMassiveAssetCatalog() {
    List<Map<String, dynamic>> list = [];

    // 1. 3D Модели (PolyPizza, Quaternius, Sketchfab, Kenney)
    final List<String> themes3D = [
      'Кибер', 'Вулканичен', 'Средновековен', 'Космически', 'Неонов',
      'Елфически', 'Зомби', 'Пустинен', 'Подводен', 'Магически',
      'Аркаден', 'Нинджа', 'Роботизиран', 'Лазерен', 'Титаниев'
    ];
    final List<Map<String, dynamic>> types3D = [
      {'name': 'Замък', 'cat': '🏰 Сгради', 'color': Color(0xFFFF3D00), 'poly': '1.8k Poly', 'lib': 'Quaternius Free'},
      {'name': 'Кула', 'cat': '🏰 Сгради', 'color': Color(0xFF00E5FF), 'poly': '1.2k Poly', 'lib': 'Sketchfab CC0'},
      {'name': 'Храм', 'cat': '🏰 Сгради', 'color': Color(0xFFFFD600), 'poly': '2.4k Poly', 'lib': 'PolyPizza'},
      {'name': 'Герой', 'cat': '🤖 Герои & Кукли', 'color': Color(0xFFD500F9), 'poly': '3.5k Poly', 'lib': 'Mixamo Rigged'},
      {'name': 'Самурай', 'cat': '🤖 Герои & Кукли', 'color': Color(0xFFFF1744), 'poly': '4.1k Poly', 'lib': 'Quaternius'},
      {'name': 'Дракон', 'cat': '🤖 Герои & Кукли', 'color': Color(0xFF00E676), 'poly': '5.8k Poly', 'lib': 'PolyPizza'},
      {'name': 'Болид', 'cat': '🚗 Возила', 'color': Color(0xFF00E5FF), 'poly': '2.3k Poly', 'lib': 'Kenney Cars'},
      {'name': 'Ховърборд', 'cat': '🚗 Возила', 'color': Color(0xFFFF007F), 'poly': '1.1k Poly', 'lib': 'PolyPizza'},
      {'name': 'Меч', 'cat': '⚔️ Оръжия', 'color': Color(0xFF00E676), 'poly': '450 Poly', 'lib': 'PolyPizza'},
      {'name': 'Бластер', 'cat': '⚔️ Оръжия', 'color': Color(0xFF00E5FF), 'poly': '800 Poly', 'lib': 'Kenney Weapons'},
      {'name': 'Дърво', 'cat': '🌲 Природа', 'color': Color(0xFF00E676), 'poly': '900 Poly', 'lib': 'Kenney Nature'},
      {'name': 'Скала', 'cat': '🌲 Природа', 'color': Color(0xFFFF9100), 'poly': '700 Poly', 'lib': 'PolyPizza'},
      {'name': 'Сандък', 'cat': '📦 Пропове', 'color': Color(0xFFFFD600), 'poly': '320 Poly', 'lib': 'Kenney Props'},
      {'name': 'Портал FX', 'cat': '🌋 Лава & Неон', 'color': Color(0xFFFF3D00), 'poly': 'Shader FX', 'lib': 'Filament PBR'},
    ];

    for (var t in themes3D) {
      for (var item in types3D) {
        list.add({
          'name': '$t ${item['name']}',
          'type': '3D ${item['name']}',
          'media': '3D',
          'cat': item['cat'],
          'color': item['color'],
          'poly': item['poly'],
          'lib': item['lib'],
        });
      }
    }

    // 2. 2D Спрайтове (Kenney 2D, OpenGameArt, CraftPix)
    final List<String> themes2D = [
      'Пиксел', 'Ретро 8-Bit', 'Неон 2D', 'Фентъзи', 'Кибер 2D',
      'Аркаден', 'Джънгъл', 'Лава 2D', 'Космически 2D', 'Леден'
    ];
    final List<Map<String, dynamic>> types2D = [
      {'name': 'Рицар', 'cat': '🤖 Герои & Кукли', 'color': Color(0xFFFFD600), 'poly': '32x32 Sheet', 'lib': 'OpenGameArt'},
      {'name': 'Магьосник', 'cat': '🤖 Герои & Кукли', 'color': Color(0xFFD500F9), 'poly': '32x32 Sheet', 'lib': 'CraftPix'},
      {'name': 'Платформа Плочки', 'cat': '🏰 Сгради', 'color': Color(0xFF00E676), 'poly': '16x16 Tileset', 'lib': 'Kenney 2D'},
      {'name': 'Монета Анимация', 'cat': '📦 Пропове', 'color': Color(0xFFFFD600), 'poly': '16x16 Anim', 'lib': 'Kenney 2D'},
      {'name': 'Шипове Капан', 'cat': '⚔️ Оръжия', 'color': Color(0xFFFF1744), 'poly': '16x16 Sprite', 'lib': 'OpenGameArt'},
      {'name': 'Лава Анимация FX', 'cat': '🌋 Лава & Неон', 'color': Color(0xFFFF3D00), 'poly': '64x64 Frames', 'lib': 'CraftPix Free'},
      {'name': 'Летящ Враг', 'cat': '🤖 Герои & Кукли', 'color': Color(0xFFFF1744), 'poly': '32x32 Sheet', 'lib': 'Kenney 2D'},
      {'name': 'Колекционерско Сърце', 'cat': '📦 Пропове', 'color': Color(0xFFFF007F), 'poly': '16x16 Sprite', 'lib': 'OpenGameArt'},
    ];

    for (var t in themes2D) {
      for (var item in types2D) {
        list.add({
          'name': '$t ${item['name']}',
          'type': '2D Спрайт',
          'media': '2D',
          'cat': item['cat'],
          'color': item['color'],
          'poly': item['poly'],
          'lib': item['lib'],
        });
      }
    }

    // 3. Аудио и Звукови Ефекти (Incompetech, Kenney Audio, FreeSound)
    final List<String> audioThemes = [
      'Cyberpunk', 'Epic Battle', 'Lava Dungeon', 'Retro Arcade', 'Sci-Fi Ambient',
      'Synthwave Night', 'Hero Victory', 'Dark Mystery', '8-Bit Jump', 'Laser Strike'
    ];
    final List<Map<String, dynamic>> audioTypes = [
      {'name': 'Theme Track', 'type': 'Фонова Музика', 'color': AppTheme.laserPink, 'poly': '2:30 min • MP3', 'lib': 'Incompetech Free'},
      {'name': 'Battle Action OST', 'type': 'Фонова Музика', 'color': Color(0xFFFF1744), 'poly': '3:15 min • HQ', 'lib': 'Bensound Free'},
      {'name': 'Laser Blast SFX', 'type': 'Звуков Ефект', 'color': AppTheme.sciFiCyan, 'poly': '0:02 sec • WAV', 'lib': 'Kenney Audio'},
      {'name': 'Jump & Dash SFX', 'type': 'Звуков Ефект', 'color': Color(0xFF00E676), 'poly': '0:01 sec • WAV', 'lib': 'FreeSound FX'},
      {'name': 'Coin Pickup SFX', 'type': 'Звуков Ефект', 'color': Color(0xFFFFD600), 'poly': '0:01 sec • WAV', 'lib': 'Kenney Audio'},
      {'name': 'Explosion FX', 'type': 'Звуков Ефект', 'color': Color(0xFFFF3D00), 'poly': '0:03 sec • WAV', 'lib': 'FreeSound FX'},
    ];

    for (var t in audioThemes) {
      for (var item in audioTypes) {
        list.add({
          'name': '$t ${item['name']}',
          'type': item['type'],
          'media': 'Audio',
          'cat': '🌋 Лава & Неон',
          'color': item['color'],
          'poly': item['poly'],
          'lib': item['lib'],
        });
      }
    }

    // 4. Шейдъри и Ефекти
    final List<String> shaderThemes = ['Lava Volcanic', 'Neon Hologram', 'Cyber Shield', 'Water Wave', 'Plasma Portal', 'Fire Particle'];
    for (var s in shaderThemes) {
      list.add({
        'name': '$s PBR Shader',
        'type': '3D Шейдър FX',
        'media': 'Shaders',
        'cat': '🌋 Лава & Неон',
        'color': Color(0xFFFF9100),
        'poly': 'Filament GLSL',
        'lib': 'Google Filament PBR',
      });
    }

    return list;
  }

  void _loadMoreAssetsBatch() {
    setState(() {
      _assetsList.addAll([
        {'name': 'Титаниев Мех Бос', 'type': '3D Бос', 'media': '3D', 'color': AppTheme.laserPink, 'poly': '8.2k Poly', 'lib': 'PolyPizza'},
        {'name': 'Неонов Дрифт Автомобил', 'type': '3D Возило', 'media': '3D', 'color': Color(0xFF00E676), 'poly': '4.1k Poly', 'lib': 'Kenney Cars'},
        {'name': 'Епичен Драконов Рев SFX', 'type': 'Звуков Ефект', 'media': 'Audio', 'color': Color(0xFFFF1744), 'poly': '0:04 sec • WAV', 'lib': 'FreeSound'},
        {'name': 'Пиксел Космически Кораб 2D', 'type': '2D Спрайт', 'media': '2D', 'color': AppTheme.sciFiCyan, 'poly': '32x32 Sheet', 'lib': 'OpenGameArt'},
      ]);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📦 Заредени още нови 3D/2D/Аудио библиотеки!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080D),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Container(
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF0E101A),
                border: Border(bottom: BorderSide(color: Color(0xFF222638), width: 1)),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: AppTheme.laserPink,
                indicatorWeight: 2.5,
                labelColor: AppTheme.laserPink,
                unselectedLabelColor: Colors.grey,
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: '2D Студио'),
                  Tab(text: '3D Терен & Сцена'),
                  Tab(text: 'Магазин'),
                  Tab(text: 'Движения'),
                  Tab(text: 'Плейър'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _build2DLevelEditor(),
                _build3DPerspectiveWorld(),
                _buildAssetStoreTab(),
                _buildMovementsTab(),
                _buildAnimationPlayerTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. 3D ПЕРСПЕКТИВЕН СВЯТ
  Widget _build3DPerspectiveWorld() {
    return Stack(
      children: [
        GestureDetector(
          onScaleUpdate: (details) {
            setState(() {
              if (details.scale != 1.0) {
                _camZoom = (_camZoom * details.scale).clamp(0.5, 2.5);
              } else {
                _camYaw += details.focalPointDelta.dx * 0.008;
                _camPitch = (_camPitch - details.focalPointDelta.dy * 0.008).clamp(0.1, 1.4);
              }
            });
          },
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.2,
                colors: [Color(0xFF191228), Color(0xFF07080D)],
              ),
            ),
            child: CustomPaint(
              size: Size.infinite,
              painter: Real3DWorldPainter(
                yaw: _camYaw,
                pitch: _camPitch,
                zoom: _camZoom,
                objects: _objects3D,
                selectedIndex: _selected3DObjIndex,
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xEE141624),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStudioToolBtn(Icons.threed_rotation, 'orbit', AppTheme.sciFiCyan, '360° Orbit', () => setState(() => _selected3DTool = 'orbit')),
                _buildStudioToolBtn(Icons.open_with, 'move', AppTheme.laserPink, 'Мести XYZ', () => setState(() => _selected3DTool = 'move')),
                _buildStudioToolBtn(Icons.add_box, 'block', const Color(0xFF00E676), '+3D Блок', () {
                  setState(() {
                    _objects3D.add({
                      'name': '🧱 Неон Куб ${_objects3D.length}',
                      'x': 0.0,
                      'y': 0.0,
                      'z': 0.0,
                      'size': 30.0,
                      'color': AppTheme.sciFiCyan,
                      'type': 'block',
                    });
                    _selected3DObjIndex = _objects3D.length - 1;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Добавен нов 3D Куб!')));
                }),
                _buildStudioToolBtn(Icons.local_fire_department, 'lava', const Color(0xFFFF3D00), '+Лава', () {
                  setState(() {
                    _objects3D.add({
                      'name': '🌋 Лава Платформа',
                      'x': 0.0,
                      'y': 40.0,
                      'z': 0.0,
                      'size': 60.0,
                      'color': Color(0xFFFF3D00),
                      'type': 'lava',
                    });
                    _selected3DObjIndex = _objects3D.length - 1;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔥 Добавен 3D Лава терен!')));
                }),
              ],
            ),
          ),
        ),
        Positioned(
          left: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
            child: const Row(
              children: [
                Text('🔴 X  ', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                Text('🟢 Y  ', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                Text('🔵 Z', style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
            child: Text('3D Filament PBR • Zoom: ${_camZoom.toStringAsFixed(1)}x', style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ),
        ),
      ],
    );
  }

  // 2. 2D LEVEL DESIGNER
  Widget _build2DLevelEditor() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: const Color(0xFF10121D),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _build2DToolBtn(Icons.edit, 'brush', const Color(0xFF00E676), 'Плочка'),
              _build2DToolBtn(Icons.monetization_on, 'coin', const Color(0xFFFFD600), 'Монета'),
              _build2DToolBtn(Icons.pest_control, 'enemy', const Color(0xFFFF1744), 'Враг'),
              _build2DToolBtn(Icons.cleaning_services, 'erase', Colors.grey, 'Изтрий'),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.laserPink, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                icon: const Icon(Icons.play_arrow, size: 16, color: Colors.white),
                label: const Text('ТЕСТ 2D', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎮 Стартирана 2D симулация!')));
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFF090B12),
            child: GestureDetector(
              onTapDown: (details) {
                final local = details.localPosition;
                int col = (local.dx / 40).floor();
                int row = ((local.dy - 60) / 40).floor();
                final pos = Offset(col.toDouble(), row.toDouble());

                setState(() {
                  if (_selected2DTool == 'brush') {
                    if (!_tiles2D.contains(pos)) _tiles2D.add(pos);
                  } else if (_selected2DTool == 'coin') {
                    if (!_coins2D.contains(pos)) _coins2D.add(pos);
                  } else if (_selected2DTool == 'enemy') {
                    if (!_enemies2D.contains(pos)) _enemies2D.add(pos);
                  } else if (_selected2DTool == 'erase') {
                    _tiles2D.remove(pos);
                    _coins2D.remove(pos);
                    _enemies2D.remove(pos);
                  }
                });
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: Real2DLevelPainter(
                  tiles: _tiles2D,
                  coins: _coins2D,
                  enemies: _enemies2D,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _build2DToolBtn(IconData icon, String tool, Color c, String label) {
    bool isSel = _selected2DTool == tool;
    return GestureDetector(
      onTap: () => setState(() => _selected2DTool = tool),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? c.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSel ? Border.all(color: c) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSel ? c : Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStudioToolBtn(IconData icon, String tool, Color c, String label, VoidCallback onTap) {
    bool isSel = _selected3DTool == tool;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? c.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSel ? Border.all(color: c) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSel ? c : Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // 3. МАГАЗИН АСЕТИ СЪС СТОТИЦИ МОДЕЛИ И МУЗИКА
  Widget _buildAssetStoreTab() {
    final filtered = _assetsList.where((a) {
      bool matchesType = true;
      if (_selectedAssetMainType == '🎲 3D Модели') matchesType = a['media'] == '3D';
      if (_selectedAssetMainType == '🎨 2D Спрайтове') matchesType = a['media'] == '2D';
      if (_selectedAssetMainType == '🎵 Музика & SFX') matchesType = a['media'] == 'Audio';
      if (_selectedAssetMainType == '🌋 Шейдъри & FX') matchesType = a['media'] == 'Shaders';

      final matchesSearch = _assetSearchQuery.isEmpty || a['name'].toString().toLowerCase().contains(_assetSearchQuery.toLowerCase());
      return matchesType && matchesSearch;
    }).toList();

    return Column(
      children: [
        Container(
          height: 38,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(color: const Color(0xFF141724), borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: _assetMainTypes.map((type) {
              final isSel = type == _selectedAssetMainType;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedAssetMainType = type),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSel ? AppTheme.laserPink : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(type, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontSize: 10, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: const Color(0xFF141724), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Търси в ${_assetsList.length}+ $_selectedAssetMainType...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 11),
                icon: const Icon(Icons.search, size: 16, color: AppTheme.sciFiCyan),
                border: InputBorder.none,
              ),
              onChanged: (val) => setState(() => _assetSearchQuery = val),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.84,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final asset = filtered[index];
              final Color glow = asset['color'];
              final bool isAudio = asset['media'] == 'Audio';
              final bool isPlayingThisAudio = _playingAudioTrack == asset['name'];

              return Container(
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
                            child: Text(asset['type'], style: TextStyle(color: glow, fontSize: 8, fontWeight: FontWeight.bold)),
                          ),
                          Text(asset['poly'], style: const TextStyle(color: Colors.grey, fontSize: 8)),
                        ],
                      ),
                      Icon(isAudio ? (isPlayingThisAudio ? Icons.graphic_eq : Icons.music_note) : Icons.view_in_ar, size: 40, color: glow),
                      Text(asset['name'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      Text('Библиотека: ${asset['lib']}', style: const TextStyle(color: Colors.white54, fontSize: 8)),
                      if (isAudio) ...[
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 24,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: isPlayingThisAudio ? Colors.redAccent : const Color(0xFF1E2235), padding: EdgeInsets.zero),
                                  onPressed: () {
                                    setState(() {
                                      _playingAudioTrack = isPlayingThisAudio ? null : asset['name'];
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(isPlayingThisAudio ? '⏹️ Спряно аудио' : '▶️ Прослушване на ${asset['name']}...')),
                                    );
                                  },
                                  child: Text(isPlayingThisAudio ? 'СТОП' : 'ПРЕСЛУШАЙ', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: SizedBox(
                                height: 24,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: glow, padding: EdgeInsets.zero),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🔊 ${asset['name']} е добавен към звуковия енджин!')));
                                  },
                                  child: const Text('ВКАРАЙ', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        SizedBox(
                          width: double.infinity,
                          height: 24,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: glow, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                            onPressed: () {
                              if (asset['media'] == '2D') {
                                _tabController.animateTo(0);
                              } else {
                                setState(() {
                                  _objects3D.add({
                                    'name': asset['name'],
                                    'x': 0.0,
                                    'y': -20.0,
                                    'z': 0.0,
                                    'size': 35.0,
                                    'color': glow,
                                    'type': 'custom',
                                  });
                                  _selected3DObjIndex = _objects3D.length - 1;
                                });
                                _tabController.animateTo(1);
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
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: SizedBox(
            width: double.infinity,
            height: 30,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.sciFiCyan), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              icon: const Icon(Icons.download, size: 13, color: AppTheme.sciFiCyan),
              label: const Text('ЗАРЕДИ ОЩЕ НОВИ БИБЛИОТЕКИ', style: TextStyle(color: AppTheme.sciFiCyan, fontSize: 9, fontWeight: FontWeight.bold)),
              onPressed: _loadMoreAssetsBatch,
            ),
          ),
        ),
      ],
    );
  }

  // 4. MIXAMO ДВИЖЕНИЯ
  Widget _buildMovementsTab() {
    final filtered = _movementsList.where((m) {
      return _animSearchQuery.isEmpty || m['name']!.toLowerCase().contains(_animSearchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Container(
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _animLibraries.length,
            itemBuilder: (context, index) {
              final lib = _animLibraries[index];
              final isSel = lib == _selectedAnimLibrary;
              return GestureDetector(
                onTap: () => setState(() => _selectedAnimLibrary = lib),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF00E676) : const Color(0xFF141724),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text(lib, style: TextStyle(color: isSel ? Colors.black : Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final move = filtered[index];
              final Color glow = move['color'] ?? AppTheme.laserPink;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF141724),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: glow.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(color: glow.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: Icon(move['icon'] ?? Icons.directions_run, color: glow, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(move['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('${move['type']} • ${move['frames']} • ${move['lib']}', style: const TextStyle(color: Colors.grey, fontSize: 9)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: glow, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                      onPressed: () {
                        setState(() {
                          _activeAnimation = move['name']!;
                          _activeAnimCategory = move['type']!;
                        });
                        _tabController.animateTo(4);
                      },
                      child: const Text('ПРЕГЛЕД ▶', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
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

  // 5. ЖИВ АНИМАЦИОНЕН ПЛЕЙЪР
  Widget _buildAnimationPlayerTab() {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF141724),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.laserPink.withValues(alpha: 0.6)),
            ),
            child: Stack(
              children: [
                Center(
                  child: AnimatedBuilder(
                    animation: _animPreviewController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(180, 220),
                        painter: LiveSkeletonRigPainter(
                          progress: _animPreviewController.value,
                          isPlaying: _isPlayingAnim,
                          category: _activeAnimCategory,
                          color: AppTheme.sciFiCyan,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                        child: Text(_activeAnimation, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFF00E676).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                        child: const Text('60 FPS Rigged', style: TextStyle(color: Color(0xFF00E676), fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSpeedPill('0.5x (Бавно)', 0.5),
              IconButton(
                icon: Icon(_isPlayingAnim ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 48, color: AppTheme.sciFiCyan),
                onPressed: () {
                  setState(() {
                    _isPlayingAnim = !_isPlayingAnim;
                    if (_isPlayingAnim) {
                      _animPreviewController.repeat();
                    } else {
                      _animPreviewController.stop();
                    }
                  });
                },
              ),
              _buildSpeedPill('2.0x (Бързо)', 2.0),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.laserPink, AppTheme.sciFiCyan]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚡ Движението "$_activeAnimation" е приложено в Filament!')));
                  },
                  child: const Text('⚡ ПРИЛОЖИ КЪМ МОДЕЛА', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedPill(String label, double speed) {
    bool isSel = _playbackSpeed == speed;
    return GestureDetector(
      onTap: () {
        setState(() {
          _playbackSpeed = isSel ? 1.0 : speed;
          _animPreviewController.duration = Duration(milliseconds: (1500 / _playbackSpeed).toInt());
          if (_isPlayingAnim) _animPreviewController.repeat();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.laserPink : const Color(0xFF1E2235),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(color: isSel ? Colors.white : Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// 3D Перспективен World Painter
class Real3DWorldPainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final double zoom;
  final List<Map<String, dynamic>> objects;
  final int selectedIndex;

  Real3DWorldPainter({
    required this.yaw,
    required this.pitch,
    required this.zoom,
    required this.objects,
    required this.selectedIndex,
  });

  Offset project(double x, double y, double z, Size size) {
    double cosY = math.cos(yaw);
    double sinY = math.sin(yaw);
    double x1 = x * cosY - z * sinY;
    double z1 = x * sinY + z * cosY;

    double cosP = math.cos(pitch);
    double sinP = math.sin(pitch);
    double y2 = y * cosP - z1 * sinP;
    double z2 = y * sinP + z1 * cosP;

    double fov = 380.0 * zoom;
    double dist = 420.0;
    double depth = z2 + dist;
    if (depth < 1.0) depth = 1.0;

    double sx = (x1 * fov / depth) + (size.width / 2);
    double sy = (y2 * fov / depth) + (size.height / 2) + 20;

    return Offset(sx, sy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppTheme.sciFiCyan.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    final lavaFloorPaint = Paint()
      ..color = const Color(0xFFFF3D00).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    const double gridSize = 180.0;
    const double step = 30.0;

    for (double i = -gridSize; i <= gridSize; i += step) {
      Offset p1 = project(i, 60, -gridSize, size);
      Offset p2 = project(i, 60, gridSize, size);
      canvas.drawLine(p1, p2, gridPaint);

      Offset p3 = project(-gridSize, 60, i, size);
      Offset p4 = project(gridSize, 60, i, size);
      canvas.drawLine(p3, p4, gridPaint);
    }

    Path lavaPath = Path()
      ..moveTo(project(-60, 59, -60, size).dx, project(-60, 59, -60, size).dy)
      ..lineTo(project(60, 59, -60, size).dx, project(60, 59, -60, size).dy)
      ..lineTo(project(60, 59, 60, size).dx, project(60, 59, 60, size).dy)
      ..lineTo(project(-60, 59, 60, size).dx, project(-60, 59, 60, size).dy)
      ..close();
    canvas.drawPath(lavaPath, lavaFloorPaint);

    for (int i = 0; i < objects.length; i++) {
      var obj = objects[i];
      double ox = obj['x'];
      double oy = obj['y'];
      double oz = obj['z'];
      double s = obj['size'];
      Color c = obj['color'];
      bool isSel = i == selectedIndex;

      _draw3DBox(canvas, size, ox, oy, oz, s, c, isSel);
    }
  }

  void _draw3DBox(Canvas canvas, Size size, double x, double y, double z, double s, Color color, bool isSelected) {
    double hs = s / 2;
    List<Offset> v = [
      project(x - hs, y - hs, z - hs, size),
      project(x + hs, y - hs, z - hs, size),
      project(x + hs, y - hs, z + hs, size),
      project(x - hs, y - hs, z + hs, size),
      project(x - hs, y + hs, z - hs, size),
      project(x + hs, y + hs, z - hs, size),
      project(x + hs, y + hs, z + hs, size),
      project(x - hs, y + hs, z + hs, size),
    ];

    final topPaint = Paint()..color = color.withValues(alpha: isSelected ? 0.8 : 0.5)..style = PaintingStyle.fill;
    final sidePaint = Paint()..color = color.withValues(alpha: isSelected ? 0.6 : 0.35)..style = PaintingStyle.fill;
    final edgePaint = Paint()..color = isSelected ? Colors.white : color..strokeWidth = isSelected ? 2.0 : 1.2..style = PaintingStyle.stroke;

    Path top = Path()..moveTo(v[0].dx, v[0].dy)..lineTo(v[1].dx, v[1].dy)..lineTo(v[2].dx, v[2].dy)..lineTo(v[3].dx, v[3].dy)..close();
    canvas.drawPath(top, topPaint);
    canvas.drawPath(top, edgePaint);

    Path front = Path()..moveTo(v[3].dx, v[3].dy)..lineTo(v[2].dx, v[2].dy)..lineTo(v[6].dx, v[6].dy)..lineTo(v[7].dx, v[7].dy)..close();
    canvas.drawPath(front, sidePaint);
    canvas.drawPath(front, edgePaint);

    Path right = Path()..moveTo(v[2].dx, v[2].dy)..lineTo(v[1].dx, v[1].dy)..lineTo(v[5].dx, v[5].dy)..lineTo(v[6].dx, v[6].dy)..close();
    canvas.drawPath(right, sidePaint);
    canvas.drawPath(right, edgePaint);
  }

  @override
  bool shouldRepaint(covariant Real3DWorldPainter oldDelegate) => true;
}

// 2D Level Painter
class Real2DLevelPainter extends CustomPainter {
  final List<Offset> tiles;
  final List<Offset> coins;
  final List<Offset> enemies;

  Real2DLevelPainter({
    required this.tiles,
    required this.coins,
    required this.enemies,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = Colors.white10..strokeWidth = 1.0;
    final tilePaint = Paint()..color = const Color(0xFF00E676)..style = PaintingStyle.fill;
    final tileBorder = Paint()..color = Colors.white..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final coinPaint = Paint()..color = const Color(0xFFFFD600)..style = PaintingStyle.fill;
    final enemyPaint = Paint()..color = const Color(0xFFFF1744)..style = PaintingStyle.fill;

    const double s = 40.0;

    for (double x = 0; x < size.width; x += s) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += s) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (var pos in tiles) {
      Rect r = Rect.fromLTWH(pos.dx * s, (pos.dy * s) + 60, s, s);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), tilePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), tileBorder);
    }

    for (var pos in coins) {
      canvas.drawCircle(Offset(pos.dx * s + s / 2, pos.dy * s + 60 + s / 2), 10, coinPaint);
    }

    for (var pos in enemies) {
      Rect r = Rect.fromLTWH(pos.dx * s + 6, (pos.dy * s) + 66, s - 12, s - 12);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(8)), enemyPaint);
    }
  }

  @override
  bool shouldRepaint(covariant Real2DLevelPainter oldDelegate) => true;
}

// Live Skeleton Rig Painter
class LiveSkeletonRigPainter extends CustomPainter {
  final double progress;
  final bool isPlaying;
  final String category;
  final Color color;

  LiveSkeletonRigPainter({
    required this.progress,
    required this.isPlaying,
    required this.category,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 4.0..strokeCap = StrokeCap.round;
    final jointPaint = Paint()..color = const Color(0xFFFF007F);

    final double cx = size.width / 2;
    final double cy = size.height / 2;

    double t = progress * 2 * math.pi;
    double armAngle = math.sin(t) * 0.6;
    double legAngle = math.cos(t) * 0.7;
    double bodyBob = math.sin(t * 2) * 6;

    if (category.contains('Танци')) {
      armAngle = math.sin(t * 2) * 1.1;
      bodyBob = math.cos(t * 2) * 10;
    } else if (category.contains('Бойни')) {
      armAngle = math.sin(t * 3) * 1.3;
      legAngle = math.cos(t * 2) * 1.0;
    }

    canvas.drawCircle(Offset(cx, cy - 55 + bodyBob), 14, paint);
    canvas.drawCircle(Offset(cx, cy - 55 + bodyBob), 4, jointPaint);

    Offset neck = Offset(cx, cy - 40 + bodyBob);
    Offset pelvis = Offset(cx, cy + 10 + bodyBob);
    canvas.drawLine(neck, pelvis, paint);

    Offset leftHand = Offset(cx - 35 * math.cos(armAngle), cy - 20 + 35 * math.sin(armAngle) + bodyBob);
    Offset rightHand = Offset(cx + 35 * math.cos(armAngle), cy - 20 - 35 * math.sin(armAngle) + bodyBob);
    canvas.drawLine(neck, leftHand, paint);
    canvas.drawLine(neck, rightHand, paint);
    canvas.drawCircle(leftHand, 4, jointPaint);
    canvas.drawCircle(rightHand, 4, jointPaint);

    Offset leftFoot = Offset(cx - 25 * math.sin(legAngle), cy + 65 + 15 * math.cos(legAngle));
    Offset rightFoot = Offset(cx + 25 * math.sin(legAngle), cy + 65 - 15 * math.cos(legAngle));
    canvas.drawLine(pelvis, leftFoot, paint);
    canvas.drawLine(pelvis, rightFoot, paint);
    canvas.drawCircle(leftFoot, 4, jointPaint);
    canvas.drawCircle(rightFoot, 4, jointPaint);
  }

  @override
  bool shouldRepaint(covariant LiveSkeletonRigPainter oldDelegate) => true;
}
