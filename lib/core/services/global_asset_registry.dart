import 'package:tiptop_game_engine/core/services/registry_data_part1.dart';
import 'package:tiptop_game_engine/core/services/registry_data_part2.dart';

export 'package:tiptop_game_engine/core/services/registry_data_part1.dart' show AssetLibraryInfo;

class GlobalAssetRegistryService {
  static final GlobalAssetRegistryService _instance = GlobalAssetRegistryService._internal();
  factory GlobalAssetRegistryService() => _instance;
  GlobalAssetRegistryService._internal() {
    _init101Libraries();
  }

  final List<AssetLibraryInfo> _libraries = [];

  List<AssetLibraryInfo> get libraries => List.unmodifiable(_libraries);

  int get totalTrackedAssets => _libraries.fold(0, (sum, lib) => sum + lib.countNumber);

  List<String> get categories => [
    'Всички (101)',
    '🎲 3D Модели & Светове',
    '🎨 2D Спрайтове & Плочки',
    '🌋 PBR Текстури & HDRIs',
    '🔊 Аудио, Музика & SFX',
    '🏃 Анимации & MoCap',
    '⚡ Шейдъри & VFX',
    '📱 UI, HUD & Шрифтове',
    '🏛️ Музеи & Наследство',
    '🗺️ Реални Терени & Карти',
  ];

  void _init101Libraries() {
    if (_libraries.isNotEmpty) return;
    _libraries.addAll(getRegistryPart1());
    _libraries.addAll(getRegistryPart2());
  }

  // Търсене с филтри по категория, име, описание и тагове
  List<AssetLibraryInfo> search({String query = '', String category = 'Всички (101)'}) {
    return _libraries.where((lib) {
      final matchesCategory = category == 'Всички (101)' || lib.category == category;
      final q = query.toLowerCase().trim();
      final matchesQuery = q.isEmpty ||
          lib.name.toLowerCase().contains(q) ||
          lib.description.toLowerCase().contains(q) ||
          lib.tags.any((t) => t.toLowerCase().contains(q));
      return matchesCategory && matchesQuery;
    }).toList();
  }

  AssetLibraryInfo? findById(String id) {
    try {
      return _libraries.firstWhere((lib) => lib.id == id);
    } catch (_) {
      return null;
    }
  }
}
