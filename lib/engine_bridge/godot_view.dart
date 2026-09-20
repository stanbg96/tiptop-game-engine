import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GodotNativeView extends StatelessWidget {
  const GodotNativeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Този AndroidView извиква нашия Kotlin код (MainActivity.kt) 
    // и показва ИСТИНСКИЯ Godot 4 Engine директно във Flutter екрана!
    return const AndroidView(
      viewType: 'godot_native_view',
      creationParamsCodec: StandardMessageCodec(),
    );
  }
}
