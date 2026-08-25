import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/features/live/presentation/live_stream_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final List<Map<String, dynamic>> _activeFriends = [
    {'name': 'Твоето Стори', 'avatar': '👑', 'isLive': false, 'isMe': true, 'color': AppTheme.laserPink},
    {'name': 'Alex_3D', 'avatar': '🎮', 'isLive': true, 'isMe': false, 'game': 'Lava Runner 3D', 'color': Color(0xFF00E676)},
    {'name': 'Maya_Dev', 'avatar': '🎨', 'isLive': true, 'isMe': false, 'game': 'Cyber Samurai Arena', 'color': AppTheme.sciFiCyan},
    {'name': 'Kiro_Gamer', 'avatar': '🤖', 'isLive': false, 'isMe': false, 'game': 'Pixel Quest', 'color': Color(0xFFFF1744)},
    {'name': 'Elena_Art', 'avatar': '💃', 'isLive': false, 'isMe': false, 'game': 'Dance Studio', 'color': AppTheme.neonPurple},
  ];

  final List<Map<String, dynamic>> _friendsFeed = [
    {
      'user': '@Alex_3D',
      'action': 'публикува нова 3D игра',
      'title': '🌋 Вулканичен Лабиринт v2.0',
      'likes': '3.4K',
      'time': 'преди 15 мин',
      'color': Color(0xFFFF3D00),
      'tag': 'Google Filament 60FPS',
    },
    {
      'user': '@Maya_Dev',
      'action': 'създаде нов 3D герой чрез AI',
      'title': '🤖 Кибер Самурай с Mixamo Rig',
      'likes': '8.1K',
      'time': 'преди 1 ч',
      'color': AppTheme.sciFiCyan,
      'tag': 'AI Generator & PBR',
    },
  ];

  // 1. Качване на Стори (Твоето Стори)
  void _showCreateStoryModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📸 Добави към Твоето Стори', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(backgroundColor: AppTheme.laserPink, child: Icon(Icons.videocam, color: Colors.white)),
                title: const Text('Запиши 3D Геймплей Клип', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Сподели 15-секундно стори от твоята игра', style: TextStyle(color: Colors.grey, fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎬 Записът на 3D стори е стартиран!')));
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: AppTheme.sciFiCyan, child: Icon(Icons.photo_camera, color: Colors.black)),
                title: const Text('Направи Скрийншот на Сцената', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Снимай нива и герои от Filament Studio', style: TextStyle(color: Colors.grey, fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📸 Скрийншотът е добавен към твоето стори!')));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Профил на приятел от Сторитата
  void _showFriendProfileModal(Map<String, dynamic> friend) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 36, backgroundColor: friend['color'], child: Text(friend['avatar'], style: const TextStyle(fontSize: 36))),
              const SizedBox(height: 10),
              Text(friend['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              Text('Любима игра: ${friend['game'] ?? "Няма"}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.laserPink, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white),
                      label: const Text('ЧАТ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('💬 Отваряне на чат с ${friend['name']}...')));
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.sciFiCyan, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      icon: const Icon(Icons.sports_esports, size: 18, color: Colors.black),
                      label: const Text('ПОКАНИ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚡ Изпратена мултиплейър покана до ${friend['name']}!')));
                      },
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

  // 3. Намери Приятели & Геймъри
  void _showAddFriendsModal() {
    final List<Map<String, dynamic>> suggestions = [
      {'name': 'Viktor_Dev', 'avatar': '⚡', 'games': '8 игри', 'isAdded': false},
      {'name': 'CyberNinja_99', 'avatar': '🥷', 'games': '15 игри', 'isAdded': false},
      {'name': 'Sara_Art', 'avatar': '🌸', 'games': '3 игри', 'isAdded': false},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) => SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 16,
              left: 16,
              right: 16,
            ),
            child: SizedBox(
              height: 480,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: Text('🔍 Намери Приятели & Създатели', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                  const SizedBox(height: 14),
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: const Color(0xFF181B28), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
                    child: const TextField(
                      style: TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(hintText: 'Търси по @потребителско име...', hintStyle: TextStyle(color: Colors.grey, fontSize: 12), icon: Icon(Icons.search, size: 18, color: AppTheme.sciFiCyan), border: InputBorder.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('ПРЕПОРЪЧАНИ СЪЗДАТЕЛИ', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        final s = suggestions[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFF161928), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              CircleAvatar(backgroundColor: AppTheme.laserPink.withValues(alpha: 0.2), child: Text(s['avatar'], style: const TextStyle(fontSize: 18))),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(s['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text(s['games'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                ]),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: s['isAdded'] ? const Color(0xFF1E2235) : const Color(0xFF00E676),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  setModalState(() => s['isAdded'] = !s['isAdded']);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s['isAdded'] ? '🎉 Добавихте ${s['name']} като приятел!' : 'Премахнат.')));
                                },
                                child: Text(s['isAdded'] ? 'ДОБАВЕН ✓' : '+ ДОБАВИ', style: TextStyle(color: s['isAdded'] ? const Color(0xFF00E676) : Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                            ],
                          ),
                        );
                      },
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

  // 4. Скенер за QR Код (ПОВДИГНАТ)
  void _showQrScannerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📷 Скенер за TipTop QR Код', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 14),
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.laserPink, width: 2),
                  boxShadow: [BoxShadow(color: AppTheme.laserPink.withValues(alpha: 0.3), blurRadius: 15)],
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner, size: 75, color: AppTheme.sciFiCyan),
                      SizedBox(height: 6),
                      Text('Насочи камерата към QR код', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF161928), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white12))),
                  icon: const Icon(Icons.photo_library, color: AppTheme.sciFiCyan, size: 18),
                  label: const Text('СКАНИРАЙ ОТ ГАЛЕРИЯТА', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📷 Избиране на QR код от галерията...')));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. Покани Контакти
  void _showContactsInviteModal() {
    final List<Map<String, dynamic>> contacts = [
      {'name': 'Георги Иванов', 'phone': '+359 888 111 222', 'isInvited': false},
      {'name': 'Иван Петров', 'phone': '+359 889 333 444', 'isInvited': false},
      {'name': 'Мария Димитрова', 'phone': '+359 877 555 666', 'isInvited': false},
      {'name': 'Николай Стоянов', 'phone': '+359 898 777 888', 'isInvited': false},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) => SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 16,
              left: 16,
              right: 16,
            ),
            child: SizedBox(
              height: 440,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: Text('📱 Покани Приятели от Контакти', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final c = contacts[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFF161928), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              CircleAvatar(backgroundColor: const Color(0xFF00E676).withValues(alpha: 0.2), child: Text(c['name'].toString().substring(0, 1), style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold))),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(c['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text(c['phone'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                ]),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: c['isInvited'] ? const Color(0xFF1E2235) : const Color(0xFF00E676),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  setModalState(() => c['isInvited'] = true);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('📩 Изпратена покана до ${c['name']}!')));
                                },
                                child: Text(c['isInvited'] ? 'ИЗПРАТЕНА ✓' : 'ПОКАНИ', style: TextStyle(color: c['isInvited'] ? const Color(0xFF00E676) : Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                            ],
                          ),
                        );
                      },
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

  // 6. Сподели Профил (ПОВДИГНАТ)
  void _showShareProfileModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👑 Твоят TipTop Профилен QR Код', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.qr_code, size: 120, color: Colors.black),
              ),
              const SizedBox(height: 10),
              const Text('@cyber_creator', style: TextStyle(color: AppTheme.laserPink, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.sciFiCyan, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      icon: const Icon(Icons.link, color: Colors.black, size: 16),
                      label: const Text('КОПИРАЙ ЛИНК', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📋 Профилният линк е копиран!')));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.laserPink, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      icon: const Icon(Icons.share, color: Colors.white, size: 16),
                      label: const Text('СПОДЕЛИ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✉️ Изпратено през WhatsApp/Telegram!')));
                      },
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

  // 7. 3D Game Launcher (ПОВДИГНАТ)
  void _showLaunchGameModal(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22)), side: BorderSide(color: Color(0xFF00E676))),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.gamepad, color: Color(0xFF00E676), size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Създадена от ${item['user']} • ${item['tag']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF181B28), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.white24))),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🎮 Стартиране на ${item['title']} в Соло режим...')));
                      },
                      child: const Text('🎮 ИГРАЙ СОЛО', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00E5FF)]), borderRadius: BorderRadius.circular(10)),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 12)),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚡ Отворена мултиплейър стая за ${item['title']}! QR кодът е активен.')));
                        },
                        child: const Text('⚡ МУЛТИПЛЕЙЪР QR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
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
        title: const Text('👥 Приятели & Активност', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: Color(0xFF00E676)),
            tooltip: 'Намери приятели',
            onPressed: _showAddFriendsModal,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: AppTheme.laserPink),
            tooltip: 'Сканирай QR за игра',
            onPressed: _showQrScannerModal,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Сторита на приятели
          Container(
            height: 105,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0E101A),
              border: Border(bottom: BorderSide(color: AppTheme.laserPink.withValues(alpha: 0.2), width: 1)),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _activeFriends.length,
              itemBuilder: (context, index) {
                final friend = _activeFriends[index];
                final Color ringColor = friend['color'];
                final bool isLive = friend['isLive'];
                final bool isMe = friend['isMe'];

                return GestureDetector(
                  onTap: () {
                    if (isMe) {
                      _showCreateStoryModal();
                    } else if (isLive) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LiveStreamScreen()));
                    } else {
                      _showFriendProfileModal(friend);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: ringColor, width: 2.2),
                                boxShadow: [BoxShadow(color: ringColor.withValues(alpha: 0.35), blurRadius: 8)],
                                color: const Color(0xFF161824),
                              ),
                              child: Center(child: Text(friend['avatar'], style: const TextStyle(fontSize: 22))),
                            ),
                            if (isLive)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(color: const Color(0xFF00E676), borderRadius: BorderRadius.circular(6)),
                                  child: const Text('LIVE', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(friend['name'], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Бутони Покани Контакти & Сподели Профил
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00B0FF)]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 8)),
                      icon: const Icon(Icons.contacts, size: 16, color: Colors.black),
                      label: const Text('ПОКАНИ КОНТАКТИ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                      onPressed: _showContactsInviteModal,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.laserPink, Color(0xFFFF1744)]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 8)),
                      icon: const Icon(Icons.share, size: 16, color: Colors.white),
                      label: const Text('СПОДЕЛИ ПРОФИЛ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      onPressed: _showShareProfileModal,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Фийд с игри на приятели
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _friendsFeed.length,
              itemBuilder: (context, index) {
                final item = _friendsFeed[index];
                final Color glow = item['color'];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10121D),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: glow.withValues(alpha: 0.4)),
                    boxShadow: [BoxShadow(color: glow.withValues(alpha: 0.15), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(item['user'], style: const TextStyle(color: AppTheme.sciFiCyan, fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 4),
                              Text(item['action'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                          Text(item['time'], style: const TextStyle(color: Colors.white38, fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFF161928), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item['tag'], style: TextStyle(color: glow, fontSize: 10, fontWeight: FontWeight.bold)),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: glow, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                  onPressed: () => _showLaunchGameModal(item),
                                  child: const Text('ИГРАЙ СЕГА ▶', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
