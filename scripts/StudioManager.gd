extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var indicator: MeshInstance3D = $SelectionIndicator
@onready var tools_ui: Control = $UI/ToolsOverlay
@onready var selected_lbl: Label = $UI/ToolsOverlay/SelectedName
@onready var chat_log: RichTextLabel = $UI/ChatPanel/VBox/Log
@onready var chat_input: TextEdit = $UI/ChatPanel/VBox/InputRow/ChatInput
@onready var world_spawn: Node3D = $WorldObjects

var selected_node: Node3D = null
var cam_yaw: float = 0.7
var cam_pitch: float = -0.4
var cam_dist: float = 12.0

func _ready():
    indicator.visible = false
    tools_ui.visible = false
    _add_log("[color=#00f2fe]✨ TipTop AI Studio[/color] е готово!")
    _add_log("[color=#aaaaaa]Докосни дървото или колата, за да ги местиш.[/color]")

func _process(delta):
    if selected_node and is_instance_valid(selected_node):
        indicator.visible = true
        var bounce = sin(Time.get_ticks_msec() * 0.005) * 0.2
        indicator.global_position = selected_node.global_position + Vector3(0, 2.5 + bounce, 0)
    else:
        indicator.visible = false

    var target = selected_node.global_position if selected_node else Vector3.ZERO
    var offset = Vector3(
        sin(cam_yaw) * cos(cam_pitch) * cam_dist,
        -sin(cam_pitch) * cam_dist,
        cos(cam_yaw) * cos(cam_pitch) * cam_dist
    )
    camera.global_position = camera.global_position.lerp(target + offset, 8.0 * delta)
    camera.look_at(target + Vector3(0, 0.5, 0), Vector3.UP)

# ВАЖНО: _unhandled_input гарантира, че ако натиснеш бутон, играта няма да отмаркира обекта!
func _unhandled_input(event):
    var view_h = get_viewport().size.y
    var zone_3d_h = view_h * 0.7

    if event is InputEventScreenTouch and event.pressed:
        if event.position.y < zone_3d_h:
            _raycast_select(event.position)
            
    elif event is InputEventScreenDrag:
        if event.position.y < zone_3d_h and not tools_ui.visible:
            cam_yaw -= event.relative.x * 0.005
            cam_pitch = clamp(cam_pitch + event.relative.y * 0.005, -1.2, -0.1)

func _raycast_select(screen_pos: Vector2):
    var from = camera.project_ray_origin(screen_pos)
    var to = from + camera.project_ray_normal(screen_pos) * 100.0
    var space = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(from, to)
    var res = space.intersect_ray(query)

    if res and res.collider.is_in_group("selectable"):
        selected_node = res.collider.get_parent() if res.collider is CollisionShape3D else res.collider
        selected_lbl.text = "Избран обект: " + selected_node.name
        tools_ui.visible = true
    else:
        selected_node = null
        tools_ui.visible = false

# БУТОНИ ЗА МЕСТЕНЕ И ИЗТРИВАНЕ (Вече работят перфектно)
func _move_obj(axis: Vector3):
    if selected_node and is_instance_valid(selected_node): 
        selected_node.global_position += axis * 1.0

func _on_btn_up(): _move_obj(Vector3.FORWARD)
func _on_btn_down(): _move_obj(Vector3.BACK)
func _on_btn_left(): _move_obj(Vector3.LEFT)
func _on_btn_right(): _move_obj(Vector3.RIGHT)

func _on_btn_delete():
    if selected_node and is_instance_valid(selected_node):
        var n = selected_node.name
        selected_node.queue_free()
        selected_node = null
        tools_ui.visible = false
        _add_log("[color=#ff3344]Изтрит обект:[/color] " + n)

func _add_log(msg: String):
    chat_log.append_text(msg + "\n")

func _on_send_chat():
    var txt = chat_input.text.strip_edges()
    if txt.is_empty(): return
    chat_input.text = ""
    _add_log("[color=#00ff88]Ти:[/color] " + txt)
    _build_procedural_object(txt.to_lower())

