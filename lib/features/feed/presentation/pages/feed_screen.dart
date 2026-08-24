import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/features/feed/presentation/widgets/feed_action_bar.dart';

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
      'bgGradient': [Colors.deepPurple, Colors.black],
    },
    {
      'title': 'Medieval Castle Defense 2D',
      'creator': '@pixel_wizard',
      'likes': 850,
      'comments': 34,
      'shares': 12,
      'bgGradient': [Colors.blueGrey, Colors.black],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Vertical Swipeable Feed
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: _gameFeed.length,
          itemBuilder: (context, index) {
            final game = _gameFeed[index];
            return Stack(
              children: [
                // 3D Game / Render Target
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
                        const Icon(Icons.gamepad_rounded, size: 80, color: Colors.purpleAccent),
                        const SizedBox(height: 12),
                        Text(
                          game['title'],
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap screen to play game',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Info
                Positioned(
                  left: 16,
                  bottom: 24,
                  right: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game['creator'],
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        game['title'],
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Icon(Icons.bolt, color: Colors.cyanAccent, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Google Filament Engine Active',
                            style: TextStyle(color: Colors.cyanAccent, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Right Action Bar
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

        // 2. Top Header (LIVE + Following / For You)
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent, width: 1.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Row(
                  children: const [
                    Text('Following', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(width: 16),
                    Text('For You', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
