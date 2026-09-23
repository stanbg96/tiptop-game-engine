import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/features/feed/presentation/widgets/feed_action_bar.dart';
import 'package:tiptop_game_engine/features/live/presentation/live_stream_screen.dart';
import 'package:tiptop_game_engine/features/brain_ai/presentation/pages/brain_ai_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PageController _pageController = PageController();
  bool _showHeartAnim = false;

  final List<Map<String, dynamic>> _gameFeed = [
    {
      'title': 'Cyberpunk Neon Runner 3D',
      'creator': '@neon_builder',
      'dimension': '3D',
      'likes': 1421,
      'isLiked': false,
      'commentsCount': 89,
      'shares': 45,
      'isSaved': false,
      'isFollowed': false,
      'bgGradient': [const Color(0xFF2A0845), const Color(0xFF0F041D)],
      'engineBadge': 'Google Filament C++ 60 FPS',
      'comments': [
        {'user': '@alex_gamer', 'text': 'Тази игра е супер яка! Физиката в Filament кърти 🔥', 'likes': 24},
        {'user': '@maya_3d', 'text': 'Как направи лазерните ефекти на пистата?', 'likes': 12},
      ],
    },
    {
      'title': 'Medieval Castle Defense 2D',
      'creator': '@pixel_wizard',
      'dimension': '2D',
      'likes': 850,
      'isLiked': false,
      'commentsCount': 34,
      'shares': 12,
      'isSaved': false,
      'isFollowed': false,
      'bgGradient': [const Color(0xFF0B2B26), const Color(0xFF051310)],
      'engineBadge': 'Godot 4 CharacterBody2D 60 FPS',
      'comments': [
        {'user': '@knight_pro', 'text': '2D пиксел артът е топ! 🏰', 'likes': 18},
      ],
    },
    {
      'title': 'Lava Volcano Arena 3D',
      'creator': '@cyber_creator',
      'dimension': '3D',
      'likes': 3240,
      'isLiked': false,
      'commentsCount': 128,
      'shares': 76,
      'isSaved': false,
      'isFollowed': false,
      'bgGradient': [const Color(0xFF380B12), const Color(0xFF140306)],
      'engineBadge': 'Jolt Physics 3D Active',
      'comments': [
        {'user': '@speed_demon', 'text': 'Лава паркурът е много труден, но забавен!', 'likes': 42},
      ],
    },
  ];

  void _handleDoubleTapLike(int index) {
    setState(() {
      if (!_gameFeed[index]['isLiked']) {
        _gameFeed[index]['isLiked'] = true;
        _gameFeed[index]['likes'] += 1;
      }
      _showHeartAnim = true;
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showHeartAnim = false);
    });
  }

  void _launchGamePlay(Map<String, dynamic> game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121422),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.sciFiCyan)),
        title: Row(
          children: [
            Icon(game['dimension'] == '3D' ? Icons.view_in_ar : Icons.grid_view, color: AppTheme.sciFiCyan),
            const SizedBox(width: 8),
            Expanded(child: Text(game['title'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(
          'Стартиране на ${game['title']} в ${game['engineBadge']} на 60 FPS...',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Затвори', style: TextStyle(color: Colors.grey))),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.laserPink),
            icon: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
            label: const Text('ИГРАЙ СЕГА', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('🎮 Стартирана игра: ${game['title']}')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _remixInStudio(Map<String, dynamic> game) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('🍄 Зареждане на "${game['title']}" в Студиото за редактиране...')),
    );
  }

  void _showCommentsModal(int index) {
    final commentController = TextEditingController();
    final game = _gameFeed[index];
    final List<Map<String, dynamic>> comments = game['comments'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: AppTheme.sciFiCyan, width: 1),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              top: 12,
              left: 14,
              right: 14,
            ),
            child: SizedBox(
              height: 480,
              child: Column(
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${game['commentsCount']} коментара', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      IconButton(icon: const Icon(Icons.close, color: Colors.grey, size: 20), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const Divider(color: Colors.white12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, cIndex) {
                        final c = comments[cIndex];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppTheme.laserPink.withValues(alpha: 0.2),
                                child: Text(c['user'].toString().substring(1, 2).toUpperCase(), style: const TextStyle(color: AppTheme.laserPink, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c['user'], style: const TextStyle(color: AppTheme.sciFiCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text(c['text'], style: const TextStyle(color: Colors.white, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(color: const Color(0xFF1A1D2C), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
                            child: TextField(
                              controller: commentController,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: const InputDecoration(hintText: 'Добави коментар...', hintStyle: TextStyle(color: Colors.grey, fontSize: 12), border: InputBorder.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send_rounded, color: AppTheme.laserPink),
                          onPressed: () {
                            if (commentController.text.trim().isEmpty) return;
                            setModalState(() {
                              comments.insert(0, {'user': '@Ти', 'text': commentController.text.trim(), 'likes': 0});
                            });
                            setState(() => game['commentsCount'] += 1);
                            commentController.clear();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
            final bool is3D = game['dimension'] == '3D';

            return GestureDetector(
              onDoubleTap: () => _handleDoubleTapLike(index),
              child: Stack(
                children: [
                  // Фон с градиент
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
                          Icon(is3D ? Icons.view_in_ar : Icons.sports_esports, size: 85, color: is3D ? AppTheme.laserPink : const Color(0xFF00E676)),
                          const SizedBox(height: 12),
                          Text(game['title'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('Докосни 2 пъти за Like ❤️ • ${game['engineBadge']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.laserPink, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                                icon: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                                label: const Text('ИГРАЙ 60 FPS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                onPressed: () => _launchGamePlay(game),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.sciFiCyan), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                                icon: const Icon(Icons.edit, color: AppTheme.sciFiCyan, size: 16),
                                label: const Text('🍄 РЕДАКТИРАЙ', style: TextStyle(color: AppTheme.sciFiCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                                onPressed: () => _remixInStudio(game),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Долна информация за играта
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
                        Row(
                          children: [
                            const Icon(Icons.bolt, color: AppTheme.laserPink, size: 15),
                            const SizedBox(width: 4),
                            Text(game['engineBadge'], style: const TextStyle(color: AppTheme.laserPink, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Странична лента с бутони за харесване и коментари
                  Positioned(
                    right: 12,
                    bottom: 20,
                    child: FeedActionBar(
                      likes: game['likes'],
                      comments: game['commentsCount'],
                      shares: game['shares'],
                      isLiked: game['isLiked'],
                      isSaved: game['isSaved'],
                      isFollowed: game['isFollowed'],
                      creatorName: game['creator'],
                      onLike: () {
                        setState(() {
                          game['isLiked'] = !game['isLiked'];
                          game['likes'] += game['isLiked'] ? 1 : -1;
                        });
                      },
                      onComment: () => _showCommentsModal(index),
                      onShare: () {
                        setState(() => game['shares'] += 1);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📋 Линкът за играта е споделен!')));
                      },
                      onSave: () {
                        setState(() => game['isSaved'] = !game['isSaved']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(game['isSaved'] ? '⭐ Запазена в профила!' : 'Премахната от запазени.')),
                        );
                      },
                      onFollow: () {
                        setState(() => game['isFollowed'] = !game['isFollowed']);
                      },
                      onProfileTap: () {},
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Анимация на сърце
        if (_showHeartAnim)
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.2, end: 1.3),
              duration: const Duration(milliseconds: 500),
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: const Icon(Icons.favorite, color: AppTheme.laserPink, size: 120),
              ),
            ),
          ),

        // Горна лента: LIVE | СЛЕДВАНИ & ЗА ТЕБ | 🧠 AI
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LiveStreamScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF1744), Color(0xFFFF007F)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, color: Colors.white, size: 8),
                        SizedBox(width: 5),
                        Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                const Row(
                  children: [
                    Text('Следвани', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
                    SizedBox(width: 12),
                    Text('За Теб', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const BrainAiScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141724),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.laserPink.withValues(alpha: 0.6), width: 1.2),
                    ),
                    child: const Row(
                      children: [
                        Text('🧠', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 3),
                        Text('AI', style: TextStyle(color: AppTheme.sciFiCyan, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
