import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';

class Godot2DEnginePainter extends CustomPainter {
  final List<Map<String, dynamic>> nodes;
  final String? selectedNodeId;
  final Color lightColor;
  final double pulseValue;
  final bool isSimulating;
  final Offset playerPos;
  final int playerFacing;

  Godot2DEnginePainter({
    required this.nodes,
    required this.selectedNodeId,
    required this.lightColor,
    required this.pulseValue,
    required this.isSimulating,
    required this.playerPos,
    required this.playerFacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double s = 36.0;

    // Мрежа
    final gridPaint = Paint()..color = const Color(0xFF181C2E)..strokeWidth = 1.0;
    for (double x = 0; x < size.width; x += s) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += s) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Рисуване на възлите
    for (var node in nodes) {
      int nx = (node['x'] as num).toInt();
      int ny = (node['y'] as num).toInt();
      if (ny < 0) continue;
      String type = node['type'];
      bool isSelected = node['id'] == selectedNodeId;
      Rect r = Rect.fromLTWH(nx * s, (ny * s) + 40, s, s);

      if (type == 'grass') {
        final p = Paint()..color = const Color(0xFF00E676)..style = PaintingStyle.fill;
        canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), p);
      } else if (type == 'dirt') {
        final p = Paint()..color = const Color(0xFF8D6E63)..style = PaintingStyle.fill;
        canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), p);
      } else if (type == 'platform') {
        final p = Paint()..color = AppTheme.sciFiCyan..style = PaintingStyle.fill;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(nx * s, (ny * s) + 40, s, 12), const Radius.circular(4)), p);
      } else if (type == 'coin' && node['collected'] != true) {
        final p = Paint()..color = const Color(0xFFFFD600)..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(nx * s + s / 2, ny * s + 40 + s / 2), 9, p);
      } else if (type == 'enemy') {
        double curX = (node['curX'] as num?)?.toDouble() ?? nx.toDouble();
        final p = Paint()..color = const Color(0xFFFF1744)..style = PaintingStyle.fill;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(curX * s + 4, ny * s + 44, s - 8, s - 8), const Radius.circular(8)), p);
      } else if (type == 'spikes') {
        final p = Paint()..color = const Color(0xFFFF9100)..style = PaintingStyle.fill;
        Path path = Path()..moveTo(nx * s, (ny * s) + 40 + s)..lineTo(nx * s + s / 2, (ny * s) + 40)..lineTo(nx * s + s, (ny * s) + 40 + s)..close();
        canvas.drawPath(path, p);
      } else if (type == 'lava') {
        final p = Paint()..color = const Color(0xFFFF3D00)..style = PaintingStyle.fill;
        canvas.drawRect(r, p);
      } else if (type == 'portal') {
        final p = Paint()..color = const Color(0xFFD500F9)..style = PaintingStyle.fill;
        canvas.drawOval(r, p);
      } else if (type == 'player' && !isSimulating) {
        final p = Paint()..color = AppTheme.laserPink.withValues(alpha: 0.6)..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(nx * s + s / 2, ny * s + 40 + s / 2), 12, p);
      }

      if (isSelected && !isSimulating) {
        final selectPaint = Paint()..color = Colors.white..strokeWidth = 2.0..style = PaintingStyle.stroke;
        canvas.drawRRect(RRect.fromRectAndRadius(r.inflate(2), const Radius.circular(8)), selectPaint);
      }
    }

    if (isSimulating) {
      final p = Paint()..color = AppTheme.laserPink..style = PaintingStyle.fill;
      canvas.drawCircle(playerPos, 13, p);
      final eye = Paint()..color = Colors.white..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(playerPos.dx + (playerFacing * 4), playerPos.dy - 2), 3, eye);
    }
  }

  @override
  bool shouldRepaint(covariant Godot2DEnginePainter oldDelegate) => true;
}
