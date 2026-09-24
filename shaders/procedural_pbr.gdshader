shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// Режими на материала: 
// 0 = Автомобилна боя с Clearcoat
// 1 = Процедурен асфалт / бетон (без PNG текстура)
// 2 = Светеща процедурна кибер мрежа
// 3 = Автомобилно затъмнено стъкло
uniform int material_mode = 0;

uniform vec4 albedo_color : source_color = vec4(1.0, 0.0, 0.2, 1.0);
uniform float metallic_val : hint_range(0.0, 1.0) = 0.9;
uniform float roughness_val : hint_range(0.0, 1.0) = 0.15;
uniform float clearcoat_val : hint_range(0.0, 1.0) = 1.0;
uniform vec4 emission_color : source_color = vec4(0.0, 0.95, 1.0, 1.0);

varying vec3 v_world_pos;

// Псевдо-случайна математическа функция за GPU шум (0 MB текстура)
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// 2D Процедурен шум в реално време
float procedural_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f); // Hermite заглаждане
    
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void vertex() {
    // Вземаме абсолютната 3D позиция в света за безшевни текстури
    v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    if (material_mode == 0) {
        // === 0: CAR PAINT (Автомобилен лак) ===
        // Микро-блясък (Metallic Flakes) изчислен на пикселно ниво
        float flake = procedural_noise(v_world_pos.xz * 120.0) * 0.08;
        
        ALBEDO = albedo_color.rgb + vec3(flake);
        METALLIC = metallic_val;
        ROUGHNESS = roughness_val;
        
        // Втори огледален защитен слой лак (Clearcoat)
        CLEARCOAT = clearcoat_val;
        CLEARCOAT_ROUGHNESS = 0.03;
        
    } else if (material_mode == 1) {
        // === 1: АСФАЛТ / БЕТОН (100% математика, 0 MB снимки) ===
        // Мулти-октавен шум за неравности
        float n1 = procedural_noise(v_world_pos.xz * 8.0);
        float n2 = procedural_noise(v_world_pos.xz * 32.0);
        float asphalt_grain = mix(n1, n2, 0.5);
        
        ALBEDO = albedo_color.rgb * mix(0.7, 1.1, asphalt_grain);
        METALLIC = 0.05;
        ROUGHNESS = mix(0.75, 0.98, asphalt_grain);
        
        // Процедурна деформация на нормалите за микро-релеф на пътя
        vec3 grain_normal = vec3(
            (procedural_noise(v_world_pos.xz * 40.0 + vec2(0.1, 0.0)) - 0.5) * 0.25,
            1.0,
            (procedural_noise(v_world_pos.xz * 40.0 + vec2(0.0, 0.1)) - 0.5) * 0.25
        );
        NORMAL = normalize(mat3(TANGENT, BINORMAL, NORMAL) * grain_normal);
        
    } else if (material_mode == 2) {
        // === 2: КИБЕР МРЕЖА (Светещ неон) ===
        vec2 grid = abs(fract(v_world_pos.xz * 0.5) - 0.5);
        float line = step(0.46, max(grid.x, grid.y));
        
        ALBEDO = albedo_color.rgb;
        METALLIC = 0.8;
        ROUGHNESS = 0.2;
        EMISSION = emission_color.rgb * line * 4.0;
        
    } else if (material_mode == 3) {
        // === 3: СТЪКЛО С ФРЕНЕЛОВО ОТРАЖЕНИЕ ===
        ALBEDO = albedo_color.rgb;
        ALPHA = albedo_color.a;
        METALLIC = 0.1;
        ROUGHNESS = 0.04;
        
        // Френелов ефект: ръбовете отразяват повече светлина
        float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
        ROUGHNESS = mix(0.04, 0.2, fresnel);
    }
}
