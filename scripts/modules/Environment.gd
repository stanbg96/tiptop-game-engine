extends RefCounted

static func apply_time_of_day(type: String, env: WorldEnvironment, sun: DirectionalLight3D):
if type == "нощ":
env.environment.background_color = Color(0.04, 0.05, 0.09)
sun.light_energy = 0.2; sun.light_color = Color(0.4, 0.6, 1.0)
elif type == "залез":
env.environment.background_color = Color(0.45, 0.18, 0.1)
sun.light_energy = 1.3; sun.light_color = Color(1.0, 0.45, 0.2)
else:
env.environment.background_color = Color(0.18, 0.22, 0.28)
sun.light_energy = 1.35; sun.light_color = Color(1.0, 0.98, 0.92)

static func set_gravity(space: RID, gravity_value: float):
PhysicsServer3D.area_set_param(space, PhysicsServer3D.AREA_PARAM_GRAVITY, gravity_value)
