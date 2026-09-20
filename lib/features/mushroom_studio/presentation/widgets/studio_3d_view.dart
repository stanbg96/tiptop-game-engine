import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/engine_bridge/filament_bindings.dart';
import 'package:tiptop_game_engine/features/mushroom_studio/presentation/widgets/studio_3d_painter.dart';

class Studio3DView extends StatefulWidget {
  const Studio3DView({Key? key}) : super(key: key);

  @override
  State<Studio3DView> createState() => _Studio3DViewState();
}

class _Studio3DViewState extends State<Studio3DView> {
  Timer? _gameLoop3DTimer;

  // 3D Камера в редактора
  double _camYaw = 0.75;
  double _camPitch = 0.55;
  double _camZoom = 1.0;
  String _selectedTool = 'orbit'; // orbit, move, scale
  String? _selectedNodeId;

  // Playable 3D Mode & Физика
  bool _isPlayMode = false;
  double _player3dX = 0.0;
  double _player3dZ = 0.0;
  int _score3D = 0;

  // Godot 4 3D Сцена (Дърво на възлите)
  final List<Map<String, dynamic>> _scene3DNodes = [
    {
      'id': 'player_spawn',
      'name': 'CharacterBody3D (Player)',
      'x': 0.0,
      'y': -25.0,
      'z': 0.0,
      'size': 32.0,
      'color': AppTheme.laserPink,
      'type': 'player',
      'glow': 0.8,
    },
    {
      'id': 'lava_lake',
      'name': 'Area3D (Lava Hazard)',
      'x': 0.0,
      'y': 60.0,
      'z': 0.0,
      'size': 100.0,
      'color': const Color(0xFFFF3D00),
      'type': 'lava',
      'glow': 1.0,
    },
    {
      'id': 'block_alpha',
      'name': 'MeshInstance3D (Neon Platform Alpha)',
      'x': -65.0,
      'y': 15.0,
      'z': -30.0,
      'size': 32.0,
      'color': AppTheme.sciFiCyan,
      'type': 'block',
      'glow': 0.4,
    },
    {
      'id': 'block_beta',
      'name': 'MeshInstance3D (Neon Platform Beta)',
      'x': 65.0,
      'y': -15.0,
      'z': 30.0,
      'size': 32.0,
      'color': const Color(0xFF00E676),
      'type': 'block',
      'glow': 0.4,
    },
    {
      'id': 'star_coin',
      'name': 'Area3D (Star Coin Pickup)',
      'x': -65.0,
      'y': -25.0,
      'z': -30.0,
      'size': 18.0,
      'color': const Color(0xFFFFD600),
      'type': 'coin',
      'glow': 0.9,
    },
  ];

  final List<List<Map<String, dynamic>>> _undoHistory = [];

  @override
  void dispose() {
    _gameLoop3DTimer?.cancel();
    super.dispose();
  }

  void _saveUndoState() {
    _undoHistory.add(_scene3DNodes.map((e) => Map<String, dynamic>.from(e)).toList());
    if (_undoHistory.length > 25) _undoHistory.removeAt(0);
  }

  void _performUndo() {
    if (_undoHistory.isNotEmpty) {
      setState(() {
        _scene3DNodes.clear();
        _scene3DNodes.addAll(_undoHistory.removeLast());
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('↩️ Godot Undo: Отменено 3D действие!')),
      );
    }
  }

  // =========================================================================
  // 🎮 PLAYABLE 3D JOLT PHYSICS LOOP
  // =========================================================================

