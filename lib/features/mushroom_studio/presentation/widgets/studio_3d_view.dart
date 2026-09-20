import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/engine_bridge/filament_bindings.dart';
import 'package:tiptop_game_engine/core/services/scene_command_bus.dart';
import 'package:tiptop_game_engine/features/mushroom_studio/presentation/widgets/studio_3d_painter.dart';

class Studio3DView extends StatefulWidget {
  const Studio3DView({Key? key}) : super(key: key);

  @override
  State<Studio3DView> createState() => _Studio3DViewState();
}

class _Studio3DViewState extends State<Studio3DView> {
  final SceneCommandBus _commandBus = SceneCommandBus();
  Timer? _gameLoop3DTimer;

  // Камера
  double _camYaw = 0.75;
  double _camPitch = 0.55;
  double _camZoom = 1.0;
  String _selectedTool = 'orbit'; // orbit, move, scale
  String? _selectedNodeId;

  // Панели (Godot Docks)
  bool _showLeftFileSystem = false;
  bool _showRightInspector = false;

  // 3D Play Mode
  bool _isPlayMode = false;
  double _player3dX = 0.0;
  double _player3dZ = 0.0;

  // Godot FileSystem Структура (res://)
  final List<Map<String, dynamic>> _projectFiles = [
    {'name': 'scenes', 'type': 'folder', 'items': ['main_3d.tscn', 'city_level.tscn']},
    {'name': 'models', 'type': 'folder', 'items': ['ybot_player.glb', 'skyscraper_a.glb']},
    {'name': 'materials', 'type': 'folder', 'items': ['cyber_neon.tres', 'lava_hazard.tres']},
    {'name': 'scripts', 'type': 'folder', 'items': ['player_controller.gd', 'enemy_patrol.gd']},
    {'name': 'audio', 'type': 'folder', 'items': ['cyber_ambient.ogg', 'jump_sfx.wav']},
  ];

  @override
  void initState() {
    super.initState();
    _commandBus.addListener(_onSceneUpdated);
  }

  @override
  void dispose() {
    _commandBus.removeListener(_onSceneUpdated);
    _gameLoop3DTimer?.cancel();
    super.dispose();
  }

  void _onSceneUpdated() {
    if (mounted) setState(() {});
  }

  // =========================================================================
  // 🎮 PLAYABLE 3D JOLT PHYSICS LOOP
  // =========================================================================

