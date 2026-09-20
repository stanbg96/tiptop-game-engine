import 'dart:ffi';
import 'dart:io';

// ==========================================
// 1. FFI C-СТРУКТУРИ
// ==========================================

final class NativeTransform3D extends Struct {
  @Float()
  external double x;
  @Float()
  external double y;
  @Float()
  external double z;

  @Float()
  external double rotX;
  @Float()
  external double rotY;
  @Float()
  external double rotZ;

  @Float()
  external double scaleX;
  @Float()
  external double scaleY;
  @Float()
  external double scaleZ;
}

final class NativeBodyState2D extends Struct {
  @Float()
  external double x;
  @Float()
  external double y;
  @Float()
  external double vx;
  @Float()
  external double vy;
  @Bool()
  external bool isGrounded;
}

final class Utf8 extends Opaque {}

// ==========================================
// 2. FFI TYPEDEFS (NATIVE & DART)
// ==========================================

typedef NativeInitEngine = Void Function();
typedef DartInitEngine = void Function();

typedef NativeShutdownEngine = Void Function();
typedef DartShutdownEngine = void Function();

// 3D
typedef Native3DCreateWorld = Void Function(Float gravityY);
typedef Dart3DCreateWorld = void Function(double gravityY);

typedef Native3DAddBox = Int32 Function(Float x, Float y, Float z, Float sizeX, Float sizeY, Float sizeZ, Int32 bodyType);
typedef Dart3DAddBox = int Function(double x, double y, double z, double sizeX, double sizeY, double sizeZ, int bodyType);

typedef Native3DSetTransform = Void Function(Int32 bodyId, Float x, Float y, Float z, Float rotY);
typedef Dart3DSetTransform = void Function(int bodyId, double x, double y, double z, double rotY);

typedef Native3DGetTransform = NativeTransform3D Function(Int32 bodyId);
typedef Dart3DGetTransform = NativeTransform3D Function(int bodyId);

typedef Native3DStep = Void Function(Float deltaTime);
typedef Dart3DStep = void Function(double deltaTime);

typedef Native3DClearWorld = Void Function();
typedef Dart3DClearWorld = void Function();

// 2D
typedef Native2DCreateWorld = Void Function(Float gravityY);
typedef Dart2DCreateWorld = void Function(double gravityY);

typedef Native2DAddBox = Int32 Function(Float x, Float y, Float width, Float height, Int32 bodyType);
typedef Dart2DAddBox = int Function(double x, double y, double width, double height, int bodyType);

typedef Native2DApplyForce = Void Function(Int32 bodyId, Float fx, Float fy);
typedef Dart2DApplyForce = void Function(int bodyId, double fx, double fy);

typedef Native2DSetVelocity = Void Function(Int32 bodyId, Float vx, Float vy);
typedef Dart2DSetVelocity = void Function(int bodyId, double vx, double vy);

typedef Native2DGetState = NativeBodyState2D Function(Int32 bodyId);
typedef Dart2DGetState = NativeBodyState2D Function(int bodyId);

typedef Native2DStep = Void Function(Float deltaTime);
typedef Dart2DStep = void Function(double deltaTime);

typedef Native2DClearWorld = Void Function();
typedef Dart2DClearWorld = void Function();

// Audio & Animation
typedef NativePlayAnimation = Void Function(Pointer<Utf8> animationName, Float speed);
typedef DartPlayAnimation = void Function(Pointer<Utf8> animationName, double speed);

// ==========================================
// 3. ГЛАВЕН FILAMENT & C++ МОСТ
// ==========================================

class FilamentEngine {
  static final FilamentEngine _instance = FilamentEngine._internal();
  factory FilamentEngine() => _instance;

  DynamicLibrary? _nativeLib;
  bool _isLoaded = false;

  // 3D функции
  late DartInitEngine _initEngine;
  late DartShutdownEngine _shutdownEngine;
  late Dart3DCreateWorld _create3DWorld;
  late Dart3DAddBox _add3DBox;
  late Dart3DSetTransform _set3DTransform;
  late Dart3DGetTransform _get3DTransform;
  late Dart3DStep _step3D;
  late Dart3DClearWorld _clear3DWorld;

  // 2D функции
  late Dart2DCreateWorld _create2DWorld;
  late Dart2DAddBox _add2DBox;
  late Dart2DApplyForce _apply2DForce;
  late Dart2DSetVelocity _set2DVelocity;
  late Dart2DGetState _get2DState;
  late Dart2DStep _step2D;
  late Dart2DClearWorld _clear2DWorld;

  // Animation
  late DartPlayAnimation _playAnimation;

  FilamentEngine._internal() {
    _loadLibrary();
    _bindFunctions();
  }

  void _loadLibrary() {
    try {
      if (Platform.isAndroid) {
        _nativeLib = DynamicLibrary.open('libtiptop_game_engine.so');
        _isLoaded = true;
      } else if (Platform.isIOS || Platform.isMacOS) {
        _nativeLib = DynamicLibrary.process();
        _isLoaded = true;
      } else if (Platform.isLinux) {
        _nativeLib = DynamicLibrary.open('libtiptop_game_engine.so');
        _isLoaded = true;
      }
    } catch (_) {
      _isLoaded = false;
    }
  }

