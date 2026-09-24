extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var indicator: MeshInstance3D = $SelectionIndicator
@onready var tools_ui: Control = $UI/ToolsOverlay
@onready var selected_lbl: Label = $UI/ToolsOverlay/SelectedName
@onready var chat_log: RichTextLabel = $UI/ChatPanel/VBox/Log
@onready var chat_input: LineEdit = $UI/ChatPanel/VBox/InputRow/ChatInput

var selected_node: Node3D = null
var cam_yaw: float = 0.7
var cam_pitch: float = -0.4
var cam_dist: float = 12.0

func _ready():
indicator.visible = false
tools_ui.visible = false
_add_log("[color=#00f2fe]TipTop Studio зареди![/color] Докосни колата или дървото, за да ги местиш.")

func _process(delta):
# 1. Анимация на маркера за селекция (подскачаща стрелка)
if selected_node and is_instance_valid(selected_node):
indicator.visible = true
var bounce = sin(Time.get_ticks_msec() * 0.005) * 0.2
indicator.global_position = selected_node.global_position + Vector3(0, 2.5 + bounce, 0)
else:
indicator.visible = false

# 2. Плавно следене на камерата
var target = selected_node.global_position if selected_node else Vector3.ZERO
var offset = Vector3(
sin(cam_yaw) * cos(cam_pitch) * cam_dist,
-sin(cam_pitch) * cam_dist,
cos(cam_yaw) * cos(cam_pitch) * cam_dist
)
camera.global_position = camera.global_position.lerp(target + offset, 8.0 * delta)
camera.look_at(target + Vector3(0, 0.5, 0), Vector3.UP)

func _input(event):
var view_h = get_viewport().size.y
var zone_3d_h = view_h * 0.7 # Горните 70%

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

# --- БУТОНИ ЗА МЕСТЕНЕ ---
func _move_obj(axis: Vector3):
if selected_node: selected_node.global_position += axis * 0.5

func _on_btn_up(): _move_obj(Vector3.FORWARD)
func _on_btn_down(): _move_obj(Vector3.BACK)
func _on_btn_left(): _move_obj(Vector3.LEFT)
func _on_btn_right(): _move_obj(Vector3.RIGHT)
func _on_btn_delete():
if selected_node:
selected_node.queue_free()
selected_node = null
tools_ui.visible = false

# --- ЧАТ СИСТЕМА ---
func _add_log(msg: String):
chat_log.append_text(msg + "\n")

func _on_send_chat():
var txt = chat_input.text.strip_edges()
if txt.is_empty(): return
chat_input.text = ""
_add_log("[color=#00ff88]Ти:[/color] " + txt)

var pos = Vector3(randf_range(-3,3), 1, randf_range(-3,3))
if "кола" in txt.to_lower():
_add_log("[color=#00f2fe]AI:[/color] Засега ползвай готовата кола от сцената!")
else:
var box = CSGBox3D.new()
box.size = Vector3(1.5, 1.5, 1.5)
box.position = pos
box.add_to_group("selectable")
box.use_collision = true
box.name = "AI_Block"
var mat = StandardMaterial3D.new()
mat.albedo_color = Color(randf(), randf(), randf())
box.material = mat
$WorldObjects.add_child(box)
_add_log("[color=#00f2fe]AI:[/color] Създадох блок!")

func _on_chip_pressed(txt: String):
chat_input.text = txt
_on_send_chat()
