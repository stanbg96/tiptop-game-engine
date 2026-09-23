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
  final TextEditingController _aiPromptController = TextEditingController();
  Timer? _gameLoop3DTimer;

  // 3D Камера
  double _camYaw = 0.75;
  double _camPitch = 0.55;
  double _camZoom = 0.85;
  String _selectedTool = 'orbit'; // orbit, select, gizmo
  String? _selectedNodeId;
  bool _showNodeInspector = false;

  // 3D Play Mode
  bool _isPlayMode = false;
  double _player3dX = 0.0;
  double _player3dZ = 0.0;

  @override
  void initState() {
    super.initState();
    _commandBus.addListener(_onSceneUpdated);
  }

  @override
  void dispose() {
    _commandBus.removeListener(_onSceneUpdated);
    _gameLoop3DTimer?.cancel();
    _aiPromptController.dispose();
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
      FilamentEngine().create3DWorld(gravityY: -9.81);
      _gameLoop3DTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
        if (!_isPlayMode) return;
        setState(() {
          FilamentEngine().step3D(0.016);
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('▶ 3D Live Engine: Свободен тест в 60 FPS свят!')),
      );
    } else {
      _gameLoop3DTimer?.cancel();
      FilamentEngine().clear3DWorld();
    }
  }

  void _movePlayer3D(double dx, double dz) {
    if (_isPlayMode) {
      setState(() {
        _player3dX = (_player3dX + dx).clamp(-850.0, 850.0);
        _player3dZ = (_player3dZ + dz).clamp(-850.0, 850.0);
      });
    }
  }

  void _executeAiCommand(String prompt) {
    if (prompt.trim().isEmpty) return;
    final res = _commandBus.executeAiPrompt(prompt);
    _aiPromptController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.message)),
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
        // 1. БЕЗКРАЕН 3D PBR VIEWPORT (95% от екрана)
        Positioned.fill(
          child: GestureDetector(
            onScaleUpdate: (details) {
              if (_isPlayMode) return;
              setState(() {
                if (details.scale != 1.0) {
                  _camZoom = (_camZoom * details.scale).clamp(0.25, 3.5);
                } else {
                  _camYaw += details.focalPointDelta.dx * 0.008;
                  _camPitch = (_camPitch - details.focalPointDelta.dy * 0.008).clamp(0.05, 1.48);
                }
              });
            },
            onTapDown: (details) {
              if (_isPlayMode) return;
              // Интелигентна селекция на обекти в 3D
              if (liveNodes.isNotEmpty) {
                setState(() {
                  _selectedNodeId = liveNodes.first['id'];
                  _showNodeInspector = true;
                });
              }
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
        ),

        // 2. ГОРИСТАТУС И LIVE TEST БУТОН
        Positioned(
          top: 8,
          left: 10,
          right: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Тънък статус бейдж от бъдещето
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
                    Text('60 FPS • Vulkan PBR • ${liveNodes.length} обекта', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // Live Playtest бутон
              GestureDetector(
                onTap: _togglePlayMode,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isPlayMode
                          ? [const Color(0xFFFF1744), const Color(0xFFFF5252)]
                          : [AppTheme.laserPink, AppTheme.sciFiCyan],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: (_isPlayMode ? Colors.red : AppTheme.laserPink).withValues(alpha: 0.4), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(_isPlayMode ? Icons.stop : Icons.play_arrow, size: 14, color: Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        _isPlayMode ? 'STOP' : 'TEST LIVE',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. ПЛАВАЩ СМАРТ ДОК ЗА ТЪЧ УПРАВЛЕНИЕ (ОТЛЯВО)
        if (!_isPlayMode)
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
                  _buildSmartToolBtn(Icons.threed_rotation, 'orbit', '360°'),
                  const SizedBox(height: 6),
                  _buildSmartToolBtn(Icons.touch_app, 'select', 'Select'),
                  const SizedBox(height: 6),
                  _buildSmartToolBtn(Icons.open_with, 'gizmo', 'Gizmo'),
                  const SizedBox(height: 6),
                  _buildSmartToolBtn(Icons.layers, 'inspector', 'Nodes', onTapCustom: () {
                    setState(() => _showNodeInspector = !_showNodeInspector);
                  }),
                ],
              ),
            ),
          ),

        // 4. ИНСПЕКТОР НА СВОЙСТВАТА НА ИЗБРАНИЯ ОБЕКТ (КАРТА В ЪГЪЛА)
        if (_showNodeInspector && selectedNode != null && selectedNode.isNotEmpty && !_isPlayMode)
          Positioned(
            right: 10,
            top: 60,
            width: 175,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xEE121626),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: (selectedNode['color'] as Color? ?? AppTheme.laserPink).withValues(alpha: 0.6)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10),
                ],
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
                  _buildCompactProp('X:', (selectedNode['x'] as num).toInt().toString()),
                  _buildCompactProp('Y:', (selectedNode['y'] as num).toInt().toString()),
                  _buildCompactProp('Z:', (selectedNode['z'] as num).toInt().toString()),
                  _buildCompactProp('Size:', (selectedNode['size'] as num).toInt().toString()),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickAdjustBtn('+X', () => setState(() => selectedNode['x'] = (selectedNode['x'] as num).toDouble() + 15.0)),
                      _buildQuickAdjustBtn('+Y', () => setState(() => selectedNode['y'] = (selectedNode['y'] as num).toDouble() - 15.0)),
                      _buildQuickAdjustBtn('+Z', () => setState(() => selectedNode['z'] = (selectedNode['z'] as num).toDouble() + 15.0)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 24,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: EdgeInsets.zero),
                      onPressed: () {
                        setState(() {
                          liveNodes.removeWhere((n) => n['id'] == selectedNode['id']);
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

        // 5. 🪄 ПЛАВАЩА AI COPILOT ЛЕНТА ОТДОЛУ (ВСИЧКО СЕ СТРОИ ОТ ТУК)
        if (!_isPlayMode)
          Positioned(
            left: 10,
            right: 10,
            bottom: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Бързи бутони за моментални светове
                SizedBox(
                  height: 28,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildAiPromptChip('🏙️ Cyberpunk Град', 'построй cyberpunk град с небостъргачи'),
                      _buildAiPromptChip('🌋 Лава Паркур', 'построй лава свят с платформи'),
                      _buildAiPromptChip('➕ Добави 3D Блок', 'добави нов блок в центъра'),
                      _buildAiPromptChip('🧹 Изчисти Сцената', 'изтрий всичко от сцената'),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Стъклено поле за писане на AI команди
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xEE161A2C),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.sciFiCyan.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(color: AppTheme.sciFiCyan.withValues(alpha: 0.15), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppTheme.sciFiCyan, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _aiPromptController,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          decoration: const InputDecoration(
                            hintText: 'AI Copilot: Напиши "построй град", "премести", "добави"...',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 11),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (val) => _executeAiCommand(val),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.arrow_upward_rounded, color: AppTheme.laserPink, size: 22),
                        onPressed: () => _executeAiCommand(_aiPromptController.text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // 6. ТЪЧ КОНТРОЛИ В СВОБОДЕН PLAY MODE
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
                    _buildPlayTouchBtn(Icons.arrow_back, () => _movePlayer3D(-25.0, 0)),
                    const SizedBox(width: 8),
                    _buildPlayTouchBtn(Icons.arrow_forward, () => _movePlayer3D(25.0, 0)),
                    const SizedBox(width: 8),
                    _buildPlayTouchBtn(Icons.arrow_upward, () => _movePlayer3D(0, -25.0)),
                    const SizedBox(width: 8),
                    _buildPlayTouchBtn(Icons.arrow_downward, () => _movePlayer3D(0, 25.0)),
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

  Widget _buildSmartToolBtn(IconData icon, String tool, String label, {VoidCallback? onTapCustom}) {
    bool isSel = _selectedTool == tool;
    return GestureDetector(
      onTap: () {
        if (onTapCustom != null) {
          onTapCustom();
        } else {
          setState(() => _selectedTool = tool);
        }
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isSel ? AppTheme.sciFiCyan.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(19),
          border: isSel ? Border.all(color: AppTheme.sciFiCyan) : null,
        ),
        child: Icon(icon, size: 18, color: isSel ? AppTheme.sciFiCyan : Colors.white70),
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
          border: Border.all(color: AppTheme.laserPink.withValues(alpha: 0.4)),
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
          Text(value, style: const TextStyle(color: AppTheme.sciFiCyan, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuickAdjustBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: const Color(0xFF242C44), borderRadius: BorderRadius.circular(4)),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
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
