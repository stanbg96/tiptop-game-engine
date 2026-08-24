import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';

class FeedActionBar extends StatelessWidget {
  final int likes;
  final int comments;
  final int shares;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const FeedActionBar({
    Key? key,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Creator Avatar with Laser Pink (+) badge
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.sciFiCyan, width: 2),
                gradient: const RadialGradient(
                  colors: [AppTheme.laserPink, Color(0xFF1E1035)],
                ),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 28),
            ),
            Positioned(
              bottom: -6,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.laserPink,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Like Button (Laser Pink)
        IconButton(
          icon: const Icon(Icons.favorite, color: AppTheme.laserPink, size: 36),
          onPressed: onLike,
        ),
        Text(
          '$likes',
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),

        // Comment Button (Sci-Fi Cyan)
        IconButton(
          icon: const Icon(Icons.comment_rounded, color: AppTheme.sciFiCyan, size: 32),
          onPressed: onComment,
        ),
        Text(
          '$comments',
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),

        // Save Button (Laser Amber / Gold)
        IconButton(
          icon: const Icon(Icons.bookmark, color: Color(0xFFFFD600), size: 32),
          onPressed: () {},
        ),
        const Text(
          'Запази',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),

        // Share Button (Laser Glow White)
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white, size: 30),
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