func _on_chip_pressed(txt: String):
    chat_input.text = txt
    _on_send_chat()

func _build_procedural_object(prompt: String):
    var pos = Vector3(randf_range(-4, 4), 0, randf_range(-4, -1))
    var obj = StaticBody3D.new()
    obj.position = pos
    obj.add_to_group("selectable")
    
    if "дърво" in prompt or "гора" in prompt:
        obj.name = "Tree_" + str(randi()%100)
        _add_mesh(obj, CylinderMesh.new(), Vector3(0.5, 1.5, 0.5), Vector3(0, 0.75, 0), Color(0.35, 0.2, 0.1))
        _add_mesh(obj, SphereMesh.new(), Vector3(3, 3, 3), Vector3(0, 2.5, 0), Color(0.1, 0.65, 0.2))
        _add_col(obj, Vector3(2, 4, 2), Vector3(0, 2, 0))
        _add_log("[color=#00f2fe]AI:[/color] Засадих голямо дърво!")
        
    elif "сграда" in prompt or "блок" in prompt or "къща" in prompt:
        obj.name = "Building_" + str(randi()%100)
        var floors = randi_range(3, 8)
        var h = floors * 1.5
        _add_mesh(obj, BoxMesh.new(), Vector3(3, h, 3), Vector3(0, h/2, 0), Color(0.2, 0.25, 0.35))
        _add_mesh(obj, BoxMesh.new(), Vector3(3.2, 0.4, 3.2), Vector3(0, h, 0), Color(0.9, 0.1, 0.3)) 
        _add_col(obj, Vector3(3, h, 3), Vector3(0, h/2, 0))
        _add_log("[color=#00f2fe]AI:[/color] Построих " + str(floors) + "-етажна сграда!")
        
    elif "кола" in prompt or "автомобил" in prompt:
        obj.name = "Car_" + str(randi()%100)
        _add_mesh(obj, BoxMesh.new(), Vector3(2.2, 0.6, 4.4), Vector3(0, 0.5, 0), Color(1.0, 0.7, 0.0))
        _add_mesh(obj, BoxMesh.new(), Vector3(1.6, 0.5, 2.0), Vector3(0, 1.05, -0.2), Color(0.1, 0.15, 0.25)) 
        _add_col(obj, Vector3(2.2, 1.2, 4.4), Vector3(0, 0.6, 0))
        _add_log("[color=#00f2fe]AI:[/color] Доставих нова кола!")
        
    else:
        obj.name = "Shape_" + str(randi()%100)
        var col = Color(randf(), randf(), randf())
        _add_mesh(obj, BoxMesh.new(), Vector3(1.5, 1.5, 1.5), Vector3(0, 0.75, 0), col)
        _add_col(obj, Vector3(1.5, 1.5, 1.5), Vector3(0, 0.75, 0))
        _add_log("[color=#00f2fe]AI:[/color] Създадох цветен блок.")

    world_spawn.add_child(obj)
    selected_node = obj
    selected_lbl.text = "Избран обект: " + obj.name
    tools_ui.visible = true

func _add_mesh(parent: Node3D, primitive: Mesh, scale_vec: Vector3, pos: Vector3, col: Color):
    var m = MeshInstance3D.new()
    primitive.size = scale_vec if primitive is BoxMesh else primitive.size
    if primitive is CylinderMesh:
        primitive.top_radius = scale_vec.x
        primitive.bottom_radius = scale_vec.x
        primitive.height = scale_vec.y
    if primitive is SphereMesh:
        primitive.radius = scale_vec.x / 2.0
        primitive.height = scale_vec.y
    m.mesh = primitive
    m.position = pos
    var mat = StandardMaterial3D.new()
    mat.albedo_color = col
    mat.roughness = 0.3
    m.material_override = mat
    parent.add_child(m)

func _add_col(parent: Node3D, size: Vector3, pos: Vector3):
    var c = CollisionShape3D.new()
    var s = BoxShape3D.new()
    s.size = size
    c.shape = s
    c.position = pos
    parent.add_child(c)
