import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _username = '@cyber_creator';
  String _displayName = 'Cyber Game Developer';
  String _bio = '🎮 Създавам 2D & 3D светове с Godot 4, Filament & AI\n⚡ Сканирай QR кода ми за мултиплейър битки!';
  String _avatarEmoji = '👑';
  final int _followingCount = 142;
  final String _followersCount = '8.5K';
  final String _likesCount = '42.1K';

  bool _isPublicProfile = true;
  bool _allowComments = true;
  bool _allowMultiplayerInvites = true;
  bool _notifyLikes = true;
  bool _notifyComments = true;

  final List<Map<String, dynamic>> _myGames = [
    {
      'title': 'Cyberpunk Neon Runner 3D',
      'dimension': '3D',
      'views': '24.5K',
      'likes': '1.4K',
      'icon': Icons.view_in_ar,
      'color': AppTheme.laserPink,
      'engine': 'Google Filament C++'
    },
    {
      'title': 'Вулканичен Лабиринт 3D',
      'dimension': '3D',
      'views': '18.2K',
      'likes': '3.4K',
      'icon': Icons.local_fire_department,
      'color': const Color(0xFFFF3D00),
      'engine': 'Jolt Physics 3D'
    },
    {
      'title': 'Medieval Castle Defense 2D',
      'dimension': '2D',
      'views': '9.8K',
      'likes': '850',
      'icon': Icons.grid_view,
      'color': const Color(0xFF00E676),
      'engine': 'Godot 4 2D Engine'
    },
  ];

  final List<Map<String, dynamic>> _myPhotos = [
    {'title': 'Lava Shader Render 4K', 'likes': '1.2K', 'icon': Icons.image, 'color': const Color(0xFFFF9100)},
    {'title': 'Cyber Samurai Rig Pose', 'likes': '3.1K', 'icon': Icons.photo_camera, 'color': AppTheme.sciFiCyan},
  ];

  final List<Map<String, dynamic>> _savedCreations = [
    {'title': 'Ninja Katana Combat 3D', 'creator': '@samurai_pro', 'icon': Icons.sports_esports, 'color': const Color(0xFFFFD600)},
    {'title': 'Dragon Flight Simulator', 'creator': '@dragon_dev', 'icon': Icons.auto_awesome, 'color': const Color(0xFF00E676)},
  ];

  final List<Map<String, dynamic>> _likedCreations = [
    {'title': 'Lava Volcano Arena 3D', 'creator': '@Alex_3D', 'icon': Icons.favorite, 'color': AppTheme.laserPink},
    {'title': 'Pixel Quest RPG 2D', 'creator': '@pixel_wizard', 'icon': Icons.favorite, 'color': AppTheme.laserPink},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showProfileQrModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppTheme.laserPink, width: 1.2),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👑 Твоят TipTop Профилен QR Код', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppTheme.laserPink.withValues(alpha: 0.5), blurRadius: 20)],
                ),
                child: const Icon(Icons.qr_code_2, size: 140, color: Colors.black),
              ),
              const SizedBox(height: 12),
              Text(_username, style: const TextStyle(color: AppTheme.laserPink, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              const Text('Сканирай за директно отваряне на профила и игрите', style: TextStyle(color: Colors.grey, fontSize: 11)),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.sciFiCyan, padding: const EdgeInsets.symmetric(vertical: 12)),
                      icon: const Icon(Icons.copy, color: Colors.black, size: 16),
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
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.laserPink, padding: const EdgeInsets.symmetric(vertical: 12)),
                      icon: const Icon(Icons.share, color: Colors.white, size: 16),
                      label: const Text('СПОДЕЛИ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✉️ Профилът е споделен успешно!')));
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

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚙️ Настройки & Поверителност', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _buildSettingsTile(Icons.lock, 'Поверителност на Игрите', _showPrivacySettingsModal),
              _buildSettingsTile(Icons.notifications, 'Известия за Коментари и Лайкове', _showNotificationSettingsModal),
              const Divider(color: Colors.white12),
              _buildSettingsTile(Icons.logout, 'Изход от Профила', () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('👋 Успешен изход от профила.')));
              }, isDestructive: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : AppTheme.sciFiCyan, size: 20),
      title: Text(title, style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
      onTap: onTap,
    );
  }

  void _showPrivacySettingsModal() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) => SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔒 Поверителност на Игрите', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text('Публичен Профил', style: TextStyle(color: Colors.white, fontSize: 13)),
                  value: _isPublicProfile,
                  activeColor: const Color(0xFF00E676),
                  onChanged: (val) => setModalState(() => _isPublicProfile = val),
                ),
                SwitchListTile(
                  title: const Text('Разреши Коментари', style: TextStyle(color: Colors.white, fontSize: 13)),
                  value: _allowComments,
                  activeColor: AppTheme.laserPink,
                  onChanged: (val) => setModalState(() => _allowComments = val),
                ),
                SwitchListTile(
                  title: const Text('Мултиплейър Покани от Всички', style: TextStyle(color: Colors.white, fontSize: 13)),
                  value: _allowMultiplayerInvites,
                  activeColor: AppTheme.sciFiCyan,
                  onChanged: (val) => setModalState(() => _allowMultiplayerInvites = val),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationSettingsModal() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) => SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔔 Известия', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text('Известия за Харесвания', style: TextStyle(color: Colors.white, fontSize: 13)),
                  value: _notifyLikes,
                  activeColor: AppTheme.laserPink,
                  onChanged: (val) => setModalState(() => _notifyLikes = val),
                ),
                SwitchListTile(
                  title: const Text('Известия за Нови Коментари', style: TextStyle(color: Colors.white, fontSize: 13)),
                  value: _notifyComments,
                  activeColor: AppTheme.sciFiCyan,
                  onChanged: (val) => setModalState(() => _notifyComments = val),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProfileModal() {
    final nameCtrl = TextEditingController(text: _displayName);
    final userCtrl = TextEditingController(text: _username);
    final bioCtrl = TextEditingController(text: _bio);
    String tempAvatar = _avatarEmoji;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: Text('✏️ Редактирай Профил', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['👑', '🎮', '🥷', '🤖', '🐉', '🎨'].map((emoji) {
                      final isSel = emoji == tempAvatar;
                      return GestureDetector(
                        onTap: () => setModalState(() => tempAvatar = emoji),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSel ? AppTheme.laserPink.withValues(alpha: 0.3) : const Color(0xFF181B28),
                            border: Border.all(color: isSel ? AppTheme.laserPink : Colors.transparent, width: 2),
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: const Color(0xFF181B28), borderRadius: BorderRadius.circular(10)),
                    child: TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: const InputDecoration(hintText: 'Име', border: InputBorder.none)),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: const Color(0xFF181B28), borderRadius: BorderRadius.circular(10)),
                    child: TextField(controller: userCtrl, style: const TextStyle(color: AppTheme.sciFiCyan, fontSize: 13), decoration: const InputDecoration(hintText: 'Потребителско име', border: InputBorder.none)),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: const Color(0xFF181B28), borderRadius: BorderRadius.circular(10)),
                    child: TextField(controller: bioCtrl, maxLines: 2, style: const TextStyle(color: Colors.white, fontSize: 12), decoration: const InputDecoration(hintText: 'Био', border: InputBorder.none)),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.laserPink),
                      onPressed: () {
                        setState(() {
                          _displayName = nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : _displayName;
                          _username = userCtrl.text.trim().isNotEmpty ? userCtrl.text.trim() : _username;
                          _bio = bioCtrl.text.trim().isNotEmpty ? bioCtrl.text.trim() : _bio;
                          _avatarEmoji = tempAvatar;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 Профилът е обновен успешно!')));
                      },
                      child: const Text('ЗАПАЗИ ПРОМЕНИТЕ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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

  void _showGameLauncherModal(Map<String, dynamic> game) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: AppTheme.laserPink),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(game['icon'] ?? Icons.gamepad, size: 46, color: game['color'] ?? AppTheme.laserPink),
              const SizedBox(height: 10),
              Text(game['title'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(height: 4),
              Text('Енджин: ${game['engine']} • 👁️ ${game['views']} • ❤️ ${game['likes']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.sciFiCyan), padding: const EdgeInsets.symmetric(vertical: 12)),
                      icon: const Icon(Icons.edit, size: 16, color: AppTheme.sciFiCyan),
                      label: const Text('РЕДАКТИРАЙ', style: TextStyle(color: AppTheme.sciFiCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🍄 Отваряне на ${game['title']} в Студиото...')));
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.laserPink, padding: const EdgeInsets.symmetric(vertical: 12)),
                      icon: const Icon(Icons.play_arrow, size: 18, color: Colors.white),
                      label: const Text('ИГРАЙ СЕГА', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🎮 Стартиране на ${game['title']} на 60 FPS...')));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E101A),
        elevation: 0,
        title: Text(_username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_2, color: AppTheme.laserPink), onPressed: _showProfileQrModal),
          IconButton(icon: const Icon(Icons.menu, color: AppTheme.sciFiCyan), onPressed: _showSettingsModal),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [AppTheme.laserPink, Color(0xFF00E676)]),
                    boxShadow: [BoxShadow(color: AppTheme.laserPink.withValues(alpha: 0.5), blurRadius: 20)],
                  ),
                  child: Center(child: Text(_avatarEmoji, style: const TextStyle(fontSize: 38))),
                ),
                const SizedBox(height: 10),
                Text(_displayName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatColumn('$_followingCount', 'Следвани', AppTheme.sciFiCyan),
                    _buildDivider(),
                    _buildStatColumn(_followersCount, 'Последователи', const Color(0xFF00E676)),
                    _buildDivider(),
                    _buildStatColumn(_likesCount, 'Харесвания', AppTheme.laserPink),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.laserPink, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10)),
                      onPressed: _showEditProfileModal,
                      child: const Text('Редактирай Профил', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(color: const Color(0xFF161928), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.sciFiCyan.withValues(alpha: 0.5))),
                      child: IconButton(icon: const Icon(Icons.share_outlined, color: AppTheme.sciFiCyan, size: 20), onPressed: _showProfileQrModal),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Text(_bio, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.laserPink,
                indicatorWeight: 2.5,
                tabs: const [
                  Tab(icon: Icon(Icons.grid_view_rounded, color: Color(0xFF00E676))),
                  Tab(icon: Icon(Icons.photo_library_outlined, color: AppTheme.sciFiCyan)),
                  Tab(icon: Icon(Icons.bookmark_border_rounded, color: Color(0xFFFFD600))),
                  Tab(icon: Icon(Icons.favorite_border_rounded, color: AppTheme.laserPink)),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildItemList(_myGames, isGame: true),
            _buildItemList(_myPhotos, isGame: false),
            _buildItemList(_savedCreations, isGame: true),
            _buildItemList(_likedCreations, isGame: true),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String count, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Column(
        children: [
          Text(count, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 18, width: 1, color: Colors.white24);
  }

  Widget _buildItemList(List<Map<String, dynamic>> items, {required bool isGame}) {
    return GridView.builder(
      padding: const EdgeInsets.all(6),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.88,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final Color cardColor = item['color'] ?? AppTheme.laserPink;

        return GestureDetector(
          onTap: () => _showGameLauncherModal(item),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF10121D),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cardColor.withValues(alpha: 0.4)),
              boxShadow: [BoxShadow(color: cardColor.withValues(alpha: 0.12), blurRadius: 8)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: cardColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                    child: Text(item['views'] ?? item['likes'] ?? 'Top', style: TextStyle(color: cardColor, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
                Icon(item['icon'] ?? Icons.gamepad, color: cardColor, size: 40),
                Text(
                  item['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(isGame ? '▶ Клик за Игра' : '👁️ Преглед', style: TextStyle(color: cardColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: const Color(0xFF0E101A), child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
