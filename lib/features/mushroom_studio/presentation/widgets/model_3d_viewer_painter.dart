import 'dart:math' as math;
import 'package:flutter/material.dart';

class Authentic3DModelViewerPainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final String shapeType;
  final Color baseColor;
  final bool showWireframe;

  Authentic3DModelViewerPainter({
    required this.yaw,
    required this.pitch,
    required this.shapeType,
    required this.baseColor,
    required this.showWireframe,
  });

  Offset project(double x, double y, double z, double cx, double cy) {
    double cosY = math.cos(yaw);
    double sinY = math.sin(yaw);
    double rx = x * cosY - z * sinY;
    double rz = x * sinY + z * cosY;

    double cosP = math.cos(pitch);
    double sinP = math.sin(pitch);
    double ry = y * cosP - rz * sinP;
    double depthZ = y * sinP + rz * cosP;

    double depth = (depthZ + 220.0) / 220.0;
    if (depth < 0.2) depth = 0.2;

    return Offset(cx + rx * depth, cy + ry * depth);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2.0;
    final double cy = size.height / 2.0;

    final floorPaint = Paint()
      ..shader = RadialGradient(
        colors: [baseColor.withValues(alpha: 0.35), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy + 65.0), radius: 60.0));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 65.0), width: 120.0, height: 32.0), floorPaint);

    if (shapeType == 'humanoid') {
      _drawHumanoid(canvas, cx, cy);
    } else if (shapeType == 'vehicle') {
      _drawVehicle(canvas, cx, cy);
    } else if (shapeType == 'sword') {
      _drawSword(canvas, cx, cy);
    } else if (shapeType == 'castle') {
      _drawCastle(canvas, cx, cy);
    } else if (shapeType == 'shuttle') {
      _drawShuttle(canvas, cx, cy);
    } else {
      _drawChest(canvas, cx, cy);
    }
  }

  void _drawHumanoid(Canvas canvas, double cx, double cy) {
    Offset head = project(0, -60, 0, cx, cy);
    Offset neck = project(0, -42, 0, cx, cy);
    Offset pelvis = project(0, 10, 0, cx, cy);

    Offset lSh = project(-18, -36, 0, cx, cy);
    Offset rSh = project(18, -36, 0, cx, cy);
    Offset lElb = project(-32, -15, 0, cx, cy);
    Offset rElb = project(32, -15, 0, cx, cy);
    Offset lHnd = project(-42, 5, 0, cx, cy);
    Offset rHnd = project(42, 5, 0, cx, cy);

    Offset lHip = project(-12, 14, 0, cx, cy);
    Offset rHip = project(12, 14, 0, cx, cy);
    Offset lKnee = project(-14, 42, 0, cx, cy);
    Offset rKnee = project(14, 42, 0, cx, cy);
    Offset lFoot = project(-14, 68, 0, cx, cy);
    Offset rFoot = project(14, 68, 0, cx, cy);

    final meshPaint = Paint()..color = baseColor..style = showWireframe ? PaintingStyle.stroke : PaintingStyle.fill;
    final edgePaint = Paint()..color = Colors.white..strokeWidth = 1.2..style = PaintingStyle.stroke;

    Path torso = Path()..moveTo(lSh.dx, lSh.dy)..lineTo(neck.dx, neck.dy)..lineTo(rSh.dx, rSh.dy)..lineTo(pelvis.dx + 12, pelvis.dy)..lineTo(pelvis.dx - 12, pelvis.dy)..close();
    canvas.drawPath(torso, meshPaint);
    if (!showWireframe) canvas.drawPath(torso, edgePaint);

    canvas.drawCircle(head, 13.0, meshPaint);
    if (!showWireframe) canvas.drawCircle(head, 13.0, edgePaint);

    _drawLink(canvas, lSh, lElb, meshPaint, edgePaint);
    _drawLink(canvas, lElb, lHnd, meshPaint, edgePaint);
    _drawLink(canvas, rSh, rElb, meshPaint, edgePaint);
    _drawLink(canvas, rElb, rHnd, meshPaint, edgePaint);

    _drawLink(canvas, lHip, lKnee, meshPaint, edgePaint);
    _drawLink(canvas, lKnee, lFoot, meshPaint, edgePaint);
    _drawLink(canvas, rHip, rKnee, meshPaint, edgePaint);
    _drawLink(canvas, rKnee, rFoot, meshPaint, edgePaint);
  }

  void _drawVehicle(Canvas canvas, double cx, double cy) {
    List<Offset> b = [
      project(-45, 10, -25, cx, cy), project(45, 10, -25, cx, cy),
      project(35, 10, 25, cx, cy), project(-35, 10, 25, cx, cy),
      project(-25, -15, -15, cx, cy), project(25, -15, -15, cx, cy),
      project(20, -15, 15, cx, cy), project(-20, -15, 15, cx, cy),
    ];
    final p = Paint()..color = baseColor..style = showWireframe ? PaintingStyle.stroke : PaintingStyle.fill;
    final edge = Paint()..color = Colors.white..strokeWidth = 1.2..style = PaintingStyle.stroke;

    Path body = Path()..moveTo(b[0].dx, b[0].dy)..lineTo(b[1].dx, b[1].dy)..lineTo(b[2].dx, b[2].dy)..lineTo(b[3].dx, b[3].dy)..close();
    Path cabin = Path()..moveTo(b[4].dx, b[4].dy)..lineTo(b[5].dx, b[5].dy)..lineTo(b[6].dx, b[6].dy)..lineTo(b[7].dx, b[7].dy)..close();
    canvas.drawPath(body, p);
    canvas.drawPath(cabin, p);
    if (!showWireframe) { canvas.drawPath(body, edge); canvas.drawPath(cabin, edge); }
  }

  void _drawSword(Canvas canvas, double cx, double cy) {
    Offset hilt = project(0, 50, 0, cx, cy);
    Offset guardL = project(-16, 32, 0, cx, cy);
    Offset guardR = project(16, 32, 0, cx, cy);
    Offset tip = project(0, -65, 0, cx, cy);

    final bladeGlow = Paint()..color = baseColor..strokeWidth = 8.0..strokeCap = StrokeCap.round;
    final bladeCore = Paint()..color = Colors.white..strokeWidth = 3.0..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, 30), tip, bladeGlow);
    canvas.drawLine(Offset(0, 30), tip, bladeCore);
    canvas.drawLine(guardL, guardR, Paint()..color = Colors.grey..strokeWidth = 4.0);
    canvas.drawLine(hilt, Offset(0, 32), Paint()..color = const Color(0xFF1E2235)..strokeWidth = 6.0);
  }

  void _drawCastle(Canvas canvas, double cx, double cy) {
    List<Offset> t1 = [project(-45, -45, -20, cx, cy), project(-25, -45, -20, cx, cy), project(-25, 45, -20, cx, cy), project(-45, 45, -20, cx, cy)];
    List<Offset> t2 = [project(25, -45, -20, cx, cy), project(45, -45, -20, cx, cy), project(45, 45, -20, cx, cy), project(25, 45, -20, cx, cy)];
    final p = Paint()..color = baseColor..style = showWireframe ? PaintingStyle.stroke : PaintingStyle.fill;
    final edge = Paint()..color = Colors.white..strokeWidth = 1.0..style = PaintingStyle.stroke;

    Path p1 = Path()..addPolygon(t1, true);
    Path p2 = Path()..addPolygon(t2, true);
    canvas.drawPath(p1, p);
    canvas.drawPath(p2, p);
    if (!showWireframe) { canvas.drawPath(p1, edge); canvas.drawPath(p2, edge); }
  }

  void _drawShuttle(Canvas canvas, double cx, double cy) {
    Offset nose = project(0, -60, 0, cx, cy);
    Offset wingL = project(-50, 35, 0, cx, cy);
    Offset wingR = project(50, 35, 0, cx, cy);
    Offset engine = project(0, 45, 0, cx, cy);

    Path shuttle = Path()..moveTo(nose.dx, nose.dy)..lineTo(wingR.dx, wingR.dy)..lineTo(engine.dx, engine.dy)..lineTo(wingL.dx, wingL.dy)..close();
    final p = Paint()..color = baseColor..style = showWireframe ? PaintingStyle.stroke : PaintingStyle.fill;
    final edge = Paint()..color = Colors.white..strokeWidth = 1.2..style = PaintingStyle.stroke;
    canvas.drawPath(shuttle, p);
    if (!showWireframe) canvas.drawPath(shuttle, edge);
  }

  void _drawChest(Canvas canvas, double cx, double cy) {
    List<Offset> box = [project(-28, -15, -20, cx, cy), project(28, -15, -20, cx, cy), project(28, 25, -20, cx, cy), project(-28, 25, -20, cx, cy)];
    final p = Paint()..color = baseColor..style = showWireframe ? PaintingStyle.stroke : PaintingStyle.fill;
    final edge = Paint()..color = Colors.white..strokeWidth = 1.2..style = PaintingStyle.stroke;
    Path chest = Path()..addPolygon(box, true);
    canvas.drawPath(chest, p);
    if (!showWireframe) canvas.drawPath(chest, edge);
  }

  void _drawLink(Canvas canvas, Offset a, Offset b, Paint fill, Paint edge) {
    canvas.drawLine(a, b, Paint()..color = fill.color..strokeWidth = 5.0..strokeCap = StrokeCap.round);
    if (!showWireframe) canvas.drawCircle(a, 3.0, edge);
  }

  @override
  bool shouldRepaint(covariant Authentic3DModelViewerPainter oldDelegate) => true;
}
