import 'package:flutter/material.dart';

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
        // Creator Avatar with Follow (+) badge
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                color: Colors.deepPurple,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 28),
            ),
            Positioned(
              bottom: -6,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Like Button
        IconButton(
          icon: const Icon(Icons.favorite, color: Colors.redAccent, size: 36),
          onPressed: onLike,
        ),
        Text(
          '$likes',
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),

        // Comment Button
        IconButton(
          icon: const Icon(Icons.comment_rounded, color: Colors.white, size: 32),
          onPressed: onComment,
        ),
        Text(
          '$comments',
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),

        // Save / Bookmark Button
        IconButton(
          icon: const Icon(Icons.bookmark, color: Colors.amberAccent, size: 32),
          onPressed: () {},
        ),
        const Text(
          'Save',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),

        // Share Button
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
