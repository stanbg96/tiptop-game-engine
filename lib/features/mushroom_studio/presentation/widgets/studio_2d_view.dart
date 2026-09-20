import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/engine_bridge/godot_view.dart';

class Studio2DView extends StatefulWidget {
  const Studio2DView({Key? key}) : super(key: key);

  @override
  State<Studio2DView> createState() => _Studio2DViewState();
}

class _Studio2DViewState extends State<Studio2DView> {
  String _editorMode = 'pencil';
  String _selectedTile = 'grass';
  int _selectedLayer = 0;
  String? _selectedNodeId;

  // Панели (Godot Docks)
  bool _showLeftFileSystem = false;
  bool _showRightInspector = false;

  // 2D Play Mode
  bool _isPlayMode = false;

  // Godot FileSystem Структура (res://)
  final List<Map<String, dynamic>> _projectFiles = [
    {'name': 'scenes', 'type': 'folder', 'items': ['level_1.tscn', 'boss_arena.tscn']},
    {'name': 'sprites', 'type': 'folder', 'items': ['player_sheet.png', 'tileset.png']},
    {'name': 'scripts', 'type': 'folder', 'items': ['player_2d.gd', 'enemy_ai.gd']},
    {'name': 'audio', 'type': 'folder', 'items': ['jump.wav', 'coin.wav']},
  ];

  void _togglePlayMode() {
    setState(() => _isPlayMode = !_isPlayMode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isPlayMode ? '▶ Godot 4: Стартиран 2D Play Mode!' : '⏹ Godot 4: Спрян 2D Play Mode.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // В реално време бихме взели възлите от енджина. Тук симулираме UI-а за Инспектора:
    final List<Map<String, dynamic>> mock2DNodes = [
      {'id': 'player_2d', 'name': 'CharacterBody2D (Player)', 'type': 'player', 'x': 36, 'y': 72, 'speed': 4.5},
      {'id': 'tilemap', 'name': 'TileMapLayer (Ground)', 'type': 'tilemap', 'x': 0, 'y': 0},
      {'id': 'enemy_1', 'name': 'CharacterBody2D (Enemy)', 'type': 'enemy', 'x': 180, 'y': 72, 'speed': 2.0},
    ];

    final selectedNode = _selectedNodeId != null
        ? mock2DNodes.firstWhere((e) => e['id'] == _selectedNodeId, orElse: () => {})
        : null;

    return Stack(
      children: [
        // 1. ИСТИНСКИЯТ GODOT 4 ЕНДЖИН (2D NATIVE VIEWPORT)
        const Positioned.fill(
          child: GodotNativeView(),
        ),

        // Тъмен филтър докато зарежда или в Edit Mode (за да се чете UI-а по-лесно)
        if (!_isPlayMode)
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.15)),
          ),

        // 2. GODOT 4 TOP CONTROL BAR
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
                  icon: Icon(Icons.folder_open, color: _showLeftFileSystem ? const Color(0xFF00E676) : Colors.grey, size: 20),
                  tooltip: 'res:// FileSystem',
                  onPressed: () => setState(() => _showLeftFileSystem = !_showLeftFileSystem),
                ),
                const SizedBox(width: 8),

