import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/engine_bridge/godot_view.dart';
import 'package:tiptop_game_engine/core/services/scene_command_bus.dart';

class Studio3DView extends StatefulWidget {
  const Studio3DView({Key? key}) : super(key: key);

  @override
  State<Studio3DView> createState() => _Studio3DViewState();
}

class _Studio3DViewState extends State<Studio3DView> {
  final SceneCommandBus _commandBus = SceneCommandBus();

  String _selectedTool = 'orbit';
  String? _selectedNodeId;

  // Панели (Godot Docks)
  bool _showLeftFileSystem = false;
  bool _showRightInspector = false;

  // 3D Play Mode
  bool _isPlayMode = false;

  // Godot FileSystem Структура (res://)
  final List<Map<String, dynamic>> _projectFiles = [
    {'name': 'scenes', 'type': 'folder', 'items': ['main_3d.tscn', 'city_level.tscn']},
    {'name': 'models', 'type': 'folder', 'items': ['ybot_player.glb', 'skyscraper_a.glb']},
    {'name': 'materials', 'type': 'folder', 'items': ['cyber_neon.tres', 'lava_hazard.tres']},
    {'name': 'scripts', 'type': 'folder', 'items': ['player_controller.gd', 'enemy_patrol.gd']},
  ];

  @override
  void initState() {
    super.initState();
    _commandBus.addListener(_onSceneUpdated);
  }

  @override
  void dispose() {
    _commandBus.removeListener(_onSceneUpdated);
    super.dispose();
  }

  void _onSceneUpdated() {
    if (mounted) setState(() {});
  }

  void _togglePlayMode() {
    setState(() => _isPlayMode = !_isPlayMode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isPlayMode ? '▶ Godot 4: Стартиран Play Mode в енджина!' : '⏹ Godot 4: Спрян Play Mode.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final liveNodes = _commandBus.live3DNodes;
    final selectedNode = _selectedNodeId != null
        ? liveNodes.firstWhere((e) => e['id'] == _selectedNodeId, orElse: () => {})
        : null;

    return Stack(
      children: [
        // 1. ИСТИНСКИЯТ GODOT 4 ЕНДЖИН (NATIVE VIEWPORT)
        const Positioned.fill(
          child: GodotNativeView(),
        ),

        // Ако GodotNativeView зарежда, показваме лек тъмен филтър
        if (!_isPlayMode)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.1),
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
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.folder_open, color: _showLeftFileSystem ? AppTheme.sciFiCyan : Colors.grey, size: 20),
                  tooltip: 'res:// FileSystem',
                  onPressed: () => setState(() => _showLeftFileSystem = !_showLeftFileSystem),
                ),
                const SizedBox(width: 8),

                Row(
                  children: [
                    _buildToolIcon(Icons.threed_rotation, 'orbit', 'Orbit'),
                    _buildToolIcon(Icons.open_with, 'move', 'Move'),
                    _buildToolIcon(Icons.aspect_ratio, 'scale', 'Scale'),
                  ],
                ),

                const Spacer(),

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
}
