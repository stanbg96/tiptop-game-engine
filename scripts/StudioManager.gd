extends Node3D

@onready var camera = $Camera3D
@onready var joy = $UI/VBox/Zone3D/VirtualJoystick
@onready var indicator = $SelectionIndicator
@onready var tools_bar = $UI/VBox/Zone3D/ToolsBar
@onready var lbl_selected = $UI/VBox/Zone3D/ToolsBar/LabelName
@onready var chat_log = $UI/VBox/ChatZone/Margin/VBox/Log
@onready var chat_input = $UI/VBox/ChatZone/Margin/VBox/InputRow/ChatInput
@onready var world_spawn = $WorldObjects
@onready var zone3d = $UI/VBox/Zone3D

var selected_obj: Node3D = null
var is_dragging: bool = false
var cam_yaw: float = 0.0
var cam_pitch: float = -0.3

func _ready():
    tools_bar.visible = false
    indicator.visible = false
    _add_log("[color=#00f2fe]✅ TipTop Studio PRO заредено![/color]")
    _add_log("🕹️ Ползвай джойстика вляво, за да летиш.")
    _add_log("👆 Докосни дървото или колата, за да ги местиш с пръст!")
    
    _build("дърво", Vector3(-4, 0, -6))
    _build("кола", Vector3(4, 0, -6))

func _process(delta):
    # ДРОН КАМЕРА: Летене с джойстика
    if joy.output.length() > 0.05:
        var forward = -camera.global_transform.basis.z
        var right = camera.global_transform.basis.x
        forward.y = 0; right.y = 0 
        forward = forward.normalized(); right = right.normalized()
        var move_dir = right * joy.output.x + forward * (-joy.output.y)
        camera.global_position += move_dir * 12.0 * delta

    # СВЕТЕЩ МАРКЕР НАД ИЗБРАНИЯ ОБЕКТ
    if selected_obj and is_instance_valid(selected_obj):
        indicator.visible = true
        indicator.global_position = selected_obj.global_position + Vector3(0, 3.0 + sin(Time.get_ticks_msec()*0.005)*0.2, 0)
    else:
        indicator.visible = false

func _unhandled_input(event):
    # Отчитаме тъч САМО ако е в горните 70% на екрана (Zone3D)
    var local_pos = zone3d.get_local_mouse_position()
    var rect = Rect2(Vector2.ZERO, zone3d.size)
    if not rect.has_point(local_pos): return

    if event is InputEventScreenTouch:
        if event.pressed:
            var hit = _raycast(event.position)
            if hit:
                _select(hit)
                is_dragging = true
            else:
                _deselect()
                is_dragging = false
        else:
            is_dragging = false

    elif event is InputEventScreenDrag:
        if is_dragging and selected_obj and is_instance_valid(selected_obj):
            # ВЛАЧЕНЕ НА ОБЕКТА ПО ЗЕМЯТА
            var drop = _get_floor_hit(event.position)
            if drop != Vector3.INF:
                selected_obj.global_position.x = drop.x
                selected_obj.global_position.z = drop.z
        else:
            # ОГЛЕЖДАНЕ (Въртене на камерата)
            cam_yaw -= event.relative.x * 0.005
            cam_pitch = clamp(cam_pitch - event.relative.y * 0.005, -1.5, 1.5)
            camera.rotation.y = cam_yaw
            camera.rotation.x = cam_pitch

func _raycast(pos: Vector2):
    var from = camera.project_ray_origin(pos)
    var to = from + camera.project_ray_normal(pos) * 1000.0
    var q = PhysicsRayQueryParameters3D.create(from, to)
    var res = get_world_3d().direct_space_state.intersect_ray(q)
    if res and res.collider.is_in_group("obj"):
        return res.collider
    return null

func _get_floor_hit(pos: Vector2):
    var from = camera.project_ray_origin(pos)
    var dir = camera.project_ray_normal(pos)
    var obj_y = selected_obj.global_position.y if selected_obj else 0.0
    var plane = Plane(Vector3.UP, obj_y)
    var hit = plane.intersects_ray(from, dir)
    return hit if hit != null else Vector3.INF

