import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';

class FeedActionBar extends StatelessWidget {
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final bool isSaved;
  final bool isFollowed;
  final String creatorName;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onFollow;
  final VoidCallback onProfileTap;

  const FeedActionBar({
    Key? key,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isLiked,
    required this.isSaved,
    required this.isFollowed,
    required this.creatorName,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
    required this.onFollow,
    required this.onProfileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Аватар на създателя + Плюсче за последване (Follow)
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.sciFiCyan, width: 2),
                  gradient: const RadialGradient(
                    colors: [AppTheme.laserPink, Color(0xFF1E1035)],
                  ),
                  boxShadow: [
                    BoxShadow(color: AppTheme.laserPink.withValues(alpha: 0.4), blurRadius: 10),
                  ],
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
            ),
            Positioned(
              bottom: -7,
              child: GestureDetector(
                onTap: onFollow,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFollowed ? const Color(0xFF00E676) : AppTheme.laserPink,
                    boxShadow: [
                      BoxShadow(
                        color: (isFollowed ? const Color(0xFF00E676) : AppTheme.laserPink).withValues(alpha: 0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    isFollowed ? Icons.check : Icons.add,
                    color: isFollowed ? Colors.black : Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 2. Сърце (Like) с анимация
        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? AppTheme.laserPink : Colors.white,
            size: 38,
          ),
          onPressed: onLike,
        ),
        Text(
          '$likes',
          style: TextStyle(
            color: isLiked ? AppTheme.laserPink : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),

        // 3. Коментари
        IconButton(
          icon: const Icon(Icons.comment_rounded, color: AppTheme.sciFiCyan, size: 34),
          onPressed: onComment,
        ),
        Text(
          '$comments',
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),

        // 4. Запази (Bookmark)
        IconButton(
          icon: Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: isSaved ? const Color(0xFFFFD600) : Colors.white,
            size: 34,
          ),
          onPressed: onSave,
        ),
        Text(
          isSaved ? 'Запазена' : 'Запази',
          style: TextStyle(
            color: isSaved ? const Color(0xFFFFD600) : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),

        // 5. Сподели (Share)
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white, size: 32),
          onPressed: onShare,
        ),
        Text(
          '$shares',
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