  void _togglePlayMode() {
    setState(() => _isPlayMode = !_isPlayMode);

    if (_isPlayMode) {
      _startPlayMode();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('▶ Godot 4 3D Viewport: Стартиран Third-Person свят!')),
      );
    } else {
      _stopPlayMode();
    }
  }

  void _startPlayMode() {
    _gameLoop3DTimer?.cancel();
    _player3dX = 0.0;
    _player3dZ = 0.0;

    FilamentEngine().create3DWorld(gravityY: -9.81);

    _gameLoop3DTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_isPlayMode) return;
      setState(() {
        FilamentEngine().step3D(0.016);
      });
    });
  }

  void _stopPlayMode() {
    _gameLoop3DTimer?.cancel();
    FilamentEngine().clear3DWorld();
  }

  void _movePlayer3D(double dx, double dz) {
    if (_isPlayMode) {
      setState(() {
        _player3dX = (_player3dX + dx).clamp(-140.0, 140.0);
        _player3dZ = (_player3dZ + dz).clamp(-140.0, 140.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveNodes = _commandBus.live3DNodes;
    final selectedNode = _selectedNodeId != null
        ? liveNodes.firstWhere((e) => e['id'] == _selectedNodeId, orElse: () => {})
        : null;

    return Stack(
      children: [
        // 1. ЦЕНТРАЛЕН БЕЗКРАЕН 3D СВЯТ
        GestureDetector(
          onScaleUpdate: (details) {
            if (_isPlayMode) return;
            setState(() {
              if (details.scale != 1.0) {
                _camZoom = (_camZoom * details.scale).clamp(0.4, 2.8);
              } else {
                _camYaw += details.focalPointDelta.dx * 0.008;
                _camPitch = (_camPitch - details.focalPointDelta.dy * 0.008).clamp(0.08, 1.45);
              }
            });
          },
          child: CustomPaint(
            size: Size.infinite,
            painter: Studio3DEnginePainter(
              yaw: _camYaw,
              pitch: _camPitch,
              zoom: _camZoom,
              objects: liveNodes,
              selectedNodeId: _selectedNodeId,
              isPlayMode: _isPlayMode,
              playerPos3D: Offset(_player3dX, _player3dZ),
            ),
          ),
        ),

        // 2. GODOT 4 TOP BAR
        Positioned(
          top: 6,
          left: 6,
          right: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xEE1E2230),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF2E344A)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Бутон за Ляв панел (FileSystem)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.folder_open, color: _showLeftFileSystem ? AppTheme.sciFiCyan : Colors.grey, size: 20),
                  tooltip: 'res:// FileSystem',
                  onPressed: () => setState(() => _showLeftFileSystem = !_showLeftFileSystem),
                ),
                const SizedBox(width: 8),

                // Инструменти за трансформация
                Row(
                  children: [
                    _buildToolIcon(Icons.threed_rotation, 'orbit', 'Orbit'),
                    _buildToolIcon(Icons.open_with, 'move', 'Move'),
                    _buildToolIcon(Icons.aspect_ratio, 'scale', 'Scale'),
                  ],
                ),

                const Spacer(),

                // Play / Stop контролер
                GestureDetector(
                  onTap: _togglePlayMode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _isPlayMode ? const Color(0xFFFF1744) : const Color(0xFF00E676),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(_isPlayMode ? Icons.stop : Icons.play_arrow, size: 14, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          _isPlayMode ? 'STOP' : 'PLAY 3D',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Бутон за Десен панел (Scene & Inspector)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.tune, color: _showRightInspector ? AppTheme.laserPink : Colors.grey, size: 20),
                  tooltip: 'Inspector & Scene',
                  onPressed: () => setState(() => _showRightInspector = !_showRightInspector),
                ),
              ],
            ),
          ),
        ),

        // 3. 📁 ЛЯВ ПАНЕЛ: GODOT 4 FILESYSTEM DOCK (res://)
        if (_showLeftFileSystem && !_isPlayMode)
          Positioned(
            left: 6,
            top: 48,
            bottom: 60,
            width: 170,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xF2181C28),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2E344A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('📁 res://', style: TextStyle(color: AppTheme.sciFiCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                      Icon(Icons.create_new_folder, size: 14, color: Colors.grey),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _projectFiles.length,
                      itemBuilder: (context, index) {
                        final folder = _projectFiles[index];
                        final items = folder['items'] as List<String>;
                        return Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            dense: true,
                            leading: const Icon(Icons.folder, size: 14, color: Color(0xFFFFD600)),
                            title: Text(folder['name'], style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            children: items.map((file) => Padding(
                              padding: const EdgeInsets.only(left: 18.0, bottom: 4.0),
                              child: Row(
                                children: [
                                  Icon(file.endsWith('.tscn') ? Icons.grid_view : Icons.insert_drive_file, size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(file, style: const TextStyle(color: Colors.white60, fontSize: 9)),
                                ],
                              ),
                            )).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 26,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.sciFiCyan), padding: EdgeInsets.zero),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('📂 Отвори файлов мениджър за импорт в res://')),
                        );
                      },
                      child: const Text('+ ИМПОРТ', style: TextStyle(color: AppTheme.sciFiCyan, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 4. 🌲 & 🔍 ДЕСЕН ПАНЕЛ: GODOT 4 SCENE TREE + INSPECTOR
        if (_showRightInspector && !_isPlayMode)
          Positioned(
            right: 6,
            top: 48,
            bottom: 60,
            width: 190,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xF2181C28),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2E344A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Горе: Дърво на сцената (Scene Tree)
                  const Text('🌲 3D Scene Tree', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: liveNodes.length,
                      itemBuilder: (context, index) {
                        final node = liveNodes[index];
                        final isSel = node['id'] == _selectedNodeId;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedNodeId = node['id']),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                            decoration: BoxDecoration(
                              color: isSel ? AppTheme.laserPink.withValues(alpha: 0.3) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.view_in_ar, size: 12, color: node['color'] as Color? ?? Colors.white),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(node['name'] ?? 'Node', style: TextStyle(color: isSel ? Colors.white : Colors.white70, fontSize: 9, fontWeight: isSel ? FontWeight.bold : FontWeight.normal), overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 10),

                  // Долу: Инспектор на свойствата (Inspector)
                  const Text('🔍 Property Inspector', style: TextStyle(color: AppTheme.laserPink, fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 4),
                  if (selectedNode != null && selectedNode.isNotEmpty)
                    Expanded(
                      child: ListView(
                        children: [
                          Text(selectedNode['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          _buildPropRow('X:', (selectedNode['x'] as num).toInt().toString()),
                          _buildPropRow('Y:', (selectedNode['y'] as num).toInt().toString()),
                          _buildPropRow('Z:', (selectedNode['z'] as num).toInt().toString()),
                          _buildPropRow('Size:', (selectedNode['size'] as num).toInt().toString()),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() => selectedNode['x'] = (selectedNode['x'] as num).toDouble() + 10.0);
                                },
                                child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFF2E344A), borderRadius: BorderRadius.circular(4)), child: const Text('+X', style: TextStyle(color: Colors.white, fontSize: 9))),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() => selectedNode['y'] = (selectedNode['y'] as num).toDouble() - 10.0);
                                },
                                child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFF2E344A), borderRadius: BorderRadius.circular(4)), child: const Text('+Y', style: TextStyle(color: Colors.white, fontSize: 9))),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() => selectedNode['z'] = (selectedNode['z'] as num).toDouble() + 10.0);
                                },
                                child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFF2E344A), borderRadius: BorderRadius.circular(4)), child: const Text('+Z', style: TextStyle(color: Colors.white, fontSize: 9))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 24,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: EdgeInsets.zero),
                              onPressed: () {
                                setState(() {
                                  liveNodes.removeWhere((n) => n['id'] == selectedNode['id']);
                                  _selectedNodeId = null;
                                });
                              },
                              child: const Text('ИЗТРИЙ ВЪЗЕЛ', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const Expanded(
                      child: Center(
                        child: Text('Избери 3D обект от сцената', style: TextStyle(color: Colors.grey, fontSize: 9), textAlign: TextAlign.center),
                      ),
                    ),
                ],
              ),
            ),
          ),

        // 5. ТЪЧ КОНТРОЛИ В PLAY MODE
        if (_isPlayMode)
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildPlayTouchBtn(Icons.arrow_back, () => _movePlayer3D(-15.0, 0)),
                    const SizedBox(width: 8),
                    _buildPlayTouchBtn(Icons.arrow_forward, () => _movePlayer3D(15.0, 0)),
                    const SizedBox(width: 8),
                    _buildPlayTouchBtn(Icons.arrow_upward, () => _movePlayer3D(0, -15.0)),
                    const SizedBox(width: 8),
                    _buildPlayTouchBtn(Icons.arrow_downward, () => _movePlayer3D(0, 15.0)),
                  ],
                ),
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [AppTheme.laserPink, AppTheme.sciFiCyan]),
                    boxShadow: [BoxShadow(color: AppTheme.laserPink.withValues(alpha: 0.6), blurRadius: 15)],
                  ),
                  child: const Center(child: Text('СКОК 🚀', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold))),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildToolIcon(IconData icon, String tool, String label) {
    bool isSel = _selectedTool == tool;
    return GestureDetector(
      onTap: () => setState(() => _selectedTool = tool),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        margin: const EdgeInsets.only(right: 3),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.sciFiCyan.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: isSel ? Border.all(color: AppTheme.sciFiCyan) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 12, color: isSel ? AppTheme.sciFiCyan : Colors.grey),
            const SizedBox(width: 3),
            Text(label, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPropRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9)),
          Text(value, style: const TextStyle(color: AppTheme.sciFiCyan, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPlayTouchBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xDD181B28),
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.sciFiCyan, width: 1.2),
        ),
        child: Icon(icon, color: AppTheme.sciFiCyan, size: 20),
      ),
    );
  }
}
