import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/core/services/scene_command_bus.dart';

class MushroomStudioScreen extends StatefulWidget {
  const MushroomStudioScreen({Key? key}) : super(key: key);

  @override
  State<MushroomStudioScreen> createState() => _MushroomStudioScreenState();
}

class _MushroomStudioScreenState extends State<MushroomStudioScreen> {
  final SceneCommandBus _commandBus = SceneCommandBus();
  final TextEditingController _consoleController = TextEditingController();
  final ScrollController _logScrollController = ScrollController();

  bool _is3DMode = true;
  bool _isNightMode = false;
  bool _isProcessing = false;

  // 3D Камера
  double _camYaw = 0.8;
  double _camPitch = 0.45;
  double _camZoom = 1.0;

  // Конзолен дневник
  final List<Map<String, String>> _consoleLogs = [
    {
      'role': 'engine',
      'text': '⚡ TipTop Engine Viewport v2.5 готов. Напиши "създай къща", "кола", "град" или "изчисти".',
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

  void _executeCommand() {
    final text = _consoleController.text.trim();
    if (text.isEmpty || _isProcessing) return;

    _consoleController.clear();
    setState(() {
      _consoleLogs.add({'role': 'user', 'text': text});
      _isProcessing = true;
    });

    _scrollToBottom();

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

    final result = _commandBus.executeAiPrompt(text);

    setState(() {
      _isProcessing = false;
      _consoleLogs.add({
        'role': 'engine',
        'text': '${result.message}\n📊 3D обекти в сцената: ${_commandBus.live3DNodes.length}',
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
            // 1. ЧИСТ 3D VIEWPORT (ГОРНА ЧАСТ)
            // ==========================================
            Expanded(
              flex: 11,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onScaleUpdate: (details) {
                        setState(() {
                          if (details.scale != 1.0) {
                            _camZoom = (_camZoom * details.scale).clamp(0.35, 3.5);
                          } else {
                            _camYaw += details.focalPointDelta.dx * 0.009;
                            _camPitch = (_camPitch - details.focalPointDelta.dy * 0.009).clamp(0.08, 1.45);
                          }
                        });
                      },
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: TruePBR3DEnginePainter(
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

                  // Превключвател 3D / 2D горе в ъгъла
                  Positioned(
                    top: 10,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
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

                  // Индикатор за осветлението
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
                          _isNightMode ? 'Cyber Night • PBR Shading' : 'Sunlit Horizon • Real 3D Culling',
                          style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Разделителна линия
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
                                      : AppTheme.sciFiCyan.withValues(alpha: 0.35),
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
                                  hintText: 'Команда: "създай къща", "кола", "нощ", "изчисти"...',
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
// 🎨 ИСТИНСКИ 3D РЕНДЕРЕР С BACKFACE CULLING (БЕЗ ДУПКИ И ЛЕТЯЩИ ВРАТИ)
// =========================================================================

class TruePBR3DEnginePainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final double zoom;
  final bool is3D;
  final bool isNight;
  final List<Map<String, dynamic>> nodes;

  TruePBR3DEnginePainter({
    required this.yaw,
    required this.pitch,
    required this.zoom,
    required this.is3D,
    required this.isNight,
    required this.nodes,
  });

  Offset project(double x, double y, double z, Size size) {
    if (!is3D) {
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

  // Изчислява ориентацията на полигона (2D Cross Product) за Backface Culling
  bool isFrontFacing(Offset p0, Offset p1, Offset p2) {
    double signedArea = (p1.dx - p0.dx) * (p2.dy - p0.dy) - (p1.dy - p0.dy) * (p2.dx - p0.dx);
    return signedArea > 0.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Небесен градиент
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isNight
            ? [const Color(0xFF05070E), const Color(0xFF0D1220), const Color(0xFF05060A)]
            : [const Color(0xFF1E2538), const Color(0xFF2C344E), const Color(0xFF131622)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    if (is3D) {
      _paint3D(canvas, size);
    } else {
      _paint2D(canvas, size);
    }
  }

  void _paint3D(Canvas canvas, Size size) {
    // Безкрайна световна мрежа
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

    for (var node in sorted) {
      double ox = (node['x'] as num).toDouble();
      double oy = (node['y'] as num).toDouble();
      double oz = (node['z'] as num).toDouble();
      double s = (node['size'] as num).toDouble();
      Color c = node['color'] as Color? ?? AppTheme.laserPink;
      String type = node['type']?.toString() ?? 'block';

      if (type == 'house') {
        _drawSolidCulledHouse(canvas, size, ox, oy, oz, s, c);
      } else if (type == 'car') {
        _drawSolidCulledCar(canvas, size, ox, oy, oz, s, c);
      } else if (type == 'tree') {
        _drawSolidCulledTree(canvas, size, ox, oy, oz, s);
      } else if (type == 'player') {
        _drawCulledPlayerPawn(canvas, size, ox, oy, oz, s);
      } else if (type == 'coin') {
        _drawGoldenOrb(canvas, size, ox, oy, oz, s);
      } else {
        _drawCulledBox(canvas, size, ox, oy, oz, s, s * 0.8, s, c);
      }
    }
  }

  void _paint2D(Canvas canvas, Size size) {
    const double s = 40.0 * 1.5;
    final grid = Paint()..color = const Color(0xFF1B2234)..strokeWidth = 0.8;
    for (double x = 0; x < size.width; x += s) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += s) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

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

  // =========================================================================
  // 🏡 3D КЪЩА С BACKFACE CULLING (ПЪЛЕН ПОКРИВ И ЗАКРЕПЕНА ВРАТА)
  // =========================================================================

  void _drawSolidCulledHouse(Canvas canvas, Size size, double x, double y, double z, double s, Color c) {
    double w = s * 0.9;
    double h = s * 0.75;
    double d = s * 0.9;

    double hx = w / 2.0;
    double hy = h / 2.0;
    double hz = d / 2.0;

    // 8 Върха на стените
    List<Offset> p = [
      project(x - hx, y - hy, z - hz, size), // 0: Top-Left-Back
      project(x + hx, y - hy, z - hz, size), // 1: Top-Right-Back
      project(x + hx, y - hy, z + hz, size), // 2: Top-Right-Front
      project(x - hx, y - hy, z + hz, size), // 3: Top-Left-Front
      project(x - hx, y + hy, z - hz, size), // 4: Bottom-Left-Back
      project(x + hx, y + hy, z - hz, size), // 5: Bottom-Right-Back
      project(x + hx, y + hy, z + hz, size), // 6: Bottom-Right-Front
      project(x - hx, y + hy, z + hz, size), // 7: Bottom-Left-Front
    ];

    // Връх на покрива (Apex)
    double roofHeight = h * 0.7;
    Offset apex = project(x, y - hy - roofHeight, z, size);

    final HSLColor hsl = HSLColor.fromColor(c);
    final Color topC = hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0)).toColor();
    final Color frontC = hsl.toColor();
    final Color sideC = hsl.withLightness((hsl.lightness - 0.20).clamp(0.0, 1.0)).toColor();

    // 1. ЗАДНА СТЕНА (-Z)
    if (isFrontFacing(p[1], p[0], p[4])) {
      _drawPolygon(canvas, [p[1], p[0], p[4], p[5]], sideC);
    }

    // 2. ЛЯВА СТЕНА (-X)
    if (isFrontFacing(p[0], p[3], p[7])) {
      _drawPolygon(canvas, [p[0], p[3], p[7], p[4]], sideC);
    }

    // 3. ДЯСНА СТЕНА (+X)
    if (isFrontFacing(p[2], p[1], p[5])) {
      _drawPolygon(canvas, [p[2], p[1], p[5], p[6]], topC);
    }

    // 4. ПРЕДНА СТЕНА (+Z) - ВРАТАТА И ПРОЗОРЕЦЪТ СЕ РИСУВАТ САМО ТУК!
    if (isFrontFacing(p[3], p[2], p[6])) {
      _drawPolygon(canvas, [p[3], p[2], p[6], p[7]], frontC);

      // Входна врата (закрепена плътно)
      Offset dTopL = project(x - w * 0.15, y + hy * 0.1, z + hz + 0.5, size);
      Offset dTopR = project(x + w * 0.15, y + hy * 0.1, z + hz + 0.5, size);
      Offset dBotR = project(x + w * 0.15, y + hy, z + hz + 0.5, size);
      Offset dBotL = project(x - w * 0.15, y + hy, z + hz + 0.5, size);
      _drawPolygon(canvas, [dTopL, dTopR, dBotR, dBotL], const Color(0xFF3E2723));

      // Светещ прозорец
      Offset winPos = project(x + w * 0.25, y - hy * 0.3, z + hz + 0.5, size);
      canvas.drawCircle(winPos, 4.0 * zoom, Paint()..color = AppTheme.sciFiCyan);
    }

    // ==========================================
    // 4-ТЕ СКАТА НА ПОКРИВА (ПЪЛНО ПОКРИТИЕ БЕЗ ДУПКИ)
    // ==========================================
    const Color roofFrontColor = Color(0xFFE64A19);
    const Color roofSideColor = Color(0xFFD84315);
    const Color roofBackColor = Color(0xFFBF360C);

    // Заден скат на покрива (-Z)
    if (isFrontFacing(apex, p[1], p[0])) {
      _drawPolygon(canvas, [apex, p[1], p[0]], roofBackColor);
    }

    // Ляв скат на покрива (-X)
    if (isFrontFacing(apex, p[0], p[3])) {
      _drawPolygon(canvas, [apex, p[0], p[3]], roofSideColor);
    }

    // Десен скат на покрива (+X)
    if (isFrontFacing(apex, p[2], p[1])) {
      _drawPolygon(canvas, [apex, p[2], p[1]], roofFrontColor);
    }

    // Преден скат на покрива (+Z)
    if (isFrontFacing(apex, p[3], p[2])) {
      _drawPolygon(canvas, [apex, p[3], p[2]], roofFrontColor);
    }
  }

  // =========================================================================
  // 🏎️ 3D КОЛА С CULLING И КОЛЕЛА
  // =========================================================================

  void _drawSolidCulledCar(Canvas canvas, Size size, double x, double y, double z, double s, Color c) {
    double len = s * 1.3;
    double w = s * 0.75;
    double h = s * 0.4;

    _drawCulledBox(canvas, size, x, y + 6.0, z, len, h, w, c);
    _drawCulledBox(canvas, size, x - len * 0.08, y - h * 0.5, z, len * 0.55, h * 0.75, w * 0.75, const Color(0xFF0F1A2C));

    // 4 Колела
    final wheel = Paint()..color = const Color(0xFF1E222B);
    canvas.drawCircle(project(x + len * 0.35, y + h * 0.8, z + w * 0.55, size), 4.5 * zoom, wheel);
    canvas.drawCircle(project(x + len * 0.35, y + h * 0.8, z - w * 0.55, size), 4.5 * zoom, wheel);
    canvas.drawCircle(project(x - len * 0.35, y + h * 0.8, z + w * 0.55, size), 4.5 * zoom, wheel);
    canvas.drawCircle(project(x - len * 0.35, y + h * 0.8, z - w * 0.55, size), 4.5 * zoom, wheel);
  }

  // 🌲 3D ДЪРВО
  void _drawSolidCulledTree(Canvas canvas, Size size, double x, double y, double z, double s) {
    _drawCulledBox(canvas, size, x, y + s * 0.35, z, s * 0.25, s * 0.65, s * 0.25, const Color(0xFF5D4037));

    Offset apex = project(x, y - s * 0.9, z, size);
    Offset b0 = project(x - s * 0.45, y - s * 0.1, z - s * 0.45, size);
    Offset b1 = project(x + s * 0.45, y - s * 0.1, z - s * 0.45, size);
    Offset b2 = project(x + s * 0.45, y - s * 0.1, z + s * 0.45, size);
    Offset b3 = project(x - s * 0.45, y - s * 0.1, z + s * 0.45, size);

    if (isFrontFacing(apex, b1, b0)) _drawPolygon(canvas, [apex, b1, b0], const Color(0xFF1B5E20));
    if (isFrontFacing(apex, b0, b3)) _drawPolygon(canvas, [apex, b0, b3], const Color(0xFF2E7D32));
    if (isFrontFacing(apex, b2, b1)) _drawPolygon(canvas, [apex, b2, b1], const Color(0xFF388E3C));
    if (isFrontFacing(apex, b3, b2)) _drawPolygon(canvas, [apex, b3, b2], const Color(0xFF43A047));
  }

  // 🤖 3D ИГРАЧ СПАУН ПАУН
  void _drawCulledPlayerPawn(Canvas canvas, Size size, double x, double y, double z, double s) {
    Offset head = project(x, y - s * 0.85, z, size);
    _drawCulledBox(canvas, size, x, y - s * 0.2, z, s * 0.55, s * 0.75, s * 0.45, AppTheme.laserPink);
    canvas.drawCircle(head, 7.5 * zoom, Paint()..color = Colors.white);
    canvas.drawCircle(head, 3.5 * zoom, Paint()..color = AppTheme.sciFiCyan);
  }

  void _drawGoldenOrb(Canvas canvas, Size size, double x, double y, double z, double s) {
    Offset pos = project(x, y, z, size);
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFFFD600).withValues(alpha: 0.85), Colors.transparent],
      ).createShader(Rect.fromCircle(center: pos, radius: 16.0 * zoom));
    canvas.drawCircle(pos, 16.0 * zoom, glow);
    canvas.drawCircle(pos, 8.0 * zoom, Paint()..color = const Color(0xFFFFC107));
  }

  // КУБ С BACKFACE CULLING ЗА ВСИЧКИ 6 СТЕНИ
  void _drawCulledBox(Canvas canvas, Size size, double x, double y, double z, double sx, double sy, double sz, Color color) {
    double hx = sx / 2.0;
    double hy = sy / 2.0;
    double hz = sz / 2.0;

    List<Offset> p = [
      project(x - hx, y - hy, z - hz, size), // 0
      project(x + hx, y - hy, z - hz, size), // 1
      project(x + hx, y - hy, z + hz, size), // 2
      project(x - hx, y - hy, z + hz, size), // 3
      project(x - hx, y + hy, z - hz, size), // 4
      project(x + hx, y + hy, z - hz, size), // 5
      project(x + hx, y + hy, z + hz, size), // 6
      project(x - hx, y + hy, z + hz, size), // 7
    ];

    final hsl = HSLColor.fromColor(color);
    final Color topC = hsl.withLightness((hsl.lightness + 0.16).clamp(0.0, 1.0)).toColor();
    final Color frontC = hsl.toColor();
    final Color sideC = hsl.withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0)).toColor();

    // 1. Задна (-Z)
    if (isFrontFacing(p[1], p[0], p[4])) _drawPolygon(canvas, [p[1], p[0], p[4], p[5]], sideC);
    // 2. Лява (-X)
    if (isFrontFacing(p[0], p[3], p[7])) _drawPolygon(canvas, [p[0], p[3], p[7], p[4]], sideC);
    // 3. Дясна (+X)
    if (isFrontFacing(p[2], p[1], p[5])) _drawPolygon(canvas, [p[2], p[1], p[5], p[6]], topC);
    // 4. Предна (+Z)
    if (isFrontFacing(p[3], p[2], p[6])) _drawPolygon(canvas, [p[3], p[2], p[6], p[7]], frontC);
    // 5. Горна (-Y)
    if (isFrontFacing(p[0], p[1], p[2])) _drawPolygon(canvas, [p[0], p[1], p[2], p[3]], topC);
    // 6. Долна (+Y)
    if (isFrontFacing(p[7], p[6], p[5])) _drawPolygon(canvas, [p[7], p[6], p[5], p[4]], sideC);
  }

  void _drawPolygon(Canvas canvas, List<Offset> points, Color color) {
    if (points.isEmpty) return;
    Path path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: 0.15)..style = PaintingStyle.stroke..strokeWidth = 0.8);
  }

  @override
  bool shouldRepaint(covariant TruePBR3DEnginePainter oldDelegate) => true;
}
