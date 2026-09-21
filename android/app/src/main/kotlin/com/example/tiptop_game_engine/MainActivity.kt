package com.example.tiptop_game_engine

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugins.GeneratedPluginRegistrant
import org.godotengine.godot.GodotFragment

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        
        // Регистрираме моста между Flutter и Godot 4
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "godot_native_view", GodotViewFactory(this)
        )
    }
}

// Фабрика за генериране на Godot прозореца
class GodotViewFactory(private val activity: FlutterFragmentActivity) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        return GodotPlatformView(activity, context)
    }
}

// Самият Android View, който държи Godot 4 Енджина
class GodotPlatformView(private val activity: FlutterFragmentActivity, context: Context) : PlatformView {
    private val frameLayout: FrameLayout = FrameLayout(context)
    private var godotFragment: GodotFragment? = null

    init {
        // Генерираме уникално ID за прозореца
        frameLayout.id = View.generateViewId()
        
        // Създаваме инстанция на официалния Godot 4
        godotFragment = GodotFragment()
        
        // Вграждаме Godot директно вътре във Flutter екрана
        activity.supportFragmentManager.beginTransaction()
            .replace(frameLayout.id, godotFragment!!)
            .commit()
    }

    override fun getView(): View {
        return frameLayout
    }

    override fun dispose() {
        godotFragment?.let {
            activity.supportFragmentManager.beginTransaction().remove(it).commitAllowingStateLoss()
        }
    }
}
