extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var indicator: MeshInstance3D = $SelectionIndicator
@onready var tools_ui: Control = $UI/ToolsOverlay
@onready var selected_lbl: Label = $UI/ToolsOverlay/SelectedName
@onready var chat_log: RichTextLabel = $UI/ChatPanel/VBox/Margin1/Log
@onready var chat_input: TextEdit = $UI/ChatPanel/VBox/Margin2/InputRow/ChatInput
@onready var world_spawn: Node3D = $WorldObjects

var selected_node: Node3D = null
var is_dragging_obj: bool = false
var obj_start_y: float = 0.0

var cam_yaw: float = 0.7
var cam_pitch: float = -0.4
var cam_dist: float = 12.0
var cam_target: Vector3 = Vector3.ZERO

func _ready():
    indicator.visible = false
    tools_ui.visible = false
    _add_log("[color=#00f2fe]✨ TipTop Studio е обновено![/color]")
    _add_log("[color=#aaaaaa]Докосни обект и плъзгай пръст, за да го местиш по земята![/color]")
    
    # Стартови обекти за тест
    _build_procedural_object("дърво")
    _build_procedural_object("кола")

func _process(delta):
    # Анимация на маркера
    if selected_node and is_instance_valid(selected_node):
        indicator.visible = true
        var bounce = sin(Time.get_ticks_msec() * 0.005) * 0.2
        indicator.global_position = selected_node.global_position + Vector3(0, 2.5 + bounce, 0)
    else:
        indicator.visible = false

    # Плавно движение на камерата
    var target = selected_node.global_position if selected_node else cam_target
    var offset = Vector3(
        sin(cam_yaw) * cos(cam_pitch) * cam_dist,
        -sin(cam_pitch) * cam_dist,
        cos(cam_yaw) * cos(cam_pitch) * cam_dist
    )
    camera.global_position = camera.global_position.lerp(target + offset, 10.0 * delta)
    camera.look_at(target + Vector3(0, 0.5, 0), Vector3.UP)

func _unhandled_input(event):
    var view_h = get_viewport().size.y
    var zone_3d_h = view_h * 0.7 # Горните 70% от екрана

    if event is InputEventScreenTouch:
        if event.position.y < zone_3d_h:
            if event.pressed:
                # Опитваме да селектираме обект
                if _raycast_select(event.position):
                    is_dragging_obj = true
                else:
                    is_dragging_obj = false
            else:
                is_dragging_obj = false
                
    elif event is InputEventScreenDrag:
        if event.position.y < zone_3d_h:
            if is_dragging_obj and selected_node and is_instance_valid(selected_node):
                # DRAG & DROP: Местим обекта по пода
                var drop_pos = _get_floor_pos(event.position)
                if drop_pos != Vector3.INF:
                    selected_node.global_position.x = drop_pos.x
                    selected_node.global_position.z = drop_pos.z
            else:
                # ОРБИТА: Въртим камерата
                cam_yaw -= event.relative.x * 0.005
                cam_pitch = clamp(cam_pitch + event.relative.y * 0.005, -1.2, -0.1)

# Търси обект под пръста
func _raycast_select(screen_pos: Vector2) -> bool:
    var from = camera.project_ray_origin(screen_pos)
    var to = from + camera.project_ray_normal(screen_pos) * 100.0
    var space = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(from, to)
    var res = space.intersect_ray(query)

    if res and res.collider.is_in_group("selectable"):
        selected_node = res.collider.get_parent() if res.collider is CollisionShape3D else res.collider
        selected_lbl.text = "Избран: " + selected_node.name
        tools_ui.visible = true
        return true
    else:
        selected_node = null
        tools_ui.visible = false
        return false

# Математика за плъзгане по 3D пода
func _get_floor_pos(screen_pos: Vector2) -> Vector3:
    var from = camera.project_ray_origin(screen_pos)
    var dir = camera.project_ray_normal(screen_pos)
    # Математическа равнина на височина 0 (пода)
    var plane = Plane(Vector3.UP, 0.0)
    var intersect = plane.intersects_ray(from, dir)
    if intersect != null:
        return intersect
    return Vector3.INF

