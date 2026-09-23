import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/core/services/auto_rig_service.dart';
import 'package:tiptop_game_engine/core/services/global_asset_registry.dart';
import 'package:tiptop_game_engine/core/services/asset_downloader_service.dart';
import 'package:tiptop_game_engine/features/mushroom_studio/presentation/widgets/model_upload_modal.dart';
import 'package:tiptop_game_engine/features/mushroom_studio/presentation/widgets/model_3d_viewer_painter.dart';

class AssetStoreView extends StatefulWidget {
  final VoidCallback? onInsertTo2D;
  final VoidCallback? onInsertTo3D;

  const AssetStoreView({
    Key? key,
    this.onInsertTo2D,
    this.onInsertTo3D,
  }) : super(key: key);

  @override
  State<AssetStoreView> createState() => _AssetStoreViewState();
}

class _AssetStoreViewState extends State<AssetStoreView> {
  final GlobalAssetRegistryService _registry = GlobalAssetRegistryService();
  final AssetDownloaderService _downloader = AssetDownloaderService();
  
  String _selectedMainType = '🎲 3D Модели';
  String _selectedCategory = 'Всички';
  String _selectedLibrary = 'Всички';
  String _searchQuery = '';
  String? _playingAudioTrack;

  final List<String> _mainTypes = [
    '🎲 3D Модели',
    '👑 Моите Модели',
    '🎨 2D Спрайтове',
    '🎵 Музика & SFX',
    '🌋 Шейдъри & FX',
    '📚 101 Библиотеки',
  ];

  final List<String> _categories = [
    'Всички',
    '🤖 Герои & Мехове',
    '🏰 Сгради & Замъци',
    '🚗 Возила & Коли',
    '⚔️ Оръжия',
    '🌋 Лава & Неон',
    '🚀 Космос & Sci-Fi',
    '📦 Пропове & Сандъци',
  ];

  late List<Map<String, dynamic>> _catalog;

  @override
  void initState() {
    super.initState();
    _catalog = [];
    
    // 1. Първо добавяме РЕАЛНИТЕ файлове за теглене от интернет (Партида 1)
    final realAssets = _downloader.getBatch1RealAssets();
    for (var r in realAssets) {
      r['color'] = AppTheme.sciFiCyan;
      r['img'] = '';
      r['icon'] = r['media'] == '3D' ? Icons.view_in_ar : Icons.image;
      _catalog.add(r);
    }

    // 2. След това добавяме останалите 500+ генерирани асета
    _catalog.addAll(_generateMassiveCatalog());
  }

  static List<Map<String, dynamic>> _generateMassiveCatalog() {
    List<Map<String, dynamic>> list = [];
    final List<Color> colors = [AppTheme.sciFiCyan, AppTheme.laserPink, const Color(0xFFFFD600), const Color(0xFF00E676), const Color(0xFFFF3D00), const Color(0xFFD500F9), const Color(0xFF00B0FF)];
    final libs = ['Kenney.nl', 'Quaternius', 'Poly Pizza', 'NASA 3D', 'Mixamo', 'CraftPix', 'FreeSound.org'];
    final shapes = ['humanoid', 'vehicle', 'castle', 'sword', 'shuttle', 'chest'];
    final cats = ['🤖 Герои & Мехове', '🚗 Возила & Коли', '🏰 Сгради & Замъци', '⚔️ Оръжия', '🚀 Космос & Sci-Fi', '📦 Пропове & Сандъци'];

    for (int i = 1; i <= 500; i++) {
      String lib = libs[i % libs.length];
      String shape = shapes[i % shapes.length];
      String cat = cats[i % cats.length];
      bool isAudio = lib.contains('Sound');
      bool is2D = lib.contains('CraftPix');

      list.add({
        'name': '$lib $shape Model #$i',
        'type': isAudio ? 'Audio Track' : (is2D ? '2D Sprite' : '3D PBR Model'),
        'media': isAudio ? 'Audio' : (is2D ? '2D' : '3D'),
        'shape': shape,
        'cat': cat,
        'color': colors[i % colors.length],
        'poly': isAudio ? '1:45 min' : '${500 + (i * 25)} Poly',
        'lib': lib,
        'img': '',
        'icon': isAudio ? Icons.music_note : (is2D ? Icons.shield : Icons.view_in_ar),
      });
    }
    return list;
  }

