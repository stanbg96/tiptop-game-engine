#ifndef TIPTOP_ENGINE_H
#define TIPTOP_ENGINE_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// ==========================================
// 1. СТРУКТУРИ ЗА ДАННИ (2D & 3D)
// ==========================================

typedef struct {
    float x;
    float y;
    float z;
    float rotX;
    float rotY;
    float rotZ;
    float scaleX;
    float scaleY;
    float scaleZ;
} Transform3D;

typedef struct {
    float x;
    float y;
    float vx;
    float vy;
    bool isGrounded;
} BodyState2D;

typedef enum {
    BODY_TYPE_STATIC = 0,    // Неподвижен терен / платформа
    BODY_TYPE_DYNAMIC = 1,   // Пада с гравитация, движи се
    BODY_TYPE_TRIGGER = 2    // Зона без колизия (монета, портал, лава)
} PhysicsBodyType;

// ==========================================
// 2. ИНИЦИАЛИЗАЦИЯ И ЖИЗНЕН ЦИКЪЛ
// ==========================================

void init_filament_engine(void);
void shutdown_filament_engine(void);

// ==========================================
// 3. 3D СВЯТ & JOLT СТИЛ ФИЗИКА
// ==========================================

void tiptop_3d_create_world(float gravityY);
int32_t tiptop_3d_add_box(float x, float y, float z, float sizeX, float sizeY, float sizeZ, int32_t bodyType);
void tiptop_3d_set_transform(int32_t bodyId, float x, float y, float z, float rotY);
Transform3D tiptop_3d_get_transform(int32_t bodyId);
void tiptop_3d_step(float deltaTime);
void tiptop_3d_clear_world(void);

// ==========================================
// 4. 2D СВЯТ & BOX2D СТИЛ ПЛАТФОРМИНГ
// ==========================================

void tiptop_2d_create_world(float gravityY);
int32_t tiptop_2d_add_box(float x, float y, float width, float height, int32_t bodyType);
void tiptop_2d_apply_force(int32_t bodyId, float fx, float fy);
void tiptop_2d_set_velocity(int32_t bodyId, float vx, float vy);
BodyState2D tiptop_2d_get_state(int32_t bodyId);
void tiptop_2d_step(float deltaTime);
void tiptop_2d_clear_world(void);

// ==========================================
// 5. АУДИО & АНИМАЦИИ МОСТ
// ==========================================

void tiptop_play_sound(const char* soundName, float volume);
void tiptop_play_animation(const char* animName, float speed);

#ifdef __cplusplus
}
#endif

#endif // TIPTOP_ENGINE_H
