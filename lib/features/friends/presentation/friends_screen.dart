import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final List<Map<String, dynamic>> _activeFriends = [
    {'name': 'Твоето Стори', 'avatar': '👑', 'isLive': false, 'color': AppTheme.laserPink},
    {'name': 'Alex_3D', 'avatar': '🎮', 'isLive': true, 'game': 'Lava Runner', 'color': Color(0xFF00E676)},
    {'name': 'Maya_Dev', 'avatar': '🎨', 'isLive': true, 'game': 'Cyber City', 'color': AppTheme.sciFiCyan},
    {'name': 'Kiro_Gamer', 'avatar': '🤖', 'isLive': false, 'game': 'Pixel Quest', 'color': Color(0xFFFF1744)},
    {'name': 'Elena_Art', 'avatar': '💃', 'isLive': false, 'game': 'Dance Studio', 'color': AppTheme.neonPurple},
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔍 Търсене на контакти и геймъри наоколо...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: AppTheme.laserPink),
            tooltip: 'Сканирай QR за игра',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📷 Отваряне на скенер за мултиплейър QR код...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Сторита и Активни приятели (Кой играе на живо 🟢)
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
                return Padding(
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
                              boxShadow: [
                                BoxShadow(color: ringColor.withValues(alpha: 0.35), blurRadius: 8),
                              ],
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
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E676),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('LIVE', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(friend['name'], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              },
            ),
          ),

          // 2. Бутони за Покани и Контакти
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
                      onPressed: () {},
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
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Фийд с активността на приятелите (TikTok Style)
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
                    boxShadow: [
                      BoxShadow(color: glow.withValues(alpha: 0.15), blurRadius: 10),
                    ],
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
                        decoration: BoxDecoration(
                          color: const Color(0xFF161928),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white10),
                        ),
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
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: glow,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('🎮 Зареждане на ${item['title']} в Filament...')),
                                    );
                                  },
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
