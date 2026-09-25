extends RefCounted

static func handle_command(cmd: String, env_node: WorldEnvironment, sun: DirectionalLight3D, rim: DirectionalLight3D, space_rid: RID) -> bool:
    if "гравитация" in cmd:
        var g = 0.0 if (" 0" in cmd or "нул" in cmd) else (1.6 if "лун" in cmd else 9.8)
        PhysicsServer3D.area_set_param(space_rid, PhysicsServer3D.AREA_PARAM_GRAVITY, g)
        return true
    elif "нощ" in cmd:
        if env_node and env_node.environment:
            env_node.environment.background_color = Color(0.04, 0.05, 0.09)
        if sun:
            sun.light_energy = 0.2
            sun.light_color = Color(0.4, 0.6, 1.0)
        if rim:
            rim.light_energy = 0.6
        return true
    elif "залез" in cmd:
        if env_node and env_node.environment:
            env_node.environment.background_color = Color(0.45, 0.18, 0.1)
        if sun:
            sun.light_energy = 1.3
            sun.light_color = Color(1.0, 0.45, 0.2)
        if rim:
            rim.light_energy = 1.8
        return true
    elif "ден" in cmd:
        if env_node and env_node.environment:
            env_node.environment.background_color = Color(0.18, 0.22, 0.28)
        if sun:
            sun.light_energy = 1.35
            sun.light_color = Color(1.0, 0.98, 0.92)
        if rim:
            rim.light_energy = 1.6
        return true
    return false
