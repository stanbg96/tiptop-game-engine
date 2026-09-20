import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/features/mushroom_studio/presentation/widgets/studio_2d_view.dart';
import 'package:tiptop_game_engine/features/mushroom_studio/presentation/widgets/studio_3d_view.dart';
import 'package:tiptop_game_engine/features/mushroom_studio/presentation/widgets/asset_store_view.dart';
import 'package:tiptop_game_engine/features/mushroom_studio/presentation/widgets/movements_view.dart';
import 'package:tiptop_game_engine/features/mushroom_studio/presentation/widgets/animator_player_view.dart';

class MushroomStudioScreen extends StatefulWidget {
  const MushroomStudioScreen({Key? key}) : super(key: key);

  @override
  State<MushroomStudioScreen> createState() => _MushroomStudioScreenState();
}

class _MushroomStudioScreenState extends State<MushroomStudioScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _activeAnimation = 'Hip Hop Dance';
  String _activeCategory = '💃 Танци & Емоути';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onAnimationSelected(String name, String category) {
    setState(() {
      _activeAnimation = name;
      _activeCategory = category;
    });
    // Автоматично превключва към Аниматора за преглед
    _tabController.animateTo(4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080D),
      body: Column(
        children: [
          // Горна лента с табове
          SafeArea(
            bottom: false,
            child: Container(
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFF0E101A),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF222638), width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: AppTheme.laserPink,
                indicatorWeight: 2.8,
                labelColor: AppTheme.laserPink,
                unselectedLabelColor: Colors.grey,
                labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(icon: Icon(Icons.grid_4x4, size: 16), text: '2D Студио'),
                  Tab(icon: Icon(Icons.view_in_ar, size: 16), text: '3D Filament'),
                  Tab(icon: Icon(Icons.storefront, size: 16), text: 'Магазин'),
                  Tab(icon: Icon(Icons.directions_run, size: 16), text: 'Движения'),
                  Tab(icon: Icon(Icons.play_circle_fill, size: 16), text: 'Аниматор'),
                ],
              ),
            ),
          ),

          // Съдържание на всеки отделен модул
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // 1. Самостоятелен 2D Енджин
                const Studio2DView(),

                // 2. Самостоятелен 3D Filament Енджин
                const Studio3DView(),

                // 3. Самостоятелен Магазин за асети
                AssetStoreView(
                  onInsertTo2D: () => _tabController.animateTo(0),
                  onInsertTo3D: () => _tabController.animateTo(1),
                ),

                // 4. Самостоятелна библиотека с движения
                MovementsView(
                  onSelectAnimation: _onAnimationSelected,
                ),

                // 5. Самостоятелен Анимационен плейър
                AnimatorPlayerView(
                  activeAnimation: _activeAnimation,
                  activeCategory: _activeCategory,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
