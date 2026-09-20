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

    // 1. Godot 4 Работен фон (Slate Editor Background)
    final bgPaint = Paint()..color = const Color(0xFF1B1E27);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Godot 4 Мрежа с малки и главни деления
    final gridPaint = Paint()..color = const Color(0xFF262B38)..strokeWidth = 0.8;
    for (double x = 0; x < size.width; x += s) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += s) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Godot 4 Координатни оси (Origin Axes: Red X & Green Y)
    final xAxis = Paint()..color = const Color(0xFFFF4081)..strokeWidth = 1.5;
    final yAxis = Paint()..color = const Color(0xFF00E676)..strokeWidth = 1.5;
    canvas.drawLine(const Offset(0, 40.0), Offset(size.width, 40.0), xAxis);
    canvas.drawLine(const Offset(0, 0), Offset(0, size.height), yAxis);

    // 3. Рисуване на възлите (Layered Nodes)
    for (var node in nodes) {
      int nx = (node['x'] as num).toInt();
      int ny = (node['y'] as num).toInt();
      if (ny < 0) continue;
      String type = node['type'];
      bool isSelected = node['id'] == selectedNodeId;
      Rect r = Rect.fromLTWH(nx * s, (ny * s) + 40.0, s, s);

      // 🟩 ТРЕВА И ЗЕМЯ (TileMapLayer с тревна корона и пръст)
      if (type == 'grass') {
        _drawGrassTile(canvas, r);
      }
      // 🟫 СКАЛА / ПРЪСТ
      else if (type == 'dirt') {
        _drawDirtTile(canvas, r);
      }
      // 🟦 СТОМАНЕНА ПЛАТФОРМА
      else if (type == 'platform') {
        _drawPlatformTile(canvas, r);
      }
      // 🪙 ЗЛАТНА МОНЕТА (Area2D с блясък)
      else if (type == 'coin' && node['collected'] != true) {
        _drawGoldCoin(canvas, r);
      }
      // 👾 ВРАГ AI (CharacterBody2D с антени и светещи очи)
      else if (type == 'enemy') {
        double curX = (node['curX'] as num?)?.toDouble() ?? nx.toDouble();
        _drawEnemyRobot(canvas, Rect.fromLTWH(curX * s, (ny * s) + 40.0, s, s));
      }
      // ⚠️ ШИПОВЕ
      else if (type == 'spikes') {
        _drawSteelSpikes(canvas, r);
      }
      // 🌋 ЛАВА (Area2D с магмени мехурчета)
      else if (type == 'lava') {
        _drawLavaTile(canvas, r);
      }
      // 🏁 ФИНАЛ ПОРТАЛ
      else if (type == 'portal') {
        _drawPortal(canvas, r);
      }
      // 🤖 ИГРАЧ СПАУН МАРКЕР (в режим Редактор)
      else if (type == 'player' && !isSimulating) {
        _drawPlayerCharacter(canvas, Offset(nx * s + s / 2.0, ny * s + 40.0 + s / 2.0), 1);
      }

      // 4. Godot 4 Портокалова селекционна рамка (Orange Bounding Box + Pivot)
      if (isSelected && !isSimulating) {
        _drawGodotSelectionBox(canvas, r);
      }
    }

    // Рисуване на Играча в Play Mode
    if (isSimulating) {
      _drawPlayerCharacter(canvas, playerPos, playerFacing);
    }
  }

  void _drawGrassTile(Canvas canvas, Rect r) {
    // Почва
    final dirtPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(4)), dirtPaint);

    // Тревна корона отгоре
    final grassRect = Rect.fromLTWH(r.left, r.top, r.width, 10.0);
    final grassPaint = Paint()..color = const Color(0xFF43A047);
    canvas.drawRRect(RRect.fromRectAndRadius(grassRect, const Radius.circular(3)), grassPaint);

    // Светъл акцент на тревата
    final trimPaint = Paint()..color = const Color(0xFF76FF03)..strokeWidth = 1.5..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(r.left + 2, r.top + 2), Offset(r.right - 2, r.top + 2), trimPaint);
  }

  void _drawDirtTile(Canvas canvas, Rect r) {
    final dirtPaint = Paint()..color = const Color(0xFF4E342E);
    canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(4)), dirtPaint);
    final detail = Paint()..color = const Color(0xFF3E2723)..strokeWidth = 2.0;
    canvas.drawLine(Offset(r.left + 6, r.top + 12), Offset(r.right - 10, r.top + 14), detail);
    canvas.drawLine(Offset(r.left + 10, r.top + 24), Offset(r.right - 6, r.top + 26), detail);
  }

  void _drawPlatformTile(Canvas canvas, Rect r) {
    final platRect = Rect.fromLTWH(r.left, r.top, r.width, 14.0);
    final bodyPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(RRect.fromRectAndRadius(platRect, const Radius.circular(4)), bodyPaint);

    final neonBar = Paint()..color = AppTheme.sciFiCyan;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(r.left + 4, r.top + 3, r.width - 8, 3.0), const Radius.circular(2)), neonBar);
  }

  void _drawGoldCoin(Canvas canvas, Rect r) {
    Offset c = Offset(r.left + r.width / 2.0, r.top + r.height / 2.0);
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFFFD600).withValues(alpha: 0.6), Colors.transparent],
      ).createShader(Rect.fromCircle(center: c, radius: 16.0));
    canvas.drawCircle(c, 16.0, glow);

    final coin = Paint()..color = const Color(0xFFFFC107);
    canvas.drawCircle(c, 9.0, coin);
    final inner = Paint()..color = const Color(0xFFFFE082);
    canvas.drawCircle(c, 5.0, inner);
  }

  void _drawEnemyRobot(Canvas canvas, Rect r) {
    Offset c = Offset(r.left + r.width / 2.0, r.top + r.height / 2.0 + 2.0);
    final bodyPaint = Paint()..color = const Color(0xFFFF1744);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: 22, height: 20), const Radius.circular(6)), bodyPaint);

    // Светещи очи
    final eyePaint = Paint()..color = const Color(0xFFFFEB3B);
    canvas.drawCircle(Offset(c.dx - 4, c.dy - 2), 2.5, eyePaint);
    canvas.drawCircle(Offset(c.dx + 4, c.dy - 2), 2.5, eyePaint);

    // Антена
    canvas.drawLine(Offset(c.dx, c.dy - 10), Offset(c.dx, c.dy - 15), Paint()..color = Colors.white..strokeWidth = 1.5);
    canvas.drawCircle(Offset(c.dx, c.dy - 16), 2.0, Paint()..color = const Color(0xFFFF1744));
  }

  void _drawSteelSpikes(Canvas canvas, Rect r) {
    final spikePaint = Paint()..color = const Color(0xFFCFD8DC);
    for (int i = 0; i < 3; i++) {
      double startX = r.left + (i * 12.0);
      Path p = Path()
        ..moveTo(startX, r.bottom)
        ..lineTo(startX + 6.0, r.top + 10.0)
        ..lineTo(startX + 12.0, r.bottom)
        ..close();
      canvas.drawPath(p, spikePaint);
    }
  }

  void _drawLavaTile(Canvas canvas, Rect r) {
    final lava = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF6D00), Color(0xFFDD2C00)],
      ).createShader(r);
    canvas.drawRect(r, lava);

    final surface = Paint()..color = const Color(0xFFFFEB3B)..strokeWidth = 2.0;
    canvas.drawLine(Offset(r.left, r.top + 2), Offset(r.right, r.top + 2), surface);
  }

  void _drawPortal(Canvas canvas, Rect r) {
    Offset c = Offset(r.left + r.width / 2.0, r.top + r.height / 2.0);
    final vortex = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFE040FB), const Color(0xFF7C4DFF).withValues(alpha: 0.2), Colors.transparent],
      ).createShader(Rect.fromCircle(center: c, radius: 20.0));
    canvas.drawCircle(c, 18.0, vortex);
    canvas.drawOval(Rect.fromCenter(center: c, width: 14.0, height: 26.0), Paint()..color = const Color(0xFF00E5FF)..style = PaintingStyle.stroke..strokeWidth = 2.0);
  }

  void _drawPlayerCharacter(Canvas canvas, Offset pos, int facing) {
    final body = Paint()..color = AppTheme.laserPink;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: pos, width: 20.0, height: 24.0), const Radius.circular(5.0)), body);

    final visor = Paint()..color = AppTheme.sciFiCyan;
    double eyeX = pos.dx + (facing * 4.0);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(eyeX, pos.dy - 3.0), width: 10.0, height: 5.0), const Radius.circular(2.0)), visor);

    final feet = Paint()..color = const Color(0xFF1E1035);
    canvas.drawRect(Rect.fromLTWH(pos.dx - 7, pos.dy + 10, 5, 4), feet);
    canvas.drawRect(Rect.fromLTWH(pos.dx + 2, pos.dy + 10, 5, 4), feet);
  }

  void _drawGodotSelectionBox(Canvas canvas, Rect r) {
    final orangeBorder = Paint()
      ..color = const Color(0xFFFF9800)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final handlePaint = Paint()..color = const Color(0xFFFF9800)..style = PaintingStyle.fill;
    final handleBorder = Paint()..color = Colors.black..strokeWidth = 1.0..style = PaintingStyle.stroke;

    canvas.drawRect(r, orangeBorder);

    List<Offset> corners = [r.topLeft, r.topRight, r.bottomLeft, r.bottomRight];
    for (var pt in corners) {
      Rect h = Rect.fromCenter(center: pt, width: 6.0, height: 6.0);
      canvas.drawRect(h, handlePaint);
      canvas.drawRect(h, handleBorder);
    }

    Offset center = Offset(r.left + r.width / 2.0, r.top + r.height / 2.0);
    final pivotPaint = Paint()..color = const Color(0xFFFF9800)..strokeWidth = 1.5;
    canvas.drawLine(Offset(center.dx - 4, center.dy), Offset(center.dx + 4, center.dy), pivotPaint);
    canvas.drawLine(Offset(center.dx, center.dy - 4), Offset(center.dx, center.dy + 4), pivotPaint);
  }

  @override
  bool shouldRepaint(covariant Godot2DEnginePainter oldDelegate) => true;
}
