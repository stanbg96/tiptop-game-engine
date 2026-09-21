import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/core/services/scene_command_bus.dart';
import 'package:tiptop_game_engine/features/brain_ai/logic/ai_service.dart';

class MushroomStudioScreen extends StatefulWidget {
  const MushroomStudioScreen({Key? key}) : super(key: key);

  @override
  State<MushroomStudioScreen> createState() => _MushroomStudioScreenState();
}

class _MushroomStudioScreenState extends State<MushroomStudioScreen> {
  final SceneCommandBus _commandBus = SceneCommandBus();
  final AiService _aiService = AiService();
  final TextEditingController _consoleController = TextEditingController();
  final ScrollController _logScrollController = ScrollController();

  bool _is3DMode = true;
  bool _isNightMode = false;
  bool _isProcessing = false;

  // Интерактивна камера на чистия прозорец
  double _camYaw = 0.8;
  double _camPitch = 0.45;
  double _camZoom = 1.0;

  // Конзолен дневник на командите
  final List<Map<String, String>> _consoleLogs = [
    {
      'role': 'engine',
      'text': '⚡ TipTop Future Engine v2.0 инициализиран. Viewport готов. Напиши команда долу.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _commandBus.addListener(_onSceneMutated);
  }

  @override
  void dispose() {
    _commandBus.removeListener(_onSceneMutated);
    _consoleController.dispose();
    _logScrollController.dispose();
    super.dispose();
  }

  void _onSceneMutated() {
    if (mounted) setState(() {});
  }

  void _executeCommand() async {
    final text = _consoleController.text.trim();
    if (text.isEmpty || _isProcessing) return;

    _consoleController.clear();
    setState(() {
      _consoleLogs.add({'role': 'user', 'text': text});
      _isProcessing = true;
    });

    _scrollToBottom();

    // 1. Анализ за специални команди за осветление и среда
    final lower = text.toLowerCase();
    if (lower.contains('нощ') || lower.contains('night')) {
      _isNightMode = true;
    } else if (lower.contains('ден') || lower.contains('слънце') || lower.contains('day')) {
      _isNightMode = false;
    }

    if (lower.contains('2d')) {
      _is3DMode = false;
    } else if (lower.contains('3d')) {
      _is3DMode = true;
    }

    // 2. Изпълнение на командата към сцената
    final result = _commandBus.executeAiPrompt(text);

    // 3. Анализ от AI сервиза за естествен отговор
    final aiResponse = await _aiService.sendPrompt(text, isBuilderMode: true);

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _consoleLogs.add({
        'role': 'engine',
        'text': '${result.message}\n💬 $aiResponse',
      });
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final nodes = _commandBus.live3DNodes;

    return Scaffold(
      backgroundColor: const Color(0xFF07080D),
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // 1. ЧИСТ VIEWPORT (ГОРНА ЧАСТ НА ЕКРАНА)
            // ==========================================
            Expanded(
              flex: 11,
              child: Stack(
                children: [
                  // Свободна интерактивна камера без никакви блокиращи overlay панели
                  Positioned.fill(
                    child: GestureDetector(
                      onScaleUpdate: (details) {
                        setState(() {
                          if (details.scale != 1.0) {
                            _camZoom = (_camZoom * details.scale).clamp(0.4, 3.0);
                          } else {
                            _camYaw += details.focalPointDelta.dx * 0.009;
                            _camPitch = (_camPitch - details.focalPointDelta.dy * 0.009).clamp(0.08, 1.45);
                          }
                        });
                      },
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: PureCleanEnginePainter(
                          yaw: _camYaw,
                          pitch: _camPitch,
                          zoom: _camZoom,
                          is3D: _is3DMode,
                          isNight: _isNightMode,
                          nodes: nodes,
                        ),
                      ),
                    ),
                  ),

                  // Единствен фин превключвател горе в ъгъла (3D / 2D)
                  Positioned(
                    top: 10,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _is3DMode = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _is3DMode ? AppTheme.laserPink : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '3D PBR',
                                style: TextStyle(
                                  color: _is3DMode ? Colors.white : Colors.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _is3DMode = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: !_is3DMode ? AppTheme.sciFiCyan : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '2D SPRITE',
                                style: TextStyle(
                                  color: !_is3DMode ? Colors.black : Colors.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Индикатор за средата (Ден / Нощ / Обекти)
                  Positioned(
                    top: 12,
                    left: 14,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isNightMode ? const Color(0xFF00E5FF) : const Color(0xFFFFD600),
                            boxShadow: [
                              BoxShadow(
                                color: (_isNightMode ? const Color(0xFF00E5FF) : const Color(0xFFFFD600)).withValues(alpha: 0.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isNightMode ? 'Cyber Night • PBR Bloom' : 'Sunlit Day • Filament 60FPS',
                          style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Разделителна линия със светлинен неонов кант
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.laserPink.withValues(alpha: 0.8),
                    AppTheme.sciFiCyan.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),

            // ==========================================
            // 2. ИНТЕЛИГЕНТНА ЧАТ КОНЗОЛА (ДОЛНА ЧАСТ)
            // ==========================================
            Expanded(
              flex: 9,
              child: Container(
                color: const Color(0xFF0C0E16),
                child: Column(
                  children: [
                    // Дневник на командите и отговорите от енджина
                    Expanded(
                      child: ListView.builder(
                        controller: _logScrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        itemCount: _consoleLogs.length,
                        itemBuilder: (context, index) {
                          final log = _consoleLogs[index];
                          final isUser = log['role'] == 'user';

                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                              decoration: BoxDecoration(
                                color: isUser ? const Color(0xFF1E1333) : const Color(0xFF121624),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isUser
                                      ? AppTheme.laserPink.withValues(alpha: 0.5)
                                      : AppTheme.sciFiCyan.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                log['text']!,
                                style: TextStyle(
                                  color: isUser ? Colors.white : const Color(0xFFB0C0E0),
                                  fontSize: 12,
                                  height: 1.35,
                                  fontFamily: isUser ? null : 'monospace',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    if (_isProcessing)
                      const LinearProgressIndicator(
                        minHeight: 2,
                        backgroundColor: Colors.transparent,
                        color: AppTheme.sciFiCyan,
                      ),

                    // Поле за писане на команди
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF10121D),
                        border: Border(top: BorderSide(color: Color(0xFF1E2336), width: 1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF181C2C),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: TextField(
                                controller: _consoleController,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: const InputDecoration(
                                  hintText: 'Команда: "направи нощ", "построй град", "премести"...',
                                  hintStyle: TextStyle(color: Colors.grey, fontSize: 11),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (_) => _executeCommand(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _executeCommand,
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [AppTheme.laserPink, AppTheme.sciFiCyan],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.laserPink.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 🎨 ЧИСТ РЕНДЕРЕР НА VIEWPORT БЕЗ ИЗЛИШНИ БУТОНИ И МЕНЮТА
// =========================================================================

class PureCleanEnginePainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final double zoom;
  final bool is3D;
  final bool isNight;
  final List<Map<String, dynamic>> nodes;

  PureCleanEnginePainter({
    required this.yaw,
    required this.pitch,
    required this.zoom,
    required this.is3D,
    required this.isNight,
    required this.nodes,
  });

  Offset project(double x, double y, double z, Size size) {
    if (!is3D) {
      // 2D Ортогонална проекция
      return Offset(
        (x * 1.8 * zoom) + (size.width / 2.0),
        (y * 1.8 * zoom) + (size.height / 2.0),
      );
    }

    double cosY = math.cos(yaw);
    double sinY = math.sin(yaw);
    double rx = x * cosY - z * sinY;
    double rz = x * sinY + z * cosY;

    double cosP = math.cos(pitch);
    double sinP = math.sin(pitch);
    double ry = y * cosP - rz * sinP;
    double depthZ = y * sinP + rz * cosP;

    double fov = 420.0 * zoom;
    double dist = 480.0;
    double depth = depthZ + dist;
    if (depth < 1.0) depth = 1.0;

    double sx = (rx * fov / depth) + (size.width / 2.0);
    double sy = (ry * fov / depth) + (size.height / 2.0) - 10.0;

    return Offset(sx, sy);
  }

  double calculateDepth(double x, double y, double z) {
    double sinY = math.sin(yaw);
    double cosY = math.cos(yaw);
    double rz = x * sinY + z * cosY;

    double sinP = math.sin(pitch);
    double cosP = math.cos(pitch);
    return y * sinP + rz * cosP;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Атмосфера и небе (Ден или Кибер Нощ)
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isNight
            ? [const Color(0xFF05070E), const Color(0xFF0B101D), const Color(0xFF04060A)]
            : [const Color(0xFF1E2538), const Color(0xFF2C344E), const Color(0xFF131622)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    if (is3D) {
      _paint3DWorld(canvas, size);
    } else {
      _paint2DWorld(canvas, size);
    }
  }

  void _paint3DWorld(Canvas canvas, Size size) {
    // Безкрайна елегантна световна мрежа
    const double extent = 750.0;
    const double step = 60.0;
    final gridColor = isNight ? const Color(0xFF162035) : const Color(0xFF2A334A);
    final gridPaint = Paint()..color = gridColor..strokeWidth = 1.0;

    for (double i = -extent; i <= extent; i += step) {
      canvas.drawLine(project(i, 40.0, -extent, size), project(i, 40.0, extent, size), gridPaint);
      canvas.drawLine(project(-extent, 40.0, i, size), project(extent, 40.0, i, size), gridPaint);
    }

    // Световни оси
    canvas.drawLine(project(-extent, 40.0, 0, size), project(extent, 40.0, 0, size), Paint()..color = const Color(0xFFFF3366)..strokeWidth = 1.8);
    canvas.drawLine(project(0, 40.0, -extent, size), project(0, 40.0, extent, size), Paint()..color = const Color(0xFF00E5FF)..strokeWidth = 1.8);

    // Сортиране на обектите
    List<Map<String, dynamic>> sorted = List.from(nodes);
    sorted.sort((a, b) {
      double d1 = calculateDepth((a['x'] as num).toDouble(), (a['y'] as num).toDouble(), (a['z'] as num).toDouble());
      double d2 = calculateDepth((b['x'] as num).toDouble(), (b['y'] as num).toDouble(), (b['z'] as num).toDouble());
      return d1.compareTo(d2);
    });

    // Изчертаване на реалните сцени
    for (var node in sorted) {
      double ox = (node['x'] as num).toDouble();
      double oy = (node['y'] as num).toDouble();
      double oz = (node['z'] as num).toDouble();
      double s = (node['size'] as num).toDouble();
      Color c = node['color'] as Color? ?? AppTheme.laserPink;
      String type = node['type']?.toString() ?? 'block';
      String name = node['name']?.toString().toLowerCase() ?? '';

      if (type == 'lava') {
        _drawLavaZone(canvas, size, ox, oy, oz, s);
      } else if (name.contains('skyscraper') || name.contains('кула') || name.contains('град')) {
        _drawSkyscraper(canvas, size, ox, oy, oz, s, c);
      } else if (type == 'player') {
        _drawHeroPawn(canvas, size, ox, oy, oz, s);
      } else if (type == 'coin') {
        _drawGoldenOrb(canvas, size, ox, oy, oz, s);
      } else {
        _drawPBRSolidMesh(canvas, size, ox, oy, oz, s, s * 0.9, s, c);
      }
    }
  }

  void _paint2DWorld(Canvas canvas, Size size) {
    const double s = 40.0 * 1.5;
    final grid = Paint()..color = const Color(0xFF1B2234)..strokeWidth = 0.8;

    for (double x = 0; x < size.width; x += s) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += s) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // Рисуване на 2D възлите като чисти красиви елементи
    for (var node in nodes) {
      double nx = (node['x'] as num).toDouble() * 32.0;
      double ny = (node['y'] as num).toDouble() * 32.0;
      Offset pos = project(nx, ny, 0, size);
      Color c = node['color'] as Color? ?? AppTheme.laserPink;

      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pos, width: 34 * zoom, height: 34 * zoom), const Radius.circular(6)),
        Paint()..color = c,
      );
    }
  }

  void _drawSkyscraper(Canvas canvas, Size size, double x, double y, double z, double s, Color c) {
    double h = s * 2.4;
    double w = s * 0.95;
    _drawPBRSolidMesh(canvas, size, x, y - h / 2.0 + 15.0, z, w, h, w, c);

    // Светещи етажи
    for (int f = 1; f <= 5; f++) {
      double fy = y + 10.0 - (f * (h / 6.0));
      Offset w1 = project(x - w * 0.25, fy, z + w / 2.0 + 1.0, size);
      Offset w2 = project(x + w * 0.25, fy, z + w / 2.0 + 1.0, size);
      final p = Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.85)..strokeWidth = 2.5 * zoom;
      canvas.drawCircle(w1, 2.0 * zoom, p);
      canvas.drawCircle(w2, 2.0 * zoom, p);
    }
  }

  void _drawHeroPawn(Canvas canvas, Size size, double x, double y, double z, double s) {
    Offset head = project(x, y - s * 0.9, z, size);
    _drawPBRSolidMesh(canvas, size, x, y - s * 0.2, z, s * 0.6, s * 0.8, s * 0.5, AppTheme.laserPink);
    canvas.drawCircle(head, 8.5 * zoom, Paint()..color = Colors.white);
    canvas.drawCircle(head, 3.5 * zoom, Paint()..color = AppTheme.sciFiCyan);
  }

  void _drawGoldenOrb(Canvas canvas, Size size, double x, double y, double z, double s) {
    Offset pos = project(x, y, z, size);
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFFFD600).withValues(alpha: 0.85), Colors.transparent],
      ).createShader(Rect.fromCircle(center: pos, radius: 18.0 * zoom));
    canvas.drawCircle(pos, 18.0 * zoom, glow);
    canvas.drawCircle(pos, 8.0 * zoom, Paint()..color = const Color(0xFFFFC107));
  }

  void _drawLavaZone(Canvas canvas, Size size, double x, double y, double z, double s) {
    final lava = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFFF3D00).withValues(alpha: 0.8), const Color(0xFFBF360C).withValues(alpha: 0.2)],
      ).createShader(Rect.fromCircle(center: project(x, 39.0, z, size), radius: s * zoom));

    Path p = Path()
      ..moveTo(project(x - s, 39.5, z - s, size).dx, project(x - s, 39.5, z - s, size).dy)
      ..lineTo(project(x + s, 39.5, z - s, size).dx, project(x + s, 39.5, z - s, size).dy)
      ..lineTo(project(x + s, 39.5, z + s, size).dx, project(x + s, 39.5, z + s, size).dy)
      ..lineTo(project(x - s, 39.5, z + s, size).dx, project(x - s, 39.5, z + s, size).dy)
      ..close();
    canvas.drawPath(p, lava);
  }

  void _drawPBRSolidMesh(Canvas canvas, Size size, double x, double y, double z, double sx, double sy, double sz, Color c) {
    double hx = sx / 2.0;
    double hy = sy / 2.0;
    double hz = sz / 2.0;

    List<Offset> v = [
      project(x - hx, y - hy, z - hz, size),
      project(x + hx, y - hy, z - hz, size),
      project(x + hx, y - hy, z + hz, size),
      project(x - hx, y - hy, z + hz, size),
      project(x - hx, y + hy, z - hz, size),
      project(x + hx, y + hy, z - hz, size),
      project(x + hx, y + hy, z + hz, size),
      project(x - hx, y + hy, z + hz, size),
    ];

    final hsl = HSLColor.fromColor(c);
    final topC = hsl.withLightness((hsl.lightness + 0.16).clamp(0.0, 1.0)).toColor();
    final frontC = hsl.toColor();
    final sideC = hsl.withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0)).toColor();

    Path top = Path()..moveTo(v[0].dx, v[0].dy)..lineTo(v[1].dx, v[1].dy)..lineTo(v[2].dx, v[2].dy)..lineTo(v[3].dx, v[3].dy)..close();
    canvas.drawPath(top, Paint()..color = topC);

    Path front = Path()..moveTo(v[3].dx, v[3].dy)..lineTo(v[2].dx, v[2].dy)..lineTo(v[6].dx, v[6].dy)..lineTo(v[7].dx, v[7].dy)..close();
    canvas.drawPath(front, Paint()..color = frontC);

    Path right = Path()..moveTo(v[2].dx, v[2].dy)..lineTo(v[1].dx, v[1].dy)..lineTo(v[5].dx, v[5].dy)..lineTo(v[6].dx, v[6].dy)..close();
    canvas.drawPath(right, Paint()..color = sideC);

    final edge = Paint()..color = c.withValues(alpha: 0.35)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    canvas.drawPath(top, edge);
    canvas.drawPath(front, edge);
    canvas.drawPath(right, edge);
  }

  @override
  bool shouldRepaint(covariant PureCleanEnginePainter oldDelegate) => true;
}
