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

    double fov = 400.0 * zoom;
    double dist = 420.0;
    double depth = depthZ + dist;
    if (depth < 1.0) depth = 1.0;

    double sx = (rx * fov / depth) + (size.width / 2.0);
    double sy = (ry * fov / depth) + (size.height / 2.0) + 15.0;

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
    // 1. Godot 4 Небе & Хоризонт с дълбочина
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF242838), Color(0xFF141620), Color(0xFF0C0E14)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // 2. Godot 4 Безкрайна 3D Координатна мрежа (XZ Plane)
    final gridPaint = Paint()
      ..color = const Color(0xFF2A2E44)
      ..strokeWidth = 1.0;

    const double gridSize = 210.0;
    const double step = 30.0;

    for (double i = -gridSize; i <= gridSize; i += step) {
      Offset p1 = project(i, 50.0, -gridSize, size);
      Offset p2 = project(i, 50.0, gridSize, size);
      canvas.drawLine(p1, p2, gridPaint);

      Offset p3 = project(-gridSize, 50.0, i, size);
      Offset p4 = project(gridSize, 50.0, i, size);
      canvas.drawLine(p3, p4, gridPaint);
    }

    // Главни Godot цветни оси: Червена (X) и Синя (Z)
    final xAxisPaint = Paint()..color = const Color(0xFFFF3366)..strokeWidth = 2.0;
    final zAxisPaint = Paint()..color = const Color(0xFF3399FF)..strokeWidth = 2.0;

    canvas.drawLine(project(-gridSize, 50.0, 0.0, size), project(gridSize, 50.0, 0.0, size), xAxisPaint);
    canvas.drawLine(project(0.0, 50.0, -gridSize, size), project(0.0, 50.0, gridSize, size), zAxisPaint);

    // 3. Лава терен / Опасна зона
    final lavaPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFF5722), Color(0xFFBF360C)],
      ).createShader(Rect.fromCircle(center: project(0, 49.0, 0, size), radius: 80.0 * zoom));

    Path lavaPath = Path()
      ..moveTo(project(-65.0, 49.5, -65.0, size).dx, project(-65.0, 49.5, -65.0, size).dy)
      ..lineTo(project(65.0, 49.5, -65.0, size).dx, project(65.0, 49.5, -65.0, size).dy)
      ..lineTo(project(65.0, 49.5, 65.0, size).dx, project(65.0, 49.5, 65.0, size).dy)
      ..lineTo(project(-65.0, 49.5, 65.0, size).dx, project(-65.0, 49.5, 65.0, size).dy)
      ..close();
    canvas.drawPath(lavaPath, lavaPaint);

    // 4. Z-Buffer Сортиране на обектите отзад напред
    List<Map<String, dynamic>> sortedObjects = List.from(objects);
    sortedObjects.sort((a, b) {
      double d1 = calculateDepth((a['x'] as num).toDouble(), (a['y'] as num).toDouble(), (a['z'] as num).toDouble());
      double d2 = calculateDepth((b['x'] as num).toDouble(), (b['y'] as num).toDouble(), (b['z'] as num).toDouble());
      return d1.compareTo(d2);
    });

    // 5. Рисуване на СОЛИДНИТЕ 3D PBR ТЕЛА
    for (var obj in sortedObjects) {
      double ox = (obj['x'] as num).toDouble();
      double oy = (obj['y'] as num).toDouble();
      double oz = (obj['z'] as num).toDouble();
      double s = (obj['size'] as num).toDouble();
      Color baseColor = obj['color'] as Color? ?? AppTheme.laserPink;
      bool isSelected = obj['id'] == selectedNodeId;

      _drawSolidPBRBox(canvas, size, ox, oy, oz, s, baseColor, isSelected);
    }

    // 6. Рисуване на 3D Играча в Play Mode
    if (isPlayMode) {
      Offset pPos = project(playerPos3D.dx, -25.0, playerPos3D.dy, size);
      final pGlow = Paint()
        ..shader = RadialGradient(
          colors: [AppTheme.laserPink.withValues(alpha: 0.8), Colors.transparent],
        ).createShader(Rect.fromCircle(center: pPos, radius: 25.0 * zoom));
      canvas.drawCircle(pPos, 25.0 * zoom, pGlow);

      final pBody = Paint()..color = Colors.white..style = PaintingStyle.fill;
      canvas.drawCircle(pPos, 14.0 * zoom, pBody);
    }

    // 7. Godot 4 Orientation 3D Компас (Горен десен ъгъл)
    _drawGodotOrientationGizmo(canvas, size);
  }

  // СОЛИДЕН 3D PBR КУБ СЪС СЛЪНЧЕВА СВЕТЛОСЯНКА
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

    // PBR Оцветяване със светлосенки (Diffuse Shading)
    final HSLColor hsl = HSLColor.fromColor(color);
    final Color topColor = hsl.withLightness((hsl.lightness + 0.18).clamp(0.0, 1.0)).toColor();
    final Color frontColor = hsl.toColor();
    final Color sideColor = hsl.withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0)).toColor();

    final topPaint = Paint()..color = topColor..style = PaintingStyle.fill;
    final frontPaint = Paint()..color = frontColor..style = PaintingStyle.fill;
    final sidePaint = Paint()..color = sideColor..style = PaintingStyle.fill;
    final edgePaint = Paint()..color = isSelected ? Colors.white : color.withValues(alpha: 0.5)..strokeWidth = isSelected ? 2.2 : 1.0..style = PaintingStyle.stroke;

    // Горен полигон (Sunlight Face)
    Path top = Path()..moveTo(v[0].dx, v[0].dy)..lineTo(v[1].dx, v[1].dy)..lineTo(v[2].dx, v[2].dy)..lineTo(v[3].dx, v[3].dy)..close();
    canvas.drawPath(top, topPaint);
    canvas.drawPath(top, edgePaint);

    // Преден полигон (Front Face)
    Path front = Path()..moveTo(v[3].dx, v[3].dy)..lineTo(v[2].dx, v[2].dy)..lineTo(v[6].dx, v[6].dy)..lineTo(v[7].dx, v[7].dy)..close();
    canvas.drawPath(front, frontPaint);
    canvas.drawPath(front, edgePaint);

    // Десен полигон (Side Shadow Face)
    Path right = Path()..moveTo(v[2].dx, v[2].dy)..lineTo(v[1].dx, v[1].dy)..lineTo(v[5].dx, v[5].dy)..lineTo(v[6].dx, v[6].dy)..close();
    canvas.drawPath(right, sidePaint);
    canvas.drawPath(right, edgePaint);

    // 8. Godot 3D Translate Gizmo стрелки върху избрания обект
    if (isSelected && !isPlayMode) {
      _drawGodot3DTransformGizmo(canvas, size, x, y, z, s);
    }
  }

  // 3D TRANSLATE GIZMO СТРЕЛКИ (X: Red, Y: Green, Z: Blue)
  void _drawGodot3DTransformGizmo(Canvas canvas, Size size, double x, double y, double z, double s) {
    Offset center = project(x, y, z, size);
    Offset xArrow = project(x + s * 0.9, y, z, size);
    Offset yArrow = project(x, y - s * 0.9, z, size);
    Offset zArrow = project(x, y, z + s * 0.9, size);

    final xPaint = Paint()..color = const Color(0xFFFF3366)..strokeWidth = 3.0..strokeCap = StrokeCap.round;
    final yPaint = Paint()..color = const Color(0xFF00E676)..strokeWidth = 3.0..strokeCap = StrokeCap.round;
    final zPaint = Paint()..color = const Color(0xFF3399FF)..strokeWidth = 3.0..strokeCap = StrokeCap.round;

    canvas.drawLine(center, xArrow, xPaint);
    canvas.drawCircle(xArrow, 4.5, xPaint);

    canvas.drawLine(center, yArrow, yPaint);
    canvas.drawCircle(yArrow, 4.5, yPaint);

    canvas.drawLine(center, zArrow, zPaint);
    canvas.drawCircle(zArrow, 4.5, zPaint);
  }

  // GODOT 4 3D ORIENTATION COMPASS (TOP RIGHT GIZMO)
  void _drawGodotOrientationGizmo(Canvas canvas, Size size) {
    final double gx = size.width - 38.0;
    const double gy = 55.0;
    const double len = 22.0;

    double cosY = math.cos(yaw);
    double sinY = math.sin(yaw);
    double cosP = math.cos(pitch);
    double sinP = math.sin(pitch);

    Offset projGizmo(double x, double y, double z) {
      double rx = x * cosY - z * sinY;
      double rz = x * sinY + z * cosY;
      double ry = y * cosP - rz * sinP;
      return Offset(gx + rx, gy + ry);
    }

    Offset center = Offset(gx, gy);
    Offset xTip = projGizmo(len, 0, 0);
    Offset yTip = projGizmo(0, -len, 0);
    Offset zTip = projGizmo(0, 0, len);

    canvas.drawCircle(center, 26.0, Paint()..color = const Color(0xCC161928)..style = PaintingStyle.fill);

    canvas.drawLine(center, xTip, Paint()..color = const Color(0xFFFF3366)..strokeWidth = 2.5);
    canvas.drawLine(center, yTip, Paint()..color = const Color(0xFF00E676)..strokeWidth = 2.5);
    canvas.drawLine(center, zTip, Paint()..color = const Color(0xFF3399FF)..strokeWidth = 2.5);
  }

  @override
  bool shouldRepaint(covariant Studio3DEnginePainter oldDelegate) => true;
}
