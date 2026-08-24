import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({Key? key}) : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final List<Map<String, String>> _chats = [
    {
      'name': 'Alex_Gamer',
      'msg': 'Прати ми QR кода за 3D мултиплейър стаята ти!',
      'time': '2 мин',
      'avatar': '🎮',
    },
    {
      'name': 'Sarah_3D_Art',
      'msg': 'Харесах новата ти лазерна състезателна писта!',
      'time': '1 ч',
      'avatar': '🎨',
    },
    {
      'name': 'Cloud Build Bot',
      'msg': 'Твоята TipTop APK компилация е готова за изтегляне.',
      'time': '3 ч',
      'avatar': '🤖',
    },
  ];

  void _showMultiplayerQrDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121422),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.laserPink, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.qr_code_2, color: AppTheme.laserPink),
            SizedBox(width: 8),
            Text('Мултиплейър Покани', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                boxShadow: [
                  BoxShadow(color: AppTheme.laserPink.withValues(alpha: 0.5), blurRadius: 15),
                ],
              ),
              child: const Icon(Icons.qr_code_scanner, size: 130, color: Colors.black),
            ),
            const SizedBox(height: 12),
            const Text(
              'Сканирай за стая #8841-SciFi',
              style: TextStyle(color: AppTheme.sciFiCyan, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Изпрати този код в чата на приятел, за да влезете заедно в 3D играта!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Затвори', style: TextStyle(color: AppTheme.laserPink)),
          ),
        ],
      ),
    );
  }

  void _showCloudExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121422),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.sciFiCyan, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.cloud_upload, color: AppTheme.sciFiCyan),
            SizedBox(width: 8),
            Text('Облачен Експорт', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                boxShadow: [
                  BoxShadow(color: AppTheme.sciFiCyan.withValues(alpha: 0.5), blurRadius: 15),
                ],
              ),
              child: const Icon(Icons.qr_code, size: 130, color: Colors.black),
            ),
            const SizedBox(height: 12),
            const Text(
              'QR Код за Сваляне (.APK / .EXE / .IPA)',
              style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            const Text(
              'Сканирай с компютър или друг телефон за директно изтегляне на играта.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Готово', style: TextStyle(color: AppTheme.sciFiCyan)),
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
        backgroundColor: const Color(0xFF0E101A),
        elevation: 0,
        title: const Text(
          'Входящи & Съобщения',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined, color: AppTheme.sciFiCyan),
            tooltip: 'Облачен Експорт',
            onPressed: _showCloudExportDialog,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_2, color: AppTheme.laserPink),
            tooltip: 'Мултиплейър QR',
            onPressed: _showMultiplayerQrDialog,
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: _chats.length,
        separatorBuilder: (context, index) => Divider(color: AppTheme.laserPink.withValues(alpha: 0.15), height: 1),
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1E1E2C),
              child: Text(chat['avatar']!, style: const TextStyle(fontSize: 20)),
            ),
            title: Text(
              chat['name']!,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              chat['msg']!,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(chat['time']!, style: const TextStyle(color: AppTheme.sciFiCyan, fontSize: 11)),
                const SizedBox(height: 4),
                const Icon(Icons.send_rounded, color: AppTheme.laserPink, size: 14),
              ],
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Отваряне на чат с ${chat['name']}...')),
              );
            },
          );
        },
      ),
    );
  }
}
