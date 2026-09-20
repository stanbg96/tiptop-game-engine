import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/engine_bridge/godot_view.dart';

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

class _AnimatorPlayerViewState extends State<AnimatorPlayerView> {
  bool _isPlaying = true;
  bool _showBones = false;
  double _speed = 1.0;
  double _currentFrame = 0.0;
  final double _totalFrames = 120.0;

  void _togglePlayPause() {
    setState(() => _isPlaying = !_isPlaying);
    // Тук изпращаме команда към Godot: "AnimationPlayer.play()" или "pause()"
  }

  void _setPlaybackSpeed(double newSpeed) {
    setState(() => _speed = newSpeed);
    // Команда към Godot: "AnimationPlayer.set_speed_scale(newSpeed)"
  }

  void _onTimelineScrub(double frameVal) {
    setState(() {
      _currentFrame = frameVal;
      if (_isPlaying) _isPlaying = false;
    });
    // Команда към Godot: "AnimationPlayer.seek(frameVal / 60.0)"
  }

  void _applyToEngine() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('⚡ Движението "${widget.activeAnimation}" е приложено към героя в Godot сцената!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. ИСТИНСКИ GODOT 4 VIEWPORT ЗА АНИМАЦИИ
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            decoration: BoxDecoration(
              color: const Color(0xFF121420),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.sciFiCyan, width: 1.5),
              boxShadow: [BoxShadow(color: AppTheme.sciFiCyan.withValues(alpha: 0.15), blurRadius: 15)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  // Вграденият Godot 4 Енджин, който зарежда .glb файла на героя
                  const Positioned.fill(
                    child: GodotNativeView(),
                  ),

                  // Тъмен филтър докато Godot зареди (само за симулация на UI)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.2),
                      child: const Center(
                        child: Text(
                          'Godot 4 Y-Bot 3D Renderer Active\n(Waiting for .glb model)',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ),
                    ),
                  ),

                  // Горна лента
                  Positioned(
                    top: 10,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: const Color(0xFF181B2C), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.laserPink.withValues(alpha: 0.5))),
                          child: Row(
                            children: [
                              const Icon(Icons.motion_photos_on, size: 14, color: AppTheme.laserPink),
                              const SizedBox(width: 6),
                              Text(widget.activeAnimation, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => _showBones = !_showBones);
                            // Команда към Godot: "Skeleton3D.show_bones = true"
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: _showBones ? const Color(0xFF00E676).withValues(alpha: 0.25) : const Color(0xFF181B2C),
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

                  // Долен статус
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
                          child: Text('Кадър: ${_currentFrame.toInt()} / ${_totalFrames.toInt()}', style: const TextStyle(color: AppTheme.sciFiCyan, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                        const Text('↔ Плъзни за 360° завъртане в Godot', style: TextStyle(color: Colors.white38, fontSize: 9)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 2. Интерактивен Таймлайн
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Row(
            children: [
              const Text('0', style: TextStyle(color: Colors.grey, fontSize: 10)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(activeTrackColor: AppTheme.laserPink, inactiveTrackColor: const Color(0xFF222638), thumbColor: AppTheme.sciFiCyan, trackHeight: 3.5),
                  child: Slider(value: _currentFrame.clamp(0.0, _totalFrames), min: 0.0, max: _totalFrames, onChanged: _onTimelineScrub),
                ),
              ),
              Text('${_totalFrames.toInt()}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
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
              IconButton(icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 46, color: AppTheme.sciFiCyan), onPressed: _togglePlayPause),
              _buildSpeedPill('1.0x', 1.0),
              _buildSpeedPill('2.0x', 2.0),
            ],
          ),
        ),

        // 4. Приложи
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: SizedBox(
              width: double.infinity,
              height: 42,
              child: Container(
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.laserPink, AppTheme.sciFiCyan]), borderRadius: BorderRadius.circular(12)),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                  onPressed: _applyToEngine,
                  child: const Text('⚡ ПРИЛОЖИ КЪМ ГЕРОЯ В СЦЕНАТА', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
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
        decoration: BoxDecoration(color: isSel ? AppTheme.laserPink : const Color(0xFF1E2235), borderRadius: BorderRadius.circular(8), border: Border.all(color: isSel ? AppTheme.laserPink : Colors.white12)),
        child: Text(label, style: TextStyle(color: isSel ? Colors.white : Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
