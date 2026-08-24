import 'package:flutter/material.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({Key? key}) : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final List<Map<String, String>> _chats = [
    {
      'name': 'Alex_Gamer',
      'msg': 'Send me the QR code for your 3D room!',
      'time': '2m ago',
      'avatar': '🎮',
    },
    {
      'name': 'Sarah_3D_Art',
      'msg': 'I liked your Cyberpunk track!',
      'time': '1h ago',
      'avatar': '🎨',
    },
    {
      'name': 'Cloud Build Bot',
      'msg': 'Your APK compilation is ready for download.',
      'time': '3h ago',
      'avatar': '🤖',
    },
  ];

  // Dialog for Multiplayer QR Invite
  void _showMultiplayerQrDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161622),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.qr_code_2, color: Colors.cyanAccent),
            SizedBox(width: 8),
            Text('Multiplayer Invite', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.qr_code_scanner, size: 140, color: Colors.black),
            ),
            const SizedBox(height: 12),
            const Text(
              'Scan to join Room #8841-3D',
              style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Share this QR code with your friend in chat to play together.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.purpleAccent)),
          ),
        ],
      ),
    );
  }

  // Dialog for Cloud Export (APK, PC, IPA)
  void _showCloudExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161622),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cloud_upload, color: Colors.purpleAccent),
            SizedBox(width: 8),
            Text('Cloud Build Export', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.qr_code, size: 140, color: Colors.black),
            ),
            const SizedBox(height: 12),
            const Text(
              'Build QR Ready (.APK / .EXE / .IPA)',
              style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            const Text(
              'Scan with PC or phone camera to download standalone compilation.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done', style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Inbox & Direct Messages',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined, color: Colors.purpleAccent),
            tooltip: 'Cloud Export Game',
            onPressed: _showCloudExportDialog,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_2, color: Colors.cyanAccent),
            tooltip: 'Generate Multiplayer QR',
            onPressed: _showMultiplayerQrDialog,
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: _chats.length,
        separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1E1E2C),
              child: Text(chat['avatar']!, style: const TextStyle(fontSize: 20)),
            ),
            title: Text(
              chat['name']!,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
              chat['msg']!,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(chat['time']!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 4),
                const Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 16),
              ],
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening chat with ${chat['name']}')),
              );
            },
          );
        },
      ),
    );
  }
}