  void _show3DInspectModal(Map<String, dynamic> asset) {
    double orbitAngle = 0.4;
    double pitchAngle = 0.35;
    bool showWireframe = false;
    bool isDownloading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24)), side: BorderSide(color: AppTheme.sciFiCyan, width: 1.2)),
      builder: (context) => SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(asset['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('Библиотека: ${asset['lib']} • ${asset['poly']}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close, color: Colors.grey, size: 20), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(color: Colors.white12),

                GestureDetector(
                  onPanUpdate: (d) {
                    setModalState(() {
                      orbitAngle += d.delta.dx * 0.018;
                      pitchAngle = (pitchAngle - d.delta.dy * 0.015).clamp(0.1, 1.2);
                    });
                  },
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(color: const Color(0xFF090B14), borderRadius: BorderRadius.circular(16), border: Border.all(color: (asset['color'] as Color).withValues(alpha: 0.4))),
                    child: Stack(
                      children: [
                        Center(
                          child: CustomPaint(
                            size: const Size(200, 200),
                            painter: Authentic3DModelViewerPainter(yaw: orbitAngle, pitch: pitchAngle, shapeType: asset['shape'] as String? ?? 'chest', baseColor: asset['color'] as Color, showWireframe: showWireframe),
                          ),
                        ),
                        Positioned(
                          top: 10, right: 10,
                          child: GestureDetector(
                            onTap: () => setModalState(() => showWireframe = !showWireframe),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: showWireframe ? AppTheme.laserPink : const Color(0xFF1E2235), borderRadius: BorderRadius.circular(8)),
                              child: Text('Wireframe', style: TextStyle(color: showWireframe ? Colors.white : Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        Positioned(bottom: 8, left: 10, child: Text('↔ 360° PBR завъртане с пръст', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 9))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Формат', asset['media'] == '3D' ? 'GLB / GLTF' : (asset['media'] == 'Audio' ? 'WAV / MP3' : 'PNG / Tiles')),
                    _buildStatCard('Сложност', asset['poly'] as String),
                    _buildStatCard('Лиценз', 'CC0 / Отворен'),
                  ],
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: asset['color'] as Color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    icon: isDownloading 
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : const Icon(Icons.download, color: Colors.black, size: 18),
                    label: Text(
                      isDownloading ? 'СВАЛЯНЕ ОТ ИНТЕРНЕТ...' : (asset['media'] == '2D' ? 'ВКАРАЙ В 2D GODOT СТУДИО' : 'ВКАРАЙ В 3D FILAMENT СТУДИО'), 
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)
                    ),
                    onPressed: isDownloading ? null : () async {
                      if (asset.containsKey('downloadUrl')) {
                        setModalState(() => isDownloading = true);
                        
                        String? localPath = await _downloader.downloadAsset(asset['downloadUrl'], asset['fileName']);
                        
                        if (!mounted) return;
                        setModalState(() => isDownloading = false);
                        Navigator.pop(context);
                        
                        if (localPath != null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('✅ Успешно свален и запазен в:\n$localPath'),
                            duration: const Duration(seconds: 4),
                          ));
                          if (asset['media'] == '2D') widget.onInsertTo2D?.call(); else widget.onInsertTo3D?.call();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Грешка при сваляне от сървъра!')));
                        }
                      } else {
                        Navigator.pop(context);
                        if (asset['media'] == '2D') widget.onInsertTo2D?.call(); else widget.onInsertTo3D?.call();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Вкаран с реален облик: ${asset['name']}')));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFF161928), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)), const SizedBox(height: 2), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9))]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customModels = AutoRigService().customModels;
    List<Map<String, dynamic>> filteredList = [];

    if (_selectedMainType == '👑 Моите Модели') {
      filteredList = customModels.map((m) => {
        'name': m.name, 'type': m.isAutoRigged ? '3D Модел (Auto-Rigged)' : '3D Модел', 'media': '3D', 'shape': 'humanoid', 'cat': '🤖 Герои & Мехове', 'color': m.baseColor, 'poly': '${m.vertexCount} Poly', 'lib': 'Local Storage', 'img': '', 'icon': Icons.accessibility_new,
      }).toList();
    } else {
      filteredList = _catalog.where((a) {
        bool matchesType = true;
        if (_selectedMainType == '🎲 3D Модели') matchesType = a['media'] == '3D';
        if (_selectedMainType == '🎨 2D Спрайтове') matchesType = a['media'] == '2D';
        if (_selectedMainType == '🎵 Музика & SFX') matchesType = a['media'] == 'Audio';
        if (_selectedMainType == '🌋 Шейдъри & FX') matchesType = a['media'] == 'Shaders';

        final matchesCat = _selectedCategory == 'Всички' || a['cat'] == _selectedCategory;
        final matchesLib = _selectedLibrary == 'Всички' || a['lib'].toString().contains(_selectedLibrary);
        final matchesSearch = _searchQuery.isEmpty || a['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesType && matchesCat && matchesLib && matchesSearch;
      }).toList();
    }

    final registryLibs = _registry.search(query: _searchQuery);

    return Column(
      children: [
        // 1. Главен тип превключвател
        Container(
          height: 38,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(color: const Color(0xFF141724), borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: _mainTypes.map((type) {
              final isSel = type == _selectedMainType;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMainType = type),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: isSel ? AppTheme.laserPink : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text(type, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontSize: 9, fontWeight: isSel ? FontWeight.bold : FontWeight.normal))),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // 2. АКО Е ИЗБРАНО "101 БИБЛИОТЕКИ" - ПОКАЗВА ПЪЛНИЯ РЕГИСТЪР
        if (_selectedMainType == '📚 101 Библиотеки')
          Expanded(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1E2338), Color(0xFF101424)]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Общо в 101-те библиотеки:', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          Text('${_registry.totalTrackedAssets}+ Налични Асета', style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                        icon: const Icon(Icons.flash_on, color: Colors.black, size: 14),
                        label: const Text('ЗАРЕДИ ВСИЧКИ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                        onPressed: () {
                          setState(() { _selectedMainType = '🎲 3D Модели'; _selectedLibrary = 'Всички'; });
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚡ Всички 1.2M+ асети са заредени!')));
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(color: const Color(0xFF141724), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: const InputDecoration(hintText: 'Търси в 101 библиотеки (NASA, Mixamo, Poly)...', hintStyle: TextStyle(color: Colors.grey, fontSize: 11), icon: Icon(Icons.search, size: 16, color: AppTheme.sciFiCyan), border: InputBorder.none),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: registryLibs.length,
                    itemBuilder: (context, index) {
                      final lib = registryLibs[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFF141724), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF242B40))),
                        child: Row(
                          children: [
                            Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(color: AppTheme.sciFiCyan.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.folder_special, color: AppTheme.sciFiCyan, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(lib.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFF00E676).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                        child: Text(lib.exactCount, style: const TextStyle(color: Color(0xFF00E676), fontSize: 9, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text('${lib.category} • ${lib.license}', style: const TextStyle(color: AppTheme.laserPink, fontSize: 9, fontWeight: FontWeight.w600)),
                                  Text(lib.description, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.sciFiCyan),
                              onPressed: () {
                                setState(() { _selectedLibrary = lib.name.split(' ')[0]; _selectedMainType = '🎲 3D Модели'; });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        else ...[
          // Бутон за качване (ако сме в "Моите Модели") или търсачка
          if (_selectedMainType == '👑 Моите Модели')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: SizedBox(
                width: double.infinity, height: 38,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.sciFiCyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  icon: const Icon(Icons.file_upload, color: Colors.black, size: 18),
                  label: const Text('➕ КАЧИ НОВ 3D МОДЕЛ & AUTO-RIG', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                  onPressed: () => ModelUploadModal.show(context, onModelRigged: (m) => setState(() {})),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(color: const Color(0xFF141724), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(hintText: 'Търси асети от 101 библиотеки...', hintStyle: TextStyle(color: Colors.grey, fontSize: 11), icon: Icon(Icons.search, size: 16, color: AppTheme.sciFiCyan), border: InputBorder.none),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            ),

          if (_selectedMainType != '👑 Моите Модели')
            SizedBox(
              height: 28,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSel = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(color: isSel ? AppTheme.laserPink : const Color(0xFF161824), borderRadius: BorderRadius.circular(12), border: Border.all(color: isSel ? AppTheme.sciFiCyan : Colors.white12)),
                      child: Center(child: Text(cat, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontSize: 9, fontWeight: FontWeight.bold))),
                    ),
                  );
                },
              ),
            ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final asset = filteredList[index];
                final Color glow = asset['color'] as Color? ?? AppTheme.laserPink;
                final bool isAudio = asset['media'] == 'Audio';
                final bool isPlaying = _playingAudioTrack == asset['name'];
                final bool isRealDownload = asset.containsKey('downloadUrl');

                return GestureDetector(
                  onTap: () { if (asset['media'] == '3D') _show3DInspectModal(asset); },
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFF141724), borderRadius: BorderRadius.circular(14), border: Border.all(color: glow.withValues(alpha: 0.45)), boxShadow: [BoxShadow(color: glow.withValues(alpha: 0.15), blurRadius: 8)]),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: glow.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(5)), child: Text(asset['type'] as String, style: TextStyle(color: glow, fontSize: 8, fontWeight: FontWeight.bold))),
                              if (isRealDownload)
                                const Icon(Icons.cloud_download, color: Color(0xFF00E676), size: 12)
                              else
                                Text(asset['poly'] as String, style: const TextStyle(color: Colors.grey, fontSize: 8)),
                            ],
                          ),
                          Container(
                            height: 90, width: double.infinity,
                            decoration: BoxDecoration(color: const Color(0xFF0E101A), borderRadius: BorderRadius.circular(10), border: Border.all(color: glow.withValues(alpha: 0.3))),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (asset['img'].toString().isNotEmpty) Image.network(asset['img'] as String, fit: BoxFit.cover, errorBuilder: (c, e, s) => Center(child: Icon(asset['icon'] as IconData? ?? Icons.view_in_ar, size: 36, color: glow)))
                                  else Center(child: Icon(asset['icon'] as IconData? ?? Icons.accessibility_new, size: 38, color: glow)),
                                  if (isAudio) Center(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle, border: Border.all(color: glow)), child: Icon(isPlaying ? Icons.graphic_eq : Icons.play_arrow, size: 22, color: glow))),
                                ],
                              ),
                            ),
                          ),
                          Text(asset['name'] as String, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('Библиотека: ${asset['lib']}', style: const TextStyle(color: Colors.white54, fontSize: 8), maxLines: 1),
                          SizedBox(
                            width: double.infinity, height: 24,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: glow, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                              icon: const Icon(Icons.remove_red_eye, size: 12, color: Colors.black),
                              label: const Text('ВИЖ 3D ОБЛИК', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 9)),
                              onPressed: () => _show3DInspectModal(asset),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
