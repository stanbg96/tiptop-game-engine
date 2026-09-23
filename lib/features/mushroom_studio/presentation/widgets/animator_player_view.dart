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
  int _viewMode = 0; // 0: Комбиниран, 1: 3D Скелет, 2: Y-Bot Броня
  double _speed = 1.0;
  double _currentFrame = 0.0;
  final double _totalFrames = 120.0;
  double _mannequinYaw = 0.0;
  double _mannequinPitch = 0.0;

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

  void _stepSingleFrame(double delta) {
    setState(() {
      _isPlaying = false;
      _animController.stop();
      _currentFrame = (_currentFrame + delta).clamp(0.0, _totalFrames);
      _animController.value = _currentFrame / _totalFrames;
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
        content: Text('⚡ Движението "${widget.activeAnimation}" е приложено към Mixamo 3D модела в Filament!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. 3D Viewport с пълния анатомичен модел
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 6, 8, 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10131E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF22283A), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 15),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0, -0.3),
                        radius: 1.2,
                        colors: [Color(0xFF222A42), Color(0xFF090B10)],
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onPanUpdate: (d) {
                    setState(() {
                      _mannequinYaw += d.delta.dx * 0.014;
                      _mannequinPitch = (_mannequinPitch + d.delta.dy * 0.01).clamp(-0.4, 0.4);
                    });
                  },
                  child: Center(
                    child: CustomPaint(
                      size: const Size(280, 300),
                      painter: CompleteHumanoidRigPainter(
                        progress: _animController.value,
                        yaw: _mannequinYaw,
                        pitch: _mannequinPitch,
                        viewMode: _viewMode,
                        category: widget.activeCategory,
                      ),
                    ),
                  ),
                ),

                // Горна лента: Име на движението + Режими
                Positioned(
                  top: 8,
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161A28),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.laserPink.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.motion_photos_on, size: 13, color: AppTheme.laserPink),
                            const SizedBox(width: 5),
                            Text(widget.activeAnimation, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _buildModeChip(0, '✨ Пълен'),
                          const SizedBox(width: 4),
                          _buildModeChip(1, '🦴 Скелет'),
                          const SizedBox(width: 4),
                          _buildModeChip(2, '🤖 Y-Bot'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Долен статус
                Positioned(
                  bottom: 8,
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          'Пълен MoCap Риг • Кадър ${_currentFrame.toInt()} / ${_totalFrames.toInt()}',
                          style: const TextStyle(color: AppTheme.sciFiCyan, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Text('↔ 360° въртене с пръст', style: TextStyle(color: Colors.white38, fontSize: 8)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Таймлайн със стъпки кадър по кадър
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.skip_previous, color: AppTheme.sciFiCyan, size: 22),
                tooltip: '-1 Кадър',
                onPressed: () => _stepSingleFrame(-1),
              ),
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
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.skip_next, color: AppTheme.sciFiCyan, size: 22),
                tooltip: '+1 Кадър',
                onPressed: () => _stepSingleFrame(1),
              ),
            ],
          ),
        ),

        // 3. Скорост и Play/Pause
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
                  size: 44,
                  color: AppTheme.sciFiCyan,
                ),
                onPressed: _togglePlayPause,
              ),
              _buildSpeedPill('1.0x', 1.0),
              _buildSpeedPill('2.0x', 2.0),
            ],
          ),
        ),

        // 4. Бутон за синхронизация
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 8),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.laserPink, AppTheme.sciFiCyan]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: AppTheme.laserPink.withValues(alpha: 0.4), blurRadius: 10),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                  onPressed: _applyToFilamentEngine,
                  child: const Text('⚡ ПРИЛОЖИ КЪМ 3D ГЕРОЯ В СЦЕНАТА', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeChip(int mode, String label) {
    bool isSel = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF00E676) : const Color(0xFF161A28),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSel ? const Color(0xFF00E676) : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSel ? Colors.black : Colors.white70, fontSize: 8, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSpeedPill(String label, double targetSpeed) {
    bool isSel = _speed == targetSpeed;
    return GestureDetector(
      onTap: () => _setPlaybackSpeed(targetSpeed),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.laserPink : const Color(0xFF1E2235),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSel ? AppTheme.laserPink : Colors.white12),
        ),
        child: Text(label, style: TextStyle(color: isSel ? Colors.white : Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// =========================================================================
// 🦴 ПЪЛЕН 3D СКЕЛЕТЕН & Y-BOT РЕНДЕРЕР (С ПЪЛНИ КРАКА, СТЪПАЛА И ПРЪСТИ)
// =========================================================================

class CompleteHumanoidRigPainter extends CustomPainter {
  final double progress;
  final double yaw;
  final double pitch;
  final int viewMode;
  final String category;

  CompleteHumanoidRigPainter({
    required this.progress,
    required this.yaw,
    required this.pitch,
    required this.viewMode,
    required this.category,
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

    double depth = (depthZ + 270.0) / 270.0;
    if (depth < 0.2) depth = 0.2;
    return Offset(cx + rx * depth, cy + ry * depth);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2.0;
    final double cy = size.height / 2.0;

    double t = progress * 2.0 * math.pi;

    // Пълна биомеханика
    double armAngle = math.sin(t) * 0.72;
    double forearmBend = (math.sin(t + 0.5) * 0.4).abs();
    double legAngle = math.cos(t) * 0.82;
    double kneeBend = (math.sin(t + math.pi / 2.0) * 0.6).abs();
    double bodyBob = math.sin(t * 2.0) * 5.0;
    double pelvisTilt = math.sin(t) * 0.08;
    double spineCurve = math.cos(t * 2.0) * 0.05;

    if (category.contains('Танци')) {
      armAngle = math.sin(t * 2.0) * 1.25;
      bodyBob = math.cos(t * 2.0) * 11.0;
      pelvisTilt = math.sin(t * 2.0) * 0.20;
    } else if (category.contains('Бойни')) {
      armAngle = math.sin(t * 3.0) * 1.35;
      legAngle = math.cos(t * 2.0) * 1.15;
      pelvisTilt = 0.18;
    } else if (category.contains('Паркур')) {
      armAngle = math.sin(t) * 1.45;
      legAngle = math.sin(t) * 1.25;
      bodyBob = math.sin(t * 2.0) * 14.0;
    }

    // 1. Подиум със светлина
    final floorPaint = Paint()
      ..shader = RadialGradient(
        colors: [AppTheme.sciFiCyan.withValues(alpha: 0.3), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy + 90.0), radius: 65.0));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 90.0), width: 130.0, height: 35.0), floorPaint);

    // 2. 19 Пълни Анатомични стави
    Offset head = project(0.0, -78.0 + bodyBob, 0.0, cx, cy);
    Offset neck = project(0.0, -54.0 + bodyBob, 0.0, cx, cy);
    Offset chest = project(0.0, -32.0 + bodyBob, spineCurve * 15.0, cx, cy);
    Offset pelvis = project(0.0, 10.0 + bodyBob, 0.0, cx, cy);

    // Рамене
    Offset lClavicle = project(-8.0, -48.0 + bodyBob, 0.0, cx, cy);
    Offset rClavicle = project(8.0, -48.0 + bodyBob, 0.0, cx, cy);
    Offset lShoulder = project(-24.0 * math.cos(pelvisTilt), -46.0 + bodyBob, -24.0 * math.sin(pelvisTilt), cx, cy);
    Offset rShoulder = project(24.0 * math.cos(pelvisTilt), -46.0 + bodyBob, 24.0 * math.sin(pelvisTilt), cx, cy);

    // Ръце, китки и длани
    Offset lElbow = project(-26.0 - 24.0 * math.cos(armAngle), -20.0 + 24.0 * math.sin(armAngle) + bodyBob, 12.0 * math.sin(armAngle), cx, cy);
    Offset lWrist = project(-28.0 - 46.0 * math.cos(armAngle + forearmBend), -2.0 + 44.0 * math.sin(armAngle + forearmBend) + bodyBob, 24.0 * math.sin(armAngle), cx, cy);
    Offset lHand = project(-29.0 - 54.0 * math.cos(armAngle + forearmBend), 6.0 + 50.0 * math.sin(armAngle + forearmBend) + bodyBob, 28.0 * math.sin(armAngle), cx, cy);

    Offset rElbow = project(26.0 + 24.0 * math.cos(armAngle), -20.0 - 24.0 * math.sin(armAngle) + bodyBob, -12.0 * math.sin(armAngle), cx, cy);
    Offset rWrist = project(28.0 + 46.0 * math.cos(armAngle - forearmBend), -2.0 - 44.0 * math.sin(armAngle - forearmBend) + bodyBob, -24.0 * math.sin(armAngle), cx, cy);
    Offset rHand = project(29.0 + 54.0 * math.cos(armAngle - forearmBend), 6.0 - 50.0 * math.sin(armAngle - forearmBend) + bodyBob, -28.0 * math.sin(armAngle), cx, cy);

    // Крака: Бедро ➔ Коляно ➔ Глезен ➔ Стъпало ➔ Пръсти
    Offset lHip = project(-14.0, 12.0 + bodyBob, 0.0, cx, cy);
    Offset rHip = project(14.0, 12.0 + bodyBob, 0.0, cx, cy);

    Offset lKnee = project(-14.0, 48.0 + 18.0 * math.cos(legAngle) + bodyBob, -30.0 * math.sin(legAngle), cx, cy);
    Offset lAnkle = project(-14.0, 80.0 + 24.0 * math.cos(legAngle + kneeBend), -42.0 * math.sin(legAngle), cx, cy);
    Offset lFoot = project(-14.0, 88.0 + 24.0 * math.cos(legAngle + kneeBend), -28.0 * math.sin(legAngle) + 12.0, cx, cy);
    Offset lToes = project(-14.0, 89.0 + 24.0 * math.cos(legAngle + kneeBend), -16.0 * math.sin(legAngle) + 22.0, cx, cy);

    Offset rKnee = project(14.0, 48.0 - 18.0 * math.cos(legAngle) + bodyBob, 30.0 * math.sin(legAngle), cx, cy);
    Offset rAnkle = project(14.0, 80.0 - 24.0 * math.cos(legAngle - kneeBend), 42.0 * math.sin(legAngle), cx, cy);
    Offset rFoot = project(14.0, 88.0 - 24.0 * math.cos(legAngle - kneeBend), 28.0 * math.sin(legAngle) + 12.0, cx, cy);
    Offset rToes = project(14.0, 89.0 - 24.0 * math.cos(legAngle - kneeBend), 16.0 * math.sin(legAngle) + 22.0, cx, cy);

    // 3. РИСУВАНЕ НА Y-BOT БРОНЯТА С ПЪЛНИ БОТУШИ И ДЛАНИ
    if (viewMode == 0 || viewMode == 2) {
      double alpha = (viewMode == 0) ? 0.65 : 1.0;
      _drawArmorLimb(canvas, lShoulder, lElbow, 7.5, 6.0, alpha);
      _drawArmorLimb(canvas, lElbow, lWrist, 6.0, 4.5, alpha);
      _drawArmorLimb(canvas, lWrist, lHand, 4.5, 3.0, alpha);

      _drawArmorLimb(canvas, rShoulder, rElbow, 7.5, 6.0, alpha);
      _drawArmorLimb(canvas, rElbow, rWrist, 6.0, 4.5, alpha);
      _drawArmorLimb(canvas, rWrist, rHand, 4.5, 3.0, alpha);

      _drawArmorLimb(canvas, lHip, lKnee, 10.0, 7.5, alpha);
      _drawArmorLimb(canvas, lKnee, lAnkle, 7.5, 5.0, alpha);
      _drawArmorBoot(canvas, lAnkle, lFoot, lToes, alpha);

      _drawArmorLimb(canvas, rHip, rKnee, 10.0, 7.5, alpha);
      _drawArmorLimb(canvas, rKnee, rAnkle, 7.5, 5.0, alpha);
      _drawArmorBoot(canvas, rAnkle, rFoot, rToes, alpha);

      _drawArmorTorso(canvas, neck, chest, pelvis, lShoulder, rShoulder, alpha);
      _drawArmorHead(canvas, head, alpha);
    }

    // 4. РИСУВАНЕ НА ПЪЛНИЯ ОКТАЕДРИЧЕН СКЕЛЕТ (С ПРЪСТИ И СТЪПАЛА)
    if (viewMode == 0 || viewMode == 1) {
      _drawOctahedralBone(canvas, pelvis, chest, 9.0);
      _drawOctahedralBone(canvas, chest, neck, 6.0);
      _drawOctahedralBone(canvas, neck, head, 5.0);

      _drawOctahedralBone(canvas, neck, lClavicle, 4.0);
      _drawOctahedralBone(canvas, lClavicle, lShoulder, 4.5);
      _drawOctahedralBone(canvas, lShoulder, lElbow, 6.0);
      _drawOctahedralBone(canvas, lElbow, lWrist, 4.5);
      _drawOctahedralBone(canvas, lWrist, lHand, 3.5);

      _drawOctahedralBone(canvas, neck, rClavicle, 4.0);
      _drawOctahedralBone(canvas, rClavicle, rShoulder, 4.5);
      _drawOctahedralBone(canvas, rShoulder, rElbow, 6.0);
      _drawOctahedralBone(canvas, rElbow, rWrist, 4.5);
      _drawOctahedralBone(canvas, rWrist, rHand, 3.5);

      _drawOctahedralBone(canvas, pelvis, lHip, 6.0);
      _drawOctahedralBone(canvas, lHip, lKnee, 7.5);
      _drawOctahedralBone(canvas, lKnee, lAnkle, 6.0);
      _drawOctahedralBone(canvas, lAnkle, lFoot, 4.5);
      _drawOctahedralBone(canvas, lFoot, lToes, 3.5);

      _drawOctahedralBone(canvas, pelvis, rHip, 6.0);
      _drawOctahedralBone(canvas, rHip, rKnee, 7.5);
      _drawOctahedralBone(canvas, rKnee, rAnkle, 6.0);
      _drawOctahedralBone(canvas, rAnkle, rFoot, 4.5);
      _drawOctahedralBone(canvas, rFoot, rToes, 3.5);
    }
  }

  void _drawOctahedralBone(Canvas canvas, Offset p1, Offset p2, double width) {
    final double dx = p2.dx - p1.dx;
    final double dy = p2.dy - p1.dy;
    final double angle = math.atan2(dy, dx) + math.pi / 2.0;

    Offset mid = Offset(p1.dx + dx * 0.25, p1.dy + dy * 0.25);
    Offset side1 = Offset(mid.dx + math.cos(angle) * width, mid.dy + math.sin(angle) * width);
    Offset side2 = Offset(mid.dx - math.cos(angle) * width, mid.dy - math.sin(angle) * width);

    Path boneLight = Path()..moveTo(p1.dx, p1.dy)..lineTo(side1.dx, side1.dy)..lineTo(p2.dx, p2.dy)..close();
    Path boneDark = Path()..moveTo(p1.dx, p1.dy)..lineTo(side2.dx, side2.dy)..lineTo(p2.dx, p2.dy)..close();

    final lightPaint = Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.85)..style = PaintingStyle.fill;
    final darkPaint = Paint()..color = const Color(0xFF0091EA).withValues(alpha: 0.85)..style = PaintingStyle.fill;
    final edgePaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.0;

    canvas.drawPath(boneLight, lightPaint);
    canvas.drawPath(boneDark, darkPaint);
    canvas.drawPath(boneLight, edgePaint);
    canvas.drawPath(boneDark, edgePaint);

    canvas.drawCircle(p1, 2.5, Paint()..color = const Color(0xFFFF007F));
    canvas.drawCircle(p2, 2.5, Paint()..color = const Color(0xFFFF007F));
  }

  void _drawArmorLimb(Canvas canvas, Offset p1, Offset p2, double r1, double r2, double alpha) {
    final double angle = math.atan2(p2.dy - p1.dy, p2.dx - p1.dx) + math.pi / 2.0;
    Offset o1 = Offset(math.cos(angle) * r1, math.sin(angle) * r1);
    Offset o2 = Offset(math.cos(angle) * r2, math.sin(angle) * r2);

    Path p = Path()
      ..moveTo(p1.dx + o1.dx, p1.dy + o1.dy)
      ..lineTo(p2.dx + o2.dx, p2.dy + o2.dy)
      ..lineTo(p2.dx - o2.dx, p2.dy - o2.dy)
      ..lineTo(p1.dx - o1.dx, p1.dy - o1.dy)
      ..close();

    final limbPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFFC4CBD8).withValues(alpha: alpha), const Color(0xFF333D50).withValues(alpha: alpha)],
      ).createShader(Rect.fromPoints(p1, p2));

    canvas.drawPath(p, limbPaint);
    canvas.drawPath(p, Paint()..color = const Color(0xFFE2E8F0).withValues(alpha: alpha * 0.5)..style = PaintingStyle.stroke..strokeWidth = 1.0);
  }

  // 👢 ПЪЛЕН 3D МЕТАЛЕН БОТУШ С ПОДМЕТКА И ПРЪСТИ
  void _drawArmorBoot(Canvas canvas, Offset ankle, Offset foot, Offset toes, double alpha) {
    Path boot = Path()
      ..moveTo(ankle.dx - 5.0, ankle.dy)
      ..lineTo(ankle.dx + 5.0, ankle.dy)
      ..lineTo(foot.dx + 6.0, foot.dy)
      ..lineTo(toes.dx + 4.0, toes.dy)
      ..lineTo(toes.dx - 4.0, toes.dy)
      ..lineTo(foot.dx - 6.0, foot.dy)
      ..close();

    final bootPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFFE2E8F0).withValues(alpha: alpha), const Color(0xFF1E293B).withValues(alpha: alpha)],
      ).createShader(Rect.fromPoints(ankle, toes));

    canvas.drawPath(boot, bootPaint);
    canvas.drawPath(boot, Paint()..color = AppTheme.sciFiCyan.withValues(alpha: alpha)..style = PaintingStyle.stroke..strokeWidth = 1.0);
  }

  void _drawArmorTorso(Canvas canvas, Offset neck, Offset chest, Offset pelvis, Offset lSh, Offset rSh, double alpha) {
    Path torso = Path()
      ..moveTo(lSh.dx, lSh.dy)
      ..lineTo(neck.dx, neck.dy - 3.0)
      ..lineTo(rSh.dx, rSh.dy)
      ..lineTo(pelvis.dx + 18.0, pelvis.dy)
      ..lineTo(pelvis.dx - 18.0, pelvis.dy)
      ..close();

    final torsoPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFFD8DFEC).withValues(alpha: alpha), const Color(0xFF2D3546).withValues(alpha: alpha)],
      ).createShader(Rect.fromCenter(center: chest, width: 55, height: 65));

    canvas.drawPath(torso, torsoPaint);
    canvas.drawPath(torso, Paint()..color = const Color(0xFFE2E8F0).withValues(alpha: alpha * 0.7)..style = PaintingStyle.stroke..strokeWidth = 1.2);

    final coreGlow = Paint()
      ..shader = RadialGradient(
        colors: [AppTheme.sciFiCyan, Colors.transparent],
      ).createShader(Rect.fromCircle(center: chest, radius: 8.0));
    canvas.drawCircle(chest, 8.0, coreGlow);
    canvas.drawCircle(chest, 4.0, Paint()..color = Colors.white);
  }

  void _drawArmorHead(Canvas canvas, Offset headPos, double alpha) {
    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.2),
        colors: [const Color(0xFFE2E8F0).withValues(alpha: alpha), const Color(0xFF1E293B).withValues(alpha: alpha)],
      ).createShader(Rect.fromCircle(center: headPos, radius: 15.0));

    canvas.drawCircle(headPos, 14.0, headPaint);
    canvas.drawCircle(headPos, 14.0, Paint()..color = const Color(0xFFCBD5E1)..style = PaintingStyle.stroke..strokeWidth = 1.2);

    final visorPaint = Paint()..color = AppTheme.sciFiCyan;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(headPos.dx, headPos.dy - 1.0), width: 15.0, height: 5.0), const Radius.circular(3.0)), visorPaint);
  }

  @override
  bool shouldRepaint(covariant CompleteHumanoidRigPainter oldDelegate) => true;
}