                Row(
                  children: [
                    _buildModeBtn(Icons.edit, 'pencil', 'Draw'),
                    _buildModeBtn(Icons.near_me, 'select', 'Select'),
                    _buildModeBtn(Icons.cleaning_services, 'erase', 'Erase'),
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
                          _isPlayMode ? 'STOP' : 'PLAY 2D',
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
                  icon: Icon(Icons.account_tree_outlined, color: _showRightInspector ? const Color(0xFF00E676) : Colors.grey, size: 20),
                  tooltip: 'Scene & Inspector',
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
            bottom: 120,
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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('📁 res://', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 12)),
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
                                  Icon(file.endsWith('.tscn') ? Icons.grid_view : (file.endsWith('.png') ? Icons.image : Icons.insert_drive_file), size: 12, color: Colors.grey),
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

        // 4. 🌲 ДЕСЕН ПАНЕЛ: SCENE TREE + INSPECTOR
        if (_showRightInspector && !_isPlayMode)
          Positioned(
            right: 6,
            top: 48,
            bottom: 120,
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
                  const Text('🌲 2D Scene Tree', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: mock2DNodes.length,
                      itemBuilder: (context, index) {
                        final node = mock2DNodes[index];
                        final isSel = node['id'] == _selectedNodeId;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedNodeId = node['id']),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFF00E676).withValues(alpha: 0.3) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(node['type'] == 'tilemap' ? Icons.grid_on : Icons.sports_esports, size: 12, color: isSel ? Colors.white : Colors.white70),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(node['name'], style: TextStyle(color: isSel ? Colors.white : Colors.white70, fontSize: 9, fontWeight: isSel ? FontWeight.bold : FontWeight.normal), overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 10),

                  const Text('🔍 2D Inspector', style: TextStyle(color: AppTheme.laserPink, fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 4),
                  if (selectedNode != null && selectedNode.isNotEmpty)
                    Expanded(
                      child: ListView(
                        children: [
                          Text(selectedNode['name'], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          _buildPropRow('Position X:', selectedNode['x'].toString()),
                          _buildPropRow('Position Y:', selectedNode['y'].toString()),
                          if (selectedNode['speed'] != null)
                            _buildPropRow('Speed:', selectedNode['speed'].toString()),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 24,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: EdgeInsets.zero),
                              onPressed: () {
                                setState(() => _selectedNodeId = null);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Възелът изтрит!')));
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
                        child: Text('Избери 2D обект от сцената', style: TextStyle(color: Colors.grey, fontSize: 9), textAlign: TextAlign.center),
                      ),
                    ),
                ],
              ),
            ),
          ),

        // 5. ДОЛЕН ПАНЕЛ: TILEMAP PALETTE (Само в Edit Mode)
        if (!_isPlayMode)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(color: Color(0xFF10121D), border: Border(top: BorderSide(color: Color(0xFF222638)))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 28,
                    color: const Color(0xFF0E101A),
                    child: Row(
                      children: [
                        _buildLayerTab(0, '🧱 TileMap (Терен)'),
                        _buildLayerTab(1, '🪙 Area2D (Тригери)'),
                        _buildLayerTab(2, '👾 Actors (Герои)'),
                      ],
                    ),
                  ),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _getPaletteForCurrentLayer(),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModeBtn(IconData icon, String mode, String label) {
    bool isSel = _editorMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _editorMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        margin: const EdgeInsets.only(right: 3),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF00E676).withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: isSel ? Border.all(color: const Color(0xFF00E676)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 12, color: isSel ? const Color(0xFF00E676) : Colors.grey),
            const SizedBox(width: 3),
            Text(label, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildLayerTab(int index, String title) {
    bool isSel = _selectedLayer == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedLayer = index),
        child: Container(
          decoration: BoxDecoration(color: isSel ? const Color(0xFF181B28) : Colors.transparent, border: Border(bottom: BorderSide(color: isSel ? const Color(0xFF00E676) : Colors.transparent, width: 2))),
          child: Center(child: Text(title, style: TextStyle(color: isSel ? const Color(0xFF00E676) : Colors.grey, fontSize: 9, fontWeight: isSel ? FontWeight.bold : FontWeight.normal))),
        ),
      ),
    );
  }

  List<Widget> _getPaletteForCurrentLayer() {
    if (_selectedLayer == 0) {
      return [
        _buildPaletteChip('🟩 Трева', 'grass', const Color(0xFF00E676)),
        _buildPaletteChip('🟫 Скала', 'dirt', const Color(0xFF8D6E63)),
        _buildPaletteChip('🟦 Платформа', 'platform', AppTheme.sciFiCyan),
      ];
    } else if (_selectedLayer == 1) {
      return [
        _buildPaletteChip('🪙 Монета', 'coin', const Color(0xFFFFD600)),
        _buildPaletteChip('⚠️ Шипове', 'spikes', const Color(0xFFFF9100)),
        _buildPaletteChip('🌋 Лава', 'lava', const Color(0xFFFF3D00)),
        _buildPaletteChip('🏁 Финал', 'portal', const Color(0xFFD500F9)),
      ];
    } else {
      return [
        _buildPaletteChip('🤖 Играч', 'player', AppTheme.laserPink),
        _buildPaletteChip('👾 Враг', 'enemy', const Color(0xFFFF1744)),
      ];
    }
  }

  Widget _buildPaletteChip(String label, String tile, Color c) {
    bool isSel = _selectedTile == tile && _editorMode == 'pencil';
    return GestureDetector(
      onTap: () => setState(() { _selectedTile = tile; _editorMode = 'pencil'; }),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: isSel ? c.withValues(alpha: 0.25) : const Color(0xFF181B28), borderRadius: BorderRadius.circular(8), border: Border.all(color: isSel ? c : Colors.white12)),
        child: Center(child: Text(label, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
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
          Text(value, style: const TextStyle(color: Color(0xFF00E676), fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
