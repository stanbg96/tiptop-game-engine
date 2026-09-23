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

  double _camYaw = 0.7;
  double _camPitch = 0.35;
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
        title: const Text('🍄 TipTop 3D & 2D Engine', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.laserPink,
          labelColor: AppTheme.laserPink,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.view_in_ar), text: '3D Свят'),
            Tab(icon: Icon(Icons.grid_on), text: '2D Свят'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ЛОГ ЗА СЪСТОЯНИЕТО
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFF141724),
            child: Text(
              _bus.engine.executionLog,
              style: const TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),

          // ЦЕНТРАЛНО ПЛАТНО
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReal3DView(),
                _buildReal2DView(),
              ],
            ),
          ),

          // ЧАТ ПОЛЕ
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
                          hintText: 'Пробвай: "къща за куче", "бой стилиян", "дъжд вечер"...',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 11),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendPrompt(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [AppTheme.laserPink, AppTheme.sciFiCyan]),
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

  // РЕАЛЕН 3D ИЗГЛЕД СЪС СВЕТЛОСЕНКИ И ПОКРИВИ
  Widget _buildReal3DView() {
    List<Color> sky = _bus.engine.timeOfDay >= 19.0
        ? [const Color(0xFF2E0854), const Color(0xFFFF5722), const Color(0xFF0F041D)]
        : [const Color(0xFF1565C0), const Color(0xFF64B5F6)];

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
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: sky)),
        child: CustomPaint(
          size: Size.infinite,
          painter: RealPolyhedron3DPainter(
            yaw: _camYaw,
            pitch: _camPitch,
            zoom: _camZoom,
            core: _bus.engine,
          ),
        ),
      ),
    );
  }

  // РЕАЛЕН 2D ИЗГЛЕД С ТРЕВА И КАМЪНИ
  Widget _buildReal2DView() {
    return Container(
      color: const Color(0xFF0D1117),
      child: CustomPaint(
        size: Size.infinite,
        painter: Real2DWorldPainter(tiles: _bus.engine.tiles2D),
      ),
    );
  }
}

