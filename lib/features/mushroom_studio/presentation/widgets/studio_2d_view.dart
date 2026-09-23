import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/engine_bridge/filament_bindings.dart';
import 'package:tiptop_game_engine/features/mushroom_studio/presentation/widgets/godot_2d_painter.dart';

class Studio2DView extends StatefulWidget {
  const Studio2DView({Key? key}) : super(key: key);

  @override
  State<Studio2DView> createState() => _Studio2DViewState();
}

class _Studio2DViewState extends State<Studio2DView> with TickerProviderStateMixin {
  late AnimationController _fx2DController;
  final TextEditingController _aiPromptController = TextEditingController();
  Timer? _gameLoopTimer;

  String _editorMode = 'pencil'; // pencil, select, erase
  String _selectedTile = 'grass';
  String? _selectedNodeId;
  bool _showNodeInspector = false;

  // 2D Симулация и физика
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

  // 2D Сцена (Възли)
  final List<Map<String, dynamic>> _scene2DNodes = [
    {'id': 'player', 'name': 'CharacterBody2D (Hero)', 'type': 'player', 'x': 1, 'y': 2, 'hp': 3, 'speed': 4.5, 'jumpForce': 12.5},
    {'id': 'tile_0', 'name': 'TileMapLayer (Grass 0)', 'type': 'grass', 'x': 0, 'y': 5, 'isSolid': true},
    {'id': 'tile_1', 'name': 'TileMapLayer (Grass 1)', 'type': 'grass', 'x': 1, 'y': 5, 'isSolid': true},
    {'id': 'tile_2', 'name': 'TileMapLayer (Grass 2)', 'type': 'grass', 'x': 2, 'y': 5, 'isSolid': true},
    {'id': 'tile_3', 'name': 'TileMapLayer (Grass 3)', 'type': 'grass', 'x': 3, 'y': 5, 'isSolid': true},
    {'id': 'tile_4', 'name': 'TileMapLayer (Grass 4)', 'type': 'grass', 'x': 4, 'y': 5, 'isSolid': true},
    {'id': 'tile_5', 'name': 'TileMapLayer (Grass 5)', 'type': 'grass', 'x': 5, 'y': 5, 'isSolid': true},
    {'id': 'tile_6', 'name': 'TileMapLayer (Grass 6)', 'type': 'grass', 'x': 6, 'y': 5, 'isSolid': true},
    {'id': 'plat_1', 'name': 'TileMapLayer (Bridge)', 'type': 'platform', 'x': 3, 'y': 3, 'isSolid': true},
    {'id': 'coin_1', 'name': 'Area2D (Star Coin)', 'type': 'coin', 'x': 3, 'y': 2, 'points': 100, 'collected': false},
    {'id': 'enemy_1', 'name': 'CharacterBody2D (Slime AI)', 'type': 'enemy', 'x': 5, 'y': 4, 'curX': 5.0, 'dir': 1, 'minX': 3, 'maxX': 6},
    {'id': 'spikes_1', 'name': 'Area2D (Spikes Trap)', 'type': 'spikes', 'x': 4, 'y': 5, 'damage': 1},
    {'id': 'portal_1', 'name': 'Area2D (Win Goal)', 'type': 'portal', 'x': 6, 'y': 4},
  ];

  @override
  void initState() {
    super.initState();
    _fx2DController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _fx2DController.dispose();
    _aiPromptController.dispose();
    super.dispose();
  }

  // =========================================================================
  // 🎮 2D PLAYTEST LOOP (60 FPS BOX2D PHYSICS)
  // =========================================================================

