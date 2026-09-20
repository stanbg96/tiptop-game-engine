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
        // 1. Преглед на скелетния Rig
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            decoration: BoxDecoration(
              color: const Color(0xFF141724),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.laserPink.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(color: AppTheme.laserPink.withValues(alpha: 0.15), blurRadius: 15),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: CustomPaint(
                    size: const Size(190, 230),
                    painter: StudioSkeletonRigPainter(
                      progress: _animController.value,
                      showBones: _showBones,
                      category: widget.activeCategory,
                      color: AppTheme.sciFiCyan,
                    ),
                  ),
                ),

                // Горна лента с данни
                Positioned(
                  top: 10,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                        child: Text(widget.activeAnimation, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _showBones = !_showBones),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _showBones ? const Color(0xFF00E676).withValues(alpha: 0.25) : Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _showBones ? const Color(0xFF00E676) : Colors.white24),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.accessibility_new, size: 12, color: _showBones ? const Color(0xFF00E676) : Colors.grey),
                              const SizedBox(width: 4),
                              Text('🦴 Скелет', style: TextStyle(color: _showBones ? const Color(0xFF00E676) : Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Индикатор на кадъра (Frame Counter)
                Positioned(
                  bottom: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      'Кадър: ${_currentFrame.toInt()} / ${_totalFrames.toInt()} (60 FPS)',
                      style: const TextStyle(color: AppTheme.sciFiCyan, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
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
              Text('0', style: const TextStyle(color: Colors.grey, fontSize: 10)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.laserPink,
                    inactiveTrackColor: const Color(0xFF222638),
                    thumbColor: AppTheme.sciFiCyan,
                    trackHeight: 3.0,
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

// 3D Skeleton Rig Painter
class StudioSkeletonRigPainter extends CustomPainter {
  final double progress;
  final bool showBones;
  final String category;
  final Color color;

  StudioSkeletonRigPainter({
    required this.progress,
    required this.showBones,
    required this.category,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bonePaint = Paint()
      ..color = showBones ? color : color.withValues(alpha: 0.4)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final jointPaint = Paint()..color = const Color(0xFFFF007F);
    final centerPaint = Paint()..color = const Color(0xFFFFD600);

    final double cx = size.width / 2.0;
    final double cy = size.height / 2.0;

    double t = progress * 2.0 * math.pi;
    double armAngle = math.sin(t) * 0.6;
    double legAngle = math.cos(t) * 0.7;
    double bodyBob = math.sin(t * 2.0) * 6.0;

    if (category.contains('Танци')) {
      armAngle = math.sin(t * 2.0) * 1.1;
      bodyBob = math.cos(t * 2.0) * 10.0;
    } else if (category.contains('Бойни')) {
      armAngle = math.sin(t * 3.0) * 1.3;
      legAngle = math.cos(t * 2.0) * 1.0;
    } else if (category.contains('Паркур')) {
      armAngle = math.sin(t) * 1.4;
      legAngle = math.sin(t) * 1.2;
      bodyBob = math.sin(t * 2.0) * 14.0;
    }

    // Глава
    canvas.drawCircle(Offset(cx, cy - 55.0 + bodyBob), 14, bonePaint);
    canvas.drawCircle(Offset(cx, cy - 55.0 + bodyBob), 4, jointPaint);

    // Гръбнак (Spine & Pelvis)
    Offset neck = Offset(cx, cy - 40.0 + bodyBob);
    Offset pelvis = Offset(cx, cy + 10.0 + bodyBob);
    canvas.drawLine(neck, pelvis, bonePaint);
    canvas.drawCircle(pelvis, 5, centerPaint);

    // Рамене и Ръце (Left & Right Arms)
    Offset leftShoulder = Offset(cx - 16.0, cy - 35.0 + bodyBob);
    Offset rightShoulder = Offset(cx + 16.0, cy - 35.0 + bodyBob);
    canvas.drawLine(neck, leftShoulder, bonePaint);
    canvas.drawLine(neck, rightShoulder, bonePaint);

    Offset leftHand = Offset(cx - 36.0 * math.cos(armAngle), cy - 20.0 + 35.0 * math.sin(armAngle) + bodyBob);
    Offset rightHand = Offset(cx + 36.0 * math.cos(armAngle), cy - 20.0 - 35.0 * math.sin(armAngle) + bodyBob);
    canvas.drawLine(leftShoulder, leftHand, bonePaint);
    canvas.drawLine(rightShoulder, rightHand, bonePaint);
    canvas.drawCircle(leftHand, 4, jointPaint);
    canvas.drawCircle(rightHand, 4, jointPaint);

    // Крака (Left & Right Legs)
    Offset leftFoot = Offset(cx - 26.0 * math.sin(legAngle), cy + 65.0 + 15.0 * math.cos(legAngle));
    Offset rightFoot = Offset(cx + 26.0 * math.sin(legAngle), cy + 65.0 - 15.0 * math.cos(legAngle));
    canvas.drawLine(pelvis, leftFoot, bonePaint);
    canvas.drawLine(pelvis, rightFoot, bonePaint);
    canvas.drawCircle(leftFoot, 4, jointPaint);
    canvas.drawCircle(rightFoot, 4, jointPaint);
  }

  @override
  bool shouldRepaint(covariant StudioSkeletonRigPainter oldDelegate) => true;
}
