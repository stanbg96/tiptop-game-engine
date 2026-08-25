import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E101A),
        elevation: 0,
        title: const Text('@cyber_creator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code, color: AppTheme.laserPink),
            tooltip: 'Профилен QR',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📷 Показване на твоя TipTop Профилен QR код')),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.menu, color: AppTheme.sciFiCyan), onPressed: () {}),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Профилна снимка с лазерно светещ неонов пръстен
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [AppTheme.laserPink, Color(0xFF00E676)]),
                    boxShadow: [
                      BoxShadow(color: AppTheme.laserPink.withValues(alpha: 0.5), blurRadius: 20),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF10121D)),
                      child: const Center(child: Text('👑', style: TextStyle(fontSize: 38))),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Cyber Game Developer', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),

                // Статистика (Following | Followers | Likes)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatColumn('142', 'Следвани', AppTheme.sciFiCyan),
                    _buildDivider(),
                    _buildStatColumn('8.5K', 'Последователи', const Color(0xFF00E676)),
                    _buildDivider(),
                    _buildStatColumn('42.1K', 'Харесвания', AppTheme.laserPink),
                  ],
                ),
                const SizedBox(height: 14),

                // Бутони Редактирай и Сподели
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppTheme.laserPink, Color(0xFFFF1744)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10)),
                        onPressed: () {},
                        child: const Text('Редактирай Профил', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF161928),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.sciFiCyan.withValues(alpha: 0.5)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.share_outlined, color: AppTheme.sciFiCyan, size: 20),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Автобиография (Bio)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.0),
                  child: Text(
                    '🎮 Създавам 3D светове с Google Filament & AI\n⚡ Сканирай QR кода ми за мултиплейър битки!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
          // 4-те Таба (Игри, Снимки, Запазени, Харесани)
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
            _buildGrid(Icons.gamepad, '3D Игри', const Color(0xFF00E676)),
            _buildGrid(Icons.image, 'Снимки & Арт', AppTheme.sciFiCyan),
            _buildGrid(Icons.bookmark, 'Запазени', const Color(0xFFFFD600)),
            _buildGrid(Icons.favorite, 'Харесани', AppTheme.laserPink),
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

  Widget _buildGrid(IconData icon, String title, Color color) {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 0.75,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF10121D),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 4),
                Text('$title #${index + 1}', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
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
