import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/engine_bridge/filament_bindings.dart';
import 'package:tiptop_game_engine/features/mushroom_studio/presentation/widgets/godot_2d_painter.dart';

class Studio2DView extends StatefulWidget {
  const Studio2DView({Key? key}) : super(key: key);

  @override
  State<Studio2DView> createState() => _Studio2DViewState();
}

class _Studio2DViewState extends State<Studio2DView> with SingleTickerProviderStateMixin {
  late AnimationController _fx2DController;
  Timer? _gameLoopTimer;

  String _editorMode = 'pencil';
  String _selectedTile = 'grass';
  int _selectedLayer = 0;
  String? _selectedNodeId;

  bool _isSimulating = false;
  int _score = 0;
  int _playerHp = 3;
  bool _isLevelComplete = false;

  double _playerX = 36.0;
  double _playerY = 72.0;
  double _velX = 0.0;
  double _velY = 0.0;
  bool _isGrounded = false;
  int _facingDirection = 1;

  double _playerSpeed = 4.5;
  double _playerJumpForce = 12.5;

  final List<Map<String, dynamic>> _sceneNodes = [
    {'id': 'player', 'name': 'CharacterBody2D (Player)', 'type': 'player', 'x': 1, 'y': 2, 'hp': 3, 'speed': 4.5, 'jumpForce': 12.5},
    {'id': 'tile_0', 'name': 'TileMapLayer (Grass 0)', 'type': 'grass', 'x': 0, 'y': 5, 'isSolid': true},
    {'id': 'tile_1', 'name': 'TileMapLayer (Grass 1)', 'type': 'grass', 'x': 1, 'y': 5, 'isSolid': true},
    {'id': 'tile_2', 'name': 'TileMapLayer (Grass 2)', 'type': 'grass', 'x': 2, 'y': 5, 'isSolid': true},
    {'id': 'tile_3', 'name': 'TileMapLayer (Grass 3)', 'type': 'grass', 'x': 3, 'y': 5, 'isSolid': true},
    {'id': 'tile_4', 'name': 'TileMapLayer (Grass 4)', 'type': 'grass', 'x': 4, 'y': 5, 'isSolid': true},
    {'id': 'tile_5', 'name': 'TileMapLayer (Grass 5)', 'type': 'grass', 'x': 5, 'y': 5, 'isSolid': true},
    {'id': 'tile_6', 'name': 'TileMapLayer (Grass 6)', 'type': 'grass', 'x': 6, 'y': 5, 'isSolid': true},
    {'id': 'tile_7', 'name': 'TileMapLayer (Grass 7)', 'type': 'grass', 'x': 7, 'y': 5, 'isSolid': true},
    {'id': 'tile_8', 'name': 'TileMapLayer (Grass 8)', 'type': 'grass', 'x': 8, 'y': 5, 'isSolid': true},
    {'id': 'plat_1', 'name': 'TileMapLayer (Bridge)', 'type': 'platform', 'x': 3, 'y': 3, 'isSolid': true},
    {'id': 'plat_2', 'name': 'TileMapLayer (Bridge)', 'type': 'platform', 'x': 4, 'y': 3, 'isSolid': true},
    {'id': 'coin_1', 'name': 'Area2D (Coin Alpha)', 'type': 'coin', 'x': 3, 'y': 2, 'points': 100, 'collected': false},
    {'id': 'coin_2', 'name': 'Area2D (Coin Beta)', 'type': 'coin', 'x': 6, 'y': 4, 'points': 100, 'collected': false},
    {'id': 'enemy_1', 'name': 'CharacterBody2D (Enemy AI)', 'type': 'enemy', 'x': 5, 'y': 4, 'curX': 5.0, 'dir': 1, 'minX': 3, 'maxX': 7, 'speed': 2.0},
    {'id': 'spikes_1', 'name': 'Area2D (Spikes Hazard)', 'type': 'spikes', 'x': 7, 'y': 5, 'damage': 1},
    {'id': 'portal_1', 'name': 'Area2D (Win Goal)', 'type': 'portal', 'x': 8, 'y': 4},
  ];

  final List<List<Map<String, dynamic>>> _undoHistory = [];

