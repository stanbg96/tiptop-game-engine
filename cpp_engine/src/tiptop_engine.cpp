#include "tiptop_engine.h"
#include <vector>
#include <unordered_map>
#include <cmath>
#include <iostream>
#include <algorithm>

// =========================================================================
// ВЪТРЕШНИ C++ СТРУКТУРИ ЗА 2D И 3D ФИЗИЧНИ ТЕЛА
// =========================================================================

struct InternalBody2D {
    int32_t id;
    float x;
    float y;
    float width;
    float height;
    float vx;
    float vy;
    PhysicsBodyType type;
    bool isGrounded;
};

struct InternalBody3D {
    int32_t id;
    float x;
    float y;
    float z;
    float sizeX;
    float sizeY;
    float sizeZ;
    float rotX;
    float rotY;
    float rotZ;
    float vx;
    float vy;
    float vz;
    PhysicsBodyType type;
    bool isGrounded;
};

// =========================================================================
// ГЛОБАЛНО СЪСТОЯНИЕ НА ЕНДЖИНА
// =========================================================================

static bool g_isEngineInitialized = false;

// 2D Свят
static float g_gravity2D = 9.81f;
static int32_t g_nextBodyId2D = 1;
static std::unordered_map<int32_t, InternalBody2D> g_bodies2D;

// 3D Свят
static float g_gravity3D = -9.81f;
static int32_t g_nextBodyId3D = 1;
static std::unordered_map<int32_t, InternalBody3D> g_bodies3D;

// =========================================================================
// 1. ИНИЦИАЛИЗАЦИЯ И ЖИЗНЕН ЦИКЪЛ
// =========================================================================

