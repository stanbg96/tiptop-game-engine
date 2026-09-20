import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/engine_bridge/filament_bindings.dart';

class AnimatorPlayerView extends StatefulWidget {
  final String activeAnimation;
  final String activeCategory;

  const AnimatorPlayerView({
    Key? key,
    required this.activeAnimation,
    required this.activeCategory,
  }) : super(key: key);

  @override
  State<AnimatorPlayerView> createState() => _AnimatorPlayerViewState();
}

class _AnimatorPlayerViewState extends State<AnimatorPlayerView> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isPlaying = true;
  bool _showBones = true;
  double _speed = 1.0;
  double _currentFrame = 0.0;
  final double _totalFrames = 120.0;
  double _mannequinYaw = 0.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addListener(() {
        if (_isPlaying) {
          setState(() {
            _currentFrame = _animController.value * _totalFrames;
          });
        }
      });
    _animController.repeat();
  }

  @override
  void didUpdateWidget(covariant AnimatorPlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeAnimation != widget.activeAnimation) {
      if (_isPlaying) {
        _animController.reset();
        _animController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _animController.repeat();
      } else {
        _animController.stop();
      }
    });
  }

  void _setPlaybackSpeed(double newSpeed) {
    setState(() {
      _speed = (_speed == newSpeed) ? 1.0 : newSpeed;
      _animController.duration = Duration(milliseconds: (1500 / _speed).toInt());
      if (_isPlaying) {
        _animController.repeat();
      }
    });
  }

  void _onTimelineScrub(double frameVal) {
    setState(() {
      _currentFrame = frameVal;
      _animController.value = frameVal / _totalFrames;
      if (_isPlaying) {
        _isPlaying = false;
        _animController.stop();
      }
    });
  }

  void _applyToFilamentEngine() {
    FilamentEngine().applyAnimation(widget.activeAnimation, _speed);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚡ Движението "${widget.activeAnimation}" е приложено към 3D модела в Filament!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Професионален 3D Viewport на Манекена
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            decoration: BoxDecoration(
              color: const Color(0xFF141622),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF222638), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 15),
              ],
            ),
            child: Stack(
              children: [
                // 3D Студио фон с осветление
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0, -0.2),
                        radius: 1.1,
                        colors: [Color(0xFF1E2338), Color(0xFF0C0E16)],
                      ),
                    ),
                  ),
                ),

                // Манекен с плъзгане за 360° завъртане
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _mannequinYaw += details.delta.dx * 0.015;
                    });
                  },
                  child: Center(
                    child: CustomPaint(
                      size: const Size(260, 300),
                      painter: VolumetricHumanMannequinPainter(
                        progress: _animController.value,
                        yaw: _mannequinYaw,
                        showBones: _showBones,
                        category: widget.activeCategory,
                      ),
                    ),
                  ),
                ),

                // Горна лента с данни (Godot Style Badge)
                Positioned(
                  top: 10,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF181B2C),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.laserPink.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.motion_photos_on, size: 14, color: AppTheme.laserPink),
                            const SizedBox(width: 6),
                            Text(widget.activeAnimation, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _showBones = !_showBones),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: _showBones ? const Color(0xFF00E676).withValues(alpha: 0.2) : const Color(0xFF181B2C),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _showBones ? const Color(0xFF00E676) : Colors.white24),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.accessibility_new, size: 13, color: _showBones ? const Color(0xFF00E676) : Colors.grey),
                              const SizedBox(width: 4),
                              Text('🦴 Скелет', style: TextStyle(color: _showBones ? const Color(0xFF00E676) : Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Долен статус за 360° завъртане & Кадър
                Positioned(
                  bottom: 8,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          'Кадър: ${_currentFrame.toInt()} / ${_totalFrames.toInt()} (60 FPS)',
                          style: const TextStyle(color: AppTheme.sciFiCyan, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Text('↔ Плъзни за 360° въртене', style: TextStyle(color: Colors.white38, fontSize: 9)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Интерактивен Таймлайн (Timeline Scrubber)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Row(
            children: [
              const Text('0', style: TextStyle(color: Colors.grey, fontSize: 10)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.laserPink,
                    inactiveTrackColor: const Color(0xFF222638),
                    thumbColor: AppTheme.sciFiCyan,
                    trackHeight: 3.5,
                  ),
                  child: Slider(
                    value: _currentFrame.clamp(0.0, _totalFrames),
                    min: 0.0,
                    max: _totalFrames,
                    onChanged: _onTimelineScrub,
                  ),
                ),
              ),
              Text('${_totalFrames.toInt()}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ),

        // 3. Контроли за скорост и Play/Pause
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSpeedPill('0.25x', 0.25),
              _buildSpeedPill('0.5x', 0.5),
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 46,
                  color: AppTheme.sciFiCyan,
                ),
                onPressed: _togglePlayPause,
              ),
              _buildSpeedPill('1.0x', 1.0),
              _buildSpeedPill('2.0x', 2.0),
            ],
          ),
        ),

        // 4. Бутон за прилагане към модела
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: SizedBox(
              width: double.infinity,
              height: 42,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.laserPink, AppTheme.sciFiCyan]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: AppTheme.laserPink.withValues(alpha: 0.4), blurRadius: 10),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                  onPressed: _applyToFilamentEngine,
                  child: const Text('⚡ ПРИЛОЖИ КЪМ 3D МОДЕЛА', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedPill(String label, double targetSpeed) {
    bool isSel = _speed == targetSpeed;
    return GestureDetector(
      onTap: () => _setPlaybackSpeed(targetSpeed),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.laserPink : const Color(0xFF1E2235),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSel ? AppTheme.laserPink : Colors.white12),
        ),
        child: Text(label, style: TextStyle(color: isSel ? Colors.white : Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// =========================================================================
// 🧍 3D ОБЕМЕН ХЮМАНОИДЕН МАНЕКЕН (VOLUMETRIC PBR MANNEQUIN PAINTER)
// =========================================================================

class VolumetricHumanMannequinPainter extends CustomPainter {
  final double progress;
  final double yaw;
  final bool showBones;
  final String category;

  VolumetricHumanMannequinPainter({
    required this.progress,
    required this.yaw,
    required this.showBones,
    required this.category,
  });

  Offset project(double x, double y, double z, double cx, double cy) {
    double cosY = math.cos(yaw);
    double sinY = math.sin(yaw);
    double rx = x * cosY - z * sinY;
    double rz = x * sinY + z * cosY;
    double depth = (rz + 260.0) / 260.0;
    if (depth < 0.2) depth = 0.2;
    return Offset(cx + rx * depth, cy + y * depth);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2.0;
    final double cy = size.height / 2.0;

    double t = progress * 2.0 * math.pi;

    // Изчисляване на анатомични ъгли според типа движение
    double armAngle = math.sin(t) * 0.7;
    double legAngle = math.cos(t) * 0.8;
    double bodyBob = math.sin(t * 2.0) * 6.0;
    double torsoTilt = math.sin(t) * 0.1;

    if (category.contains('Танци')) {
      armAngle = math.sin(t * 2.0) * 1.2;
      bodyBob = math.cos(t * 2.0) * 12.0;
      torsoTilt = math.sin(t * 2.0) * 0.25;
    } else if (category.contains('Бойни')) {
      armAngle = math.sin(t * 3.0) * 1.4;
      legAngle = math.cos(t * 2.0) * 1.1;
      torsoTilt = 0.2;
    } else if (category.contains('Паркур')) {
      armAngle = math.sin(t) * 1.5;
      legAngle = math.sin(t) * 1.3;
      bodyBob = math.sin(t * 2.0) * 16.0;
    }

    // 1. Подиум с метални отражения под краката
    final pedestalPaint = Paint()
      ..shader = RadialGradient(
        colors: [AppTheme.sciFiCyan.withValues(alpha: 0.25), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy + 90.0), radius: 65.0));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 90.0), width: 130.0, height: 36.0), pedestalPaint);

    // 2. Анатомични възли (3D костни позиции)
    Offset head = project(0.0, -75.0 + bodyBob, 0.0, cx, cy);
    Offset neck = project(0.0, -52.0 + bodyBob, 0.0, cx, cy);
    Offset chest = project(0.0, -32.0 + bodyBob, 0.0, cx, cy);
    Offset pelvis = project(0.0, 10.0 + bodyBob, 0.0, cx, cy);

    // Рамене
    Offset lShoulder = project(-22.0 * math.cos(torsoTilt), -45.0 + bodyBob, -22.0 * math.sin(torsoTilt), cx, cy);
    Offset rShoulder = project(22.0 * math.cos(torsoTilt), -45.0 + bodyBob, 22.0 * math.sin(torsoTilt), cx, cy);

    // Ръце
    Offset lElbow = project(
      -22.0 - 24.0 * math.cos(armAngle),
      -20.0 + 26.0 * math.sin(armAngle) + bodyBob,
      12.0 * math.sin(armAngle),
      cx,
      cy,
    );
    Offset lHand = project(
      -22.0 - 46.0 * math.cos(armAngle),
      -2.0 + 44.0 * math.sin(armAngle) + bodyBob,
      24.0 * math.sin(armAngle),
      cx,
      cy,
    );

    Offset rElbow = project(
      22.0 + 24.0 * math.cos(armAngle),
      -20.0 - 26.0 * math.sin(armAngle) + bodyBob,
      -12.0 * math.sin(armAngle),
      cx,
      cy,
    );
    Offset rHand = project(
      22.0 + 46.0 * math.cos(armAngle),
      -2.0 - 44.0 * math.sin(armAngle) + bodyBob,
      -24.0 * math.sin(armAngle),
      cx,
      cy,
    );

    // Крака
    Offset lHip = project(-14.0, 12.0 + bodyBob, 0.0, cx, cy);
    Offset rHip = project(14.0, 12.0 + bodyBob, 0.0, cx, cy);

    Offset lKnee = project(
      -14.0,
      48.0 + 18.0 * math.cos(legAngle) + bodyBob,
      -30.0 * math.sin(legAngle),
      cx,
      cy,
    );
    Offset lFoot = project(
      -14.0,
      82.0 + 26.0 * math.cos(legAngle),
      -45.0 * math.sin(legAngle),
      cx,
      cy,
    );

    Offset rKnee = project(
      14.0,
      48.0 - 18.0 * math.cos(legAngle) + bodyBob,
      30.0 * math.sin(legAngle),
      cx,
      cy,
    );
    Offset rFoot = project(
      14.0,
      82.0 - 26.0 * math.cos(legAngle),
      45.0 * math.sin(legAngle),
      cx,
      cy,
    );

    // 3. Рисуване на ОБЕМНОТО АНАТОМИЧНО ТЯЛО (PBR Shaded Muscle Volumes)
    _drawLimbVolume(canvas, lShoulder, lElbow, 8.0, 6.0);
    _drawLimbVolume(canvas, lElbow, lHand, 6.0, 4.5);
    _drawLimbVolume(canvas, rShoulder, rElbow, 8.0, 6.0);
    _drawLimbVolume(canvas, rElbow, rHand, 6.0, 4.5);

    _drawLimbVolume(canvas, lHip, lKnee, 10.0, 7.5);
    _drawLimbVolume(canvas, lKnee, lFoot, 7.5, 5.0);
    _drawLimbVolume(canvas, rHip, rKnee, 10.0, 7.5);
    _drawLimbVolume(canvas, rKnee, rFoot, 7.5, 5.0);

    // Торс (Chest & Abdomen armor plates)
    _drawTorsoVolume(canvas, neck, chest, pelvis, lShoulder, rShoulder);

    // Глава с обем и шлем
    _drawHeadVolume(canvas, head);

    // 4. Скелетни светещи кости (ако са включени)
    if (showBones) {
      final bonePaint = Paint()
        ..color = AppTheme.sciFiCyan.withValues(alpha: 0.9)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;

      final jointPaint = Paint()..color = const Color(0xFFFF007F);

      List<List<Offset>> boneLinks = [
        [neck, head],
        [neck, chest],
        [chest, pelvis],
        [neck, lShoulder],
        [lShoulder, lElbow],
        [lElbow, lHand],
        [neck, rShoulder],
        [rShoulder, rElbow],
        [rElbow, rHand],
        [pelvis, lHip],
        [lHip, lKnee],
        [lKnee, lFoot],
        [pelvis, rHip],
        [rHip, rKnee],
        [rKnee, rFoot],
      ];

      for (var link in boneLinks) {
        canvas.drawLine(link[0], link[1], bonePaint);
        canvas.drawCircle(link[0], 3.0, jointPaint);
        canvas.drawCircle(link[1], 3.0, jointPaint);
      }
    }
  }

  void _drawLimbVolume(Canvas canvas, Offset p1, Offset p2, double r1, double r2) {
    final double angle = math.atan2(p2.dy - p1.dy, p2.dx - p1.dx) + math.pi / 2.0;
    Offset offset1 = Offset(math.cos(angle) * r1, math.sin(angle) * r1);
    Offset offset2 = Offset(math.cos(angle) * r2, math.sin(angle) * r2);

    Path path = Path()
      ..moveTo(p1.dx + offset1.dx, p1.dy + offset1.dy)
      ..lineTo(p2.dx + offset2.dx, p2.dy + offset2.dy)
      ..lineTo(p2.dx - offset2.dx, p2.dy - offset2.dy)
      ..lineTo(p1.dx - offset1.dx, p1.dy - offset1.dy)
      ..close();

    final limbPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF323B54), const Color(0xFF161A28)],
      ).createShader(Rect.fromPoints(p1, p2));

    final outlinePaint = Paint()
      ..color = AppTheme.sciFiCyan.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(path, limbPaint);
    canvas.drawPath(path, outlinePaint);
    canvas.drawCircle(p1, r1, limbPaint);
    canvas.drawCircle(p2, r2, limbPaint);
  }

  void _drawTorsoVolume(Canvas canvas, Offset neck, Offset chest, Offset pelvis, Offset lSh, Offset rSh) {
    Path torso = Path()
      ..moveTo(lSh.dx, lSh.dy)
      ..lineTo(neck.dx, neck.dy - 2.0)
      ..lineTo(rSh.dx, rSh.dy)
      ..lineTo(pelvis.dx + 16.0, pelvis.dy)
      ..lineTo(pelvis.dx - 16.0, pelvis.dy)
      ..close();

    final torsoPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3E4866), Color(0xFF1E2335)],
      ).createShader(Rect.fromCenter(center: chest, width: 50, height: 60));

    final edge = Paint()
      ..color = AppTheme.laserPink.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(torso, torsoPaint);
    canvas.drawPath(torso, edge);
  }

  void _drawHeadVolume(Canvas canvas, Offset headPos) {
    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [const Color(0xFF536085), const Color(0xFF161A28)],
      ).createShader(Rect.fromCircle(center: headPos, radius: 15.0));

    final visorPaint = Paint()..color = AppTheme.sciFiCyan;

    canvas.drawCircle(headPos, 14.0, headPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(headPos.dx, headPos.dy - 1.0), width: 14.0, height: 4.5), visorPaint);
  }

  @override
  bool shouldRepaint(covariant VolumetricHumanMannequinPainter oldDelegate) => true;
}
