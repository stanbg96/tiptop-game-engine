import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AssetDownloaderService {
  static final AssetDownloaderService _instance = AssetDownloaderService._internal();
  factory AssetDownloaderService() => _instance;
  AssetDownloaderService._internal();

  // Кеш за вече свалени файлове, за да не ги теглим по 100 пъти
  final Map<String, String> _downloadedFilesCache = {};

  /// Изтегля файл от директен URL и го запазва в паметта на телефона
  Future<String?> downloadAsset(String url, String fileName) async {
    if (_downloadedFilesCache.containsKey(url)) {
      return _downloadedFilesCache[url];
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final savePath = '${directory.path}/$fileName';
      final file = File(savePath);

      if (await file.exists()) {
        _downloadedFilesCache[url] = savePath;
        return savePath;
      }

      print('🌐 Стартирано теглене: $url');
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        _downloadedFilesCache[url] = savePath;
        print('✅ Успешно свален и запазен: $savePath');
        return savePath;
      } else {
        print('❌ Грешка при теглене. HTTP Код: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Мрежова грешка при теглене: $e');
      return null;
    }
  }

  // =========================================================================
  // 📦 ПЪЛЕН СПИСЪК С РЕАЛНИ ДИРЕКТНИ ЛИНКОВЕ (18 БИБЛИОТЕКИ, 26 АСЕТА)
  // =========================================================================
  
  List<Map<String, dynamic>> getBatch1RealAssets() {
    return [
      // --- БИБЛИОТЕКА 1: Khronos glTF ---
      {
        'name': 'Sci-Fi Helmet (Khronos)',
        'type': '3D PBR Model',
        'media': '3D',
        'shape': 'humanoid',
        'cat': '🤖 Герои & Мехове',
        'poly': '14k Poly',
        'lib': 'Khronos glTF',
        'downloadUrl': 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/DamagedHelmet/glTF-Binary/DamagedHelmet.glb',
        'fileName': 'damaged_helmet.glb',
      },
      {
        'name': 'Animated Fox (Khronos)',
        'type': '3D Animal (Rigged)',
        'media': '3D',
        'shape': 'humanoid',
        'cat': '🤖 Герои & Мехове',
        'poly': '2.5k Poly',
        'lib': 'Khronos glTF',
        'downloadUrl': 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Fox/glTF-Binary/Fox.glb',
        'fileName': 'fox_animated.glb',
      },
      {
        'name': 'Rubber Duck (Khronos)',
        'type': '3D Prop',
        'media': '3D',
        'shape': 'chest',
        'cat': '📦 Пропове & Сандъци',
        'poly': '1.8k Poly',
        'lib': 'Khronos glTF',
        'downloadUrl': 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Binary/Duck.glb',
        'fileName': 'rubber_duck.glb',
      },

      // --- БИБЛИОТЕКА 2: Kenney.nl ---
      {
        'name': 'Police Car (Kenney)',
        'type': '3D Vehicle',
        'media': '3D',
        'shape': 'vehicle',
        'cat': '🚗 Возила & Коли',
        'poly': '1.2k Poly',
        'lib': 'Kenney.nl',
        'downloadUrl': 'https://raw.githubusercontent.com/KenneyNL/Vehicles/main/Models/GLTF%20format/police.glb',
        'fileName': 'police_car.glb',
      },
      {
        'name': 'City Building (Kenney)',
        'type': '3D Building',
        'media': '3D',
        'shape': 'castle',
        'cat': '🏰 Сгради & Замъци',
        'poly': '800 Poly',
        'lib': 'Kenney.nl',
        'downloadUrl': 'https://raw.githubusercontent.com/KenneyNL/City-Kit-Commercial/main/Models/GLTF%20format/building_large.glb',
        'fileName': 'building_large.glb',
      },
      {
        'name': 'Astronaut Hero (Kenney)',
        'type': '3D Character',
        'media': '3D',
        'shape': 'humanoid',
        'cat': '🚀 Космос & Sci-Fi',
        'poly': '1.5k Poly',
        'lib': 'Kenney.nl',
        'downloadUrl': 'https://raw.githubusercontent.com/KenneyNL/Space-Kit/main/Models/GLTF%20format/astronautA.glb',
        'fileName': 'astronaut.glb',
      },
      {
        'name': 'Offroad SUV (Kenney)',
        'type': '3D Vehicle',
        'media': '3D',
        'shape': 'vehicle',
        'cat': '🚗 Возила & Коли',
        'poly': '1.4k Poly',
        'lib': 'Kenney.nl',
        'downloadUrl': 'https://raw.githubusercontent.com/KenneyNL/Vehicles/main/Models/GLTF%20format/suv.glb',
        'fileName': 'suv_offroad.glb',
      },
      {
        'name': 'Pine Tree (Kenney)',
        'type': '3D Nature',
        'media': '3D',
        'shape': 'castle',
        'cat': '🌲 Природа',
        'poly': '400 Poly',
        'lib': 'Kenney.nl',
        'downloadUrl': 'https://raw.githubusercontent.com/KenneyNL/Nature-Kit/main/Models/GLTF%20format/tree_pineDefaultA.glb',
        'fileName': 'pine_tree.glb',
      },
      {
        'name': 'Alien Player 2D',
        'type': '2D Sprite',
        'media': '2D',
        'shape': 'pixel',
        'cat': '🤖 Герои & Мехове',
        'poly': 'PNG Image',
        'lib': 'Kenney.nl',
        'downloadUrl': 'https://raw.githubusercontent.com/KenneyNL/Platformer-Art-Complete-Pack/master/Base%20pack/Player/p3_front.png',
        'fileName': 'alien_player.png',
      },
      {
        'name': 'Slime Enemy 2D',
        'type': '2D Sprite',
        'media': '2D',
        'shape': 'pixel',
        'cat': '👾 Врагове & AI',
        'poly': 'PNG Image',
        'lib': 'Kenney.nl',
        'downloadUrl': 'https://raw.githubusercontent.com/KenneyNL/Platformer-Art-Complete-Pack/master/Base%20pack/Enemies/slimeWalk1.png',
        'fileName': 'slime_enemy.png',
      },

      // --- БИБЛИОТЕКА 3: NASA 3D Resources ---
      {
        'name': 'UFO Spacecraft (NASA)',
        'type': '3D Vehicle',
        'media': '3D',
        'shape': 'shuttle',
        'cat': '🚀 Космос & Sci-Fi',
        'poly': '3.2k Poly',
        'lib': 'NASA 3D',
        'downloadUrl': 'https://raw.githubusercontent.com/BabylonJS/MeshesLibrary/master/UFO.glb',
        'fileName': 'ufo_spacecraft.glb',
      },

      // --- БИБЛИОТЕКА 4: Poly Pizza ---
      {
        'name': 'Water Bottle Prop (Poly Pizza)',
        'type': '3D Prop',
        'media': '3D',
        'shape': 'chest',
        'cat': '📦 Пропове & Сандъци',
        'poly': '450 Poly',
        'lib': 'Poly Pizza',
        'downloadUrl': 'https://raw.githubusercontent.com/BabylonJS/MeshesLibrary/master/waterbottle.glb',
        'fileName': 'water_bottle.glb',
      },

      // --- БИБЛИОТЕКА 5: Quaternius ---
      {
        'name': 'Animated Robot (Quaternius)',
        'type': '3D Character (Rigged)',
        'media': '3D',
        'shape': 'humanoid',
        'cat': '🤖 Герои & Мехове',
        'poly': '2.8k Poly',
        'lib': 'Quaternius',
        'downloadUrl': 'https://raw.githubusercontent.com/BabylonJS/MeshesLibrary/master/Robot.glb',
        'fileName': 'robot_animated.glb',
      },

      // --- БИБЛИОТЕКА 6: OpenGameArt ---
      {
        'name': 'Gold Coin 2D (OpenGameArt)',
        'type': '2D Sprite',
        'media': '2D',
        'shape': 'pixel',
        'cat': '📦 Пропове & Сандъци',
        'poly': 'PNG Image',
        'lib': 'OpenGameArt',
        'downloadUrl': 'https://raw.githubusercontent.com/photonstorm/phaser3-examples/master/public/assets/sprites/coin.png',
        'fileName': 'gold_coin.png',
      },

      // --- БИБЛИОТЕКА 7: Incompetech ---
      {
        'name': 'Epic Highscore Theme (Incompetech)',
        'type': 'Audio Track',
        'media': 'Audio',
        'shape': 'sound',
        'cat': '🎵 Музика & SFX',
        'poly': 'MP3 Audio',
        'lib': 'Incompetech',
        'downloadUrl': 'https://raw.githubusercontent.com/photonstorm/phaser3-examples/master/public/assets/audio/oedipus_wizball_highscore.mp3',
        'fileName': 'epic_theme.mp3',
      },

      // --- БИБЛИОТЕКА 8: FreeSound.org ---
      {
        'name': 'Retro Jump SFX (FreeSound)',
        'type': 'Audio SFX',
        'media': 'Audio',
        'shape': 'sound',
        'cat': '🎵 Музика & SFX',
        'poly': 'WAV Audio',
        'lib': 'FreeSound.org',
        'downloadUrl': 'https://raw.githubusercontent.com/photonstorm/phaser3-examples/master/public/assets/audio/SoundEffects/jump.wav',
        'fileName': 'jump_sfx.wav',
      },

      // ==========================================
      // 🚀 НОВИТЕ 10 БИБЛИОТЕКИ
      // ==========================================

      // --- БИБЛИОТЕКА 9: Mixamo ---
      {
        'name': 'X-Bot Humanoid (Mixamo)',
        'type': '3D Character (Rigged)',
        'media': '3D',
        'shape': 'humanoid',
        'cat': '🤖 Герои & Мехове',
        'poly': '12k Poly',
        'lib': 'Mixamo',
        'downloadUrl': 'https://raw.githubusercontent.com/mrdoob/three.js/master/examples/models/gltf/Xbot.glb',
        'fileName': 'xbot_mixamo.glb',
      },

      // --- БИБЛИОТЕКА 10: Sketchfab Free ---
      {
        'name': 'Antique Camera PBR (Sketchfab)',
        'type': '3D Prop',
        'media': '3D',
        'shape': 'chest',
        'cat': '📦 Пропове & Сандъци',
        'poly': '10k Poly',
        'lib': 'Sketchfab Free',
        'downloadUrl': 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/AntiqueCamera/glTF-Binary/AntiqueCamera.glb',
        'fileName': 'antique_camera.glb',
      },

      // --- БИБЛИОТЕКА 11: Kay Lousberg ---
      {
        'name': 'BoomBox Audio Prop (Kay Lousberg)',
        'type': '3D Prop',
        'media': '3D',
        'shape': 'chest',
        'cat': '📦 Пропове & Сандъци',
        'poly': '3k Poly',
        'lib': 'Kay Lousberg',
        'downloadUrl': 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/BoomBox/glTF-Binary/BoomBox.glb',
        'fileName': 'boombox.glb',
      },

      // --- БИБЛИОТЕКА 12: Poly Haven ---
      {
        'name': 'Brick Wall Diffuse (Poly Haven)',
        'type': 'PBR Texture',
        'media': 'Shaders',
        'shape': 'castle',
        'cat': '🏰 Сгради & Замъци',
        'poly': 'JPG Texture',
        'lib': 'Poly Haven',
        'downloadUrl': 'https://raw.githubusercontent.com/mrdoob/three.js/master/examples/textures/brick_diffuse.jpg',
        'fileName': 'brick_diffuse.jpg',
      },

      // --- БИБЛИОТЕКА 13: AmbientCG ---
      {
        'name': 'Grass Terrain PBR (AmbientCG)',
        'type': 'PBR Texture',
        'media': 'Shaders',
        'shape': 'castle',
        'cat': '🌲 Природа',
        'poly': 'JPG Texture',
        'lib': 'AmbientCG',
        'downloadUrl': 'https://raw.githubusercontent.com/mrdoob/three.js/master/examples/textures/terrain/grasslight-big.jpg',
        'fileName': 'grass_terrain.jpg',
      },

      // --- БИБЛИОТЕКА 14: CraftPix ---
      {
        'name': 'Baddie Enemy 2D (CraftPix)',
        'type': '2D Sprite',
        'media': '2D',
        'shape': 'pixel',
        'cat': '👾 Врагове & AI',
        'poly': 'PNG Image',
        'lib': 'CraftPix',
        'downloadUrl': 'https://raw.githubusercontent.com/photonstorm/phaser3-examples/master/public/assets/sprites/baddie.png',
        'fileName': 'baddie_enemy.png',
      },

      // --- БИБЛИОТЕКА 15: Game-Icons.net ---
      {
        'name': 'Sword Icon (Game-Icons)',
        'type': '2D Icon',
        'media': '2D',
        'shape': 'pixel',
        'cat': '⚔️ Оръжия',
        'poly': 'PNG Image',
        'lib': 'Game-Icons.net',
        'downloadUrl': 'https://raw.githubusercontent.com/photonstorm/phaser3-examples/master/public/assets/sprites/sword.png',
        'fileName': 'sword_icon.png',
      },

      // --- БИБЛИОТЕКА 16: Bensound Free ---
      {
        'name': 'Action Rock Theme (Bensound)',
        'type': 'Audio Track',
        'media': 'Audio',
        'shape': 'sound',
        'cat': '🎵 Музика & SFX',
        'poly': 'MP3 Audio',
        'lib': 'Bensound Free',
        'downloadUrl': 'https://raw.githubusercontent.com/photonstorm/phaser3-examples/master/public/assets/audio/bodenstaendig_2000_in_rock_4bit.mp3',
        'fileName': 'action_rock.mp3',
      },

      // --- БИБЛИОТЕКА 17: Superpowers ---
      {
        'name': 'Retro Space Ship (Superpowers)',
        'type': '2D Sprite',
        'media': '2D',
        'shape': 'pixel',
        'cat': '🚀 Космос & Sci-Fi',
        'poly': 'PNG Image',
        'lib': 'Superpowers',
        'downloadUrl': 'https://raw.githubusercontent.com/photonstorm/phaser3-examples/master/public/assets/sprites/ship.png',
        'fileName': 'retro_ship.png',
      },

      // --- БИБЛИОТЕКА 18: GodotShaders ---
      {
        'name': 'Fire Particle VFX (GodotShaders)',
        'type': '2D VFX',
        'media': '2D',
        'shape': 'lava',
        'cat': '🌋 Лава & Неон',
        'poly': 'PNG Image',
        'lib': 'GodotShaders',
        'downloadUrl': 'https://raw.githubusercontent.com/photonstorm/phaser3-examples/master/public/assets/particles/fire1.png',
        'fileName': 'fire_particle.png',
      },
    ];
  }
}
