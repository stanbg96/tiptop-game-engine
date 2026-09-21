import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';

class Studio3DEnginePainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final double zoom;
  final List<Map<String, dynamic>> objects;
  final String? selectedNodeId;
  final bool isPlayMode;
  final Offset playerPos3D;

  Studio3DEnginePainter({
    required this.yaw,
    required this.pitch,
    required this.zoom,
    required this.objects,
    required this.selectedNodeId,
    required this.isPlayMode,
    required this.playerPos3D,
  });

  Offset project(double x, double y, double z, Size size) {
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
    double sy = (ry * fov / depth) + (size.height / 2.0) + 20.0;

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
    // 1. Небе и хоризонт
    final horizonPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.45, 0.52, 1.0],
        colors: [Color(0xFF1B2030), Color(0xFF282E42), Color(0xFF181A22), Color(0xFF0C0E14)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), horizonPaint);

    // 2. Безкрайна координатна мрежа
    const double farExtent = 900.0;
    const double majorStep = 90.0;
    const double minorStep = 30.0;

    final minorGrid = Paint()..color = const Color(0xFF202434)..strokeWidth = 0.8;
    for (double i = -farExtent; i <= farExtent; i += minorStep) {
      if ((i % majorStep).abs() < 0.1) continue;
      canvas.drawLine(project(i, 50.0, -farExtent, size), project(i, 50.0, farExtent, size), minorGrid);
      canvas.drawLine(project(-farExtent, 50.0, i, size), project(farExtent, 50.0, i, size), minorGrid);
    }

    final majorGrid = Paint()..color = const Color(0xFF2F364C)..strokeWidth = 1.2;
    for (double i = -farExtent; i <= farExtent; i += majorStep) {
      canvas.drawLine(project(i, 50.0, -farExtent, size), project(i, 50.0, farExtent, size), majorGrid);
      canvas.drawLine(project(-farExtent, 50.0, i, size), project(farExtent, 50.0, i, size), majorGrid);
    }

    // Оси: Червена (X) и Синя (Z)
    canvas.drawLine(project(-farExtent, 50.0, 0, size), project(farExtent, 50.0, 0, size), Paint()..color = const Color(0xFFFF3366)..strokeWidth = 2.0);
    canvas.drawLine(project(0, 50.0, -farExtent, size), project(0, 50.0, farExtent, size), Paint()..color = const Color(0xFF3399FF)..strokeWidth = 2.0);

    // 3. Сортиране на обектите по дълбочина
    List<Map<String, dynamic>> sorted = List.from(objects);
    sorted.sort((a, b) {
      double d1 = calculateDepth((a['x'] as num).toDouble(), (a['y'] as num).toDouble(), (a['z'] as num).toDouble());
      double d2 = calculateDepth((b['x'] as num).toDouble(), (b['y'] as num).toDouble(), (b['z'] as num).toDouble());
      return d1.compareTo(d2);
    });

    // 4. Рисуване на ИСТИНСКИТЕ КОМПЛЕКСНИ 3D ОБЕКТИ
    for (var obj in sorted) {
      double ox = (obj['x'] as num).toDouble();
      double oy = (obj['y'] as num).toDouble();
      double oz = (obj['z'] as num).toDouble();
      double s = (obj['size'] as num).toDouble();
      Color c = obj['color'] as Color? ?? AppTheme.laserPink;
      bool isSelected = obj['id'] == selectedNodeId;
      String type = obj['type']?.toString() ?? 'block';
      String name = obj['name']?.toString().toLowerCase() ?? '';

      if (type == 'lava') {
        _drawLavaLake(canvas, size, ox, oy, oz, s);
      } else if (name.contains('skyscraper') || name.contains('tower') || name.contains('сграда')) {
        _draw3DSkyscraper(canvas, size, ox, oy, oz, s, c, isSelected);
      } else if (name.contains('car') || name.contains('болид') || name.contains('кола') || type == 'vehicle') {
        _draw3DCar(canvas, size, ox, oy, oz, s, c, isSelected);
      } else if (type == 'coin' || name.contains('coin') || name.contains('монета')) {
        _draw3DCoin(canvas, size, ox, oy, oz, s);
      } else if (type == 'player' && !isPlayMode) {
        _draw3DPlayerPawn(canvas, size, ox, oy, oz, s, c, isSelected);
      } else {
        _drawSolidPBRBox(canvas, size, ox, oy, oz, s, s * 0.8, s, c, isSelected);
      }
    }

    // 5. Играч в Play Mode
    if (isPlayMode) {
      Offset pPos = project(playerPos3D.dx, -25.0, playerPos3D.dy, size);
      Offset pShadow = project(playerPos3D.dx, 49.5, playerPos3D.dy, size);
      canvas.drawOval(Rect.fromCenter(center: pShadow, width: 26.0 * zoom, height: 12.0 * zoom), Paint()..color = Colors.black54);
      canvas.drawCircle(pPos, 14.0 * zoom, Paint()..color = Colors.white);
      canvas.drawCircle(pPos, 6.0 * zoom, Paint()..color = AppTheme.laserPink);
    }
  }

  // 🏢 ИСТИНСКИ НЕБОСТЪРГАЧ С ЕТАЖИ И ПРОЗОРЦИ
  void _draw3DSkyscraper(Canvas canvas, Size size, double x, double y, double z, double s, Color color, bool isSelected) {
    double height = s * 2.2;
    double width = s * 0.9;
    _drawSolidPBRBox(canvas, size, x, y - height / 2.0 + 20.0, z, width, height, width, color, isSelected);

    // Светещи прозорци по етажите
    for (int floor = 1; floor <= 4; floor++) {
      double fy = y + 10.0 - (floor * (height / 5.0));
      Offset w1 = project(x - width * 0.25, fy, z + width / 2.0 + 1.0, size);
      Offset w2 = project(x + width * 0.25, fy, z + width / 2.0 + 1.0, size);
      final winPaint = Paint()..color = AppTheme.sciFiCyan.withValues(alpha: 0.8)..strokeWidth = 3.0 * zoom;
      canvas.drawCircle(w1, 2.5 * zoom, winPaint);
      canvas.drawCircle(w2, 2.5 * zoom, winPaint);
    }
  }

  // 🏎️ ИСТИНСКА 3D КОЛА С ШАСИ, КАБИНА И 4 КОЛЕЛА
  void _draw3DCar(Canvas canvas, Size size, double x, double y, double z, double s, Color color, bool isSelected) {
    double len = s * 1.4;
    double w = s * 0.8;
    double h = s * 0.45;

    // Шаси
    _drawSolidPBRBox(canvas, size, x, y + 5.0, z, len, h, w, color, isSelected);
    // Кабина със стъкло
    _drawSolidPBRBox(canvas, size, x - len * 0.1, y - h * 0.6, z, len * 0.55, h * 0.8, w * 0.75, const Color(0xFF0B1424), false);

    // 4 Колела
    final wheelPaint = Paint()..color = const Color(0xFF1E1E24)..style = PaintingStyle.fill;
    Offset whFL = project(x + len * 0.35, y + h * 0.8, z + w * 0.55, size);
    Offset whFR = project(x + len * 0.35, y + h * 0.8, z - w * 0.55, size);
    Offset whBL = project(x - len * 0.35, y + h * 0.8, z + w * 0.55, size);
    Offset whBR = project(x - len * 0.35, y + h * 0.8, z - w * 0.55, size);

    canvas.drawCircle(whFL, 5.0 * zoom, wheelPaint);
    canvas.drawCircle(whFR, 5.0 * zoom, wheelPaint);
    canvas.drawCircle(whBL, 5.0 * zoom, wheelPaint);
    canvas.drawCircle(whBR, 5.0 * zoom, wheelPaint);
  }

  // 🪙 3D ЗЛАТНА МОНЕТА С БЛЯСЪК
  void _draw3DCoin(Canvas canvas, Size size, double x, double y, double z, double s) {
    Offset c = project(x, y, z, size);
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFFFD600).withValues(alpha: 0.8), Colors.transparent],
      ).createShader(Rect.fromCircle(center: c, radius: 18.0 * zoom));
    canvas.drawCircle(c, 18.0 * zoom, glow);
    canvas.drawCircle(c, 9.0 * zoom, Paint()..color = const Color(0xFFFFC107));
    canvas.drawCircle(c, 4.0 * zoom, Paint()..color = const Color(0xFFFFF9C4));
  }

  // 🤖 3D ИГРАЧ МА НЕКЕН (В РЕДАКТОР)
  void _draw3DPlayerPawn(Canvas canvas, Size size, double x, double y, double z, double s, Color color, bool isSelected) {
    Offset head = project(x, y - s * 0.8, z, size);

    _drawSolidPBRBox(canvas, size, x, y - s * 0.2, z, s * 0.6, s * 0.8, s * 0.4, color, isSelected);
    canvas.drawCircle(head, 8.0 * zoom, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawRect(Rect.fromCenter(center: Offset(head.dx, head.dy), width: 10.0 * zoom, height: 3.5 * zoom), Paint()..color = AppTheme.sciFiCyan);
  }

  // 🌋 ВРЯЩО ЛАВА ЕЗЕРО
  void _drawLavaLake(Canvas canvas, Size size, double x, double y, double z, double s) {
    final lavaPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFF5722), Color(0xFFBF360C)],
      ).createShader(Rect.fromCircle(center: project(x, 49.0, z, size), radius: s * zoom));

    Path lavaPath = Path()
      ..moveTo(project(x - s, 49.5, z - s, size).dx, project(x - s, 49.5, z - s, size).dy)
      ..lineTo(project(x + s, 49.5, z - s, size).dx, project(x + s, 49.5, z - s, size).dy)
      ..lineTo(project(x + s, 49.5, z + s, size).dx, project(x + s, 49.5, z + s, size).dy)
      ..lineTo(project(x - s, 49.5, z + s, size).dx, project(x - s, 49.5, z + s, size).dy)
      ..close();
    canvas.drawPath(lavaPath, lavaPaint);
  }

  // СОЛИДЕН 3D PBR КУБ / ПАРАЛЕЛЕПИПЕД
  void _drawSolidPBRBox(Canvas canvas, Size size, double x, double y, double z, double sx, double sy, double sz, Color color, bool isSelected) {
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

    final HSLColor hsl = HSLColor.fromColor(color);
    final Color topColor = hsl.withLightness((hsl.lightness + 0.18).clamp(0.0, 1.0)).toColor();
    final Color frontColor = hsl.toColor();
    final Color sideColor = hsl.withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0)).toColor();

    final topPaint = Paint()..color = topColor..style = PaintingStyle.fill;
    final frontPaint = Paint()..color = frontColor..style = PaintingStyle.fill;
    final sidePaint = Paint()..color = sideColor..style = PaintingStyle.fill;
    final edgePaint = Paint()..color = isSelected ? Colors.white : color.withValues(alpha: 0.45)..strokeWidth = isSelected ? 2.0 : 0.8..style = PaintingStyle.stroke;

    Path top = Path()..moveTo(v[0].dx, v[0].dy)..lineTo(v[1].dx, v[1].dy)..lineTo(v[2].dx, v[2].dy)..lineTo(v[3].dx, v[3].dy)..close();
    canvas.drawPath(top, topPaint);
    canvas.drawPath(top, edgePaint);

    Path front = Path()..moveTo(v[3].dx, v[3].dy)..lineTo(v[2].dx, v[2].dy)..lineTo(v[6].dx, v[6].dy)..lineTo(v[7].dx, v[7].dy)..close();
    canvas.drawPath(front, frontPaint);
    canvas.drawPath(front, edgePaint);

    Path right = Path()..moveTo(v[2].dx, v[2].dy)..lineTo(v[1].dx, v[1].dy)..lineTo(v[5].dx, v[5].dy)..lineTo(v[6].dx, v[6].dy)..close();
    canvas.drawPath(right, sidePaint);
    canvas.drawPath(right, edgePaint);
  }

  @override
  bool shouldRepaint(covariant Studio3DEnginePainter oldDelegate) => true;
}
