class_name EnvironmentStudio

static func set_time_of_day(type: String, env_node: WorldEnvironment, sun_light: DirectionalLight3D, rim_light: DirectionalLight3D):
if not env_node or not env_node.environment: return
if "нощ" in type:
env_node.environment.background_color = Color(0.04, 0.05, 0.09)
sun_light.light_energy = 0.2
sun_light.light_color = Color(0.4, 0.6, 1.0)
if rim_light: rim_light.light_energy = 0.6
elif "залез" in type:
env_node.environment.background_color = Color(0.45, 0.18, 0.1)
sun_light.light_energy = 1.3
sun_light.light_color = Color(1.0, 0.45, 0.2)
if rim_light: rim_light.light_energy = 1.8
else:
env_node.environment.background_color = Color(0.18, 0.22, 0.28)
sun_light.light_energy = 1.35
sun_light.light_color = Color(1.0, 0.98, 0.92)
if rim_light: rim_light.light_energy = 1.6

static func set_gravity(space_rid: RID, val: float):
PhysicsServer3D.area_set_param(space_rid, PhysicsServer3D.AREA_PARAM_GRAVITY, val)
