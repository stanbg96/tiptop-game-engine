import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/core/services/scene_command_bus.dart';
import 'package:tiptop_game_engine/core/engine/universal_engine_core.dart';

class MushroomStudioScreen extends StatefulWidget {
  const MushroomStudioScreen({Key? key}) : super(key: key);

  @override
  State<MushroomStudioScreen> createState() => _MushroomStudioScreenState();
}

class _MushroomStudioScreenState extends State<MushroomStudioScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _gameLoop;
  final SceneCommandBus _bus = SceneCommandBus();
  final TextEditingController _promptController = TextEditingController();

  double _camYaw = 0.6;
  double _camPitch = 0.4;
  double _camZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _gameLoop = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _gameLoop.addListener(() {
      _bus.engine.update(0.016);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _gameLoop.dispose();
    _promptController.dispose();
    super.dispose();
  }

  void _sendPrompt() {
    String text = _promptController.text.trim();
    if (text.isEmpty) return;
    _bus.executeAiPrompt(text);
    _promptController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E101A),
        elevation: 0,
        title: const Text('🍄 Universal Engine (2D & 3D)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.laserPink,
          labelColor: AppTheme.laserPink,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.grid_on), text: '2D Енджин'),
            Tab(icon: Icon(Icons.view_in_ar), text: '3D Енджин'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ГОРЕН ЛОГ ЗА СЪБИТИЯТА
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFF141724),
            child: Text(
              _bus.engine.executionLog,
              style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),

          // ЦЕНТЪР: 2D ИЛИ 3D ПЛАТНО
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _build2DViewport(),
                _build3DViewport(),
              ],
            ),
          ),

          // ДОЛНО ПОЛЕ: ЧАТ ЗА УПРАВЛЕНИЕ НА ВСИЧКО В РЕАЛНО ВРЕМЕ
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161824),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppTheme.sciFiCyan.withValues(alpha: 0.5)),
                      ),
                      child: TextField(
                        controller: _promptController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Пиши: "слон в 3d", "бой стилиян георги", "дъжд вечер"...',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 11),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendPrompt(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.laserPink, AppTheme.sciFiCyan]),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                      onPressed: _sendPrompt,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. 2D VIEWPORT
  Widget _build2DViewport() {
    return Container(
      color: const Color(0xFF0A0C14),
      child: CustomPaint(
        size: Size.infinite,
        painter: Engine2DPainter(entities: _bus.engine.entities2D),
      ),
    );
  }

  // 2. 3D VIEWPORT
  Widget _build3DViewport() {
    List<Color> skyGradient = _bus.engine.timeOfDay >= 19.0
        ? [const Color(0xFF2A0845), const Color(0xFFFF5722), const Color(0xFF0F041D)]
        : [const Color(0xFF0D47A1), const Color(0xFF42A5F5)];

    return GestureDetector(
      onScaleUpdate: (details) {
        setState(() {
          if (details.scale != 1.0) {
            _camZoom = (_camZoom * details.scale).clamp(0.5, 3.0);
          } else {
            _camYaw += details.focalPointDelta.dx * 0.008;
            _camPitch = (_camPitch - details.focalPointDelta.dy * 0.008).clamp(0.1, 1.4);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: skyGradient),
        ),
        child: CustomPaint(
          size: Size.infinite,
          painter: Engine3DPainter(
            yaw: _camYaw,
            pitch: _camPitch,
            zoom: _camZoom,
            core: _bus.engine,
          ),
        ),
      ),
    );
  }
}

// РЕНДЕР ЗА 2D
class Engine2DPainter extends CustomPainter {
  final List<Entity2D> entities;
  Engine2DPainter({required this.entities});

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = Colors.white10..strokeWidth = 1.0;
    for (double x = 0; x < size.width; x += 32) canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    for (double y = 0; y < size.height; y += 32) canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);

    // Под
    canvas.drawRect(Rect.fromLTWH(0, size.height - 40, size.width, 40), Paint()..color = const Color(0xFF00E676));

    for (var e in entities) {
      final p = Paint()..color = e.color;
      if (e.type == 'coin') {
        canvas.drawCircle(e.pos, 10, p);
      } else {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(e.pos.dx - 14, e.pos.dy - 14, 28, 28), const Radius.circular(6)), p);
      }
      final tp = TextPainter(text: TextSpan(text: e.name, style: const TextStyle(color: Colors.white, fontSize: 10)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(e.pos.dx - tp.width / 2, e.pos.dy - 28));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// РЕНДЕР ЗА 3D
class Engine3DPainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final double zoom;
  final UniversalEngineCore core;

  Engine3DPainter({required this.yaw, required this.pitch, required this.zoom, required this.core});

  Offset project(double x, double y, double z, Size size) {
    double shake = core.cameraShake > 0 ? (math.sin(DateTime.now().millisecondsSinceEpoch * 0.1) * core.cameraShake) : 0.0;
    double cosY = math.cos(yaw);
    double sinY = math.sin(yaw);
    double x1 = x * cosY - z * sinY;
    double z1 = x * sinY + z * cosY;

    double cosP = math.cos(pitch);
    double sinP = math.sin(pitch);
    double y2 = y * cosP - z1 * sinP;
    double z2 = y * sinP + z1 * cosP;

    double fov = 380.0 * zoom;
    double dist = 420.0;
    double depth = z2 + dist;
    if (depth < 1.0) depth = 1.0;

    return Offset((x1 * fov / depth) + (size.width / 2) + shake, (y2 * fov / depth) + (size.height / 2) + 30);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 3D Мрежа на пода
    final grid = Paint()..color = Colors.cyanAccent.withValues(alpha: 0.2)..strokeWidth = 1.0;
    for (double i = -160; i <= 160; i += 32) {
      canvas.drawLine(project(i, 40, -160, size), project(i, 40, 160, size), grid);
      canvas.drawLine(project(-160, 40, i, size), project(160, 40, i, size), grid);
    }

    // 3D Обекти, Герои и Ленти с Кръв
    for (var e in core.entities3D) {
      final p = project(e.pos.x, e.pos.y, e.pos.z, size);
      double r = 16.0 * e.scale.x;

      canvas.drawCircle(p, r, Paint()..color = e.color);

      // Лента за здраве
      Offset hpPos = project(e.pos.x, e.pos.y - (30 * e.scale.y), e.pos.z, size);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(hpPos.dx - 20, hpPos.dy, 40, 5), const Radius.circular(2)), Paint()..color = Colors.black54);
      double ratio = (e.hp / e.maxHp).clamp(0.0, 1.0);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(hpPos.dx - 20, hpPos.dy, 40 * ratio, 5), const Radius.circular(2)), Paint()..color = e.hp > 30 ? Colors.greenAccent : Colors.redAccent);

      final tp = TextPainter(text: TextSpan(text: '${e.name} (${e.hp.toInt()} HP)', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(hpPos.dx - tp.width / 2, hpPos.dy - 12));
    }

    // Дъжд в 3D
    if (core.weather == 'rain') {
      final rainPaint = Paint()..color = Colors.lightBlueAccent.withValues(alpha: 0.6)..strokeWidth = 1.2;
      final rand = math.Random(42);
      for (int i = 0; i < 60; i++) {
        double rx = (rand.nextDouble() - 0.5) * 300;
        double ry = -120 + ((DateTime.now().millisecondsSinceEpoch * 0.4 + i * 20) % 240);
        double rz = (rand.nextDouble() - 0.5) * 300;
        canvas.drawLine(project(rx, ry, rz, size), project(rx, ry + 10, rz, size), rainPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