extern "C" {

void init_filament_engine(void) {
    if (!g_isEngineInitialized) {
        g_isEngineInitialized = true;
        std::cout << "[TipTop C++ Engine] Filament & Physics Engine Initialized Successfully." << std::endl;
    }
}

void shutdown_filament_engine(void) {
    tiptop_2d_clear_world();
    tiptop_3d_clear_world();
    g_isEngineInitialized = false;
    std::cout << "[TipTop C++ Engine] Engine Shutdown." << std::endl;
}

// =========================================================================
// 2. 3D СВЯТ & СИМУЛАЦИЯ
// =========================================================================

void tiptop_3d_create_world(float gravityY) {
    tiptop_3d_clear_world();
    g_gravity3D = gravityY;
    std::cout << "[TipTop 3D] World created with gravity: " << gravityY << std::endl;
}

int32_t tiptop_3d_add_box(float x, float y, float z, float sizeX, float sizeY, float sizeZ, int32_t bodyType) {
    int32_t id = g_nextBodyId3D++;
    InternalBody3D body;
    body.id = id;
    body.x = x;
    body.y = y;
    body.z = z;
    body.sizeX = sizeX;
    body.sizeY = sizeY;
    body.sizeZ = sizeZ;
    body.rotX = 0.0f;
    body.rotY = 0.0f;
    body.rotZ = 0.0f;
    body.vx = 0.0f;
    body.vy = 0.0f;
    body.vz = 0.0f;
    body.type = static_cast<PhysicsBodyType>(bodyType);
    body.isGrounded = false;

    g_bodies3D[id] = body;
    return id;
}

void tiptop_3d_set_transform(int32_t bodyId, float x, float y, float z, float rotY) {
    auto it = g_bodies3D.find(bodyId);
    if (it != g_bodies3D.end()) {
        it->second.x = x;
        it->second.y = y;
        it->second.z = z;
        it->second.rotY = rotY;
    }
}

Transform3D tiptop_3d_get_transform(int32_t bodyId) {
    Transform3D t = {0, 0, 0, 0, 0, 0, 1.0f, 1.0f, 1.0f};
    auto it = g_bodies3D.find(bodyId);
    if (it != g_bodies3D.end()) {
        t.x = it->second.x;
        t.y = it->second.y;
        t.z = it->second.z;
        t.rotX = it->second.rotX;
        t.rotY = it->second.rotY;
        t.rotZ = it->second.rotZ;
        t.scaleX = it->second.sizeX;
        t.scaleY = it->second.sizeY;
        t.scaleZ = it->second.sizeZ;
    }
    return t;
}

void tiptop_3d_step(float deltaTime) {
    if (deltaTime <= 0.0f) deltaTime = 0.016f;

    for (auto& pair : g_bodies3D) {
        InternalBody3D& b = pair.second;
        if (b.type != BODY_TYPE_DYNAMIC) continue;

        // Гравитация
        b.vy += g_gravity3D * deltaTime;

        // Интеграция на скоростта
        b.x += b.vx * deltaTime;
        b.y += b.vy * deltaTime;
        b.z += b.vz * deltaTime;

        // Проверка с плосък под при Y = 60.0 (Лава / Земя)
        if (b.y >= 50.0f) {
            b.y = 50.0f;
            b.vy = 0.0f;
            b.isGrounded = true;
        } else {
            b.isGrounded = false;
        }
    }
}

void tiptop_3d_clear_world(void) {
    g_bodies3D.clear();
    g_nextBodyId3D = 1;
}

// =========================================================================
// 3. 2D СВЯТ & СИМУЛАЦИЯ
// =========================================================================

void tiptop_2d_create_world(float gravityY) {
    tiptop_2d_clear_world();
    g_gravity2D = gravityY;
    std::cout << "[TipTop 2D] World created with gravity: " << gravityY << std::endl;
}

int32_t tiptop_2d_add_box(float x, float y, float width, float height, int32_t bodyType) {
    int32_t id = g_nextBodyId2D++;
    InternalBody2D body;
    body.id = id;
    body.x = x;
    body.y = y;
    body.width = width;
    body.height = height;
    body.vx = 0.0f;
    body.vy = 0.0f;
    body.type = static_cast<PhysicsBodyType>(bodyType);
    body.isGrounded = false;

    g_bodies2D[id] = body;
    return id;
}

void tiptop_2d_apply_force(int32_t bodyId, float fx, float fy) {
    auto it = g_bodies2D.find(bodyId);
    if (it != g_bodies2D.end() && it->second.type == BODY_TYPE_DYNAMIC) {
        it->second.vx += fx;
        it->second.vy += fy;
    }
}

void tiptop_2d_set_velocity(int32_t bodyId, float vx, float vy) {
    auto it = g_bodies2D.find(bodyId);
    if (it != g_bodies2D.end()) {
        it->second.vx = vx;
        it->second.vy = vy;
    }
}

BodyState2D tiptop_2d_get_state(int32_t bodyId) {
    BodyState2D state = {0.0f, 0.0f, 0.0f, 0.0f, false};
    auto it = g_bodies2D.find(bodyId);
    if (it != g_bodies2D.end()) {
        state.x = it->second.x;
        state.y = it->second.y;
        state.vx = it->second.vx;
        state.vy = it->second.vy;
        state.isGrounded = it->second.isGrounded;
    }
    return state;
}

void tiptop_2d_step(float deltaTime) {
    if (deltaTime <= 0.0f) deltaTime = 0.016f;
    const float friction = 0.85f;

    for (auto& pair : g_bodies2D) {
        InternalBody2D& dynamicBody = pair.second;
        if (dynamicBody.type != BODY_TYPE_DYNAMIC) continue;

        // Гравитация и триене
        dynamicBody.vy += g_gravity2D * deltaTime * 50.0f;
        dynamicBody.vx *= friction;

        float nextX = dynamicBody.x + dynamicBody.vx;
        float nextY = dynamicBody.y + dynamicBody.vy;
        dynamicBody.isGrounded = false;

        // AABB Колизии с всички Static тела
        for (const auto& staticPair : g_bodies2D) {
            const InternalBody2D& staticBody = staticPair.second;
            if (staticBody.type != BODY_TYPE_STATIC) continue;

            bool overlapX = (nextX + dynamicBody.width / 2.0f > staticBody.x - staticBody.width / 2.0f) &&
                            (nextX - dynamicBody.width / 2.0f < staticBody.x + staticBody.width / 2.0f);
            bool overlapY = (nextY + dynamicBody.height / 2.0f > staticBody.y - staticBody.height / 2.0f) &&
                            (nextY - dynamicBody.height / 2.0f < staticBody.y + staticBody.height / 2.0f);

            if (overlapX && overlapY) {
                // Приземяване отгоре
                if (dynamicBody.vy > 0.0f && (dynamicBody.y + dynamicBody.height / 2.0f <= staticBody.y - staticBody.height / 2.0f + 10.0f)) {
                    nextY = (staticBody.y - staticBody.height / 2.0f) - dynamicBody.height / 2.0f;
                    dynamicBody.vy = 0.0f;
                    dynamicBody.isGrounded = true;
                }
                // Удар в таван
                else if (dynamicBody.vy < 0.0f && (dynamicBody.y - dynamicBody.height / 2.0f >= staticBody.y + staticBody.height / 2.0f - 10.0f)) {
                    nextY = (staticBody.y + staticBody.height / 2.0f) + dynamicBody.height / 2.0f;
                    dynamicBody.vy = 0.0f;
                }
                // Странични стени
                else if (dynamicBody.vx > 0.0f) {
                    nextX = (staticBody.x - staticBody.width / 2.0f) - dynamicBody.width / 2.0f;
                    dynamicBody.vx = 0.0f;
                } else if (dynamicBody.vx < 0.0f) {
                    nextX = (staticBody.x + staticBody.width / 2.0f) + dynamicBody.width / 2.0f;
                    dynamicBody.vx = 0.0f;
                }
            }
        }

        dynamicBody.x = nextX;
        dynamicBody.y = nextY;
    }
}

void tiptop_2d_clear_world(void) {
    g_bodies2D.clear();
    g_nextBodyId2D = 1;
}

// =========================================================================
// 4. АУДИО & АНИМАЦИОННИ СЪОБЩЕНИЯ
// =========================================================================

void tiptop_play_sound(const char* soundName, float volume) {
    if (soundName) {
        std::cout << "[TipTop Audio Engine] Playing SFX: " << soundName << " at volume: " << volume << std::endl;
    }
}

void tiptop_play_animation(const char* animName, float speed) {
    if (animName) {
        std::cout << "[TipTop Animation] Playing Skeletal Anim: " << animName << " at speed: " << speed << "x" << std::endl;
    }
}

} // extern "C"
