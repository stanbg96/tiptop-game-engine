import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({Key? key}) : super(key: key);

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int _coins = 850;
  int _likesCount = 24890;

  final List<Map<String, String>> _liveComments = [
    {'user': '@alex_pro', 'text': 'Тази 3D лава сцена в Filament е брутална! 🔥'},
    {'user': '@maya_gamer', 'text': 'Пратих ти Кибер Дракон! 🐉'},
    {'user': '@speed_runner', 'text': 'Кой води в класирането днес? 🏆'},
    {'user': '@pixel_queen', 'text': 'Геймплеят върви на 60 FPS! 😍'},
  ];

  final List<Map<String, dynamic>> _topRankedCreators = [
    {'rank': 1, 'name': 'NeoBuilder_3D', 'points': '142.5K', 'badge': '👑 Златен Шампион', 'color': Color(0xFFFFD600)},
    {'rank': 2, 'name': 'CyberQueen', 'points': '98.2K', 'badge': '🥈 Сребърен Майстор', 'color': Color(0xFFE0E0E0)},
    {'rank': 3, 'name': 'LavaDev_Pro', 'points': '74.1K', 'badge': '🥉 Бронзов Титан', 'color': Color(0xFFFF6D00)},
    {'rank': 4, 'name': 'PixelWizard', 'points': '45.8K', 'badge': '⚡ Топ 10', 'color': AppTheme.sciFiCyan},
    {'rank': 5, 'name': 'Samurai_Games', 'points': '38.4K', 'badge': '⚡ Топ 10', 'color': AppTheme.laserPink},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showGiftsSheet() {
    final List<Map<String, dynamic>> gifts = [
      {'name': 'Роза', 'cost': 1, 'icon': Icons.local_florist, 'color': Color(0xFFFF1744)},
      {'name': 'Геймпад', 'cost': 10, 'icon': Icons.sports_esports, 'color': AppTheme.sciFiCyan},
      {'name': 'Плазмен Меч', 'cost': 50, 'icon': Icons.flash_on, 'color': Color(0xFFFFD600)},
      {'name': 'Кибер Дракон', 'cost': 200, 'icon': Icons.auto_awesome, 'color': AppTheme.laserPink},
      {'name': 'Корона 3D', 'cost': 500, 'icon': Icons.emoji_events, 'color': Color(0xFFFFAB00)},
      {'name': 'НЛО Кораб', 'cost': 1000, 'icon': Icons.rocket_launch, 'color': Color(0xFF00E676)},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🎁 Изпрати 3D Подарък', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _tabController.animateTo(1);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Color(0xFFFFD600), size: 16),
                      const SizedBox(width: 4),
                      Text('$_coins Монети +', style: const TextStyle(color: Color(0xFFFFD600), fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: gifts.length,
                itemBuilder: (context, index) {
                  final gift = gifts[index];
                  return InkWell(
                    onTap: () {
                      if (_coins >= (gift['cost'] as int)) {
                        setState(() {
                          _coins -= gift['cost'] as int;
                          _liveComments.add({
                            'user': '@Ти',
                            'text': 'Изпрати ${gift['name']}! 🎉',
                          });
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('⚡ 3D Анимация: ${gift['name']} на екрана!')),
                        );
                      } else {
                        Navigator.pop(context);
                        _tabController.animateTo(1);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF161928),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: (gift['color'] as Color).withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(gift['icon'], color: gift['color'], size: 30),
                          const SizedBox(height: 4),
                          Text(gift['name'], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          Text('🪙 ${gift['cost']}', style: const TextStyle(color: Color(0xFFFFD600), fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.sciFiCyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('🔴 TipTop LIVE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.laserPink,
          indicatorWeight: 3,
          labelColor: AppTheme.laserPink,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.live_tv, size: 18), text: 'На Живо'),
            Tab(icon: Icon(Icons.monetization_on, size: 18), text: 'Монети'),
            Tab(icon: Icon(Icons.emoji_events, size: 18), text: 'Ранкове'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLiveStreamTab(),
          _buildCoinStoreTab(),
          _buildRankingsTab(),
        ],
      ),
    );
  }

  // 1. ТАБ: НА ЖИВО (FULL TIKTOK LIVE)
  Widget _buildLiveStreamTab() {
    return GestureDetector(
      onTap: () => setState(() => _likesCount += 1),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E112A), Colors.black],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gamepad, size: 70, color: AppTheme.sciFiCyan),
                  SizedBox(height: 12),
                  Text('3D Gameplay Stream (Google Filament)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('Докосни екрана за изпращане на сърчица ❤️', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 14, backgroundColor: AppTheme.laserPink, child: Text('🎮', style: TextStyle(fontSize: 14))),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('@host_creator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          Text('$_likesCount Лайка', style: const TextStyle(color: Colors.grey, fontSize: 9)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppTheme.laserPink, borderRadius: BorderRadius.circular(10)),
                        child: const Text('Следвай', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(14)),
                  child: const Row(
                    children: [
                      Icon(Icons.remove_red_eye, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('18.4K', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    reverse: true,
                    itemCount: _liveComments.length,
                    itemBuilder: (context, index) {
                      final comment = _liveComments[_liveComments.length - 1 - index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: '${comment['user']}: ', style: const TextStyle(color: AppTheme.sciFiCyan, fontWeight: FontWeight.bold, fontSize: 11)),
                              TextSpan(text: comment['text'], style: const TextStyle(color: Colors.white, fontSize: 11)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                          children: [
                            Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 16),
                            SizedBox(width: 6),
                            Text('Напиши коментар...', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(icon: const Icon(Icons.share, color: Colors.white, size: 24), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.card_giftcard, color: AppTheme.laserPink, size: 26), onPressed: _showGiftsSheet),
                    IconButton(icon: const Icon(Icons.favorite, color: Color(0xFFFF1744), size: 26), onPressed: () => setState(() => _likesCount += 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. ТАБ: МАГАЗИН ЗА МОНЕТИ & ПОРТФЕЙЛ
  Widget _buildCoinStoreTab() {
    final List<Map<String, dynamic>> coinPacks = [
      {'coins': 100, 'bonus': 0, 'price': '\$0.99', 'color': AppTheme.sciFiCyan},
      {'coins': 500, 'bonus': 50, 'price': '\$4.99', 'color': Color(0xFF00E676)},
      {'coins': 1200, 'bonus': 150, 'price': '\$9.99', 'color': AppTheme.laserPink},
      {'coins': 3500, 'bonus': 500, 'price': '\$24.99', 'color': Color(0xFFFFD600)},
      {'coins': 10000, 'bonus': 2000, 'price': '\$69.99', 'color': Color(0xFFFF1744)},
    ];

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF00B0FF)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Твоят Баланс', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Color(0xFFFFD600), size: 24),
                      const SizedBox(width: 6),
                      Text('$_coins Монети', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () {},
                child: const Text('История', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('ПАКЕТИ ЗА ЗАРЕЖДАНЕ', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...coinPacks.map((pack) {
          final Color packColor = pack['color'];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF121422),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: packColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.monetization_on, color: packColor, size: 28),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${pack['coins']} Монети', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        if (pack['bonus'] > 0)
                          Text('+${pack['bonus']} Бонус безплатно!', style: TextStyle(color: packColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: packColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setState(() => _coins += (pack['coins'] as int) + (pack['bonus'] as int));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('🎉 Заредени ${pack['coins']} монети успешно!')),
                    );
                  },
                  child: Text(pack['price'], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // 3. ТАБ: РАНКОВЕ & КЛАСАЦИЯ
  Widget _buildRankingsTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF121422),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD600).withValues(alpha: 0.5)),
          ),
          child: const Row(
            children: [
              Text('👑', style: TextStyle(fontSize: 32)),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Седмична Класация на Създателите', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Топ 10 разработчици печелят реални награди и монети', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('ТОП СЪЗДАТЕЛИ ТАЗИ СЕДМИЦА', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._topRankedCreators.map((creator) {
          final Color badgeColor = creator['color'];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10121D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: Center(child: Text('#${creator['rank']}', style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 12))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(creator['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(creator['badge'], style: TextStyle(color: badgeColor, fontSize: 11)),
                    ],
                  ),
                ),
                Text('💎 ${creator['points']}', style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
