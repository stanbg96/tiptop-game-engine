import 'package:flutter/material.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({Key? key}) : super(key: key);

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  int _coins = 350;
  int _likesCount = 12450;

  final List<Map<String, String>> _liveComments = [
    {'user': '@alex_pro', 'text': 'Streaming with Google Filament engine! 🔥'},
    {'user': '@maya_gamer', 'text': 'Look at those 3D lighting effects! 😍'},
    {'user': '@dev_kyle', 'text': 'Sent a Cyber Dragon 🐉'},
    {'user': '@speed_runner', 'text': 'Hello everyone in the live stream!'},
  ];

  void _showCoinStore() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161622),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recharge Coins', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Balance: $_coins', style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildCoinTier('100 Coins', '\$0.99', 100),
            _buildCoinTier('500 Coins (+50 Bonus)', '\$4.99', 550),
            _buildCoinTier('1200 Coins (+150 Bonus)', '\$9.99', 1350),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinTier(String title, String price, int amount) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.monetization_on, color: Colors.amberAccent, size: 28),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
        onPressed: () {
          setState(() => _coins += amount);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Purchased $amount Coins!')));
        },
        child: Text(price),
      ),
    );
  }

  void _showGiftsSheet() {
    final List<Map<String, dynamic>> gifts = [
      {'name': 'Rose', 'cost': 1, 'icon': Icons.local_florist, 'color': Colors.redAccent},
      {'name': 'Gamepad', 'cost': 10, 'icon': Icons.sports_esports, 'color': Colors.cyanAccent},
      {'name': 'Magic Sword', 'cost': 50, 'icon': Icons.flash_on, 'color': Colors.amberAccent},
      {'name': 'Cyber Dragon', 'cost': 200, 'icon': Icons.auto_awesome, 'color': Colors.purpleAccent},
      {'name': 'Crown', 'cost': 500, 'icon': Icons.emoji_events, 'color': Colors.yellowAccent},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161622),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Send Gifts', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showCoinStore();
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amberAccent, size: 16),
                      const SizedBox(width: 4),
                      Text('$_coins Recharge', style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.8,
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
                            'user': '@You',
                            'text': 'Sent a ${gift['name']}! 🎁',
                          });
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gift sent: ${gift['name']}!')),
                        );
                      } else {
                        Navigator.pop(context);
                        _showCoinStore();
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(gift['icon'], color: gift['color'], size: 36),
                        const SizedBox(height: 4),
                        Text(gift['name'], style: const TextStyle(color: Colors.white, fontSize: 11)),
                        Text('${gift['cost']} Coins', style: const TextStyle(color: Colors.amberAccent, fontSize: 11)),
                      ],
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
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() => _likesCount += 1);
        },
        child: Stack(
          children: [
            // 1. Full Screen Live 3D Gameplay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E112A), Colors.black],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.live_tv, size: 70, color: Colors.purpleAccent),
                    SizedBox(height: 12),
                    Text(
                      'Live 3D Gameplay Stream',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Tap screen to send likes ❤️',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Top Host Info Bar (1:1 with TikTok)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.purpleAccent,
                            child: Icon(Icons.person, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '@host_creator',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              Text(
                                '$_likesCount Likes',
                                style: const TextStyle(color: Colors.grey, fontSize: 10),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Follow',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.remove_red_eye, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('18.4K', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Floating Comments + TikTok Action Row
            Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: Column(
                children: [
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      reverse: true,
                      itemCount: _liveComments.length,
                      itemBuilder: (context, index) {
                        final comment = _liveComments[_liveComments.length - 1 - index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: '${comment['user']}: ', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                                TextSpan(text: comment['text'], style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 18),
                              SizedBox(width: 8),
                              Text('Add comment...', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white, size: 26),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.card_giftcard, color: Colors.purpleAccent, size: 28),
                        onPressed: _showGiftsSheet,
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.redAccent, size: 28),
                        onPressed: () {
                          setState(() => _likesCount += 10);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
