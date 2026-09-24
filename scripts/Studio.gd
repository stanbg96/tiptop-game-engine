extends Node3D

@onready var camera = $Camera3D
@onready var joy = $UI/JoystickArea/VirtualJoystick
@onready var chat_log = $UI/ChatBG/VBox/Log
@onready var chat_input = $UI/ChatBG/VBox/InputRow/ChatInput
@onready var tools_bar = $UI/ToolsBar
@onready var lbl_selected = $UI/ToolsBar/HBox/LabelName
@onready var indicator = $Indicator
@onready var world = $World

var selected_obj: Node3D = null
var is_dragging: bool = false
var cam_yaw: float = 0.0
var cam_pitch: float = -0.4

func _ready():
    tools_bar.visible = false
    indicator.visible = false
    _add_log("[color=#00ff00]Системата е онлайн![/color] Джойстикът е вляво. Докосни обектите.")
    _build("дърво", Vector3(-3, 0, -5))
    _build("кола", Vector3(3, 0, -5))

func _process(delta):
    # ДВИЖЕНИЕ С ДЖОЙСТИК (Летене)
    if joy.output.length() > 0.05:
        var fwd = -camera.global_transform.basis.z
        var rgt = camera.global_transform.basis.x
        fwd.y = 0; rgt.y = 0
        fwd = fwd.normalized(); rgt = rgt.normalized()
        camera.global_position += (rgt * joy.output.x + fwd * -joy.output.y) * 15.0 * delta

    # МАРКЕР НАД ОБЕКТ
    if selected_obj and is_instance_valid(selected_obj):
        indicator.visible = true
        indicator.global_position = selected_obj.global_position + Vector3(0, 3.5, 0)
    else:
        indicator.visible = false

func _unhandled_input(event):
    var screen_h = get_viewport().size.y
    var limit_h = screen_h * 0.65 # Горните 65% са за игра

    if event is InputEventScreenTouch:
        if event.position.y > limit_h: return
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
        if event.position.y > limit_h: return
        if is_dragging and selected_obj and is_instance_valid(selected_obj):
            var drop = _get_floor(event.position)
            if drop != Vector3.INF:
                selected_obj.global_position.x = drop.x
                selected_obj.global_position.z = drop.z
        else:
            cam_yaw -= event.relative.x * 0.005
            cam_pitch = clamp(cam_pitch - event.relative.y * 0.005, -1.5, 1.5)
            camera.rotation.y = cam_yaw
            camera.rotation.x = cam_pitch

func _raycast(pos: Vector2):
    var from = camera.project_ray_origin(pos)
    var to = from + camera.project_ray_normal(pos) * 1000.0
    var q = PhysicsRayQueryParameters3D.create(from, to)
    var res = get_world_3d().direct_space_state.intersect_ray(q)
    if res and res.collider.is_in_group("prop"):
        return res.collider.get_parent()
    return null

func _get_floor(pos: Vector2):
    var from = camera.project_ray_origin(pos)
    var dir = camera.project_ray_normal(pos)
    var h = selected_obj.global_position.y if selected_obj else 0.0
    var plane = Plane(Vector3.UP, h)
    return plane.intersects_ray(from, dir)

func _select(obj):
    selected_obj = obj
    lbl_selected.text = "Обект: " + obj.name
    tools_bar.visible = true

func _deselect():
    selected_obj = null
    tools_bar.visible = false

# --- ИНСТРУМЕНТИ ---
func _on_act_up(): if selected_obj: selected_obj.global_position.y += 1.0
func _on_act_down(): if selected_obj: selected_obj.global_position.y -= 1.0
func _on_act_rot(): if selected_obj: selected_obj.rotate_y(deg_to_rad(45))
func _on_act_del():
    if selected_obj:
        selected_obj.queue_free()
        _deselect()

# --- СТРОЕНЕ ---
func _add_log(msg: String): chat_log.append_text(msg + "\n")

func _on_send_chat():
    var t = chat_input.text.strip_edges()
    if t.is_empty(): return
    chat_input.text = ""
    _add_log("[color=#00ffff]Ти:[/color] " + t)
    _build(t.to_lower(), Vector3.INF)

func _on_chip_pressed(txt: String):
    _add_log("[color=#00ffff]Ти:[/color] " + txt)
    _build(txt.to_lower(), Vector3.INF)

func _build(prompt: String, f_pos: Vector3):
    var pos = f_pos
    if pos == Vector3.INF:
        var fwd = -camera.global_transform.basis.z
        fwd.y = 0
        pos = camera.global_position + fwd.normalized() * 5.0
        pos.y = 0.0

    var obj = Node3D.new()
    obj.position = pos
    
    var rb = StaticBody3D.new()
    rb.add_to_group("prop")
    obj.add_child(rb)

    if "дърво" in prompt:
        obj.name = "Tree"
        _add_m(rb, CylinderMesh.new(), Vector3(0.6, 1.5, 0.6), Vector3(0, 0.75, 0), Color(0.4, 0.2, 0.1))
        _add_m(rb, SphereMesh.new(), Vector3(3, 3, 3), Vector3(0, 2.5, 0), Color(0.1, 0.8, 0.2))
        _add_c(rb, Vector3(2, 4, 2), Vector3(0, 2, 0))
    elif "кола" in prompt:
        obj.name = "Car"
        _add_m(rb, BoxMesh.new(), Vector3(2.4, 0.8, 4.6), Vector3(0, 0.4, 0), Color(1.0, 0.1, 0.1))
        _add_m(rb, BoxMesh.new(), Vector3(1.8, 0.6, 2.2), Vector3(0, 1.1, -0.2), Color(0.1, 0.1, 0.1))
        _add_c(rb, Vector3(2.4, 1.4, 4.6), Vector3(0, 0.7, 0))
    else:
        obj.name = "Block"
        _add_m(rb, BoxMesh.new(), Vector3(2, 2, 2), Vector3(0, 1, 0), Color(randf(), randf(), randf()))
        _add_c(rb, Vector3(2, 2, 2), Vector3(0, 1, 0))

    world.add_child(obj)
    _select(rb)

func _add_m(p, msh, sz, pos, col):
    var m = MeshInstance3D.new()
    msh.size = sz if msh is BoxMesh else msh.size
    if msh is CylinderMesh: msh.top_radius=sz.x/2.0; msh.bottom_radius=sz.x/2.0; msh.height=sz.y
    if msh is SphereMesh: msh.radius=sz.x/2.0; msh.height=sz.y
    m.mesh = msh; m.position = pos
    var mat = StandardMaterial3D.new()
    mat.albedo_color = col
    m.material_override = mat
    p.add_child(m)

func _add_c(p, sz, pos):
    var c = CollisionShape3D.new()
    var s = BoxShape3D.new(); s.size = sz
    c.shape = s; c.position = pos
    p.add_child(c)
