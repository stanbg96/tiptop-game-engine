import 'package:flutter/material.dart';

class MushroomStudioScreen extends StatefulWidget {
  const MushroomStudioScreen({Key? key}) : super(key: key);

  @override
  State<MushroomStudioScreen> createState() => _MushroomStudioScreenState();
}

class _MushroomStudioScreenState extends State<MushroomStudioScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Drawers & Tool States
  bool _isLeftDrawerOpen = false;
  bool _isRightDrawerOpen = false;
  String _selectedTool = 'move'; // move, rotate, scale
  bool _isPlayingSimulation = false;
  String _selectedObject = 'Игpaч (3D Mesh)';

  // Animation Player State
  bool _isPlayingAnim = true;
  double _playbackSpeed = 1.0;
  String _activeAnimation = '🎁 Hip Hop Dance (Mixamo)';

  // Asset Store Filters
  String _selectedStoreCategory = 'Всички';
  final List<String> _storeCategories = ['Всички', '🏰 Сгради', '🤖 Кукли & Герои', '🌋 Лава & Неон', '🚗 Возила', '⚔️ Оръжия'];

  final List<Map<String, dynamic>> _assetsList = [
    {'name': 'Вулканичен Замък', 'type': '3D Сграда', 'cat': '🏰 Сгради', 'color': Color(0xFFFF3D00), 'poly': '1.2k Poly', 'lib': 'Quaternius Free'},
    {'name': 'Кибер Самурай', 'type': '3D Кукла/Герой', 'cat': '🤖 Кукли & Герои', 'color': Color(0xFFD500F9), 'poly': '3.4k Poly', 'lib': 'Mixamo Rigged'},
    {'name': 'Лава Портал FX', 'type': '3D Шейдър', 'cat': '🌋 Лава & Неон', 'color': Color(0xFFFF9100), 'poly': 'Shader FX', 'lib': 'Filament PBR'},
    {'name': 'Неонова Бегачка', 'type': '3D Возило', 'cat': '🚗 Возила', 'color': Color(0xFF00E5FF), 'poly': '2.1k Poly', 'lib': 'Kenney Car Kit'},
    {'name': 'Плазмен Меч', 'type': '3D Оръжие', 'cat': '⚔️ Оръжия', 'color': Color(0xFF00E676), 'poly': '450 Poly', 'lib': 'PolyPizza'},
    {'name': 'Пиксел Рицар', 'type': '2D Спрайт', 'cat': '🤖 Кукли & Герои', 'color': Color(0xFFFFD600), 'poly': '32x32 Sheet', 'lib': 'OpenGameArt'},
    {'name': 'Небостъргач Неон', 'type': '3D Сграда', 'cat': '🏰 Сгради', 'color': Color(0xFF00E5FF), 'poly': '4.8k Poly', 'lib': 'Sketchfab CC0'},
    {'name': 'Лава Дракон', 'type': '3D Бос/Кукла', 'cat': '🌋 Лава & Неон', 'color': Color(0xFFFF1744), 'poly': '6.2k Poly', 'lib': 'Quaternius'},
  ];

  final List<Map<String, String>> _movementsList = [
    {'name': 'Hip Hop Dance', 'type': 'Танци', 'frames': '120 frames', 'tag': 'Mixamo Pack'},
    {'name': 'Ninja Katana Slash', 'type': 'Бойни', 'frames': '45 frames', 'tag': 'ActorCore'},
    {'name': 'Cyber Sprint Run', 'type': 'Ходене & Бягане', 'frames': '24 frames', 'tag': 'Mixamo'},
    {'name': 'Super Hero Jump', 'type': 'Скокове', 'frames': '38 frames', 'tag': 'MotionCapture'},
    {'name': 'Zombie Crawl', 'type': 'Реакции', 'frames': '80 frames', 'tag': 'Mixamo'},
    {'name': 'Victory Flip', 'type': 'Танци', 'frames': '60 frames', 'tag': 'Mixamo Free'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10121A),
        elevation: 0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🍄 ', style: TextStyle(fontSize: 20)),
            Text('TipTop Studio', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17)),
          ],
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.purpleAccent,
          indicatorWeight: 3,
          labelColor: Colors.purpleAccent,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.grid_view, size: 18), text: '2D Студио'),
            Tab(icon: Icon(Icons.view_in_ar, size: 18), text: '3D Студио'),
            Tab(icon: Icon(Icons.shopping_bag_outlined, size: 18), text: 'Магазин Асети'),
            Tab(icon: Icon(Icons.accessibility_new, size: 18), text: 'Движения'),
            Tab(icon: Icon(Icons.play_circle_outline, size: 18), text: 'Плейър'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildSceneEditor(is3D: false),
          _buildSceneEditor(is3D: true),
          _buildAssetStoreTab(),
          _buildMovementsTab(),
          _buildAnimationPlayerTab(),
        ],
      ),
    );
  }

  // 1 & 2. 2D and 3D SCENE EDITOR WITH MAGICAL DRAWERS
  Widget _buildSceneEditor({required bool is3D}) {
    return Stack(
      children: [
        // Canvas Background Viewport
        Container(
          color: const Color(0xFF0D0F18),
          child: Stack(
            children: [
              // Grid Pattern Simulation
              CustomPaint(
                size: Size.infinite,
                painter: GridPainter(is3D: is3D),
              ),
              // Viewport Center Object Display
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: is3D
                              ? [Colors.cyanAccent.withValues(alpha: 0.4), Colors.transparent]
                              : [Colors.purpleAccent.withValues(alpha: 0.4), Colors.transparent],
                        ),
                      ),
                      child: Icon(
                        is3D ? Icons.view_in_ar : Icons.crop_square_rounded,
                        size: 55,
                        color: is3D ? Colors.cyanAccent : Colors.purpleAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: is3D ? Colors.cyanAccent : Colors.purpleAccent),
                      ),
                      child: Text(
                        _selectedObject,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Top Floating Tools Bar (Move, Rotate, Scale, Play, Grid)
        Positioned(
          top: 10,
          left: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xEE161824),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildToolBtn(Icons.pan_tool_alt, 'move', Colors.cyanAccent),
                _buildToolBtn(Icons.rotate_right, 'rotate', Colors.purpleAccent),
                _buildToolBtn(Icons.aspect_ratio, 'scale', Colors.amberAccent),
                Container(height: 20, width: 1, color: Colors.white24),
                // Play / Pause Simulation Button
                GestureDetector(
                  onTap: () {
                    setState(() => _isPlayingSimulation = !_isPlayingSimulation);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_isPlayingSimulation ? 'Стартирана симулация на живо!' : 'Пауза на сцената')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isPlayingSimulation ? Colors.redAccent : Colors.greenAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(_isPlayingSimulation ? Icons.pause : Icons.play_arrow, size: 16, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          _isPlayingSimulation ? 'ПАУЗА' : 'ТЕСТ',
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

        // Left Magical Drawer Trigger (Сцена & Файлове)
        Positioned(
          left: 0,
          top: 70,
          child: GestureDetector(
            onTap: () => setState(() => _isLeftDrawerOpen = !_isLeftDrawerOpen),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF1E2235),
                borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                boxShadow: [BoxShadow(color: Colors.cyanAccent, blurRadius: 4)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_open, color: Colors.cyanAccent, size: 16),
                  const SizedBox(width: 4),
                  Text(_isLeftDrawerOpen ? '◀' : 'СЦЕНА ▶', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),

        // Left Sliding Drawer (Hierarchy & File Tree)
        if (_isLeftDrawerOpen)
          Positioned(
            left: 0,
            top: 110,
            bottom: 20,
            width: 170,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xF0121420),
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📁 ЙЕРАРХИЯ', style: TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                  const Divider(color: Colors.white24),
                  _buildHierarchyItem('📷 Главна Камера', false),
                  _buildHierarchyItem('💡 PBR Слънце', false),
                  _buildHierarchyItem('🤖 Играч (Mesh)', true),
                  _buildHierarchyItem('🏰 Замък Ниво 1', false),
                  _buildHierarchyItem('🌋 Лава Колизия', false),
                  const Spacer(),
                  const Text('📦 АСЕТИ', style: TextStyle(color: Colors.purpleAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                  const Divider(color: Colors.white24),
                  const Text('• player.glb\n• level_texture.png\n• jump.anim', style: TextStyle(color: Colors.grey, fontSize: 10, height: 1.4)),
                ],
              ),
            ),
          ),

        // Right Magical Drawer Trigger (Инспектор)
        Positioned(
          right: 0,
          top: 70,
          child: GestureDetector(
            onTap: () => setState(() => _isRightDrawerOpen = !_isRightDrawerOpen),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF1E2235),
                borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                boxShadow: [BoxShadow(color: Colors.purpleAccent, blurRadius: 4)],
              ),
              child: Row(
                children: [
                  Text(_isRightDrawerOpen ? '▶' : '◀ ИНСПЕКТОР', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  const Icon(Icons.tune, color: Colors.purpleAccent, size: 16),
                ],
              ),
            ),
          ),
        ),

        // Right Sliding Drawer (Inspector & Components)
        if (_isRightDrawerOpen)
          Positioned(
            right: 0,
            top: 110,
            bottom: 20,
            width: 170,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xF0121420),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.5)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔍 ИНСПЕКТОР', style: TextStyle(color: Colors.purpleAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.white24),
                    const Text('ТРАНСФОРМАЦИЯ', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    _buildInspectorField('Поз X', '0.00'),
                    _buildInspectorField('Поз Y', '1.50'),
                    _buildInspectorField('Поз Z', '-3.20'),
                    const SizedBox(height: 8),
                    const Text('ФИЗИКА & РИГ', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                    _buildInspectorField('Маса', '75 kg'),
                    _buildInspectorField('Гравитация', '9.81'),
                    const SizedBox(height: 8),
                    const Text('МАТЕРИАЛ', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                    _buildInspectorField('Шейдър', 'PBR Lava'),
                    _buildInspectorField('Емисия', '100% Ne'),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildToolBtn(IconData icon, String toolName, Color activeColor) {
    bool isSelected = _selectedTool == toolName;
    return GestureDetector(
      onTap: () => setState(() => _selectedTool = toolName),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: activeColor) : null,
        ),
        child: Icon(icon, color: isSelected ? activeColor : Colors.grey, size: 20),
      ),
    );
  }

  Widget _buildHierarchyItem(String title, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedObject = title),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purpleAccent.withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: TextStyle(color: isSelected ? Colors.cyanAccent : Colors.white70, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }

  Widget _buildInspectorField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
            child: Text(value, style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 3. ASSET STORE WITH GLOWING VIBRANT TILES & MULTIPLE LIBRARIES
  Widget _buildAssetStoreTab() {
    final filtered = _selectedStoreCategory == 'Всички'
        ? _assetsList
        : _assetsList.where((a) => a['cat'] == _selectedStoreCategory).toList();

    return Column(
      children: [
        // Category Pills
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            itemCount: _storeCategories.length,
            itemBuilder: (context, index) {
              final cat = _storeCategories[index];
              final isSel = cat == _selectedStoreCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedStoreCategory = cat),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSel ? Colors.purpleAccent : const Color(0xFF161824),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSel ? Colors.cyanAccent : Colors.white12),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
        // Grid with Gorgeous Glowing Asset Tiles
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.82,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final asset = filtered[index];
              final Color glow = asset['color'];
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF141724),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: glow.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(color: glow.withValues(alpha: 0.15), blurRadius: 10, spreadRadius: 1),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: glow.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                            child: Text(asset['type'], style: TextStyle(color: glow, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                          Text(asset['poly'], style: const TextStyle(color: Colors.grey, fontSize: 9)),
                        ],
                      ),
                      Icon(Icons.auto_awesome_motion, size: 48, color: glow),
                      Text(asset['name'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('Библиотека: ${asset['lib']}', style: const TextStyle(color: Colors.white54, fontSize: 9)),
                      SizedBox(
                        width: double.infinity,
                        height: 28,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: glow,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('✅ Добавен в сцената: ${asset['name']}')),
                            );
                          },
                          child: const Text('ВКАРАЙ В СЦЕНА', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 4. MOVEMENTS CATALOG WITH BATCH DOWNLOAD BUTTON
  Widget _buildMovementsTab() {
    return Column(
      children: [
        // Batch Download Banner (Mixamo / ActorCore)
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF00B0FF)]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.cloud_download, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mixamo & Motion Full Pack', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('Свали всички 500+ движения наведнъж', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📥 Сваляне на пълния Mixamo Motion пакет...')),
                  );
                },
                child: const Text('СВАЛИ ВСИЧКИ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
          ),
        ),
        // Compact Movements List with Smooth Cards
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _movementsList.length,
            itemBuilder: (context, index) {
              final move = _movementsList[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF141724),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.cyanAccent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.directions_run, color: Colors.cyanAccent, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(move['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('${move['type']} • ${move['frames']} • ${move['tag']}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        setState(() => _activeAnimation = move['name']!);
                        _tabController.animateTo(4); // Switch to Player tab
                      },
                      child: const Text('ПРЕГЛЕД ▶', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
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

  // 5. ANIMATION PLAYER TAB
  Widget _buildAnimationPlayerTab() {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141724),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(color: Colors.purpleAccent.withValues(alpha: 0.2), blurRadius: 25, spreadRadius: 2),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.3), blurRadius: 40)],
                        ),
                        child: const Icon(Icons.accessibility, size: 90, color: Colors.cyanAccent),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          _activeAnimation,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Скорост: ${_playbackSpeed}x • 60 FPS Skeletal Rig', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Playback Controls (Slow-Mo & Fast-Forward)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSpeedPill('0.5x (Бавно)', 0.5),
              IconButton(
                icon: Icon(_isPlayingAnim ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 52, color: Colors.cyanAccent),
                onPressed: () => setState(() => _isPlayingAnim = !_isPlayingAnim),
              ),
              _buildSpeedPill('2.0x (Бързо)', 2.0),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Big Apply Button
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFAA00FF), Color(0xFF00E5FF)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('⚡ Анимацията "$_activeAnimation" е приложена към 3D модела в Filament!')),
                    );
                  },
                  child: const Text('⚡ ПРИЛОЖИ КЪМ МОДЕЛА', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
      onTap: () => setState(() => _playbackSpeed = isSel ? 1.0 : speed),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? Colors.purpleAccent : const Color(0xFF1E2235),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSel ? Colors.cyanAccent : Colors.white12),
        ),
        child: Text(label, style: TextStyle(color: isSel ? Colors.white : Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// Custom Grid Canvas Painter for 2D/3D Viewport
class GridPainter extends CustomPainter {
  final bool is3D;
  GridPainter({required this.is3D});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = is3D ? Colors.cyanAccent.withValues(alpha: 0.08) : Colors.purpleAccent.withValues(alpha: 0.08)
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
