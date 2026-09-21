import 'dart:async';
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

  // Godot Docks (Панели)
  bool _showLeftFileSystem = false;
  bool _showRightInspector = false;

  // 2D Play Mode
  bool _isSimulating = false;
  int _score = 0;
  int _playerHp = 3;
  bool _isLevelComplete = false;

  double _playerX = 36.0;
  double _playerY = 72.0;
  double _velX = 0.0;
  double _velY = 0.0;
  bool _isGrounded = false;

  final List<Map<String, dynamic>> _scene2DNodes = [
    {'id': 'player', 'name': 'CharacterBody2D (Player)', 'type': 'player', 'x': 1, 'y': 2, 'hp': 3, 'speed': 4.5, 'jumpForce': 12.5},
    {'id': 'tile_0', 'name': 'TileMapLayer (Grass 0)', 'type': 'grass', 'x': 0, 'y': 5, 'isSolid': true},
    {'id': 'tile_1', 'name': 'TileMapLayer (Grass 1)', 'type': 'grass', 'x': 1, 'y': 5, 'isSolid': true},
    {'id': 'tile_2', 'name': 'TileMapLayer (Grass 2)', 'type': 'grass', 'x': 2, 'y': 5, 'isSolid': true},
    {'id': 'tile_3', 'name': 'TileMapLayer (Grass 3)', 'type': 'grass', 'x': 3, 'y': 5, 'isSolid': true},
    {'id': 'tile_4', 'name': 'TileMapLayer (Grass 4)', 'type': 'grass', 'x': 4, 'y': 5, 'isSolid': true},
    {'id': 'coin_1', 'name': 'Area2D (Coin)', 'type': 'coin', 'x': 3, 'y': 2, 'points': 100, 'collected': false},
    {'id': 'enemy_1', 'name': 'CharacterBody2D (Enemy)', 'type': 'enemy', 'x': 5, 'y': 4, 'curX': 5.0, 'dir': 1, 'minX': 3, 'maxX': 7},
    {'id': 'portal_1', 'name': 'Area2D (Win Goal)', 'type': 'portal', 'x': 8, 'y': 4},
  ];

  final List<Map<String, dynamic>> _projectFiles = [
    {'name': 'scenes', 'type': 'folder', 'items': ['world_2d.tscn', 'dungeon.tscn']},
    {'name': 'tilesets', 'type': 'folder', 'items': ['terrain_set.tres', 'hazards.tres']},
    {'name': 'scripts', 'type': 'folder', 'items': ['player_controller.gd', 'enemy_patrol.gd']},
    {'name': 'audio', 'type': 'folder', 'items': ['bgm_cyber.ogg', 'sfx_jump.wav']},
  ];

  Timer? _gameLoopTimer;

  void _toggleSimulation() {
    setState(() => _isSimulating = !_isSimulating);
    if (_isSimulating) {
      _startSimulation();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('▶ Godot 4 2D Play Mode: Старт на физиката!')));
    } else {
      _gameLoopTimer?.cancel();
    }
  }

  void _startSimulation() {
    _gameLoopTimer?.cancel();
    _playerX = 36.0;
    _playerY = 72.0;
    _velX = 0.0;
    _velY = 0.0;
    _score = 0;
    _playerHp = 3;
    _isLevelComplete = false;

    for (var el in _scene2DNodes) {
      if (el['type'] == 'coin') el['collected'] = false;
      if (el['type'] == 'enemy') el['curX'] = (el['x'] as num).toDouble();
    }

    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_isSimulating) return;
      setState(() {
        const double tileSize = 36.0;
        const double gravity = 0.85;
        const double friction = 0.78;

        _velY += gravity;
        _velX *= friction;

        double nextX = _playerX + _velX;
        double nextY = _playerY + _velY;
        _isGrounded = false;

        Rect playerBox = Rect.fromCenter(center: Offset(nextX, nextY), width: 22, height: 26);

        for (var el in _scene2DNodes) {
          String type = el['type'];
          double tx = ((el['x'] as num).toDouble() * tileSize) + (tileSize / 2.0);
          double ty = ((el['y'] as num).toDouble() * tileSize) + 40.0 + (tileSize / 2.0);
          Rect tileBox = Rect.fromCenter(center: Offset(tx, ty), width: tileSize, height: tileSize);

          if (el['isSolid'] == true || type == 'grass' || type == 'dirt' || type == 'platform') {
            if (playerBox.overlaps(tileBox)) {
              if (_velY > 0 && _playerY + 12 <= tileBox.top + 8) {
                nextY = tileBox.top - 13;
                _velY = 0;
                _isGrounded = true;
              }
            }
          }

          if (type == 'coin' && el['collected'] != true) {
            if (playerBox.overlaps(tileBox)) {
              el['collected'] = true;
              _score += 100;
            }
          }

          if (type == 'portal' && playerBox.overlaps(tileBox)) {
            _isLevelComplete = true;
          }
        }

        _playerX = nextX.clamp(14.0, 360.0);
        _playerY = nextY.clamp(20.0, 480.0);
      });
    });
  }

  void _movePlayer(double dir) {
    if (_isSimulating) {
      setState(() {
        _velX = dir * 4.5;
      });
    }
  }

  void _jumpPlayer() {
    if (_isSimulating && _isGrounded) {
      setState(() {
        _velY = -12.5;
        _isGrounded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> mock2DNodes = [
      {'id': 'player_2d', 'name': 'CharacterBody2D (Player)', 'type': 'player', 'x': 36, 'y': 72, 'speed': 4.5, 'layer': _selectedLayer},
      {'id': 'tilemap', 'name': 'TileMapLayer ($_selectedTile)', 'type': 'tilemap', 'x': 0, 'y': 0, 'layer': _selectedLayer},
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

        if (!_isSimulating)
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.15)),
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
                  icon: Icon(Icons.folder_open, color: _showLeftFileSystem ? const Color(0xFF00E676) : Colors.grey, size: 20),
                  tooltip: 'res:// FileSystem',
                  onPressed: () => setState(() => _showLeftFileSystem = !_showLeftFileSystem),
                ),
                const SizedBox(width: 8),

                Row(
                  children: [
                    _buildModeBtn(Icons.edit, 'pencil', 'Draw: $_selectedTile'),
                    _buildModeBtn(Icons.near_me, 'select', 'Select'),
                    _buildModeBtn(Icons.cleaning_services, 'erase', 'Erase'),
                  ],
                ),

                const Spacer(),

                GestureDetector(
                  onTap: _toggleSimulation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _isSimulating ? const Color(0xFFFF1744) : const Color(0xFF00E676),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(_isSimulating ? Icons.stop : Icons.play_arrow, size: 14, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          _isSimulating ? 'STOP' : 'PLAY 2D',
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
        if (_showLeftFileSystem && !_isSimulating)
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

        // 4. 🌲 ДЕСЕН ПАНЕЛ: SCENE TREE + INSPECTOR
        if (_showRightInspector && !_isSimulating)
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
                                const Icon(Icons.grid_on, size: 12, color: Colors.white70),
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
                          _buildPropRow('Active Layer:', 'Layer $_selectedLayer'),
                          _buildPropRow('Selected Tile:', _selectedTile),
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
                        child: Text('Избери възел за инспекция', style: TextStyle(color: Colors.grey, fontSize: 9), textAlign: TextAlign.center),
                      ),
                    ),
                ],
              ),
            ),
          ),

        // 5. ДОЛЕН ПАНЕЛ: TILEMAP PALETTE (Само в Edit Mode)
        if (!_isSimulating)
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

        // 6. ПОБЕДЕН ЕКРАН ПРИ ЗАВЪРШВАНЕ НА НИВОТО
        if (_isLevelComplete)
          Positioned.fill(
            child: Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎉 НИВОТО Е ЗАВЪРШЕНО!', style: TextStyle(color: Color(0xFF00E676), fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.laserPink),
                      onPressed: () => setState(() => _isLevelComplete = false),
                      child: const Text('ПРОДЪЛЖИ', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 7. HUD И ТЪЧ КОНТРОЛИ В PLAY MODE
        if (_isSimulating) ...[
          Positioned(
            top: 50,
            left: 14,
            right: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: List.generate(3, (i) => Icon(i < _playerHp ? Icons.favorite : Icons.favorite_border, color: const Color(0xFFFF1744), size: 22))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFD600))),
                  child: Text('🪙 Точки: $_score', style: const TextStyle(color: Color(0xFFFFD600), fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  _buildTouchBtn(Icons.arrow_back, () => _movePlayer(-1)),
                  const SizedBox(width: 12),
                  _buildTouchBtn(Icons.arrow_forward, () => _movePlayer(1)),
                ]),
                GestureDetector(
                  onTap: _jumpPlayer,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00E5FF)]), boxShadow: [BoxShadow(color: const Color(0xFF00E676).withValues(alpha: 0.6), blurRadius: 16)]),
                    child: const Center(child: Text('СКОК 🚀', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold))),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildTouchBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(color: const Color(0xDD181B28), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00E676), width: 1.5)),
        child: Icon(icon, color: const Color(0xFF00E676), size: 24),
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
