import 'dart:ffi';
import 'dart:io';

final class Utf8 extends Opaque {}

typedef NativeInitEngine = Void Function();
typedef NativeLoadModel = Void Function(Pointer<Utf8> modelPath);
typedef NativePlayAnimation = Void Function(Pointer<Utf8> animationName, Float speed);

typedef DartInitEngine = void Function();
typedef DartLoadModel = void Function(Pointer<Utf8> modelPath);
typedef DartPlayAnimation = void Function(Pointer<Utf8> animationName, double speed);

class FilamentEngine {
  static final FilamentEngine _instance = FilamentEngine._internal();
  factory FilamentEngine() => _instance;

  late DynamicLibrary _nativeLib;
  late DartInitEngine initEngine;
  
  FilamentEngine._internal() {
    _loadLibrary();
    _bindFunctions();
  }

  void _loadLibrary() {
    if (Platform.isAndroid) {
      _nativeLib = DynamicLibrary.open('libtiptop_game_engine.so');
    } else if (Platform.isIOS) {
      _nativeLib = DynamicLibrary.process();
    } else {
      throw UnsupportedError('Platform not supported for TipTop Filament engine yet.');
    }
  }

  void _bindFunctions() {
    initEngine = _nativeLib
        .lookup<NativeFunction<NativeInitEngine>>('init_filament_engine')
        .asFunction();
        
    print("TipTop C++ Filament Bridge is ready!");
  }

  void applyAnimation(String animName, double speed) {
    print("Sending command to C++: Animate with \$animName at speed \$speed");
  }
}
