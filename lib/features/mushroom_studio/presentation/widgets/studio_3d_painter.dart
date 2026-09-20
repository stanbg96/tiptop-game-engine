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
    // 1. БЕЗКРАЕН GODOT 4 НЕБЕСЕН КУПОЛ С ХОРИЗОНТ И МЪГЛА
    final horizonPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.45, 0.52, 1.0],
        colors: [
          Color(0xFF1D2230), // Дълбоко небе
          Color(0xFF2C3246), // Атмосфера
          Color(0xFF1A1C24), // Линия на хоризонта
          Color(0xFF0F1117), // Безкрайна бездна
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), horizonPaint);

    // 2. БЕЗКРАЙНА МНОГОСЛОЙНА 3D МРЕЖА (ОГРОМЕН МАЩАБЕН СВЯТ)
    const double farExtent = 900.0;
    const double majorStep = 90.0;
    const double minorStep = 30.0;

    // Второстепенна фина мрежа
    final minorGridPaint = Paint()
      ..color = const Color(0xFF222638).withValues(alpha: 0.6)
      ..strokeWidth = 0.8;

    for (double i = -farExtent; i <= farExtent; i += minorStep) {
      if ((i % majorStep).abs() < 0.1) continue;
      Offset p1 = project(i, 50.0, -farExtent, size);
      Offset p2 = project(i, 50.0, farExtent, size);
      canvas.drawLine(p1, p2, minorGridPaint);

      Offset p3 = project(-farExtent, 50.0, i, size);
      Offset p4 = project(farExtent, 50.0, i, size);
      canvas.drawLine(p3, p4, minorGridPaint);
    }

    // Главна мрежа с ясни деления на всеки 90м
    final majorGridPaint = Paint()
      ..color = const Color(0xFF333A52)
      ..strokeWidth = 1.2;

    for (double i = -farExtent; i <= farExtent; i += majorStep) {
      Offset p1 = project(i, 50.0, -farExtent, size);
      Offset p2 = project(i, 50.0, farExtent, size);
      canvas.drawLine(p1, p2, majorGridPaint);

      Offset p3 = project(-farExtent, 50.0, i, size);
      Offset p4 = project(farExtent, 50.0, i, size);
      canvas.drawLine(p3, p4, majorGridPaint);
    }

    // БЕЗКРАЙНИ СВЕТОВНИ ОСИ: Червена (X: Изток/Запад) и Синя (Z: Север/Юг)
    final xAxisPaint = Paint()..color = const Color(0xFFFF3366)..strokeWidth = 2.2;
    final zAxisPaint = Paint()..color = const Color(0xFF3399FF)..strokeWidth = 2.2;

    canvas.drawLine(project(-farExtent, 50.0, 0.0, size), project(farExtent, 50.0, 0.0, size), xAxisPaint);
    canvas.drawLine(project(0.0, 50.0, -farExtent, size), project(0.0, 50.0, farExtent, size), zAxisPaint);

    // Център на координатите (0,0,0) - Зелена Y-ос
    Offset origin = project(0.0, 50.0, 0.0, size);
    Offset yUp = project(0.0, -30.0, 0.0, size);
    canvas.drawLine(origin, yUp, Paint()..color = const Color(0xFF00E676)..strokeWidth = 2.2);

    // 3. Z-BUFFER СОРТИРАНЕ НА ОБЕКТИТЕ
    List<Map<String, dynamic>> sortedObjects = List.from(objects);
    sortedObjects.sort((a, b) {
      double d1 = calculateDepth((a['x'] as num).toDouble(), (a['y'] as num).toDouble(), (a['z'] as num).toDouble());
      double d2 = calculateDepth((b['x'] as num).toDouble(), (b['y'] as num).toDouble(), (b['z'] as num).toDouble());
      return d1.compareTo(d2);
    });

    // 4. РИСУВАНЕ НА СОЛИДНИ 3D ОБЕКТИ В ГОЛЕМИЯ СВЯТ
    for (var obj in sortedObjects) {
      double ox = (obj['x'] as num).toDouble();
      double oy = (obj['y'] as num).toDouble();
      double oz = (obj['z'] as num).toDouble();
      double s = (obj['size'] as num).toDouble();
      Color baseColor = obj['color'] as Color? ?? AppTheme.laserPink;
      bool isSelected = obj['id'] == selectedNodeId;

      _drawSolidPBRBox(canvas, size, ox, oy, oz, s, baseColor, isSelected);
    }

    // 5. РИСУВАНЕ НА ИГРАЧА В СВОБОДЕН PLAY MODE
    if (isPlayMode) {
      Offset pPos = project(playerPos3D.dx, -25.0, playerPos3D.dy, size);
      Offset pShadow = project(playerPos3D.dx, 49.5, playerPos3D.dy, size);

      // Сянка върху пода под героя
      canvas.drawOval(
        Rect.fromCenter(center: pShadow, width: 26.0 * zoom, height: 12.0 * zoom),
        Paint()..color = Colors.black.withValues(alpha: 0.5)..style = PaintingStyle.fill,
      );

      // Тяло на героя със светлина
      final pGlow = Paint()
        ..shader = RadialGradient(
          colors: [AppTheme.laserPink.withValues(alpha: 0.9), Colors.transparent],
        ).createShader(Rect.fromCircle(center: pPos, radius: 24.0 * zoom));
      canvas.drawCircle(pPos, 24.0 * zoom, pGlow);

      canvas.drawCircle(pPos, 14.0 * zoom, Paint()..color = Colors.white..style = PaintingStyle.fill);
      canvas.drawCircle(pPos, 6.0 * zoom, Paint()..color = AppTheme.sciFiCyan..style = PaintingStyle.fill);
    }

    // 6. GODOT 3D НАВИГАЦИОНЕН КОМПАС (ГОРЕН ДЕСЕН ЪГЪЛ)
    _drawGodotOrientationGizmo(canvas, size);
  }

  void _drawSolidPBRBox(Canvas canvas, Size size, double x, double y, double z, double s, Color color, bool isSelected) {
    double hs = s / 2.0;
    List<Offset> v = [
      project(x - hs, y - hs, z - hs, size),
      project(x + hs, y - hs, z - hs, size),
      project(x + hs, y - hs, z + hs, size),
      project(x - hs, y - hs, z + hs, size),
      project(x - hs, y + hs, z - hs, size),
      project(x + hs, y + hs, z - hs, size),
      project(x + hs, y + hs, z + hs, size),
      project(x - hs, y + hs, z + hs, size),
    ];

    final HSLColor hsl = HSLColor.fromColor(color);
    final Color topColor = hsl.withLightness((hsl.lightness + 0.18).clamp(0.0, 1.0)).toColor();
    final Color frontColor = hsl.toColor();
    final Color sideColor = hsl.withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0)).toColor();

    final topPaint = Paint()..color = topColor..style = PaintingStyle.fill;
    final frontPaint = Paint()..color = frontColor..style = PaintingStyle.fill;
    final sidePaint = Paint()..color = sideColor..style = PaintingStyle.fill;
    final edgePaint = Paint()..color = isSelected ? Colors.white : color.withValues(alpha: 0.45)..strokeWidth = isSelected ? 2.2 : 1.0..style = PaintingStyle.stroke;

    // Горен полигон
    Path top = Path()..moveTo(v[0].dx, v[0].dy)..lineTo(v[1].dx, v[1].dy)..lineTo(v[2].dx, v[2].dy)..lineTo(v[3].dx, v[3].dy)..close();
    canvas.drawPath(top, topPaint);
    canvas.drawPath(top, edgePaint);

    // Преден полигон
    Path front = Path()..moveTo(v[3].dx, v[3].dy)..lineTo(v[2].dx, v[2].dy)..lineTo(v[6].dx, v[6].dy)..lineTo(v[7].dx, v[7].dy)..close();
    canvas.drawPath(front, frontPaint);
    canvas.drawPath(front, edgePaint);

    // Десен полигон
    Path right = Path()..moveTo(v[2].dx, v[2].dy)..lineTo(v[1].dx, v[1].dy)..lineTo(v[5].dx, v[5].dy)..lineTo(v[6].dx, v[6].dy)..close();
    canvas.drawPath(right, sidePaint);
    canvas.drawPath(right, edgePaint);

    // 3D Gizmo стрелки върху избрания обект
    if (isSelected && !isPlayMode) {
      Offset center = project(x, y, z, size);
      Offset xArrow = project(x + s * 1.1, y, z, size);
      Offset yArrow = project(x, y - s * 1.1, z, size);
      Offset zArrow = project(x, y, z + s * 1.1, size);

      canvas.drawLine(center, xArrow, Paint()..color = const Color(0xFFFF3366)..strokeWidth = 3.0);
      canvas.drawCircle(xArrow, 4.5, Paint()..color = const Color(0xFFFF3366));

      canvas.drawLine(center, yArrow, Paint()..color = const Color(0xFF00E676)..strokeWidth = 3.0);
      canvas.drawCircle(yArrow, 4.5, Paint()..color = const Color(0xFF00E676));

      canvas.drawLine(center, zArrow, Paint()..color = const Color(0xFF3399FF)..strokeWidth = 3.0);
      canvas.drawCircle(zArrow, 4.5, Paint()..color = const Color(0xFF3399FF));
    }
  }

  void _drawGodotOrientationGizmo(Canvas canvas, Size size) {
    final double gx = size.width - 40.0;
    const double gy = 55.0;
    const double len = 22.0;

    double cosY = math.cos(yaw);
    double sinY = math.sin(yaw);
    double cosP = math.cos(pitch);
    double sinP = math.sin(pitch);

    Offset proj(double x, double y, double z) {
      double rx = x * cosY - z * sinY;
      double rz = x * sinY + z * cosY;
      double ry = y * cosP - rz * sinP;
      return Offset(gx + rx, gy + ry);
    }

    Offset center = Offset(gx, gy);
    canvas.drawCircle(center, 26.0, Paint()..color = const Color(0xCC161928)..style = PaintingStyle.fill);

    canvas.drawLine(center, proj(len, 0, 0), Paint()..color = const Color(0xFFFF3366)..strokeWidth = 2.5);
    canvas.drawLine(center, proj(0, -len, 0), Paint()..color = const Color(0xFF00E676)..strokeWidth = 2.5);
    canvas.drawLine(center, proj(0, 0, len), Paint()..color = const Color(0xFF3399FF)..strokeWidth = 2.5);
  }

  @override
  bool shouldRepaint(covariant Studio3DEnginePainter oldDelegate) => true;
}
