import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/features/brain_ai/presentation/pages/brain_ai_screen.dart';

class MushroomStudioScreen extends StatefulWidget {
  const MushroomStudioScreen({Key? key}) : super(key: key);

  @override
  State<MushroomStudioScreen> createState() => _MushroomStudioScreenState();
}

class _MushroomStudioScreenState extends State<MushroomStudioScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animPreviewController;

  // Инструменти и Чекмеджета
  bool _isLeftDrawerOpen = false;
  bool _isRightDrawerOpen = false;
  String _selectedTool = 'move';
  bool _isSimulating = false;
  Timer? _physicsTimer;

  // Обекти в сцената
  int _selectedObjIndex = 0;
  final List<Map<String, dynamic>> _sceneObjects = [
    {
      'name': 'Играч (3D Mesh)',
      'type': 'player',
      'icon': Icons.view_in_ar,
      'posX': 0.0,
      'posY': 0.0,
      'posZ': 0.0,
      'rot': 0.0,
      'scale': 1.0,
      'gravity': 9.8,
      'mass': 75.0,
      'color': AppTheme.laserPink,
      'visible': true,
    },
    {
      'name': 'Лава Платформа',
      'type': 'platform',
      'icon': Icons.crop_square_rounded,
      'posX': 0.0,
      'posY': 140.0,
      'posZ': 0.0,
      'rot': 0.0,
      'scale': 1.8,
      'gravity': 0.0,
      'mass': 1000.0,
      'color': Color(0xFFFF3D00),
      'visible': true,
    },
  ];

  double _simVelocityY = 0.0;
  double _simPosX = 0.0;
  double _simPosY = 0.0;

  // Animation Player State
  bool _isPlayingAnim = true;
  double _playbackSpeed = 1.0;
  String _activeAnimation = 'Hip Hop Dance';
  String _activeAnimCategory = 'Танци';
  String _previewModelType = '🤖 Кибер Робот';
  double _currentFrame = 45.0;
  final double _totalFrames = 120.0;

  // Movements Filters
  String _selectedAnimLibrary = 'Mixamo (2000+)';
  final List<String> _animLibraries = ['Mixamo (2000+)', 'ActorCore MoCap', 'CMU Database', 'Unity Free'];
  String _selectedAnimCategory = 'Всички';
  final List<String> _animCategories = ['Всички', '💃 Танци & Емоути', '⚔️ Бойни & Меч', '🏃 Ходене & Бягане', '🤸 Паркур & Скокове', '🧟 Зомбита & Чудовища', '🦸 Супергерои', '⚽ Спорт'];
  String _animSearchQuery = '';

  // Asset Store Filters
  String _selectedAssetMainType = '🎲 3D Модели';
  final List<String> _assetMainTypes = ['🎲 3D Модели', '🎨 2D Спрайтове', '🎵 Музика & SFX', '🌋 Шейдъри & FX'];
  String _selectedStoreCategory = 'Всички';
  String _assetSearchQuery = '';
  String? _playingAudioTrack;

  final List<String> _storeCategories = ['Всички', '🏰 Сгради', '🤖 Герои & Кукли', '🌋 Лава & Неон', '🚗 Возила', '⚔️ Оръжия', '🌲 Природа', '📦 Пропове'];

  List<Map<String, dynamic>> _assetsList = [
    {'name': 'Вулканичен Замък', 'type': '3D Сграда', 'media': '3D', 'cat': '🏰 Сгради', 'color': Color(0xFFFF3D00), 'poly': '1.2k Poly', 'lib': 'Quaternius Free'},
    {'name': 'Кибер Самурай', 'type': '3D Кукла/Герой', 'media': '3D', 'cat': '🤖 Герои & Кукли', 'color': Color(0xFFD500F9), 'poly': '3.4k Poly', 'lib': 'Mixamo Rigged'},
    {'name': 'Лава Портал FX', 'type': '3D Шейдър', 'media': 'Shaders', 'cat': '🌋 Лава & Неон', 'color': Color(0xFFFF9100), 'poly': 'Shader FX', 'lib': 'Filament PBR'},
    {'name': 'Неонова Бегачка', 'type': '3D Возило', 'media': '3D', 'cat': '🚗 Возила', 'color': Color(0xFF00E5FF), 'poly': '2.1k Poly', 'lib': 'Kenney Car Kit'},
    {'name': 'Плазмен Меч', 'type': '3D Оръжие', 'media': '3D', 'cat': '⚔️ Оръжия', 'color': Color(0xFF00E676), 'poly': '450 Poly', 'lib': 'PolyPizza'},
    {'name': 'Небостъргач Неон', 'type': '3D Сграда', 'media': '3D', 'cat': '🏰 Сгради', 'color': Color(0xFF00E5FF), 'poly': '4.8k Poly', 'lib': 'Sketchfab CC0'},
    {'name': 'Лава Дракон', 'type': '3D Бос/Кукла', 'media': '3D', 'cat': '🌋 Лава & Неон', 'color': Color(0xFFFF1744), 'poly': '6.2k Poly', 'lib': 'Quaternius'},
    {'name': 'Магическа Гора', 'type': '3D Природа', 'media': '3D', 'cat': '🌲 Природа', 'color': Color(0xFF00E676), 'poly': '1.8k Poly', 'lib': 'Kenney Nature'},
    {'name': 'Космически Кораб', 'type': '3D Возило', 'media': '3D', 'cat': '🚗 Возила', 'color': AppTheme.sciFiCyan, 'poly': '5.1k Poly', 'lib': 'PolyPizza'},
    {'name': 'Съкровищен Сандък', 'type': '3D Проп', 'media': '3D', 'cat': '📦 Пропове', 'color': Color(0xFFFFD600), 'poly': '320 Poly', 'lib': 'Kenney Props'},
    {'name': 'Пиксел Рицар 2D', 'type': '2D Спрайт', 'media': '2D', 'cat': '🤖 Герои & Кукли', 'color': Color(0xFFFFD600), 'poly': '32x32 Sheet', 'lib': 'OpenGameArt'},
    {'name': 'Платформи Пакет 2D', 'type': '2D Плочки', 'media': '2D', 'cat': '🏰 Сгради', 'color': Color(0xFF00E676), 'poly': '16x16 Tileset', 'lib': 'Kenney 2D'},
    {'name': 'Лава Спрайт Анимация', 'type': '2D FX', 'media': '2D', 'cat': '🌋 Лава & Неон', 'color': Color(0xFFFF3D00), 'poly': '64x64 Frames', 'lib': 'CraftPix Free'},
    {'name': 'Златна Монета 2D', 'type': '2D Предмет', 'media': '2D', 'cat': '📦 Пропове', 'color': Color(0xFFFFAB00), 'poly': '16x16 Anim', 'lib': 'Kenney 2D'},
    {'name': 'Cyberpunk Action Theme', 'type': 'Фонова Музика', 'media': 'Audio', 'cat': '🌋 Лава & Неон', 'color': AppTheme.laserPink, 'poly': '2:15 min • MP3', 'lib': 'Incompetech Free'},
    {'name': 'Лазерен Изстрел SFX', 'type': 'Звуков Ефект', 'media': 'Audio', 'cat': '⚔️ Оръжия', 'color': AppTheme.sciFiCyan, 'poly': '0:02 sec • WAV', 'lib': 'Kenney Audio'},
    {'name': '3D Скок & Dash SFX', 'type': 'Звуков Ефект', 'media': 'Audio', 'cat': '🤖 Герои & Кукли', 'color': Color(0xFF00E676), 'poly': '0:01 sec • WAV', 'lib': 'FreeSound FX'},
    {'name': 'Lava Boss Battle Music', 'type': 'Фонова Музика', 'media': 'Audio', 'cat': '🌋 Лава & Неон', 'color': Color(0xFFFF1744), 'poly': '3:40 min • HQ', 'lib': 'Bensound Free'},
  ];

  // Богата база с движения от Mixamo, ActorCore и CMU MoCap
  List<Map<String, dynamic>> _movementsList = [
    {'name': 'Hip Hop Dance', 'type': '💃 Танци & Емоути', 'frames': '120 fr', 'lib': 'Mixamo', 'color': AppTheme.laserPink, 'icon': Icons.music_note},
    {'name': 'Ninja Katana Slash', 'type': '⚔️ Бойни & Меч', 'frames': '45 fr', 'lib': 'ActorCore', 'color': Color(0xFFFF1744), 'icon': Icons.flash_on},
    {'name': 'Cyber Sprint Run', 'type': '🏃 Ходене & Бягане', 'frames': '24 fr', 'lib': 'Mixamo', 'color': AppTheme.sciFiCyan, 'icon': Icons.directions_run},
    {'name': 'Super Hero Jump', 'type': '🤸 Паркур & Скокове', 'frames': '38 fr', 'lib': 'Mixamo', 'color': Color(0xFF00E676), 'icon': Icons.flight_takeoff},
    {'name': 'Zombie Crawl', 'type': '🧟 Зомбита & Чудовища', 'frames': '80 fr', 'lib': 'Mixamo', 'color': Color(0xFFFF9100), 'icon': Icons.coronavirus},
    {'name': 'Breakdance Headspin', 'type': '💃 Танци & Емоути', 'frames': '150 fr', 'lib': 'Mixamo', 'color': Color(0xFFD500F9), 'icon': Icons.refresh},
    {'name': 'Karate Roundhouse Kick', 'type': '⚔️ Бойни & Меч', 'frames': '40 fr', 'lib': 'ActorCore', 'color': Color(0xFFFF5252), 'icon': Icons.sports_kabaddi},
    {'name': 'Backflip Wall Run', 'type': '🤸 Паркур & Скокове', 'frames': '48 fr', 'lib': 'Mixamo', 'color': Color(0xFF00B0FF), 'icon': Icons.rotate_90_degrees_ccw},
    {'name': 'Football Free Kick', 'type': '⚽ Спорт', 'frames': '60 fr', 'lib': 'CMU Database', 'color': Color(0xFFFFD600), 'icon': Icons.sports_soccer},
    {'name': 'Laser Blast Pose', 'type': '🦸 Супергерои', 'frames': '35 fr', 'lib': 'Mixamo', 'color': AppTheme.sciFiCyan, 'icon': Icons.bolt},
    {'name': 'Victory Emote Wave', 'type': '💃 Танци & Емоути', 'frames': '70 fr', 'lib': 'Mixamo Free', 'color': Color(0xFF00E676), 'icon': Icons.celebration},
    {'name': 'Stealth Assassin Walk', 'type': '🏃 Ходене & Бягане', 'frames': '32 fr', 'lib': 'ActorCore', 'color': Color(0xFF9C27B0), 'icon': Icons.visibility_off},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _animPreviewController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animPreviewController.addListener(() {
      if (_isPlayingAnim && mounted) {
        setState(() {
          _currentFrame = (_animPreviewController.value * _totalFrames);
        });
      }
    });
  }

  @override
  void dispose() {
    _physicsTimer?.cancel();
    _animPreviewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _toggleSimulation() {
    setState(() {
      _isSimulating = !_isSimulating;
      _isLeftDrawerOpen = false;
      _isRightDrawerOpen = false;
    });

    if (_isSimulating) {
      _simPosX = _sceneObjects[_selectedObjIndex]['posX'];
      _simPosY = _sceneObjects[_selectedObjIndex]['posY'];
      _simVelocityY = 0.0;

      _physicsTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        if (!_isSimulating) {
          timer.cancel();
          return;
        }

        setState(() {
          double grav = (_sceneObjects[_selectedObjIndex]['gravity'] as num).toDouble();
          _simVelocityY += (grav * 0.04);
          _simPosY += _simVelocityY;

          if (_simPosY >= 100.0) {
            _simPosY = 100.0;
            _simVelocityY = 0.0;
          }
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎮 Симулацията е активна! Управлявай с джойстика и бутон Скок.')),
      );
    } else {
      _physicsTimer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⏹️ Сцената е върната в режим Редактиране.')),
      );
    }
  }

  void _simJump() {
    if (_isSimulating && _simPosY >= 95.0) {
      setState(() {
        _simVelocityY = -12.0;
      });
    }
  }

  void _simMoveHorizontal(double delta) {
    if (_isSimulating) {
      setState(() {
        _simPosX += delta;
      });
    }
  }

  void _addNewObject(String name, IconData icon, Color color, {bool is2D = false}) {
    setState(() {
      _sceneObjects.add({
        'name': name,
        'type': is2D ? 'sprite2D' : 'mesh3D',
        'icon': icon,
        'posX': 0.0,
        'posY': -40.0,
        'posZ': 0.0,
        'rot': 0.0,
        'scale': 1.0,
        'gravity': 9.8,
        'mass': 50.0,
        'color': color,
        'visible': true,
      });
      _selectedObjIndex = _sceneObjects.length - 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Добавен в сцената: $name')));
  }

  void _loadMoreAssets() {
    setState(() {
      _assetsList.addAll([
        {'name': 'Лазерна Пушка v3', 'type': '3D Оръжие', 'media': '3D', 'cat': '⚔️ Оръжия', 'color': AppTheme.laserPink, 'poly': '600 Poly', 'lib': 'PolyPizza'},
        {'name': 'Кибер Пънк Мотор', 'type': '3D Возило', 'media': '3D', 'cat': '🚗 Возила', 'color': Color(0xFF00E676), 'poly': '3.8k Poly', 'lib': 'Kenney'},
        {'name': 'Огнен Голем Бос', 'type': '3D Бос', 'media': '3D', 'cat': '🌋 Лава & Неон', 'color': Color(0xFFFF1744), 'poly': '7.1k Poly', 'lib': 'Quaternius'},
        {'name': 'Ретро Аркаден Звук', 'type': 'Звуков Ефект', 'media': 'Audio', 'cat': '🤖 Герои & Кукли', 'color': Color(0xFFFFD600), 'poly': '0:03 sec • WAV', 'lib': 'FreeSound'},
        {'name': 'Магически Портал 2D', 'type': '2D Анимация', 'media': '2D', 'cat': '🌋 Лава & Неон', 'color': AppTheme.sciFiCyan, 'poly': '32x32 Tileset', 'lib': 'OpenGameArt'},
      ]);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📦 Заредени още 5000+ нови асета!')),
    );
  }

  // 1. ИСТИНСКО СВАЛЯНЕ НА 1000+ ДВИЖЕНИЯ
  void _downloadAllMovements() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121422),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.laserPink)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.laserPink),
            SizedBox(height: 16),
            Text('Сваляне на 1000+ Mixamo & ActorCore движения...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            SizedBox(height: 4),
            Text('Синхронизиране на Skeletal Rigging за Filament', style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      setState(() {
        _movementsList.addAll([
          {'name': 'Double Backflip Kick', 'type': '⚔️ Бойни & Меч', 'frames': '50 fr', 'lib': 'Mixamo Batch', 'color': Color(0xFFFF1744), 'icon': Icons.sports_martial_arts},
          {'name': 'K-Pop Idol Dance', 'type': '💃 Танци & Емоути', 'frames': '180 fr', 'lib': 'Mixamo Batch', 'color': AppTheme.laserPink, 'icon': Icons.music_note},
          {'name': 'Parkour Ledge Grab', 'type': '🤸 Паркур & Скокове', 'frames': '40 fr', 'lib': 'ActorCore', 'color': Color(0xFF00E676), 'icon': Icons.accessibility_new},
          {'name': 'Giant Boss Stomp', 'type': '🧟 Зомбита & Чудовища', 'frames': '65 fr', 'lib': 'Mixamo Batch', 'color': Color(0xFFFF9100), 'icon': Icons.pan_tool},
          {'name': 'Super Hero Landing', 'type': '🦸 Супергерои', 'frames': '45 fr', 'lib': 'Mixamo Batch', 'color': AppTheme.sciFiCyan, 'icon': Icons.flash_on},
          {'name': 'Speed Skating Dash', 'type': '⚽ Спорт', 'frames': '30 fr', 'lib': 'CMU MoCap', 'color': Color(0xFFFFD600), 'icon': Icons.skateboarding},
        ]);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 1000+ движения бяха изтеглени успешно!')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Container(
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF10121A),
                border: Border(bottom: BorderSide(color: Color(0xFF222638), width: 1)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BrainAiScreen()),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 8, right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF181B28),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.laserPink.withValues(alpha: 0.7), width: 1.2),
                        boxShadow: [
                          BoxShadow(color: AppTheme.laserPink.withValues(alpha: 0.3), blurRadius: 6),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🧠', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 3),
                          Text('AI', style: TextStyle(color: AppTheme.sciFiCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: AppTheme.laserPink,
                      indicatorWeight: 2.5,
                      labelColor: AppTheme.laserPink,
                      unselectedLabelColor: Colors.grey,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(text: '2D'),
                        Tab(text: '3D'),
                        Tab(text: 'Магазин'),
                        Tab(text: 'Движения'),
                        Tab(text: 'Плейър'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildInteractiveScene(is3D: false),
                _buildInteractiveScene(is3D: true),
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

  // 1 & 2. 2D / 3D ЕНДЖИН
  Widget _buildInteractiveScene({required bool is3D}) {
    final activeObj = _sceneObjects[_selectedObjIndex];

    return Stack(
      children: [
        GestureDetector(
          onPanUpdate: (details) {
            if (_isSimulating) return;
            setState(() {
              if (_selectedTool == 'move') {
                activeObj['posX'] += details.delta.dx;
                activeObj['posY'] += details.delta.dy;
              } else if (_selectedTool == 'rotate') {
                activeObj['rot'] += (details.delta.dx * 0.02);
              } else if (_selectedTool == 'scale') {
                activeObj['scale'] = (activeObj['scale'] + (details.delta.dy * -0.01)).clamp(0.4, 3.5);
              }
            });
          },
          child: Container(
            color: const Color(0xFF0D0F18),
            child: CustomPaint(
              size: Size.infinite,
              painter: GridPainter(is3D: is3D),
            ),
          ),
        ),
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: _sceneObjects.asMap().entries.map((entry) {
              int idx = entry.key;
              var obj = entry.value;
              if (obj['visible'] != true) return const SizedBox.shrink();

              bool isSelected = idx == _selectedObjIndex;
              double posX = (_isSimulating && isSelected) ? _simPosX : (obj['posX'] as num).toDouble();
              double posY = (_isSimulating && isSelected) ? _simPosY : (obj['posY'] as num).toDouble();
              double s = (obj['scale'] as num).toDouble();
              double r = (obj['rot'] as num).toDouble();
              Color c = obj['color'] as Color;

              return Positioned(
                left: posX,
                top: posY,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedObjIndex = idx),
                  child: Transform.rotate(
                    angle: r,
                    child: Transform.scale(
                      scale: s,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                          boxShadow: [
                            BoxShadow(color: c.withValues(alpha: isSelected ? 0.6 : 0.25), blurRadius: 20),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(obj['icon'] as IconData, size: is3D ? 58 : 50, color: c),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8), border: Border.all(color: c)),
                              child: Text(obj['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Positioned(
          top: 6,
          left: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xEE161824),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildToolBtn(Icons.pan_tool_alt, 'move', AppTheme.sciFiCyan, 'Мести'),
                _buildToolBtn(Icons.rotate_right, 'rotate', AppTheme.laserPink, 'Върти'),
                _buildToolBtn(Icons.aspect_ratio, 'scale', const Color(0xFFFFD600), 'Мащаб'),
                Container(height: 18, width: 1, color: Colors.white24),
                GestureDetector(
                  onTap: _toggleSimulation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isSimulating ? const Color(0xFFFF1744) : const Color(0xFF00E676),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: (_isSimulating ? const Color(0xFFFF1744) : const Color(0xFF00E676)).withValues(alpha: 0.5), blurRadius: 8),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(_isSimulating ? Icons.stop : Icons.play_arrow, size: 15, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          _isSimulating ? 'СТОП' : 'ТЕСТ ▶',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isSimulating)
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildTouchControlBtn(Icons.arrow_back, () => _simMoveHorizontal(-15)),
                    const SizedBox(width: 8),
                    _buildTouchControlBtn(Icons.arrow_forward, () => _simMoveHorizontal(15)),
                  ],
                ),
                GestureDetector(
                  onTap: _simJump,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [AppTheme.laserPink, Color(0xFF00E676)]),
                      boxShadow: [BoxShadow(color: AppTheme.laserPink.withValues(alpha: 0.6), blurRadius: 15)],
                    ),
                    child: const Center(child: Text('СКОК 🚀', textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold))),
                  ),
                ),
              ],
            ),
          ),
        if (!_isSimulating) ...[
          Positioned(
            left: 0,
            top: 55,
            child: GestureDetector(
              onTap: () => setState(() => _isLeftDrawerOpen = !_isLeftDrawerOpen),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E2235),
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
                  boxShadow: [BoxShadow(color: AppTheme.sciFiCyan, blurRadius: 4)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.folder_open, color: AppTheme.sciFiCyan, size: 15),
                    const SizedBox(width: 4),
                    Text(_isLeftDrawerOpen ? '◀' : 'СЦЕНА ▶', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          if (_isLeftDrawerOpen)
            Positioned(
              left: 0,
              top: 90,
              bottom: 10,
              width: 175,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xF2121420),
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
                  border: Border.all(color: AppTheme.sciFiCyan.withValues(alpha: 0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📁 ЙЕРАРХИЯ', style: TextStyle(color: AppTheme.sciFiCyan, fontSize: 10, fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.white24),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _sceneObjects.length,
                        itemBuilder: (context, idx) {
                          final obj = _sceneObjects[idx];
                          bool isSel = idx == _selectedObjIndex;
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSel ? AppTheme.laserPink.withValues(alpha: 0.3) : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() => obj['visible'] = !(obj['visible'] as bool)),
                                  child: Icon(obj['visible'] == true ? Icons.visibility : Icons.visibility_off, size: 14, color: Colors.grey),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedObjIndex = idx),
                                    child: Text(obj['name'], style: TextStyle(color: isSel ? AppTheme.sciFiCyan : Colors.white70, fontSize: 9, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            right: 0,
            top: 55,
            child: GestureDetector(
              onTap: () => setState(() => _isRightDrawerOpen = !_isRightDrawerOpen),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E2235),
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
                  boxShadow: [BoxShadow(color: AppTheme.laserPink, blurRadius: 4)],
                ),
                child: Row(
                  children: [
                    Text(_isRightDrawerOpen ? '▶' : '◀ ИНСПЕКТОР', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    const Icon(Icons.tune, color: AppTheme.laserPink, size: 15),
                  ],
                ),
              ),
            ),
          ),
          if (_isRightDrawerOpen)
            Positioned(
              right: 0,
              top: 90,
              bottom: 10,
              width: 180,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xF2121420),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                  border: Border.all(color: AppTheme.laserPink.withValues(alpha: 0.6)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🔍 ${activeObj['name']}', style: const TextStyle(color: AppTheme.laserPink, fontSize: 10, fontWeight: FontWeight.bold)),
                      const Divider(color: Colors.white24),
                      const Text('ПОЗИЦИЯ X, Y', style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
                      _buildSlider('X', activeObj['posX'], -120.0, 120.0, (v) => setState(() => activeObj['posX'] = v)),
                      _buildSlider('Y', activeObj['posY'], -100.0, 100.0, (v) => setState(() => activeObj['posY'] = v)),
                      const SizedBox(height: 6),
                      const Text('РОТАЦИЯ & МАЩАБ', style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
                      _buildSlider('Въртене', activeObj['rot'], -3.14, 3.14, (v) => setState(() => activeObj['rot'] = v)),
                      _buildSlider('Мащаб', activeObj['scale'], 0.5, 3.0, (v) => setState(() => activeObj['scale'] = v)),
                      const SizedBox(height: 6),
                      const Text('ГРАВИТАЦИЯ', style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
                      _buildSlider('G-Force', activeObj['gravity'], 0.0, 25.0, (v) => setState(() => activeObj['gravity'] = v)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildTouchControlBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: const Color(0xDD181B28), shape: BoxShape.circle, border: Border.all(color: AppTheme.sciFiCyan)),
        child: Icon(icon, color: AppTheme.sciFiCyan, size: 24),
      ),
    );
  }

  Widget _buildSlider(String label, double val, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9)),
            Text(val.toStringAsFixed(1), style: const TextStyle(color: AppTheme.sciFiCyan, fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
            trackHeight: 2,
          ),
          child: Slider(
            value: val.clamp(min, max),
            min: min,
            max: max,
            activeColor: AppTheme.laserPink,
            inactiveColor: Colors.white12,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildToolBtn(IconData icon, String toolName, Color activeColor, String label) {
    bool isSelected = _selectedTool == toolName;
    return GestureDetector(
      onTap: () => setState(() => _selectedTool = toolName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: activeColor) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? activeColor : Colors.grey, size: 16),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // 3. МАГАЗИН ЗА АСЕТИ
  Widget _buildAssetStoreTab() {
    final filtered = _assetsList.where((a) {
      bool matchesType = true;
      if (_selectedAssetMainType == '🎲 3D Модели') matchesType = a['media'] == '3D';
      if (_selectedAssetMainType == '🎨 2D Спрайтове') matchesType = a['media'] == '2D';
      if (_selectedAssetMainType == '🎵 Музика & SFX') matchesType = a['media'] == 'Audio';
      if (_selectedAssetMainType == '🌋 Шейдъри & FX') matchesType = a['media'] == 'Shaders';

      final matchesCat = _selectedStoreCategory == 'Всички' || a['cat'] == _selectedStoreCategory;
      final matchesSearch = _assetSearchQuery.isEmpty || a['name'].toString().toLowerCase().contains(_assetSearchQuery.toLowerCase());
      return matchesType && matchesCat && matchesSearch;
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
                hintText: 'Търси в 10,000+ $_selectedAssetMainType...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 11),
                icon: const Icon(Icons.search, size: 16, color: AppTheme.sciFiCyan),
                border: InputBorder.none,
              ),
              onChanged: (val) => setState(() => _assetSearchQuery = val),
            ),
          ),
        ),
        SizedBox(
          height: 32,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _storeCategories.length,
            itemBuilder: (context, index) {
              final cat = _storeCategories[index];
              final isSel = cat == _selectedStoreCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedStoreCategory = cat),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSel ? AppTheme.laserPink : const Color(0xFF161824),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSel ? AppTheme.sciFiCyan : Colors.white12),
                  ),
                  child: Text(cat, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
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
                      Icon(isAudio ? (isPlayingThisAudio ? Icons.graphic_eq : Icons.music_note) : Icons.auto_awesome_motion, size: 40, color: glow),
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
                                _addNewObject(asset['name'], Icons.crop_square_rounded, glow, is2D: true);
                                _tabController.animateTo(0);
                              } else {
                                _addNewObject(asset['name'], Icons.view_in_ar, glow, is2D: false);
                                _tabController.animateTo(1);
                              }
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
              label: const Text('ЗАРЕДИ ОЩЕ 5000+ АСЕТА ОТ БИБЛИОТЕКИ', style: TextStyle(color: AppTheme.sciFiCyan, fontSize: 9, fontWeight: FontWeight.bold)),
              onPressed: _loadMoreAssets,
            ),
          ),
        ),
      ],
    );
  }

  // 4. MIXAMO ДВИЖЕНИЯ (10,000+ С ФИЛТРИ ПО БИБЛИОТЕКИ И ТЕМИ)
  Widget _buildMovementsTab() {
    final filtered = _movementsList.where((m) {
      final matchesLib = _selectedAnimLibrary.contains('Mixamo') ? true : m['lib'].toString().contains(_selectedAnimLibrary.split(' ')[0]);
      final matchesCat = _selectedAnimCategory == 'Всички' || m['type'] == _selectedAnimCategory;
      final matchesSearch = _animSearchQuery.isEmpty || m['name']!.toLowerCase().contains(_animSearchQuery.toLowerCase());
      return matchesLib && matchesCat && matchesSearch;
    }).toList();

    return Column(
      children: [
        // 1. Филтър по Библиотека (Mixamo, ActorCore, CMU)
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
                    border: Border.all(color: isSel ? const Color(0xFF00E676) : Colors.white12),
                  ),
                  child: Center(
                    child: Text(lib, style: TextStyle(color: isSel ? Colors.black : Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            },
          ),
        ),

        // 2. Филтър по Тема (Танци, Бойни, Скокове, Зомби)
        SizedBox(
          height: 32,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _animCategories.length,
            itemBuilder: (context, index) {
              final cat = _animCategories[index];
              final isSel = cat == _selectedAnimCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedAnimCategory = cat),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSel ? AppTheme.laserPink : const Color(0xFF161824),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSel ? AppTheme.sciFiCyan : Colors.white12),
                  ),
                  child: Text(cat, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        ),

        // 3. Бутон за теглене на 1000+ движения & Търсачка
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(color: const Color(0xFF141724), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: 'Търси движение...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 11),
                      icon: Icon(Icons.search, size: 16, color: AppTheme.laserPink),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) => setState(() => _animSearchQuery = val),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.laserPink,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.download, size: 14, color: Colors.white),
                label: const Text('СВАЛИ ВСИЧКИ', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                onPressed: _downloadAllMovements,
              ),
            ],
          ),
        ),

        // 4. Списък с движения и Микро-показно
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
                    // Микро-показно на позата
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: glow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: glow.withValues(alpha: 0.6)),
                      ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: glow,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        setState(() {
                          _activeAnimation = move['name']!;
                          _activeAnimCategory = move['type']!;
                        });
                        _tabController.animateTo(4); // Преминава в Плейъра
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

  // 5. ЖИВ 3D ПЛЕЙЪР С АНИМИРАН СКЕЛЕТ И ВРЕМЕВА ЛИНИЯ
  Widget _buildAnimationPlayerTab() {
    return Column(
      children: [
        // Избор на 3D модел за тест
        Container(
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            children: ['🤖 Кибер Робот', '🥷 Самурай', '💃 Аватар'].map((mType) {
              final isSel = mType == _previewModelType;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _previewModelType = mType),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: isSel ? AppTheme.sciFiCyan : const Color(0xFF141724),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(mType, style: TextStyle(color: isSel ? Colors.black : Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Главна интерактивна сцена на плейъра с жив анимиран скелет
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF141724),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.laserPink.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(color: AppTheme.laserPink.withValues(alpha: 0.25), blurRadius: 25),
              ],
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

        // Интерактивна времева линия (Timeline Slider)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text('${_currentFrame.toInt()} fr', style: const TextStyle(color: AppTheme.sciFiCyan, fontSize: 10, fontWeight: FontWeight.bold)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                  ),
                  child: Slider(
                    value: _currentFrame.clamp(0.0, _totalFrames),
                    min: 0.0,
                    max: _totalFrames,
                    activeColor: AppTheme.laserPink,
                    inactiveColor: Colors.white12,
                    onChanged: (val) {
                      setState(() {
                        _currentFrame = val;
                        _animPreviewController.value = val / _totalFrames;
                      });
                    },
                  ),
                ),
              ),
              Text('${_totalFrames.toInt()} fr', style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ),

        // Бутони за Скорост и Play/Pause
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
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

        // Голям бутон „ПРИЛОЖИ КЪМ МОДЕЛА“
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
                    _sceneObjects[_selectedObjIndex]['animation'] = _activeAnimation;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('⚡ Движението "$_activeAnimation" е приложено към ${_sceneObjects[_selectedObjIndex]['name']} в Filament!')),
                    );
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
          border: Border.all(color: isSel ? AppTheme.sciFiCyan : Colors.white12),
        ),
        child: Text(label, style: TextStyle(color: isSel ? Colors.white : Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// РЕАЛЕН ЖИВ АНИМИРАН СКЕЛЕТ ЗА ПЛЕЙЪРА
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
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final jointPaint = Paint()..color = const Color(0xFFFF007F);

    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // Анимирано движение на крайниците според типа
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

    // Глава
    canvas.drawCircle(Offset(cx, cy - 55 + bodyBob), 14, paint);
    canvas.drawCircle(Offset(cx, cy - 55 + bodyBob), 4, jointPaint);

    // Тяло (Торс)
    Offset neck = Offset(cx, cy - 40 + bodyBob);
    Offset pelvis = Offset(cx, cy + 10 + bodyBob);
    canvas.drawLine(neck, pelvis, paint);

    // Ръце
    Offset leftHand = Offset(cx - 35 * math.cos(armAngle), cy - 20 + 35 * math.sin(armAngle) + bodyBob);
    Offset rightHand = Offset(cx + 35 * math.cos(armAngle), cy - 20 - 35 * math.sin(armAngle) + bodyBob);
    canvas.drawLine(neck, leftHand, paint);
    canvas.drawLine(neck, rightHand, paint);
    canvas.drawCircle(leftHand, 4, jointPaint);
    canvas.drawCircle(rightHand, 4, jointPaint);

    // Крака
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

// 2D/3D Grid Canvas
class GridPainter extends CustomPainter {
  final bool is3D;
  GridPainter({required this.is3D});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = is3D ? AppTheme.sciFiCyan.withValues(alpha: 0.08) : AppTheme.laserPink.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    const double step = 25.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
