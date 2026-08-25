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

class _FeedScreenState extends State<FeedScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  bool _showHeartAnim = false;

  final List<Map<String, dynamic>> _gameFeed = [
    {
      'title': 'Cyberpunk Neon Runner 3D',
      'creator': '@neon_builder',
      'likes': 1420,
      'isLiked': false,
      'commentsCount': 89,
      'shares': 45,
      'isSaved': false,
      'isFollowed': false,
      'bgGradient': [Color(0xFF2A0845), Color(0xFF0F041D)],
      'comments': [
        {'user': '@alex_gamer', 'text': 'Тази игра е супер яка! Физиката в Filament кърти 🔥', 'likes': 24},
        {'user': '@maya_3d', 'text': 'Как направи лазерните ефекти на пистата?', 'likes': 12},
        {'user': '@speed_demon', 'text': 'Направих нов рекорд: 2:14 мин! 🏆', 'likes': 5},
      ],
    },
    {
      'title': 'Medieval Castle Defense 2D',
      'creator': '@pixel_wizard',
      'likes': 850,
      'isLiked': false,
      'commentsCount': 34,
      'shares': 12,
      'isSaved': false,
      'isFollowed': false,
      'bgGradient': [Color(0xFF0B2B26), Color(0xFF051310)],
      'comments': [
        {'user': '@knight_pro', 'text': '2D пиксел артът е топ! 🏰', 'likes': 18},
        {'user': '@samurai_dev', 'text': 'Добави още нива с дракони!', 'likes': 8},
      ],
    },
  ];

  // Double Tap to Like
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

  // Comments Bottom Sheet
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
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
                    Text(
                      '${game['commentsCount']} коментара',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
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
                            Column(
                              children: [
                                const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                                Text('${c['likes']}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                              comments.insert(0, {
                                'user': '@Ти',
                                'text': commentController.text.trim(),
                                'likes': 0,
                              });
                            });
                            setState(() {
                              game['commentsCount'] += 1;
                            });
                            commentController.clear();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Share Sheet
  void _showShareModal(int index) {
    final game = _gameFeed[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: AppTheme.laserPink, width: 1),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text('Сподели с приятели', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareIcon(Icons.link, 'Копирай', AppTheme.sciFiCyan, () {
                  Navigator.pop(context);
                  setState(() => game['shares'] += 1);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📋 Връзката към играта е копирана!')));
                }),
                _buildShareIcon(Icons.chat, 'В Чат', AppTheme.laserPink, () {
                  Navigator.pop(context);
                  setState(() => game['shares'] += 1);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✉️ Играта е изпратена в TipTop чата!')));
                }),
                _buildShareIcon(Icons.qr_code_2, 'QR Код', const Color(0xFF00E676), () {
                  Navigator.pop(context);
                  setState(() => game['shares'] += 1);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📷 QR кодът за мултиплейър е генериран!')));
                }),
                _buildShareIcon(Icons.download_for_offline, 'Свали APK', const Color(0xFFFFD600), () {
                  Navigator.pop(context);
                  setState(() => game['shares'] += 1);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📦 Стартирано сваляне на APK пакета...')));
                }),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildShareIcon(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle, border: Border.all(color: color)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  // Creator Profile Modal
  void _showCreatorProfileModal(String creator) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.laserPink, width: 2), color: const Color(0xFF1E1035)),
              child: const Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(creator, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            const Text('3D Game Creator & Level Designer', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Column(children: [Text('12', style: TextStyle(color: AppTheme.sciFiCyan, fontWeight: FontWeight.bold, fontSize: 16)), Text('Игри', style: TextStyle(color: Colors.grey, fontSize: 11))]),
                Column(children: [Text('14.8K', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 16)), Text('Последователи', style: TextStyle(color: Colors.grey, fontSize: 11))]),
                Column(children: [Text('95.2K', style: TextStyle(color: AppTheme.laserPink, fontWeight: FontWeight.bold, fontSize: 16)), Text('Харесвания', style: TextStyle(color: Colors.grey, fontSize: 11))]),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: Container(
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.laserPink, AppTheme.neonPurple]), borderRadius: BorderRadius.circular(10)),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🎉 Вие последвахте $creator!')));
                  },
                  child: const Text('ПОСЛЕДВАЙ СЪЗДАТЕЛЯ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ),
          ],
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
            return GestureDetector(
              onDoubleTap: () => _handleDoubleTapLike(index),
              child: Stack(
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
                          const Icon(Icons.gamepad_rounded, size: 85, color: AppTheme.laserPink),
                          const SizedBox(height: 12),
                          Text(game['title'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          const Text('Докосни 2 пъти за Like ❤️ • Цъкни за игра', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                            Text('Google Filament C++ 60 FPS Active', style: TextStyle(color: AppTheme.laserPink, fontSize: 11)),
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
                      onShare: () => _showShareModal(index),
                      onSave: () {
                        setState(() {
                          game['isSaved'] = !game['isSaved'];
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(game['isSaved'] ? '⭐ Играта е запазена в профила!' : 'Премахната от запазени.')),
                        );
                      },
                      onFollow: () {
                        setState(() {
                          game['isFollowed'] = !game['isFollowed'];
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(game['isFollowed'] ? '🎉 Последвахте ${game['creator']}!' : 'Вече не следвате ${game['creator']}.')),
                        );
                      },
                      onProfileTap: () => _showCreatorProfileModal(game['creator']),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Double Tap Burst Heart
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

        // TOP HEADER: 🔴 LIVE (ВЛЯВО) | СЛЕДВАНИ & ЗА ТЕБ (В СРЕДАТА) | 🧠 AI (ВДЯСНО)
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. 🔴 LIVE БУТОН (ВЛЯВО)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LiveStreamScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  ),
                ),

                // 2. СЛЕДВАНИ | ЗА ТЕБ (В СРЕДАТА)
                const Row(
                  children: [
                    Text('Следвани', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
                    SizedBox(width: 12),
                    Text('За Теб', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),

                // 3. 🧠 AI МОЗЪК БУТОН (ВДЯСНО)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BrainAiScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141724),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.laserPink.withValues(alpha: 0.6), width: 1.2),
                      boxShadow: [
                        BoxShadow(color: AppTheme.laserPink.withValues(alpha: 0.35), blurRadius: 8),
                      ],
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
