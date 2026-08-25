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
      'id': '1',
      'name': 'Alex_Gamer',
      'msg': '⚡ Изпрати ти покана за мултиплейър стая #8841-Lava!',
      'time': '2 мин',
      'avatar': '🎮',
      'isRoom': true,
      'color': Color(0xFF00E676),
      'messages': [
        {'sender': 'Alex_Gamer', 'text': 'Здрасти! Направих ново 3D ниво с лава в Filament.', 'isMe': false, 'time': '14:30'},
        {'sender': 'Ти', 'text': 'Супер, пускай мултиплейър стаята!', 'isMe': true, 'time': '14:31'},
        {
          'sender': 'Alex_Gamer',
          'text': '⚡ Ето поканата за стая #8841-Lava! Влизай.',
          'isMe': false,
          'time': '14:32',
          'isRoomCard': true,
          'roomCode': '#8841-Lava',
          'gameTitle': 'Lava Parkour 3D',
        },
      ],
    },
    {
      'id': '2',
      'name': 'Sarah_3D_Art',
      'msg': 'Харесах новия ти 3D модел на Кибер Дракон!',
      'time': '1 ч',
      'avatar': '🎨',
      'isRoom': false,
      'color': AppTheme.laserPink,
      'messages': [
        {'sender': 'Sarah_3D_Art', 'text': 'Хей, видях новия Кибер Дракон в магазина!', 'isMe': false, 'time': '13:15'},
        {'sender': 'Sarah_3D_Art', 'text': 'Анимациите от Mixamo с крилата са страхотни 🔥', 'isMe': false, 'time': '13:16'},
        {'sender': 'Ти', 'text': 'Благодаря! AI агентът помогна с шейдърите.', 'isMe': true, 'time': '13:20'},
      ],
    },
    {
      'id': '3',
      'name': 'TipTop Cloud Bot',
      'msg': '📦 Твоята APK компилация е готова. Свали с QR код.',
      'time': '3 ч',
      'avatar': '🤖',
      'isRoom': false,
      'color': AppTheme.sciFiCyan,
      'messages': [
        {'sender': 'TipTop Cloud Bot', 'text': '🚀 Заявката за облачен билд на "Cyberpunk Runner" беше обработена успешно.', 'isMe': false, 'time': '11:00'},
        {
          'sender': 'TipTop Cloud Bot',
          'text': '📦 Твоят Android APK пакет е готов за инсталиране.',
          'isMe': false,
          'time': '11:02',
          'isApkCard': true,
          'buildSize': '51.4 MB',
          'version': 'v1.0.4 Release',
        },
      ],
    },
  ];

  void _openChatDetail(Map<String, dynamic> chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(chat: chat),
      ),
    ).then((_) => setState(() {}));
  }

  // 1. ОБЛАЧЕН ЕКСПОРТ (ПОВДИГНАТ С ДОПЪЛНИТЕЛЕН SAFEAREA ОТСТЪП)
  void _showCloudExportModal() {
    String selectedPlatform = 'Android (.APK)';
    String selectedGame = 'Cyberpunk Neon Runner 3D';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: AppTheme.sciFiCyan, width: 1.2),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 16,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.cloud_upload, color: AppTheme.sciFiCyan, size: 24),
                    SizedBox(width: 10),
                    Text('Облачен Експорт на Игра', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('ИЗБЕРИ ИГРА ЗА КОМПИЛАЦИЯ', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: const Color(0xFF181B28), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedGame,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF181B28),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      items: ['Cyberpunk Neon Runner 3D', 'Lava Volcano Arena 3D', 'Medieval Castle Defense 2D']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (val) => setModalState(() => selectedGame = val!),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('ИЗБЕРИ ПЛАТФОРМА', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(
                  children: ['Android (.APK)', 'Windows (.EXE)', 'iOS (.IPA)'].map((plat) {
                    final isSel = plat == selectedPlatform;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => selectedPlatform = plat),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? AppTheme.sciFiCyan : const Color(0xFF181B28),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSel ? AppTheme.sciFiCyan : Colors.white12),
                          ),
                          child: Center(
                            child: Text(plat, style: TextStyle(color: isSel ? Colors.black : Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF00E676)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                      icon: const Icon(Icons.bolt, color: Colors.black, size: 18),
                      label: const Text('СТАРТИРАЙ ОБЛАЧЕН БИЛД', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('🚀 Стартирана $selectedPlatform компилация за $selectedGame! TipTop Bot ще изпрати QR код.')),
                        );
                      },
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

  // 2. МУЛТИПЛЕЙЪР QR ГЕНЕРАТОР (ПОВДИГНАТ С ДОПЪЛНИТЕЛЕН SAFEAREA ОТСТЪП)
  void _showMultiplayerQrModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: Color(0xFF00E676), width: 1.2),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚡ Мултиплейър Стая (QR Покани)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: const Color(0xFF00E676).withValues(alpha: 0.4), blurRadius: 15)],
                ),
                child: const Icon(Icons.qr_code_scanner, size: 120, color: Colors.black),
              ),
              const SizedBox(height: 10),
              const Text('Код на стая: #8841-TipTop (2-8 Играчи)', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF181B28), padding: const EdgeInsets.symmetric(vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.white24))),
                      icon: const Icon(Icons.copy, color: Colors.white, size: 16),
                      label: const Text('КОПИРАЙ ЛИНК', style: TextStyle(color: Colors.white, fontSize: 11)),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📋 Линкът за стаята е копиран!')));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00B0FF)]), borderRadius: BorderRadius.circular(10)),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 11)),
                        icon: const Icon(Icons.send, color: Colors.black, size: 16),
                        label: const Text('ИЗПРАТИ В ЧАТ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                        onPressed: () {
                          Navigator.pop(context);
                          _openChatDetail(_chats[0]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
            onPressed: _showCloudExportModal,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_2, color: Color(0xFF00E676)),
            tooltip: 'Мултиплейър QR',
            onPressed: _showMultiplayerQrModal,
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _chats.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final chat = _chats[index];
          final Color cardColor = chat['color'];
          final bool isRoom = chat['isRoom'];
          return GestureDetector(
            onTap: () => _openChatDetail(chat),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10121D),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cardColor.withValues(alpha: 0.45)),
                boxShadow: [
                  BoxShadow(color: cardColor.withValues(alpha: 0.12), blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: cardColor.withValues(alpha: 0.2),
                    child: Text(chat['avatar']!, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(chat['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(chat['time']!, style: TextStyle(color: cardColor, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chat['msg']!,
                          style: TextStyle(
                            color: isRoom ? cardColor : Colors.grey,
                            fontSize: 12,
                            fontWeight: isRoom ? FontWeight.bold : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(isRoom ? Icons.sports_esports : Icons.arrow_forward_ios, color: cardColor, size: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  final Map<String, dynamic> chat;
  const ChatDetailScreen({Key? key, required this.chat}) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgController = TextEditingController();

  void _sendMessage() {
    String text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      (widget.chat['messages'] as List).add({
        'sender': 'Ти',
        'text': text,
        'isMe': true,
        'time': 'Току-що',
      });
      widget.chat['msg'] = text;
      widget.chat['time'] = 'Току-що';
    });

    _msgController.clear();
  }

  void _sendRoomInvite() {
    setState(() {
      (widget.chat['messages'] as List).add({
        'sender': 'Ти',
        'text': '⚡ Ето QR поканата за мултиплейър стаята ми!',
        'isMe': true,
        'time': 'Току-що',
        'isRoomCard': true,
        'roomCode': '#8841-TipTop',
        'gameTitle': 'Cyberpunk Neon Runner 3D',
      });
      widget.chat['msg'] = '⚡ Изпратена мултиплейър покана за стая!';
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚡ Поканата за мултиплейър стаята е изпратена в чата!')));
  }

  @override
  Widget build(BuildContext context) {
    final List messages = widget.chat['messages'] ?? [];
    final Color chatColor = widget.chat['color'] ?? AppTheme.laserPink;

    return Scaffold(
      backgroundColor: const Color(0xFF07080D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E101A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.sciFiCyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(radius: 16, backgroundColor: chatColor.withValues(alpha: 0.3), child: Text(widget.chat['avatar'] ?? '👤', style: const TextStyle(fontSize: 16))),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.chat['name'] ?? 'Чат', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const Row(
                  children: [
                    Icon(Icons.circle, color: Color(0xFF00E676), size: 7),
                    SizedBox(width: 4),
                    Text('Онлайн в TipTop', style: TextStyle(color: Color(0xFF00E676), fontSize: 10)),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sports_esports, color: Color(0xFF00E676)),
            tooltip: 'Покани в мултиплейър',
            onPressed: _sendRoomInvite,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final bool isMe = msg['isMe'] == true;
                final bool isRoomCard = msg['isRoomCard'] == true;
                final bool isApkCard = msg['isApkCard'] == true;

                if (isRoomCard) {
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      width: 260,
                      decoration: BoxDecoration(
                        color: const Color(0xFF101C24),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF00E676)),
                        boxShadow: [BoxShadow(color: const Color(0xFF00E676).withValues(alpha: 0.2), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.qr_code_2, color: Color(0xFF00E676), size: 22),
                              const SizedBox(width: 6),
                              Text(msg['roomCode'] ?? '#Room', style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(msg['gameTitle'] ?? '3D Game', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          const Text('Google Filament 60FPS Multiplayer Room', style: TextStyle(color: Colors.grey, fontSize: 10)),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 32,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🎮 Влизане в стая ${msg['roomCode']}...')));
                              },
                              child: const Text('ВЛЕЗ В ИГРАТА ▶', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (isApkCard) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      width: 260,
                      decoration: BoxDecoration(
                        color: const Color(0xFF121A28),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.sciFiCyan),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.android, color: AppTheme.sciFiCyan, size: 22),
                              SizedBox(width: 6),
                              Text('Android APK Компилация', style: TextStyle(color: AppTheme.sciFiCyan, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Версия: ${msg['version']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Размер: ${msg['buildSize']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 32,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.sciFiCyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              icon: const Icon(Icons.download, size: 16, color: Colors.black),
                              label: const Text('СВАЛИ .APK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📦 Стартирано изтегляне на APK пакета...')));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? AppTheme.laserPink.withValues(alpha: 0.25) : const Color(0xFF141724),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isMe ? AppTheme.laserPink.withValues(alpha: 0.6) : Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(msg['text'], style: const TextStyle(color: Colors.white, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(msg['time'], style: const TextStyle(color: Colors.grey, fontSize: 9)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.qr_code_2, color: Color(0xFF00E676)),
                    tooltip: 'Прати мултиплейър покана',
                    onPressed: _sendRoomInvite,
                  ),
                  Expanded(
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: const Color(0xFF161824), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
                      child: TextField(
                        controller: _msgController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(hintText: 'Напиши съобщение...', hintStyle: TextStyle(color: Colors.grey, fontSize: 12), border: InputBorder.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppTheme.laserPink),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
