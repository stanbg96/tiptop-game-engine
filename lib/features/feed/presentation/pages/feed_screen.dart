import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/features/feed/presentation/widgets/feed_action_bar.dart';
import 'package:tiptop_game_engine/features/live/presentation/live_stream_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _gameFeed = [
    {
      'title': 'Cyberpunk Neon Runner 3D',
      'creator': '@neon_builder',
      'likes': 1420,
      'comments': 89,
      'shares': 45,
      'bgGradient': [Color(0xFF2A0845), Color(0xFF0F041D)],
    },
    {
      'title': 'Medieval Castle Defense 2D',
      'creator': '@pixel_wizard',
      'likes': 850,
      'comments': 34,
      'shares': 12,
      'bgGradient': [Color(0xFF0B2B26), Color(0xFF051310)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: _gameFeed.length,
          itemBuilder: (context, index) {
            final game = _gameFeed[index];
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: game['bgGradient'],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.gamepad_rounded, size: 80, color: AppTheme.laserPink),
                        const SizedBox(height: 12),
                        Text(game['title'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        const Text('Докосни екрана за интеракция с 3D енджина', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 24,
                  right: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(game['creator'], style: const TextStyle(color: AppTheme.sciFiCyan, fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(game['title'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 6),
                      const Row(
                        children: [
                          Icon(Icons.bolt, color: AppTheme.laserPink, size: 15),
                          SizedBox(width: 4),
                          Text('Google Filament C++ 60 FPS', style: TextStyle(color: AppTheme.laserPink, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 20,
                  child: FeedActionBar(
                    likes: game['likes'],
                    comments: game['comments'],
                    shares: game['shares'],
                    onLike: () {},
                    onComment: () {},
                    onShare: () {},
                  ),
                ),
              ],
            );
          },
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 🔴 LIVE БУТОН - 100% РАБОТЕЩ
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LiveStreamScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF1744), Color(0xFFFF007F)]),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFFF1744).withValues(alpha: 0.5), blurRadius: 8),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, color: Colors.white, size: 8),
                        SizedBox(width: 5),
                        Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const Row(
                  children: [
                    Text('Следвани', style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w600)),
                    SizedBox(width: 14),
                    Text('За Теб', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(width: 45),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