  void _togglePlayMode() {
    setState(() => _isPlayMode = !_isPlayMode);

    if (_isPlayMode) {
      _startPlayMode();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('▶ Godot 4 3D Play Mode: Стартиран Third-Person свят!')),
      );
    } else {
      _stopPlayMode();
    }
  }

  void _startPlayMode() {
    _gameLoop3DTimer?.cancel();
    _player3dX = 0.0;
    _player3dZ = 0.0;
    _score3D = 0;

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

  // =========================================================================
  // 🌲 GODOT 3D SCENE TREE MODAL
  // =========================================================================

  void _showSceneTreeModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: AppTheme.sciFiCyan, width: 1.2),
      ),
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
                    const Row(
                      children: [
                        Icon(Icons.account_tree_outlined, color: AppTheme.sciFiCyan, size: 20),
                        SizedBox(width: 8),
                        Text('🌲 Godot 4 3D Scene Tree', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12),
                SizedBox(
                  height: 240,
                  child: ListView.builder(
                    itemCount: _scene3DNodes.length,
                    itemBuilder: (context, index) {
                      final node = _scene3DNodes[index];
                      final bool isSelected = node['id'] == _selectedNodeId;
                      final Color col = node['color'] as Color? ?? Colors.white;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? col.withValues(alpha: 0.25) : const Color(0xFF161826),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? col : Colors.white10),
                        ),
                        child: ListTile(
                          dense: true,
                          leading: Icon(Icons.view_in_ar, color: col, size: 18),
                          title: Text(node['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
                          subtitle: Text('XYZ: (${(node['x'] as num).toInt()}, ${(node['y'] as num).toInt()}, ${(node['z'] as num).toInt()})', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                          trailing: IconButton(
                            icon: const Icon(Icons.tune, color: AppTheme.laserPink, size: 16),
                            onPressed: () {
                              setState(() => _selectedNodeId = node['id']);
                              Navigator.pop(context);
                              _showInspectorModal(node);
                            },
                          ),
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

  // =========================================================================
  // 🔍 GODOT 3D PROPERTY & PBR MATERIAL INSPECTOR
  // =========================================================================

  void _showInspectorModal(Map<String, dynamic> node) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: AppTheme.laserPink, width: 1.2),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 18,
              right: 18,
              top: 14,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.view_in_ar, color: node['color'] as Color? ?? AppTheme.laserPink, size: 20),
                        const SizedBox(width: 8),
                        Text(node['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () {
                        _saveUndoState();
                        setState(() {
                          _scene3DNodes.removeWhere((e) => e['id'] == node['id']);
                          _selectedNodeId = null;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🗑️ 3D Обектът е изтрит!')),
                        );
                      },
                    ),
                  ],
                ),
                const Divider(color: Colors.white12),

                // Настройки на 3D Обекта (Size & PBR Glow)
                _buildInspectorSlider('📏 3D Мащаб (Size / Scale)', (node['size'] as num).toDouble(), 10.0, 80.0, (val) {
                  setState(() => node['size'] = val);
                  setModalState(() {});
                }),
                _buildInspectorSlider('✨ Неонов Glow / Emissive', ((node['glow'] as num?)?.toDouble() ?? 0.5) * 100.0, 0.0, 100.0, (val) {
                  setState(() => node['glow'] = val / 100.0);
                  setModalState(() {});
                }),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.laserPink),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ЗАПАЗИ 3D НАСТРОЙКИТЕ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInspectorSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
            Text(value.toStringAsFixed(1), style: const TextStyle(color: AppTheme.sciFiCyan, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.laserPink,
            thumbColor: AppTheme.sciFiCyan,
            trackHeight: 3.0,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 📱 BUILD МЕТОД
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final selectedNode = _selectedNodeId != null
        ? _scene3DNodes.firstWhere((e) => e['id'] == _selectedNodeId, orElse: () => {})
        : null;

    return Stack(
      children: [
        // 1. 3D PERSPECTIVE VIEWPORT
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
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.2,
                colors: [Color(0xFF1B122C), Color(0xFF07080D)],
              ),
            ),
            child: CustomPaint(
              size: Size.infinite,
              painter: Studio3DEnginePainter(
                yaw: _camYaw,
                pitch: _camPitch,
                zoom: _camZoom,
                objects: _scene3DNodes,
                selectedNodeId: _selectedNodeId,
                isPlayMode: _isPlayMode,
                playerPos3D: Offset(_player3dX, _player3dZ),
              ),
            ),
          ),
        ),

        // 2. GODOT 4 3D TOP CONTROL BAR
        Positioned(
          top: 8,
          left: 8,
          right: 8,
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
                Row(
                  children: [
                    _buildTopBtn(Icons.threed_rotation, 'orbit', 'Orbit'),
                    const SizedBox(width: 4),
                    _buildTopBtn(Icons.open_with, 'move', 'XYZ'),
                    const SizedBox(width: 4),
                    _buildTopBtn(Icons.aspect_ratio, 'scale', 'Мащаб'),
                    const SizedBox(width: 6),
                    Container(height: 18, width: 1, color: Colors.white24),
                    const SizedBox(width: 6),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.account_tree_outlined, color: AppTheme.sciFiCyan, size: 20),
                      tooltip: '3D Scene Tree',
                      onPressed: _showSceneTreeModal,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.undo, color: Colors.white70, size: 20),
                      tooltip: 'Undo',
                      onPressed: _performUndo,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _togglePlayMode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isPlayMode
                            ? [const Color(0xFFFF1744), const Color(0xFFFF5252)]
                            : [AppTheme.laserPink, AppTheme.sciFiCyan],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(_isPlayMode ? Icons.stop : Icons.play_arrow, size: 15, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          _isPlayMode ? 'СТОП' : 'PLAY 3D',
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

        // 3. ДОЛЕН ИНСПЕКТОР / GIZMO КОНТРОЛЕР ЗА ИЗБРАНИЯ 3D ОБЕКТ
        if (selectedNode != null && selectedNode.isNotEmpty && !_isPlayMode)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xEE10121D),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: (selectedNode['color'] as Color? ?? AppTheme.laserPink).withValues(alpha: 0.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(selectedNode['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.tune, color: AppTheme.sciFiCyan, size: 18),
                        onPressed: () => _showInspectorModal(selectedNode),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (_selectedTool == 'move')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAxisBtn('X', Colors.redAccent, () => setState(() => selectedNode['x'] = (selectedNode['x'] as num).toDouble() - 10.0), () => setState(() => selectedNode['x'] = (selectedNode['x'] as num).toDouble() + 10.0), selectedNode['x']),
                        _buildAxisBtn('Y', Colors.greenAccent, () => setState(() => selectedNode['y'] = (selectedNode['y'] as num).toDouble() - 10.0), () => setState(() => selectedNode['y'] = (selectedNode['y'] as num).toDouble() + 10.0), selectedNode['y']),
                        _buildAxisBtn('Z', Colors.blueAccent, () => setState(() => selectedNode['z'] = (selectedNode['z'] as num).toDouble() - 10.0), () => setState(() => selectedNode['z'] = (selectedNode['z'] as num).toDouble() + 10.0), selectedNode['z']),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.touch_app, size: 14, color: AppTheme.sciFiCyan),
                        const SizedBox(width: 6),
                        Text('360° Orbit • Zoom: ${_camZoom.toStringAsFixed(1)}x', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                ],
              ),
            ),
          ),

        // 4. ТЪЧ КОНТРОЛИ & HUD В PLAY 3D РЕЖИМ
        if (_isPlayMode) ...[
          Positioned(
            top: 52,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD600)),
              ),
              child: Text(
                '🪙 Точки: $_score3D',
                style: const TextStyle(color: Color(0xFFFFD600), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildTouchControl(Icons.arrow_back, () => _movePlayer3D(-15.0, 0)),
                    const SizedBox(width: 8),
                    _buildTouchControl(Icons.arrow_forward, () => _movePlayer3D(15.0, 0)),
                    const SizedBox(width: 8),
                    _buildTouchControl(Icons.arrow_upward, () => _movePlayer3D(0, -15.0)),
                    const SizedBox(width: 8),
                    _buildTouchControl(Icons.arrow_downward, () => _movePlayer3D(0, 15.0)),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🦘 3D Скок в Jolt Physics!')),
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [AppTheme.laserPink, AppTheme.sciFiCyan]),
                      boxShadow: [
                        BoxShadow(color: AppTheme.laserPink.withValues(alpha: 0.6), blurRadius: 16),
                      ],
                    ),
                    child: const Center(
                      child: Text('СКОК 🚀', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTopBtn(IconData icon, String tool, String label) {
    bool isSel = _selectedTool == tool;
    return GestureDetector(
      onTap: () => setState(() => _selectedTool = tool),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.sciFiCyan.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSel ? Border.all(color: AppTheme.sciFiCyan) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSel ? AppTheme.sciFiCyan : Colors.grey),
            const SizedBox(width: 3),
            Text(label, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAxisBtn(String label, Color c, VoidCallback onMinus, VoidCallback onPlus, num val) {
    return Row(
      children: [
        Text('$label: ', style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 11)),
        GestureDetector(
          onTap: onMinus,
          child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFF1E2235), borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.remove, size: 14, color: Colors.white)),
        ),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 5.0), child: Text('${val.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
        GestureDetector(
          onTap: onPlus,
          child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFF1E2235), borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.add, size: 14, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildTouchControl(IconData icon, VoidCallback onTap) {
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
