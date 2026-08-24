import 'package:flutter/material.dart';

class MushroomStudioScreen extends StatefulWidget {
  const MushroomStudioScreen({Key? key}) : super(key: key);

  @override
  State<MushroomStudioScreen> createState() => _MushroomStudioScreenState();
}

class _MushroomStudioScreenState extends State<MushroomStudioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPlaying = true;
  double _playbackSpeed = 1.0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          '🍄 Creator Studio',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.purpleAccent,
          indicatorWeight: 3,
          labelColor: Colors.purpleAccent,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: '2D World'),
            Tab(text: '3D World'),
            Tab(text: 'Asset Store'),
            Tab(text: 'Movements'),
            Tab(text: 'Anim Player'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _build2DBuilder(),
          _build3DBuilder(),
          _buildAssetStore(),
          _buildMovementPicker(),
          _buildAnimationPlayer(),
        ],
      ),
    );
  }

  // 1. 2D Scene Canvas
  Widget _build2DBuilder() {
    return Container(
      color: const Color(0xFF121218),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.grid_4x4, size: 64, color: Colors.purpleAccent),
            SizedBox(height: 12),
            Text(
              '2D Scene Canvas',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Controlled via AI Chat commands',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // 2. 3D Filament Viewport
  Widget _build3DBuilder() {
    return Container(
      color: const Color(0xFF0F0F14),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.view_in_ar, size: 64, color: Colors.cyanAccent),
            SizedBox(height: 12),
            Text(
              'Google Filament 3D Viewport',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Real-time PBR Shaders & Lighting Active',
              style: TextStyle(color: Colors.cyanAccent, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Free Asset Store
  Widget _buildAssetStore() {
    final List<Map<String, String>> sampleAssets = [
      {'name': 'Cyber Dragon', 'type': '3D Model', 'category': 'Creatures'},
      {'name': 'Sci-Fi Hover Bike', 'type': '3D Model', 'category': 'Vehicles'},
      {'name': 'Laser Rifle', 'type': '3D Weapon', 'category': 'Weapons'},
      {'name': 'Pixel Knight', 'type': '2D Sprite', 'category': 'Heroes'},
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search free 2D/3D assets...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.purpleAccent),
              filled: true,
              fillColor: const Color(0xFF1E1E28),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: sampleAssets.length,
            itemBuilder: (context, index) {
              final asset = sampleAssets[index];
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF181822),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.token, size: 40, color: Colors.purpleAccent),
                    const SizedBox(height: 8),
                    Text(
                      asset['name']!,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      asset['type']!,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {},
                      child: const Text('Add to Scene', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 4. Animation Movement Library
  Widget _buildMovementPicker() {
    final List<String> moves = ['Combat Kick', 'Hip Hop Dance', 'Sprint Run', 'Hero Jump', 'Zombie Walk'];
    return ListView.builder(
      itemCount: moves.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.accessibility_new, color: Colors.cyanAccent),
          title: Text(moves[index], style: const TextStyle(color: Colors.white)),
          subtitle: const Text('Mixamo Motion Library', style: TextStyle(color: Colors.grey, fontSize: 12)),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
            onPressed: () {
              _tabController.animateTo(4);
            },
            child: const Text('Preview', style: TextStyle(color: Colors.black)),
          ),
        );
      },
    );
  }

  // 5. Animation Player & Controls
  Widget _buildAnimationPlayer() {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF14141E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.man, size: 100, color: Colors.cyanAccent),
                  const SizedBox(height: 12),
                  const Text(
                    'Previewing: Hip Hop Dance',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Speed: ${_playbackSpeed}x | ${_isPlaying ? "Playing" : "Paused"}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Playback Control Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.fast_rewind, color: Colors.white),
                onPressed: () {
                  setState(() => _playbackSpeed = 0.5);
                },
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: Colors.purpleAccent, size: 48),
                onPressed: () {
                  setState(() => _isPlaying = !_isPlaying);
                },
              ),
              IconButton(
                icon: const Icon(Icons.fast_forward, color: Colors.white),
                onPressed: () {
                  setState(() => _playbackSpeed = 2.0);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Big Apply Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Animation applied to 3D character!')),
                );
              },
              child: const Text(
                'APPLY ANIMATION',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