  void _bindFunctions() {
    if (!_isLoaded || _nativeLib == null) {
      return;
    }

    try {
      _initEngine = _nativeLib!.lookup<NativeFunction<NativeInitEngine>>('init_filament_engine').asFunction();
      _shutdownEngine = _nativeLib!.lookup<NativeFunction<NativeShutdownEngine>>('shutdown_filament_engine').asFunction();

      // 3D
      _create3DWorld = _nativeLib!.lookup<NativeFunction<Native3DCreateWorld>>('tiptop_3d_create_world').asFunction();
      _add3DBox = _nativeLib!.lookup<NativeFunction<Native3DAddBox>>('tiptop_3d_add_box').asFunction();
      _set3DTransform = _nativeLib!.lookup<NativeFunction<Native3DSetTransform>>('tiptop_3d_set_transform').asFunction();
      _get3DTransform = _nativeLib!.lookup<NativeFunction<Native3DGetTransform>>('tiptop_3d_get_transform').asFunction();
      _step3D = _nativeLib!.lookup<NativeFunction<Native3DStep>>('tiptop_3d_step').asFunction();
      _clear3DWorld = _nativeLib!.lookup<NativeFunction<Native3DClearWorld>>('tiptop_3d_clear_world').asFunction();

      // 2D
      _create2DWorld = _nativeLib!.lookup<NativeFunction<Native2DCreateWorld>>('tiptop_2d_create_world').asFunction();
      _add2DBox = _nativeLib!.lookup<NativeFunction<Native2DAddBox>>('tiptop_2d_add_box').asFunction();
      _apply2DForce = _nativeLib!.lookup<NativeFunction<Native2DApplyForce>>('tiptop_2d_apply_force').asFunction();
      _set2DVelocity = _nativeLib!.lookup<NativeFunction<Native2DSetVelocity>>('tiptop_2d_set_velocity').asFunction();
      _get2DState = _nativeLib!.lookup<NativeFunction<Native2DGetState>>('tiptop_2d_get_state').asFunction();
      _step2D = _nativeLib!.lookup<NativeFunction<Native2DStep>>('tiptop_2d_step').asFunction();
      _clear2DWorld = _nativeLib!.lookup<NativeFunction<Native2DClearWorld>>('tiptop_2d_clear_world').asFunction();

      // Anim
      _playAnimation = _nativeLib!.lookup<NativeFunction<NativePlayAnimation>>('tiptop_play_animation').asFunction();

      _initEngine();
    } catch (_) {
      _isLoaded = false;
    }
  }

  // ==========================================
  // PUBLIC DART API МЕТОДИ
  // ==========================================

  bool get isNativeReady => _isLoaded;

  void initEngine() {
    if (_isLoaded) _initEngine();
  }

  void shutdown() {
    if (_isLoaded) _shutdownEngine();
  }

  // 3D
  void create3DWorld({double gravityY = -9.81}) {
    if (_isLoaded) _create3DWorld(gravityY);
  }

  int add3DBox(double x, double y, double z, double sizeX, double sizeY, double sizeZ, int bodyType) {
    if (_isLoaded) return _add3DBox(x, y, z, sizeX, sizeY, sizeZ, bodyType);
    return -1;
  }

  void set3DTransform(int bodyId, double x, double y, double z, double rotY) {
    if (_isLoaded) _set3DTransform(bodyId, x, y, z, rotY);
  }

  NativeTransform3D? get3DTransform(int bodyId) {
    if (_isLoaded) return _get3DTransform(bodyId);
    return null;
  }

  void step3D(double dt) {
    if (_isLoaded) _step3D(dt);
  }

  void clear3DWorld() {
    if (_isLoaded) _clear3DWorld();
  }

  // 2D
  void create2DWorld({double gravityY = 9.81}) {
    if (_isLoaded) _create2DWorld(gravityY);
  }

  int add2DBox(double x, double y, double width, double height, int bodyType) {
    if (_isLoaded) return _add2DBox(x, y, width, height, bodyType);
    return -1;
  }

  void apply2DForce(int bodyId, double fx, double fy) {
    if (_isLoaded) _apply2DForce(bodyId, fx, fy);
  }

  void set2DVelocity(int bodyId, double vx, double vy) {
    if (_isLoaded) _set2DVelocity(bodyId, vx, vy);
  }

  NativeBodyState2D? get2DState(int bodyId) {
    if (_isLoaded) return _get2DState(bodyId);
    return null;
  }

  void step2D(double dt) {
    if (_isLoaded) _step2D(dt);
  }

  void clear2DWorld() {
    if (_isLoaded) _clear2DWorld();
  }

  // Анимации и Аудио
  void applyAnimation(String animName, double speed) {
    if (_isLoaded) {
      _playAnimation(nullptr, speed);
    }
  }
}