func _select(obj):
    selected_obj = obj
    lbl_selected.text = "📦 " + obj.name
    tools_bar.visible = true

func _deselect():
    selected_obj = null
    tools_bar.visible = false

# --- ГОРНО МЕНЮ С ИНСТРУМЕНТИ ---
func _on_act_up(): if selected_obj: selected_obj.global_position.y += 0.5
func _on_act_down(): if selected_obj: selected_obj.global_position.y -= 0.5
func _on_act_rot(): if selected_obj: selected_obj.rotate_y(deg_to_rad(45))
func _on_act_dup():
    if selected_obj:
        var copy = selected_obj.duplicate()
        copy.position += Vector3(1.5, 0, 1.5)
        world_spawn.add_child(copy)
        _select(copy)
func _on_act_del():
    if selected_obj:
        selected_obj.queue_free()
        _deselect()

# --- ЧАТ И СТРОЕНЕ ---
func _add_log(msg: String): chat_log.append_text(msg + "\n")

func _on_send_chat():
    var t = chat_input.text.strip_edges()
    if t.is_empty(): return
    chat_input.text = ""
    _add_log("[color=#00ff88]Ти:[/color] " + t)
    _build(t.to_lower(), Vector3.INF)

func _on_chip_pressed(txt: String):
    _add_log("[color=#00ff88]Ти:[/color] " + txt)
    _build(txt.to_lower(), Vector3.INF)

func _build(prompt: String, forced_pos: Vector3):
    var pos = forced_pos
    if pos == Vector3.INF:
        var forward = -camera.global_transform.basis.z
        forward.y = 0
        pos = camera.global_position + forward.normalized() * 6.0
        pos.y = 0.0

    var obj = CSGCombiner3D.new()
    obj.position = pos
    obj.use_collision = true
    obj.add_to_group("obj")
    
    if "дърво" in prompt:
        obj.name = "Tree_" + str(randi()%100)
        var trunk = CSGCylinder3D.new()
        trunk.radius = 0.4; trunk.height = 1.5; trunk.position.y = 0.75
        trunk.material = _mat(Color(0.4, 0.2, 0.1))
        var leaves = CSGSphere3D.new()
        leaves.radius = 2.0; leaves.position.y = 2.5
        leaves.material = _mat(Color(0.1, 0.7, 0.2))
        obj.add_child(trunk); obj.add_child(leaves)
    elif "сграда" in prompt or "блок" in prompt:
        obj.name = "Building_" + str(randi()%100)
        var h = randi_range(3, 6) * 1.5
        var b = CSGBox3D.new()
        b.size = Vector3(3, h, 3); b.position.y = h/2.0
        b.material = _mat(Color(0.2, 0.3, 0.4))
        obj.add_child(b)
    elif "кола" in prompt:
        obj.name = "Car_" + str(randi()%100)
        var b1 = CSGBox3D.new()
        b1.size = Vector3(2.2, 0.8, 4.4); b1.position.y = 0.4
        b1.material = _mat(Color(0.9, 0.1, 0.2))
        var b2 = CSGBox3D.new()
        b2.size = Vector3(1.8, 0.6, 2.0); b2.position = Vector3(0, 1.1, -0.2)
        b2.material = _mat(Color(0.1, 0.1, 0.15))
        obj.add_child(b1); obj.add_child(b2)
    else:
        obj.name = "Shape_" + str(randi()%100)
        var b = CSGBox3D.new()
        b.size = Vector3(1.5, 1.5, 1.5); b.position.y = 0.75
        b.material = _mat(Color(randf(), randf(), randf()))
        obj.add_child(b)

    world_spawn.add_child(obj)
    _select(obj)

func _mat(col: Color) -> StandardMaterial3D:
    var m = StandardMaterial3D.new()
    m.albedo_color = col
    m.roughness = 0.3
    return m