  void _toggleSimulation() {
    setState(() => _isSimulating = !_isSimulating);
    if (_isSimulating) {
      _startSimulation();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('▶ 2D Live Engine: Старт на 60 FPS играта!')));
    } else {
      _gameLoopTimer?.cancel();
      FilamentEngine().clear2DWorld();
    }
  }

  void _startSimulation() {
    _gameLoopTimer?.cancel();
    final playerNode = _scene2DNodes.firstWhere((e) => e['type'] == 'player', orElse: () => {'x': 1, 'y': 2});
    _playerX = ((playerNode['x'] as num).toDouble() * 36.0) + 18.0;
    _playerY = ((playerNode['y'] as num).toDouble() * 36.0) + 40.0;
    _velX = 0.0;
    _velY = 0.0;
    _score = 0;
    _playerHp = (playerNode['hp'] as num?)?.toInt() ?? 3;
    _isLevelComplete = false;

    for (var el in _scene2DNodes) {
      if (el['type'] == 'coin') el['collected'] = false;
      if (el['type'] == 'enemy') el['curX'] = (el['x'] as num).toDouble();
    }

    FilamentEngine().create2DWorld(gravityY: 9.81);

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

          if (type == 'spikes' && playerBox.overlaps(tileBox)) {
            _playerHp -= 1;
            if (_playerHp <= 0) {
              _playerX = 36.0;
              _playerY = 72.0;
              _playerHp = 3;
            } else {
              _velY = -8.0;
              _playerX = 36.0;
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
        _facingDirection = dir > 0 ? 1 : -1;
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

  void _executeAiCommand(String prompt) {
    if (prompt.trim().isEmpty) return;
    String p = prompt.toLowerCase();

    setState(() {
      if (p.contains('замък') || p.contains('castle')) {
        _scene2DNodes.clear();
        _scene2DNodes.addAll([
          {'id': 'player', 'name': 'CharacterBody2D (Knight)', 'type': 'player', 'x': 1, 'y': 2, 'hp': 4},
          {'id': 'g0', 'name': 'Castle Floor 0', 'type': 'grass', 'x': 0, 'y': 5, 'isSolid': true},
          {'id': 'g1', 'name': 'Castle Floor 1', 'type': 'grass', 'x': 1, 'y': 5, 'isSolid': true},
          {'id': 'g2', 'name': 'Castle Floor 2', 'type': 'grass', 'x': 2, 'y': 5, 'isSolid': true},
          {'id': 'g3', 'name': 'Castle Floor 3', 'type': 'grass', 'x': 3, 'y': 5, 'isSolid': true},
          {'id': 'g4', 'name': 'Castle Floor 4', 'type': 'grass', 'x': 4, 'y': 5, 'isSolid': true},
          {'id': 'bridge', 'name': 'Drawbridge', 'type': 'platform', 'x': 3, 'y': 3, 'isSolid': true},
          {'id': 'coin', 'name': 'Golden Crown', 'type': 'coin', 'x': 3, 'y': 2, 'points': 200, 'collected': false},
          {'id': 'guard', 'name': 'Guard AI', 'type': 'enemy', 'x': 4, 'y': 4, 'curX': 4.0, 'dir': 1, 'minX': 2, 'maxX': 6},
          {'id': 'win', 'name': 'Throne Portal', 'type': 'portal', 'x': 7, 'y': 4},
        ]);
      } else if (p.contains('изчисти') || p.contains('изтрий')) {
        _scene2DNodes.clear();
        _scene2DNodes.add({'id': 'player', 'name': 'Player Spawn', 'type': 'player', 'x': 1, 'y': 2, 'hp': 3});
      } else {
        _scene2DNodes.add({
          'id': 'node_${DateTime.now().millisecondsSinceEpoch}',
          'name': 'Node ($prompt)',
          'type': 'platform',
          'x': 3,
          'y': 3,
          'isSolid': true,
        });
      }
    });

    _aiPromptController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('⚡ 2D AI Copilot: Сцената беше обновена за "$prompt"!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedNode = _selectedNodeId != null
        ? _scene2DNodes.firstWhere((e) => e['id'] == _selectedNodeId, orElse: () => {})
        : null;

    return Stack(
      children: [
        // 1. БЕЗКРАЕН 2D VIEWPORT (95% от екрана)
        Positioned.fill(
          child: GestureDetector(
            onTapDown: (details) {
              if (_isSimulating) return;
              final local = details.localPosition;
              int col = (local.dx / 36.0).floor();
              int row = ((local.dy - 40.0) / 36.0).floor();
              if (row < 0 || col < 0 || col > 9) return;

              setState(() {
                if (_editorMode == 'select') {
                  final found = _scene2DNodes.firstWhere((e) => e['x'] == col && e['y'] == row, orElse: () => {});
                  if (found.isNotEmpty) {
                    _selectedNodeId = found['id'];
                    _showNodeInspector = true;
                  } else {
                    _selectedNodeId = null;
                  }
                } else if (_editorMode == 'erase') {
                  _scene2DNodes.removeWhere((e) => e['x'] == col && e['y'] == row);
                } else {
                  _scene2DNodes.removeWhere((e) => e['x'] == col && e['y'] == row);
                  String id = 'node_${DateTime.now().millisecondsSinceEpoch}';
                  Map<String, dynamic> newNode = {'id': id, 'name': 'Node ($col, $row)', 'type': _selectedTile, 'x': col, 'y': row};
                  if (_selectedTile == 'grass' || _selectedTile == 'dirt' || _selectedTile == 'platform') {
                    newNode['isSolid'] = true;
                    newNode['name'] = 'TileMapLayer ($_selectedTile)';
                  } else if (_selectedTile == 'coin') {
                    newNode['name'] = 'Area2D (Coin)';
                    newNode['collected'] = false;
                  } else if (_selectedTile == 'enemy') {
                    newNode['name'] = 'CharacterBody2D (Enemy)';
                    newNode['dir'] = 1;
                    newNode['minX'] = 1;
                    newNode['maxX'] = 8;
                    newNode['curX'] = col.toDouble();
                  } else if (_selectedTile == 'spikes') {
                    newNode['name'] = 'Area2D (Spikes)';
                    newNode['damage'] = 1;
                  } else if (_selectedTile == 'portal') {
                    newNode['name'] = 'Area2D (Win Goal)';
                  }
                  _scene2DNodes.add(newNode);
                }
              });
            },
            child: AnimatedBuilder(
              animation: _fx2DController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: Godot2DEnginePainter(
                    nodes: _scene2DNodes,
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

        // 2. ГОРЕН СТАТУС И LIVE TEST БУТОН
        Positioned(
          top: 8,
          left: 10,
          right: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xCC101424),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF222A40)),
                ),
                child: Row(
                  children: [
                    Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF00E676), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('60 FPS • Godot 2D • ${_scene2DNodes.length} възела', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              GestureDetector(
                onTap: _toggleSimulation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isSimulating
                          ? [const Color(0xFFFF1744), const Color(0xFFFF5252)]
                          : [const Color(0xFF00E676), const Color(0xFF00E5FF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: (_isSimulating ? Colors.red : const Color(0xFF00E676)).withValues(alpha: 0.4), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(_isSimulating ? Icons.stop : Icons.play_arrow, size: 14, color: Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        _isSimulating ? 'STOP' : 'TEST 2D',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. ПЛАВАЩ СМАРТ ДОК ЗА 2D ИНСТРУМЕНТИ (ОТЛЯВО)
        if (!_isSimulating)
          Positioned(
            left: 10,
            top: 60,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xCC141828),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF242C44)),
              ),
              child: Column(
                children: [
                  _buildSmart2DToolBtn(Icons.crop_square, 'grass', 'Земя'),
                  const SizedBox(height: 6),
                  _buildSmart2DToolBtn(Icons.layers, 'platform', 'Мост'),
                  const SizedBox(height: 6),
                  _buildSmart2DToolBtn(Icons.monetization_on, 'coin', 'Монета'),
                  const SizedBox(height: 6),
                  _buildSmart2DToolBtn(Icons.pest_control, 'enemy', 'Враг'),
                  const SizedBox(height: 6),
                  _buildSmart2DToolBtn(Icons.warning_amber, 'spikes', 'Шип'),
                  const SizedBox(height: 6),
                  _buildSmart2DToolBtn(Icons.vpn_key, 'portal', 'Цел'),
                  const SizedBox(height: 6),
                  _buildSmart2DToolBtn(Icons.cleaning_services, 'erase', 'Изтрий'),
                ],
              ),
            ),
          ),

        // 4. ИНСПЕКТОР НА ИЗБРАНИЯ ВЪЗЕЛ (КАРТА В ЪГЪЛА)
        if (_showNodeInspector && selectedNode != null && selectedNode.isNotEmpty && !_isSimulating)
          Positioned(
            right: 10,
            top: 60,
            width: 175,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xEE121626),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.laserPink.withValues(alpha: 0.6)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(selectedNode['name'] ?? 'Node', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _showNodeInspector = false),
                        child: const Icon(Icons.close, size: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 10),
                  _buildCompactProp('Grid X:', selectedNode['x'].toString()),
                  _buildCompactProp('Grid Y:', selectedNode['y'].toString()),
                  _buildCompactProp('Тип:', selectedNode['type'].toString()),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 24,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: EdgeInsets.zero),
                      onPressed: () {
                        setState(() {
                          _scene2DNodes.removeWhere((n) => n['id'] == selectedNode['id']);
                          _selectedNodeId = null;
                          _showNodeInspector = false;
                        });
                      },
                      child: const Text('ИЗТРИЙ ВЪЗЕЛ', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 5. 🪄 ПЛАВАЩА 2D AI COPILOT ЛЕНТА ОТДОЛУ
        if (!_isSimulating)
          Positioned(
            left: 10,
            right: 10,
            bottom: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 28,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildAiPromptChip('🏰 2D Замък', 'построй 2d замък с платформи и рицар'),
                      _buildAiPromptChip('🪙 Златна Пътека', 'добави 5 монети във въздуха'),
                      _buildAiPromptChip('👾 AI Патрул', 'добави патрулиращ враг'),
                      _buildAiPromptChip('🧹 Изчисти Сцената', 'изчисти сцената'),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xEE161A2C),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF00E676).withValues(alpha: 0.15), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF00E676), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _aiPromptController,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          decoration: const InputDecoration(
                            hintText: '2D AI Copilot: Напиши "построй замък", "добави монети"...',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 11),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (val) => _executeAiCommand(val),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.arrow_upward_rounded, color: Color(0xFF00E676), size: 22),
                        onPressed: () => _executeAiCommand(_aiPromptController.text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // 6. ПОБЕДЕН ЕКРАН ПРИ КРАЙ НА НИВОТО
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
        if (_isSimulating && !_isLevelComplete) ...[
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

  Widget _buildSmart2DToolBtn(IconData icon, String tool, String label) {
    bool isSel = _selectedTile == tool && _editorMode == 'pencil';
    if (tool == 'erase') isSel = _editorMode == 'erase';

    return GestureDetector(
      onTap: () {
        setState(() {
          if (tool == 'erase') {
            _editorMode = 'erase';
          } else {
            _editorMode = 'pencil';
            _selectedTile = tool;
          }
        });
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF00E676).withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: isSel ? Border.all(color: const Color(0xFF00E676)) : null,
        ),
        child: Icon(icon, size: 16, color: isSel ? const Color(0xFF00E676) : Colors.white70),
      ),
    );
  }

  Widget _buildAiPromptChip(String label, String prompt) {
    return GestureDetector(
      onTap: () => _executeAiCommand(prompt),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xCC1A1F30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4)),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildCompactProp(String label, String value) {
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
