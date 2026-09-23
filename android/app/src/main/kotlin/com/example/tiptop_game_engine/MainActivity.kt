package com.example.tiptop_game_engine

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("godot_native_view", GodotViewFactory())
    }
}

class GodotViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return object : PlatformView {
            private val frameLayout = FrameLayout(context).apply {
                setBackgroundColor(android.graphics.Color.BLACK)
            }
            override fun getView(): View = frameLayout
            override fun dispose() {}
        }
    }
}