func _on_btn_delete():
    if selected_node and is_instance_valid(selected_node):
        var n = selected_node.name
        selected_node.queue_free()
        selected_node = null
        tools_ui.visible = false
        is_dragging_obj = false
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
    chat_input.text = ""
    _add_log("[color=#00ff88]Ти (Бутон):[/color] " + txt)
    _build_procedural_object(txt.to_lower())

func _build_procedural_object(prompt: String):
    # Спаунва точно пред камерата
    var pos = cam_target + Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))
    
    var obj = StaticBody3D.new()
    obj.position = pos
    obj.add_to_group("selectable")
    
    if "дърво" in prompt or "гора" in prompt:
        obj.name = "Tree_" + str(randi()%100)
        _add_mesh(obj, CylinderMesh.new(), Vector3(0.5, 1.5, 0.5), Vector3(0, 0.75, 0), Color(0.35, 0.2, 0.1))
        _add_mesh(obj, SphereMesh.new(), Vector3(3, 3, 3), Vector3(0, 2.5, 0), Color(0.1, 0.65, 0.2))
        _add_col(obj, Vector3(2, 4, 2), Vector3(0, 2, 0))
        _add_log("[color=#00f2fe]AI:[/color] Засадих дърво! Плъзни го с пръст.")
        
    elif "сграда" in prompt or "блок" in prompt:
        obj.name = "Building_" + str(randi()%100)
        var floors = randi_range(3, 7)
        var h = floors * 1.5
        _add_mesh(obj, BoxMesh.new(), Vector3(3, h, 3), Vector3(0, h/2, 0), Color(0.15, 0.2, 0.3))
        _add_col(obj, Vector3(3, h, 3), Vector3(0, h/2, 0))
        _add_log("[color=#00f2fe]AI:[/color] Построих " + str(floors) + "-етажна сграда!")
        
    elif "кола" in prompt:
        obj.name = "Car_" + str(randi()%100)
        _add_mesh(obj, BoxMesh.new(), Vector3(2.2, 0.6, 4.4), Vector3(0, 0.5, 0), Color(0.9, 0.1, 0.2))
        _add_mesh(obj, BoxMesh.new(), Vector3(1.6, 0.5, 2.0), Vector3(0, 1.05, -0.2), Color(0.05, 0.05, 0.1)) 
        _add_col(obj, Vector3(2.2, 1.2, 4.4), Vector3(0, 0.6, 0))
        _add_log("[color=#00f2fe]AI:[/color] Спаунах кола!")
        
    else:
        obj.name = "Block_" + str(randi()%100)
        var col = Color(randf(), randf(), randf())
        _add_mesh(obj, BoxMesh.new(), Vector3(1.5, 1.5, 1.5), Vector3(0, 0.75, 0), col)
        _add_col(obj, Vector3(1.5, 1.5, 1.5), Vector3(0, 0.75, 0))
        _add_log("[color=#00f2fe]AI:[/color] Създадох блок.")

    world_spawn.add_child(obj)
    
    # Автоматично го избираме
    selected_node = obj
    selected_lbl.text = "Избран: " + obj.name
    tools_ui.visible = true

func _add_mesh(parent: Node3D, primitive: Mesh, scale_vec: Vector3, pos: Vector3, col: Color):
    var m = MeshInstance3D.new()
    primitive.size = scale_vec if primitive is BoxMesh else primitive.size
    if primitive is CylinderMesh:
        primitive.top_radius = scale_vec.x * 0.5
        primitive.bottom_radius = scale_vec.x * 0.5
        primitive.height = scale_vec.y
    if primitive is SphereMesh:
        primitive.radius = scale_vec.x * 0.5
        primitive.height = scale_vec.y
    m.mesh = primitive
    m.position = pos
    var mat = StandardMaterial3D.new()
    mat.albedo_color = col
    mat.roughness = 0.3
    mat.metallic = 0.1
    m.material_override = mat
    parent.add_child(m)

func _add_col(parent: Node3D, size: Vector3, pos: Vector3):
    var c = CollisionShape3D.new()
    var s = BoxShape3D.new()
    s.size = size
    c.shape = s
    c.position = pos
    parent.add_child(c)
