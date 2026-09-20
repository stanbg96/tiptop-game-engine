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

    double sx = (x1 * fov / depth) + (size.width / 2.0);
    double sy = (y2 * fov / depth) + (size.height / 2.0) + 20.0;

    return Offset(sx, sy);
  }

  double calculateDepth(double x, double y, double z) {
    double sinY = math.sin(yaw);
    double cosY = math.cos(yaw);
    double z1 = x * sinY + z * cosY;

    double sinP = math.sin(pitch);
    double cosP = math.cos(pitch);
    return y * sinP + z1 * cosP;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 3D Координатна мрежа (XZ Grid)
    final gridPaint = Paint()
      ..color = AppTheme.sciFiCyan.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    const double gridSize = 180.0;
    const double step = 30.0;

    for (double i = -gridSize; i <= gridSize; i += step) {
      Offset p1 = project(i, 60.0, -gridSize, size);
      Offset p2 = project(i, 60.0, gridSize, size);
      canvas.drawLine(p1, p2, gridPaint);

      Offset p3 = project(-gridSize, 60.0, i, size);
      Offset p4 = project(gridSize, 60.0, i, size);
      canvas.drawLine(p3, p4, gridPaint);
    }

    // 2. Лава зона / Опасен под
    final lavaFloorPaint = Paint()
      ..color = const Color(0xFFFF3D00).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    Path lavaPath = Path()
      ..moveTo(project(-60.0, 59.0, -60.0, size).dx, project(-60.0, 59.0, -60.0, size).dy)
      ..lineTo(project(60.0, 59.0, -60.0, size).dx, project(60.0, 59.0, -60.0, size).dy)
      ..lineTo(project(60.0, 59.0, 60.0, size).dx, project(60.0, 59.0, 60.0, size).dy)
      ..lineTo(project(-60.0, 59.0, 60.0, size).dx, project(-60.0, 59.0, 60.0, size).dy)
      ..close();
    canvas.drawPath(lavaPath, lavaFloorPaint);

    // 3. Z-Buffer Сортиране на обектите отзад напред
    List<Map<String, dynamic>> sortedObjects = List.from(objects);
    sortedObjects.sort((a, b) {
      double d1 = calculateDepth(
        (a['x'] as num).toDouble(),
        (a['y'] as num).toDouble(),
        (a['z'] as num).toDouble(),
      );
      double d2 = calculateDepth(
        (b['x'] as num).toDouble(),
        (b['y'] as num).toDouble(),
        (b['z'] as num).toDouble(),
      );
      return d1.compareTo(d2); // Рисуваме най-далечните първо
    });

    // 4. Рисуване на 3D Телата
    for (var obj in sortedObjects) {
      double ox = (obj['x'] as num).toDouble();
      double oy = (obj['y'] as num).toDouble();
      double oz = (obj['z'] as num).toDouble();
      double s = (obj['size'] as num).toDouble();
      Color c = obj['color'] as Color? ?? AppTheme.laserPink;
      bool isSelected = obj['id'] == selectedNodeId;

      _draw3DBox(canvas, size, ox, oy, oz, s, c, isSelected);
    }

    // 5. Рисуване на 3D Играча в Play Mode
    if (isPlayMode) {
      Offset pPos = project(playerPos3D.dx, -25.0, playerPos3D.dy, size);
      final pPaint = Paint()..color = AppTheme.laserPink..style = PaintingStyle.fill;
      canvas.drawCircle(pPos, 16.0 * zoom, pPaint);
      final pCore = Paint()..color = Colors.white..style = PaintingStyle.fill;
      canvas.drawCircle(pPos, 6.0 * zoom, pCore);
    }
  }

  void _draw3DBox(Canvas canvas, Size size, double x, double y, double z, double s, Color color, bool isSelected) {
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

    final topPaint = Paint()..color = color.withValues(alpha: isSelected ? 0.9 : 0.6)..style = PaintingStyle.fill;
    final sidePaint = Paint()..color = color.withValues(alpha: isSelected ? 0.7 : 0.4)..style = PaintingStyle.fill;
    final edgePaint = Paint()..color = isSelected ? Colors.white : color..strokeWidth = isSelected ? 2.0 : 1.2..style = PaintingStyle.stroke;

    // Горен полигон
    Path top = Path()..moveTo(v[0].dx, v[0].dy)..lineTo(v[1].dx, v[1].dy)..lineTo(v[2].dx, v[2].dy)..lineTo(v[3].dx, v[3].dy)..close();
    canvas.drawPath(top, topPaint);
    canvas.drawPath(top, edgePaint);

    // Преден полигон
    Path front = Path()..moveTo(v[3].dx, v[3].dy)..lineTo(v[2].dx, v[2].dy)..lineTo(v[6].dx, v[6].dy)..lineTo(v[7].dx, v[7].dy)..close();
    canvas.drawPath(front, sidePaint);
    canvas.drawPath(front, edgePaint);

    // Десен полигон
    Path right = Path()..moveTo(v[2].dx, v[2].dy)..lineTo(v[1].dx, v[1].dy)..lineTo(v[5].dx, v[5].dy)..lineTo(v[6].dx, v[6].dy)..close();
    canvas.drawPath(right, sidePaint);
    canvas.drawPath(right, edgePaint);
  }

  @override
  bool shouldRepaint(covariant Studio3DEnginePainter oldDelegate) => true;
}