  @override
  void initState() {
    super.initState();
    _fx2DController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _fx2DController.dispose();
    super.dispose();
  }

  void _saveUndoState() {
    _undoHistory.add(_sceneNodes.map((e) => Map<String, dynamic>.from(e)).toList());
    if (_undoHistory.length > 25) _undoHistory.removeAt(0);
  }

  void _performUndo() {
    if (_undoHistory.isNotEmpty) {
      setState(() {
        _sceneNodes.clear();
        _sceneNodes.addAll(_undoHistory.removeLast());
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('↩️ Godot Undo: Отменено действие!')));
    }
  }

  void _toggleSimulation() {
    setState(() => _isSimulating = !_isSimulating);
    if (_isSimulating) {
      _startSimulation();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('▶ Godot 4 Play Mode: Старт на физиката!')));
    } else {
      _stopSimulation();
    }
  }

  void _startSimulation() {
    _gameLoopTimer?.cancel();
    final playerNode = _sceneNodes.firstWhere((e) => e['type'] == 'player', orElse: () => {'x': 1, 'y': 2});
    _playerX = ((playerNode['x'] as num).toDouble() * 36.0) + 18.0;
    _playerY = ((playerNode['y'] as num).toDouble() * 36.0) + 40.0;
    _velX = 0.0;
    _velY = 0.0;
    _score = 0;
    _playerHp = (playerNode['hp'] as num?)?.toInt() ?? 3;
    _playerSpeed = (playerNode['speed'] as num?)?.toDouble() ?? 4.5;
    _playerJumpForce = (playerNode['jumpForce'] as num?)?.toDouble() ?? 12.5;
    _isLevelComplete = false;

    for (var el in _sceneNodes) {
      if (el['type'] == 'coin') el['collected'] = false;
      if (el['type'] == 'enemy') el['curX'] = (el['x'] as num).toDouble();
    }

    FilamentEngine().create2DWorld(gravityY: 9.81);

    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_isSimulating) return;
      _updatePhysicsTick();
    });
  }

  void _stopSimulation() {
    _gameLoopTimer?.cancel();
    FilamentEngine().clear2DWorld();
  }

  void _updatePhysicsTick() {
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

      for (var el in _sceneNodes) {
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
            } else if (_velY < 0 && _playerY - 12 >= tileBox.bottom - 8) {
              nextY = tileBox.bottom + 13;
              _velY = 0;
            } else if (_velX > 0) {
              nextX = tileBox.left - 12;
              _velX = 0;
            } else if (_velX < 0) {
              nextX = tileBox.right + 12;
              _velX = 0;
            }
          }
        }

        if (type == 'coin' && el['collected'] != true) {
          if (playerBox.overlaps(tileBox)) {
            el['collected'] = true;
            _score += (el['points'] as num?)?.toInt() ?? 100;
          }
        }

        if (type == 'spikes' || type == 'lava') {
          if (playerBox.overlaps(tileBox)) {
            _playerHp -= (el['damage'] as num?)?.toInt() ?? 1;
            if (_playerHp <= 0) {
              _playerX = 36.0;
              _playerY = 72.0;
              _playerHp = 3;
            } else {
              _velY = -8;
              _playerX = 36.0;
            }
          }
        }

        if (type == 'enemy') {
          double curX = (el['curX'] as num?)?.toDouble() ?? (el['x'] as num).toDouble();
          int dir = (el['dir'] as num?)?.toInt() ?? 1;
          double minX = (el['minX'] as num?)?.toDouble() ?? 1.0;
          double maxX = (el['maxX'] as num?)?.toDouble() ?? 8.0;

          curX += dir * 0.035;
          if (curX >= maxX) {
            curX = maxX;
            el['dir'] = -1;
          } else if (curX <= minX) {
            curX = minX;
            el['dir'] = 1;
          }
          el['curX'] = curX;

          Rect enemyBox = Rect.fromCenter(center: Offset(curX * tileSize + tileSize / 2, ty), width: 24, height: 24);
          if (playerBox.overlaps(enemyBox)) {
            if (_velY > 0 && _playerY < enemyBox.top + 6) {
              el['y'] = -999;
              _velY = -9.0;
              _score += 250;
            } else {
              _playerHp -= 1;
              _playerX = 36.0;
              _playerY = 72.0;
            }
          }
        }

        if (type == 'portal' && playerBox.overlaps(tileBox)) {
          _isLevelComplete = true;
        }
      }

      _playerX = nextX.clamp(14.0, 360.0);
      _playerY = nextY.clamp(20.0, 480.0);

      if (_playerY > 440) {
        _playerX = 36.0;
        _playerY = 72.0;
        _velY = 0;
        _playerHp -= 1;
      }

      FilamentEngine().step2D(0.016);
    });
  }

  void _movePlayer(double dir) {
    if (_isSimulating) {
      setState(() {
        _velX = dir * _playerSpeed;
        _facingDirection = dir > 0 ? 1 : -1;
      });
    }
  }

  void _jumpPlayer() {
    if (_isSimulating && _isGrounded) {
      setState(() {
        _velY = -_playerJumpForce;
        _isGrounded = false;
      });
    }
  }

  void _showSceneTreeModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22)), side: BorderSide(color: Color(0xFF00E676), width: 1.2)),
      builder: (context) => SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(children: [Icon(Icons.account_tree_outlined, color: Color(0xFF00E676), size: 20), SizedBox(width: 8), Text('🌲 Godot 4 Scene Tree', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))]),
                    IconButton(icon: const Icon(Icons.close, color: Colors.grey, size: 20), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(color: Colors.white12),
                SizedBox(
                  height: 240,
                  child: ListView.builder(
                    itemCount: _sceneNodes.length,
                    itemBuilder: (context, index) {
                      final node = _sceneNodes[index];
                      final isSelected = node['id'] == _selectedNodeId;
                      final icon = _getNodeIcon(node['type']);
                      final col = _getNodeColor(node['type']);

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(color: isSelected ? col.withValues(alpha: 0.25) : const Color(0xFF161826), borderRadius: BorderRadius.circular(8), border: Border.all(color: isSelected ? col : Colors.white10)),
                        child: ListTile(
                          dense: true,
                          leading: Icon(icon, color: col, size: 18),
                          title: Text(node['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
                          trailing: IconButton(icon: const Icon(Icons.tune, color: AppTheme.sciFiCyan, size: 16), onPressed: () {
                            setState(() => _selectedNodeId = node['id']);
                            Navigator.pop(context);
                            _showInspectorModal(node);
                          }),
                          onTap: () {
                            setState(() => _selectedNodeId = node['id']);
                            setModalState(() {});
                            Navigator.pop(context);
                          },
                        ),
                      );
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

  void _showInspectorModal(Map<String, dynamic> node) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22)), side: BorderSide(color: AppTheme.laserPink, width: 1.2)),
      builder: (context) => SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16, left: 18, right: 18, top: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [Icon(_getNodeIcon(node['type']), color: _getNodeColor(node['type']), size: 20), const SizedBox(width: 8), Text(node['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))]),
                    IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20), onPressed: () {
                      setState(() {
                        _sceneNodes.removeWhere((e) => e['id'] == node['id']);
                        _selectedNodeId = null;
                      });
                      Navigator.pop(context);
                    }),
                  ],
                ),
                const Divider(color: Colors.white12),
                if (node['type'] == 'player') ...[
                  _buildSlider('⚡ Скорост (Speed)', (node['speed'] as num).toDouble(), 2.0, 8.0, (v) { setState(() => node['speed'] = v); setModalState(() {}); }),
                  _buildSlider('🦘 Скок (Jump Force)', (node['jumpForce'] as num).toDouble(), 8.0, 18.0, (v) { setState(() => node['jumpForce'] = v); setModalState(() {}); }),
                  _buildSlider('❤️ HP (Животи)', (node['hp'] as num).toDouble(), 1.0, 5.0, (v) { setState(() => node['hp'] = v.toInt()); setModalState(() {}); }),
                ] else if (node['type'] == 'enemy') ...[
                  _buildSlider('👾 Скорост патрул', (node['speed'] as num?)?.toDouble() ?? 2.0, 1.0, 5.0, (v) { setState(() => node['speed'] = v); setModalState(() {}); }),
                ] else if (node['type'] == 'coin') ...[
                  _buildSlider('🪙 Точки', (node['points'] as num?)?.toDouble() ?? 100.0, 50.0, 500.0, (v) { setState(() => node['points'] = v.toInt()); setModalState(() {}); }),
                ] else if (node['type'] == 'spikes') ...[
                  _buildSlider('⚠️ Демидж', (node['damage'] as num?)?.toDouble() ?? 1.0, 1.0, 3.0, (v) { setState(() => node['damage'] = v.toInt()); setModalState(() {}); }),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.laserPink),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ЗАПАЗИ НАСТРОЙКИТЕ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double val, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)), Text(val.toStringAsFixed(1), style: const TextStyle(color: AppTheme.sciFiCyan, fontSize: 11, fontWeight: FontWeight.bold))]),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(activeTrackColor: AppTheme.laserPink, thumbColor: AppTheme.sciFiCyan, trackHeight: 3.0),
          child: Slider(value: val.clamp(min, max), min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  IconData _getNodeIcon(String type) {
    switch (type) {
      case 'player': return Icons.sports_esports;
      case 'grass':
      case 'dirt':
      case 'platform': return Icons.grid_view;
      case 'coin': return Icons.monetization_on;
      case 'enemy': return Icons.pest_control;
      case 'spikes': return Icons.warning_amber;
      case 'portal': return Icons.vpn_key;
      default: return Icons.widgets;
    }
  }

  Color _getNodeColor(String type) {
    switch (type) {
      case 'player': return AppTheme.laserPink;
      case 'grass': return const Color(0xFF00E676);
      case 'platform': return AppTheme.sciFiCyan;
      case 'coin': return const Color(0xFFFFD600);
      case 'enemy': return const Color(0xFFFF1744);
      case 'spikes': return const Color(0xFFFF9100);
      case 'portal': return const Color(0xFFD500F9);
      default: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // 1. TOP BAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: const Color(0xFF10121D),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildModeBtn(Icons.edit, 'pencil', 'Рисувай'),
                      const SizedBox(width: 4),
                      _buildModeBtn(Icons.near_me, 'select', 'Селекция'),
                      const SizedBox(width: 4),
                      _buildModeBtn(Icons.cleaning_services, 'erase', 'Изтрий'),
                      const SizedBox(width: 6),
                      Container(height: 18, width: 1, color: Colors.white24),
                      const SizedBox(width: 6),
                      IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: const Icon(Icons.account_tree_outlined, color: Color(0xFF00E676), size: 20), onPressed: _showSceneTreeModal),
                      const SizedBox(width: 8),
                      IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: const Icon(Icons.undo, color: Colors.white70, size: 20), onPressed: _performUndo),
                    ],
                  ),
                  GestureDetector(
                    onTap: _toggleSimulation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: _isSimulating ? [const Color(0xFFFF1744), const Color(0xFFFF5252)] : [const Color(0xFF00E676), const Color(0xFF00E5FF)]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(_isSimulating ? Icons.stop : Icons.play_arrow, size: 15, color: Colors.black),
                          const SizedBox(width: 4),
                          Text(_isSimulating ? 'СТОП' : 'PLAY 2D', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. VIEWPORT CANVAS
            Expanded(
              child: Container(
                color: const Color(0xFF090B14),
                child: GestureDetector(
                  onTapDown: (details) {
                    if (_isSimulating) return;
                    final local = details.localPosition;
                    int col = (local.dx / 36.0).floor();
                    int row = ((local.dy - 40.0) / 36.0).floor();
                    if (row < 0 || col < 0 || col > 9) return;

                    _saveUndoState();

                    setState(() {
                      if (_editorMode == 'select') {
                        final found = _sceneNodes.firstWhere((e) => e['x'] == col && e['y'] == row, orElse: () => {});
                        if (found.isNotEmpty) {
                          _selectedNodeId = found['id'];
                          _showInspectorModal(found);
                        } else {
                          _selectedNodeId = null;
                        }
                      } else if (_editorMode == 'erase') {
                        _sceneNodes.removeWhere((e) => e['x'] == col && e['y'] == row);
                      } else {
                        _sceneNodes.removeWhere((e) => e['x'] == col && e['y'] == row);
                        String id = 'node_${DateTime.now().millisecondsSinceEpoch}';
                        Map<String, dynamic> newNode = {'id': id, 'name': 'Node ($col, $row)', 'type': _selectedTile, 'x': col, 'y': row};

                        if (_selectedTile == 'grass' || _selectedTile == 'dirt' || _selectedTile == 'platform') {
                          newNode['isSolid'] = true;
                          newNode['name'] = 'TileMapLayer ($_selectedTile)';
                        } else if (_selectedTile == 'coin') {
                          newNode['name'] = 'Area2D (Coin)';
                          newNode['points'] = 100;
                          newNode['collected'] = false;
                        } else if (_selectedTile == 'enemy') {
                          newNode['name'] = 'CharacterBody2D (Enemy)';
                          newNode['dir'] = 1;
                          newNode['minX'] = math.max<int>(0, col - 2);
                          newNode['maxX'] = math.min<int>(9, col + 2);
                          newNode['curX'] = col.toDouble();
                          newNode['speed'] = 2.0;
                        } else if (_selectedTile == 'spikes') {
                          newNode['name'] = 'Area2D (Spikes)';
                          newNode['damage'] = 1;
                        } else if (_selectedTile == 'portal') {
                          newNode['name'] = 'Area2D (Win Goal)';
                        }
                        _sceneNodes.add(newNode);
                      }
                    });
                  },
                  child: AnimatedBuilder(
                    animation: _fx2DController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size.infinite,
                        painter: Godot2DEnginePainter(
                          nodes: _sceneNodes,
                          selectedNodeId: _selectedNodeId,
                          lightColor: AppTheme.sciFiCyan,
                          pulseValue: _fx2DController.value,
                          isSimulating: _isSimulating,
                          playerPos: Offset(_playerX, _playerY),
                          playerFacing: _facingDirection,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // 3. LAYERED TILESET DOCK
            if (!_isSimulating)
              Container(
                decoration: const BoxDecoration(color: Color(0xFF10121D), border: Border(top: BorderSide(color: Color(0xFF222638)))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 28,
                      color: const Color(0xFF0E101A),
                      child: Row(
                        children: [
                          _buildLayerTab(0, '🧱 Solids (Терен)'),
                          _buildLayerTab(1, '🪙 Items (Тригери)'),
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
          ],
        ),

        // HUD
        if (_isSimulating)
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
                  child: Text('🪙 Резултат: $_score', style: const TextStyle(color: Color(0xFFFFD600), fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),

        if (_isLevelComplete)
          Container(
            color: Colors.black87,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉 НИВОТО Е ЗАВЪРШЕНО!', style: TextStyle(color: Color(0xFF00E676), fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Финални точки: $_score', style: const TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.laserPink),
                    onPressed: () { setState(() { _isLevelComplete = false; _startSimulation(); }); },
                    child: const Text('ИГРАЙ ОТНОВО', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),

        if (_isSimulating && !_isLevelComplete)
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
    );
  }

  Widget _buildModeBtn(IconData icon, String mode, String label) {
    bool isSel = _editorMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _editorMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(color: isSel ? AppTheme.laserPink.withValues(alpha: 0.25) : Colors.transparent, borderRadius: BorderRadius.circular(6), border: isSel ? Border.all(color: AppTheme.laserPink) : null),
        child: Row(children: [Icon(icon, size: 14, color: isSel ? AppTheme.laserPink : Colors.grey), const SizedBox(width: 3), Text(label, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontSize: 9, fontWeight: FontWeight.bold))]),
      ),
    );
  }

  Widget _buildLayerTab(int index, String title) {
    bool isSel = _selectedLayer == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedLayer = index),
        child: Container(
          decoration: BoxDecoration(color: isSel ? const Color(0xFF181B28) : Colors.transparent, border: Border(bottom: BorderSide(color: isSel ? AppTheme.sciFiCyan : Colors.transparent, width: 2))),
          child: Center(child: Text(title, style: TextStyle(color: isSel ? AppTheme.sciFiCyan : Colors.grey, fontSize: 9, fontWeight: isSel ? FontWeight.bold : FontWeight.normal))),
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
        _buildPaletteChip('🤖 Играч Spawn', 'player', AppTheme.laserPink),
        _buildPaletteChip('👾 Враг AI', 'enemy', const Color(0xFFFF1744)),
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
}
