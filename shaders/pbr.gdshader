shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform vec4 albedo_color : source_color = vec4(1.0, 0.0, 0.25, 1.0);
uniform float metallic_val : hint_range(0.0, 1.0) = 0.95;
uniform float roughness_val : hint_range(0.0, 1.0) = 0.12;
uniform float clearcoat_val : hint_range(0.0, 1.0) = 1.0;
uniform vec4 emission_color : source_color = vec4(0.0);

varying vec3 v_world_pos;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void vertex() {
    v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    float flake = (hash(v_world_pos.xz * 60.0) - 0.5) * 0.08;
    ALBEDO = albedo_color.rgb + vec3(flake);
    METALLIC = metallic_val;
    ROUGHNESS = roughness_val;
    CLEARCOAT = clearcoat_val;
    CLEARCOAT_ROUGHNESS = 0.03;
    EMISSION = emission_color.rgb * 3.0;
}
