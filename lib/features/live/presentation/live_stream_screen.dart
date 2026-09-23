import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({Key? key}) : super(key: key);

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _streamPageController = PageController();

  int _coins = 850;
  int _activeLeaderboardTab = 0;

  final List<Map<String, dynamic>> _coinHistory = [
    {'title': 'Зареждане на Монети', 'change': '+500', 'date': 'Днес, 14:20', 'isAdd': true},
    {'title': 'Подарък: Кибер Дракон', 'change': '-200', 'date': 'Вчера, 21:45', 'isAdd': false},
    {'title': 'Зареждане на Монети', 'change': '+1200', 'date': '24 Авг, 19:10', 'isAdd': true},
  ];

  final List<Map<String, dynamic>> _liveStreamers = [
    {
      'name': '@host_creator',
      'avatar': '👑',
      'title': '3D Gameplay Stream (Google Filament)',
      'game': 'Cyberpunk Neon Runner 3D',
      'likes': 24893,
      'viewers': '18.4K',
      'isFollowed': false,
      'bgGradient': [Color(0xFF2A0845), Color(0xFF0F041D)],
      'comments': [
        {'user': '@alex_pro', 'text': 'Тази 3D лава сцена в Filament е брутална! 🔥'},
        {'user': '@maya_gamer', 'text': 'Пратих ти Кибер Дракон! 🐉'},
        {'user': '@speed_runner', 'text': 'Кой води в класирането днес? 🏆'},
      ],
    },
    {
      'name': '@alex_3d_live',
      'avatar': '🎮',
      'title': 'Строене на 3D Лава Ниво с AI Мозъка',
      'game': 'Lava Volcano Arena',
      'likes': 18450,
      'viewers': '12.1K',
      'isFollowed': false,
      'bgGradient': [Color(0xFF380B12), Color(0xFF140306)],
      'comments': [
        {'user': '@neo_fan', 'text': 'Добави още платформи за скачане! 🌋'},
        {'user': '@kris_dev', 'text': 'Анимациите от Mixamo изглеждат супер плавни.'},
      ],
    },
    {
      'name': '@cyber_queen',
      'avatar': '🎨',
      'title': 'Мултиплейър битки на живо с фенове',
      'game': 'Sci-Fi Hover Racers',
      'likes': 32100,
      'viewers': '25.6K',
      'isFollowed': false,
      'bgGradient': [Color(0xFF0B2538), Color(0xFF030E17)],
      'comments': [
        {'user': '@pro_gamer', 'text': 'Сканирах QR кода и вече съм в стаята! 🚀'},
        {'user': '@dani_art', 'text': 'Екип Сини ще победи днес! 💙'},
      ],
    },
  ];

  final List<Map<String, dynamic>> _topRankedCreators = [
    {'rank': 1, 'name': 'NeoBuilder_3D', 'points': '142.5K', 'badge': '👑 Златен Шампион', 'color': Color(0xFFFFD600), 'isFollowed': false},
    {'rank': 2, 'name': 'CyberQueen', 'points': '98.2K', 'badge': '🥈 Сребърен Майстор', 'color': Color(0xFFE0E0E0), 'isFollowed': false},
    {'rank': 3, 'name': 'LavaDev_Pro', 'points': '74.1K', 'badge': '🥉 Бронзов Титан', 'color': Color(0xFFFF6D00), 'isFollowed': false},
    {'rank': 4, 'name': 'PixelWizard', 'points': '45.8K', 'badge': '⚡ Топ 10', 'color': AppTheme.sciFiCyan, 'isFollowed': false},
    {'rank': 5, 'name': 'Samurai_Games', 'points': '38.4K', 'badge': '⚡ Топ 10', 'color': AppTheme.laserPink, 'isFollowed': false},
  ];

  final List<Map<String, dynamic>> _topRankedGifters = [
    {'rank': 1, 'name': 'Mega_Whale_VIP', 'points': '350.0K 💎', 'badge': '👑 VIP Дарител #1', 'color': Color(0xFFFFD600)},
    {'rank': 2, 'name': 'Diamond_Dragon', 'points': '210.5K 💎', 'badge': '🥈 VIP Дарител #2', 'color': Color(0xFFE0E0E0)},
    {'rank': 3, 'name': 'Cyber_Knight', 'points': '125.8K 💎', 'badge': '🥉 VIP Дарител #3', 'color': Color(0xFFFF6D00)},
    {'rank': 4, 'name': 'Elena_Top', 'points': '89.4K 💎', 'badge': '⚡ Топ Поддръжник', 'color': AppTheme.sciFiCyan},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _streamPageController.dispose();
    super.dispose();
  }

  void _showStreamerProfileModal(Map<String, dynamic> streamer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppTheme.laserPink, width: 1),
      ),
      builder: (context) => SafeArea(
        child: StatefulBuilder(
          builder: (context, setModalState) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [AppTheme.laserPink, AppTheme.sciFiCyan]),
                    boxShadow: [
                      BoxShadow(color: AppTheme.laserPink.withValues(alpha: 0.5), blurRadius: 20),
                    ],
                  ),
                  child: Center(child: Text(streamer['avatar'], style: const TextStyle(fontSize: 36))),
                ),
                const SizedBox(height: 10),
                Text(streamer['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text('🔴 Стриймва на живо: ${streamer['game']}', style: const TextStyle(color: Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildProfileStat('Ниво 45', 'Ранг'),
                    _buildProfileStat('${streamer['viewers']}', 'Зрители'),
                    _buildProfileStat('${streamer['likes']}', 'Харесвания'),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: streamer['isFollowed']
                                ? [const Color(0xFF1E2235), const Color(0xFF1E2235)]
                                : [AppTheme.laserPink, AppTheme.neonPurple],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: streamer['isFollowed'] ? Border.all(color: const Color(0xFF00E676)) : null,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 12)),
                          onPressed: () {
                            setModalState(() => streamer['isFollowed'] = !streamer['isFollowed']);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(streamer['isFollowed'] ? '🎉 Последвахте ${streamer['name']}!' : 'Вече не следвате ${streamer['name']}.')),
                            );
                          },
                          child: Text(
                            streamer['isFollowed'] ? 'СЛЕДВАШ ✓' : 'ПОСЛЕДВАЙ',
                            style: TextStyle(color: streamer['isFollowed'] ? const Color(0xFF00E676) : Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF00E676)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 12)),
                          icon: const Icon(Icons.sports_esports, color: Colors.black, size: 18),
                          label: const Text('ИГРАЙ С НЕГО', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('🎮 Свързване към 3D играта на ${streamer['name']}...')),
                            );
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
      ),
    );
  }

  Widget _buildProfileStat(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: AppTheme.sciFiCyan, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  void _buyCoinsPackage(int amount, String price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121422),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFFFD600))),
        title: const Row(
          children: [
            Icon(Icons.monetization_on, color: Color(0xFFFFD600)),
            SizedBox(width: 8),
            Text('Google Play Зареждане', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Text(
          'Желаете ли да закупите $amount Монети за $price?',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отказ', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD600)),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _coins += amount;
                _coinHistory.insert(0, {
                  'title': 'Закупени Монети ($price)',
                  'change': '+$amount',
                  'date': 'Току-що',
                  'isAdd': true,
                });
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('🎉 Успешно закупихте $amount монети! Нов баланс: $_coins')),
              );
            },
            child: const Text('КУПИ СЕГА', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCoinHistoryModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📜 История на Монетите', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _coinHistory.length,
                  itemBuilder: (context, index) {
                    final h = _coinHistory[index];
                    final bool isAdd = h['isAdd'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF161928), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(h['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(h['date'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                          Text(
                            '${h['change']} 🪙',
                            style: TextStyle(color: isAdd ? const Color(0xFF00E676) : const Color(0xFFFF1744), fontWeight: FontWeight.bold, fontSize: 14),
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
    );
  }

  void _showGiftsSheet(Map<String, dynamic> streamer) {
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 310,
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
              const SizedBox(height: 12),
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
                            streamer['comments'].add({
                              'user': '@Ти',
                              'text': 'Изпрати ${gift['name']}! 🎉',
                            });
                            _coinHistory.insert(0, {
                              'title': 'Подарък: ${gift['name']}',
                              'change': '-${gift['cost']}',
                              'date': 'Току-що',
                              'isAdd': false,
                            });
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('⚡ 3D Анимация: ${gift['name']} за ${streamer['name']}!')),
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
                            Icon(gift['icon'], color: gift['color'], size: 28),
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
          _buildLiveStreamSwipeFeed(),
          _buildCoinStoreTab(),
          _buildRankingsTab(),
        ],
      ),
    );
  }

  // 1. ТАБ: НА ЖИВО (С ПОВДИГНАТО ПОЛЕ И SAFEAREA)
  Widget _buildLiveStreamSwipeFeed() {
    return PageView.builder(
      controller: _streamPageController,
      scrollDirection: Axis.vertical,
      itemCount: _liveStreamers.length,
      itemBuilder: (context, index) {
        final streamer = _liveStreamers[index];
        final List<Map<String, String>> comments = streamer['comments'];

        return GestureDetector(
          onTap: () => setState(() => streamer['likes'] += 1),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: streamer['bgGradient'],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.gamepad, size: 75, color: AppTheme.sciFiCyan),
                      const SizedBox(height: 12),
                      Text(streamer['title'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('🎮 Игра: ${streamer['game']}', style: const TextStyle(color: AppTheme.laserPink, fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      const Text('Плъзни НАГОРЕ ⬆ за следващ стриймър', style: TextStyle(color: Colors.grey, fontSize: 11)),
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
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _showStreamerProfileModal(streamer),
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: AppTheme.laserPink,
                              child: Text(streamer['avatar'], style: const TextStyle(fontSize: 15)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _showStreamerProfileModal(streamer),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(streamer['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                Text('${streamer['likes']} Лайка', style: const TextStyle(color: Colors.grey, fontSize: 9)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() => streamer['isFollowed'] = !streamer['isFollowed']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(streamer['isFollowed'] ? '🎉 Последвахте ${streamer['name']}!' : 'Вече не следвате ${streamer['name']}.')),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: streamer['isFollowed'] ? const Color(0xFF00E676) : AppTheme.laserPink,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                streamer['isFollowed'] ? 'Следваш ✓' : 'Следвай',
                                style: TextStyle(color: streamer['isFollowed'] ? Colors.black : Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          const Icon(Icons.remove_red_eye, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(streamer['viewers'], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ДОЛНА ЛЕНТА С ПОДВИЖЕН SAFE AREA ОТСТЪП (ПОВДИГНАТА НАГОРЕ)
              Positioned(
                left: 12,
                right: 12,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 110,
                          child: ListView.builder(
                            reverse: true,
                            itemCount: comments.length,
                            itemBuilder: (context, cIdx) {
                              final comment = comments[comments.length - 1 - cIdx];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 42,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
                                child: const Row(
                                  children: [
                                    Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 16),
                                    SizedBox(width: 6),
                                    Text('Коментирай на живо...', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(icon: const Icon(Icons.share, color: Colors.white, size: 24), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.card_giftcard, color: AppTheme.laserPink, size: 26), onPressed: () => _showGiftsSheet(streamer)),
                            IconButton(icon: const Icon(Icons.favorite, color: Color(0xFFFF1744), size: 26), onPressed: () => setState(() => streamer['likes'] += 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. ТАБ: МОНЕТИ
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
                onPressed: _showCoinHistoryModal,
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
                  style: ElevatedButton.styleFrom(backgroundColor: packColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () => _buyCoinsPackage(pack['coins'] as int, pack['price'] as String),
                  child: Text(pack['price'], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // 3. ТАБ: РАНКОВЕ
  Widget _buildRankingsTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: const Color(0xFF161928), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeLeaderboardTab = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _activeLeaderboardTab == 0 ? AppTheme.laserPink : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text('🏆 Топ Създатели', style: TextStyle(color: Colors.white, fontWeight: _activeLeaderboardTab == 0 ? FontWeight.bold : FontWeight.normal, fontSize: 12))),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeLeaderboardTab = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _activeLeaderboardTab == 1 ? const Color(0xFFFFD600) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text('💎 Топ Дарители', style: TextStyle(color: _activeLeaderboardTab == 1 ? Colors.black : Colors.white, fontWeight: _activeLeaderboardTab == 1 ? FontWeight.bold : FontWeight.normal, fontSize: 12))),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (_activeLeaderboardTab == 0) ...[
          const Text('СЕДМИЧНО КЛАСИРАНЕ НА РАЗРАБОТЧИЦИТЕ', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._topRankedCreators.map((c) {
            final Color bColor = c['color'];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF10121D), borderRadius: BorderRadius.circular(12), border: Border.all(color: bColor.withValues(alpha: 0.4))),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: bColor.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: Center(child: Text('#${c['rank']}', style: TextStyle(color: bColor, fontWeight: FontWeight.bold, fontSize: 12))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(c['badge'], style: TextStyle(color: bColor, fontSize: 10)),
                      ],
                    ),
                  ),
                  Text('💎 ${c['points']}', style: TextStyle(color: bColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            );
          }).toList(),
        ] else ...[
          const Text('ТОП ДАРИТЕЛИ & VIP ПОДДРЪЖНИЦИ', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._topRankedGifters.map((g) {
            final Color gColor = g['color'];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF10121D), borderRadius: BorderRadius.circular(12), border: Border.all(color: gColor.withValues(alpha: 0.4))),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: gColor.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: Center(child: Text('#${g['rank']}', style: TextStyle(color: gColor, fontWeight: FontWeight.bold, fontSize: 12))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(g['badge'], style: TextStyle(color: gColor, fontSize: 10)),
                      ],
                    ),
                  ),
                  Text(g['points'], style: TextStyle(color: gColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }
}
