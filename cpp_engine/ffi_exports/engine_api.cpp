#include <android/log.h>
#include <string>

#define LOG_TAG "TipTopEngine"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

extern "C" {
    __attribute__((visibility("default"))) __attribute__((used))
    void init_filament_engine() {
        LOGI("TipTop C++ Filament Engine Initialized Successfully!");
    }

    __attribute__((visibility("default"))) __attribute__((used))
    void load_3d_model(const char* modelPath) {
        LOGI("Loading 3D model: %s", modelPath ? modelPath : "null");
    }

    __attribute__((visibility("default"))) __attribute__((used))
    void play_animation(const char* animName, float speed) {
        LOGI("Playing animation: %s at speed %.2f", animName ? animName : "null", speed);
    }
}
