import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({Key? key}) : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Alex_Gamer',
      'msg': '⚡ Изпрати ти покана за мултиплейър стая #8841-Lava!',
      'time': '2 мин',
      'avatar': '🎮',
      'isRoom': true,
      'color': Color(0xFF00E676),
    },
    {
      'name': 'Sarah_3D_Art',
      'msg': 'Харесах новия ти 3D модел на Кибер Дракон!',
      'time': '1 ч',
      'avatar': '🎨',
      'isRoom': false,
      'color': AppTheme.laserPink,
    },
    {
      'name': 'TipTop Cloud Bot',
      'msg': '📦 Твоята APK компилация е готова. Свали с QR код.',
      'time': '3 ч',
      'avatar': '🤖',
      'isRoom': false,
      'color': AppTheme.sciFiCyan,
    },
  ];

  void _showMultiplayerQrDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF10121D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF00E676), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.qr_code_2, color: Color(0xFF00E676)),
            SizedBox(width: 8),
            Text('Мултиплейър Покани', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF00E676).withValues(alpha: 0.5), blurRadius: 15),
                ],
              ),
              child: const Icon(Icons.qr_code_scanner, size: 130, color: Colors.black),
            ),
            const SizedBox(height: 12),
            const Text(
              'Стая: #8841-TipTop (Lava 3D)',
              style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            const Text(
              'Сканирай или изпрати кода на приятел в чата, за да играете заедно в реално време!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Затвори', style: TextStyle(color: AppTheme.laserPink, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCloudExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF10121D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppTheme.sciFiCyan, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.cloud_upload, color: AppTheme.sciFiCyan),
            SizedBox(width: 8),
            Text('Облачен Експорт (QR)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: AppTheme.sciFiCyan.withValues(alpha: 0.5), blurRadius: 15),
                ],
              ),
              child: const Icon(Icons.qr_code, size: 130, color: Colors.black),
            ),
            const SizedBox(height: 12),
            const Text(
              'Свали играта (.APK / .EXE / .IPA)',
              style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            const Text(
              'Сканирай с компютър за .EXE или друг телефон за .APK директна компилация.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Готово', style: TextStyle(color: AppTheme.sciFiCyan, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E101A),
        elevation: 0,
        title: const Text('💬 Входящи & Чат', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined, color: AppTheme.sciFiCyan),
            tooltip: 'Облачен Експорт',
            onPressed: _showCloudExportDialog,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_2, color: Color(0xFF00E676)),
            tooltip: 'Мултиплейър QR',
            onPressed: _showMultiplayerQrDialog,
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(10),
        itemCount: _chats.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final chat = _chats[index];
          final Color cardColor = chat['color'];
          final bool isRoom = chat['isRoom'];
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF10121D),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cardColor.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(color: cardColor.withValues(alpha: 0.12), blurRadius: 8),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: cardColor.withValues(alpha: 0.2),
                child: Text(chat['avatar']!, style: const TextStyle(fontSize: 20)),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(chat['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(chat['time']!, style: TextStyle(color: cardColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  chat['msg']!,
                  style: TextStyle(color: isRoom ? cardColor : Colors.grey, fontSize: 12, fontWeight: isRoom ? FontWeight.bold : FontWeight.normal),
                ),
              ),
              trailing: Icon(isRoom ? Icons.sports_esports : Icons.arrow_forward_ios, color: cardColor, size: 16),
              onTap: () {
                if (isRoom) {
                  _showMultiplayerQrDialog();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Отваряне на чат с ${chat['name']}...')),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