// РЕНДЕР С ДЪЛБОЧИННО СОРТИРАНЕ (DEPTH SORTING) И СЕНКИ
class RealPolyhedron3DPainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final double zoom;
  final UniversalEngineCore core;

  RealPolyhedron3DPainter({required this.yaw, required this.pitch, required this.zoom, required this.core});

  Offset project(Vec3 v, Size size, {double shake = 0.0}) {
    double cosY = math.cos(yaw), sinY = math.sin(yaw);
    double x1 = v.x * cosY - v.z * sinY;
    double z1 = v.x * sinY + v.z * cosY;

    double cosP = math.cos(pitch), sinP = math.sin(pitch);
    double y2 = v.y * cosP - z1 * sinP;
    double z2 = v.y * sinP + z1 * cosP;

    double fov = 380.0 * zoom;
    double dist = 420.0;
    double depth = z2 + dist;
    if (depth < 1.0) depth = 1.0;

    return Offset((x1 * fov / depth) + (size.width / 2) + shake, -(y2 * fov / depth) + (size.height / 2) + 60);
  }

  @override
  void paint(Canvas canvas, Size size) {
    double shake = core.cameraShake > 0 ? (math.sin(DateTime.now().millisecondsSinceEpoch * 0.1) * core.cameraShake) : 0.0;
    Vec3 sunDir = const Vec3(0.5, -0.8, 0.4).normalized();

    // 1. 3D Земя (Мокър под с отразяваща мрежа)
    final gridPaint = Paint()..color = Colors.cyanAccent.withValues(alpha: 0.18)..strokeWidth = 1.0;
    for (double i = -160; i <= 160; i += 32) {
      canvas.drawLine(project(Vec3(i, 0, -160), size, shake: shake), project(Vec3(i, 0, 160), size, shake: shake), gridPaint);
      canvas.drawLine(project(Vec3(-160, 0, i), size, shake: shake), project(Vec3(160, 0, i), size, shake: shake), gridPaint);
    }

    // 2. Събиране на всички 3D полигони от всички модели
    List<Map<String, dynamic>> renderQueue = [];

    for (var model in core.models3D) {
      for (var poly in model.polys) {
        // Трансформиране на полигона в координатите на модела
        List<Vec3> worldVertices = poly.v.map((vert) => vert + model.pos).toList();

        // Пресмятане на средна дълбочина (Painter's Algorithm)
        double avgZ = 0;
        for (var wv in worldVertices) {
          double z1 = wv.x * math.sin(yaw) + wv.z * math.cos(yaw);
          double z2 = wv.y * math.sin(pitch) + z1 * math.cos(pitch);
          avgZ += z2;
        }
        avgZ /= worldVertices.length;

        poly.computeLighting(sunDir);

        renderQueue.add({
          'poly': poly,
          'vertices': worldVertices,
          'depth': avgZ,
        });
      }
    }

    // Сортиране от най-далечния към най-близкия (за да няма застъпване на формите!)
    renderQueue.sort((a, b) => (b['depth'] as double).compareTo(a['depth'] as double));

    // 3. Изрисуване на полигоните с осветление
    for (var item in renderQueue) {
      Poly3D poly = item['poly'];
      List<Vec3> verts = item['vertices'];

      Path path = Path();
      Offset first = project(verts[0], size, shake: shake);
      path.moveTo(first.dx, first.dy);

      for (int i = 1; i < verts.length; i++) {
        Offset pt = project(verts[i], size, shake: shake);
        path.lineTo(pt.dx, pt.dy);
      }
      path.close();

      canvas.drawPath(path, Paint()..color = poly.litColor..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 0.8);
    }

    // 4. Ленти за здраве и имена над моделите
    for (var model in core.models3D) {
      if (model.id == 'hero' || model.id == 'rival') {
        Offset headPos = project(Vec3(model.pos.x, model.pos.y + 44, model.pos.z), size, shake: shake);

        // Черна рамка на лентата
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(headPos.dx - 22, headPos.dy, 44, 5), const Radius.circular(2)), Paint()..color = Colors.black87);
        double hpRatio = (model.hp / model.maxHp).clamp(0.0, 1.0);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(headPos.dx - 22, headPos.dy, 44 * hpRatio, 5), const Radius.circular(2)), Paint()..color = model.hp > 30 ? Colors.greenAccent : Colors.redAccent);

        final tp = TextPainter(text: TextSpan(text: '${model.name} (${model.hp.toInt()} HP)', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
        tp.paint(canvas, Offset(headPos.dx - tp.width / 2, headPos.dy - 14));
      }
    }

    // 5. Дъждовни капки в 3D
    if (core.weather == 'rain') {
      final rainPaint = Paint()..color = Colors.lightBlueAccent.withValues(alpha: 0.75)..strokeWidth = 1.4;
      final rand = math.Random(1337);
      for (int i = 0; i < 70; i++) {
        double rx = (rand.nextDouble() - 0.5) * 320;
        double ry = ((DateTime.now().millisecondsSinceEpoch * 0.5 + i * 25) % 250);
        double rz = (rand.nextDouble() - 0.5) * 320;
        canvas.drawLine(project(Vec3(rx, ry, rz), size), project(Vec3(rx, ry - 14, rz), size), rainPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 2D РЕНДЕР С ТРЕВНИ ПЛОЧКИ И КАМЕННА ПЪТЕКА
class Real2DWorldPainter extends CustomPainter {
  final List<Tile2D> tiles;
  Real2DWorldPainter({required this.tiles});

  @override
  void paint(Canvas canvas, Size size) {
    const double tileSize = 36.0;

    // Зелена поляна
    canvas.drawRect(Rect.fromLTWH(0, size.height - 120, size.width, 120), Paint()..color = const Color(0xFF2E7D32));

    for (var tile in tiles) {
      double x = tile.pos.dx * tileSize + 10;
      double y = size.height - 120 + (tile.pos.dy - 4) * tileSize;

      if (tile.type == 'path') {
        // Каменна пътека
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, tileSize - 2, tileSize - 2), const Radius.circular(4)), Paint()..color = const Color(0xFF78909C));
        canvas.drawCircle(Offset(x + 10, y + 10), 3, Paint()..color = const Color(0xFF455A64));
      } else if (tile.type == 'grass') {
        // Свежа трева
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, tileSize - 2, tileSize - 2), const Radius.circular(6)), Paint()..color = const Color(0xFF4CAF50));
      } else if (tile.type == 'player') {
        // 2D Герой с очи и каска
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y - 10, 26, 32), const Radius.circular(6)), Paint()..color = const Color(0xFF00E5FF));
        canvas.drawCircle(Offset(x + 7, y - 2), 2, Paint()..color = Colors.black);
        canvas.drawCircle(Offset(x + 17, y - 2), 2, Paint()..color = Colors.black);
      } else if (tile.type == 'enemy') {
        // 2D Враг
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y - 10, 26, 32), const Radius.circular(6)), Paint()..color = const Color(0xFFFF1744));
        canvas.drawCircle(Offset(x + 8, y), 2.5, Paint()..color = Colors.yellow);
        canvas.drawCircle(Offset(x + 18, y), 2.5, Paint()..color = Colors.yellow);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
