extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var world_spawn: Node3D = $WorldObjects
@onready var selection_ring: MeshInstance3D = $SelectionRing
@onready var chat_history: RichTextLabel = $UI/BottomChatPanel/ChatHistory
@onready var chat_input: LineEdit = $UI/BottomChatPanel/InputRow/ChatInput
@onready var object_tools_bar: PanelContainer = $UI/ObjectToolsBar
@onready var selected_name_lbl: Label = $UI/ObjectToolsBar/HBox/SelectedName
@onready var move_gizmo_ui: Control = $UI/MoveGizmoUI
@onready var api_modal: Panel = $UI/ApiModal
@onready var api_input: LineEdit = $UI/ApiModal/ApiKeyInput

var selected_node: Node3D = null
var current_tool_mode: String = "move" # move, rotate, scale
var api_key: String = ""

# Камера орбитални параметри (за горните 70%)
var cam_yaw: float = 0.5
var cam_pitch: float = -0.4
var cam_dist: float = 12.0
var cam_target: Vector3 = Vector3(0, 1.0, 0)
var is_dragging_cam: bool = false
var last_touch_pos: Vector2 = Vector2.ZERO

func _ready():
_add_ai_message("Добре дошъл в TipTop Studio! Докосни обект на екрана, за да го местиш, или пиши в чата долу.")
_spawn_initial_showcase()
object_tools_bar.visible = false
move_gizmo_ui.visible = false
selection_ring.visible = false

func _spawn_initial_showcase():
_spawn_shape("куб", Vector3(-3, 1, 0), Color(1.0, 0.35, 0.0), Vector3(2, 2, 2))
_spawn_shape("сфера", Vector3(3, 1.2, 0), Color(0.0, 0.85, 1.0), Vector3(2.4, 2.4, 2.4))
_spawn_human(Vector3(0, 0, 0))

func _process(delta):
# Плавно следване на фокуса от камерата
var offset = Vector3(
sin(cam_yaw) * cos(cam_pitch) * cam_dist,
-sin(cam_pitch) * cam_dist,
cos(cam_yaw) * cos(cam_pitch) * cam_dist
)
camera.global_position = camera.global_position.lerp(cam_target + offset, 12.0 * delta)
camera.look_at(cam_target, Vector3.UP)

# Позициониране на маркера за селекция под избрания обект
if selected_node and is_instance_valid(selected_node):
selection_ring.visible = true
selection_ring.global_position = selected_node.global_position + Vector3(0, 0.05, 0)
else:
selection_ring.visible = false

func _input(event):
# 70% от височината е зоната за 3D студио
var viewport_h = get_viewport().size.y
var builder_zone_h = viewport_h * 0.70

if event is InputEventScreenTouch:
if event.pressed:
if event.position.y < builder_zone_h:
last_touch_pos = event.position
is_dragging_cam = true
_try_select_object(event.position)
else:
is_dragging_cam = false

elif event is InputEventScreenDrag:
if is_dragging_cam and event.position.y < builder_zone_h:
var delta = event.position - last_touch_pos
last_touch_pos = event.position
# Завъртане на сцената с един пръст в горната зона
cam_yaw -= delta.x * 0.007
cam_pitch = clamp(cam_pitch + delta.y * 0.007, -1.2, -0.1)

# Raycast докосване за селекция на обект
func _try_select_object(screen_pos: Vector2):
var from = camera.project_ray_origin(screen_pos)
var to = from + camera.project_ray_normal(screen_pos) * 100.0
var space_state = get_world_3d().direct_space_state
var query = PhysicsRayQueryParameters3D.create(from, to)
var result = space_state.intersect_ray(query)

if result:
var collider = result.collider
if collider and collider != $Floor:
_select_object(collider)
return

# Ако сме цъкнали на празно място на пода
if not move_gizmo_ui.visible:
_deselect_object()

func _select_object(node: Node3D):
selected_node = node
selected_name_lbl.text = "📦 " + node.name
object_tools_bar.visible = true
move_gizmo_ui.visible = true
_set_gizmo_mode("move")

func _deselect_object():
selected_node = null
object_tools_bar.visible = false
move_gizmo_ui.visible = false
selection_ring.visible = false

# === ИНСТРУМЕНТИ ЗА ПРЕМЕСТВАНЕ, ВЪРТЕНЕ И МАЩАБИРАНЕ ===
func _set_gizmo_mode(mode: String):
current_tool_mode = mode
$UI/MoveGizmoUI/ModeTitle.text = "РЕЖИМ: " + mode.to_upper()

func _on_move_btn_pressed(): _set_gizmo_mode("move")
func _on_rotate_btn_pressed(): _set_gizmo_mode("rotate")
func _on_scale_btn_pressed(): _set_gizmo_mode("scale")

func _apply_transform_step(axis: Vector3, sign: float):
if not selected_node or not is_instance_valid(selected_node): return
var step = 0.5 * sign

match current_tool_mode:
"move":
selected_node.global_position += axis * step
"rotate":
selected_node.rotate(axis, deg_to_rad(15.0 * sign))
"scale":
var factor = 1.1 if sign > 0 else 0.9
selected_node.scale = (selected_node.scale * factor).clamp(Vector3(0.2, 0.2, 0.2), Vector3(20, 20, 20))

func _on_axis_x_pos(): _apply_transform_step(Vector3.RIGHT, 1.0)
func _on_axis_x_neg(): _apply_transform_step(Vector3.RIGHT, -1.0)
func _on_axis_y_pos(): _apply_transform_step(Vector3.UP, 1.0)
func _on_axis_y_neg(): _apply_transform_step(Vector3.UP, -1.0)
func _on_axis_z_pos(): _apply_transform_step(Vector3.BACK, 1.0)
func _on_axis_z_neg(): _apply_transform_step(Vector3.BACK, -1.0)

func _on_delete_selected():
if selected_node and is_instance_valid(selected_node):
_add_ai_message("Изтрит обект: " + selected_node.name)
selected_node.queue_free()
_deselect_object()

func _on_duplicate_selected():
if selected_node and is_instance_valid(selected_node):
var copy = selected_node.duplicate()
copy.position += Vector3(1.5, 0, 1.5)
world_spawn.add_child(copy)
_select_object(copy)
_add_ai_message("Дублиран: " + copy.name)

func _on_random_color_selected():
if selected_node:
var col = Color(randf(), randf(), randf())
_set_node_color(selected_node, col)
_add_ai_message("Сменен цвят на " + selected_node.name)

func _set_node_color(node: Node, col: Color):
if node is MeshInstance3D:
var mat = StandardMaterial3D.new()
mat.albedo_color = col
mat.metallic = 0.4
mat.roughness = 0.3
node.material_override = mat
for child in node.get_children():
_set_node_color(child, col)

# === СПАУНЪР НА 3D ОБЕКТИ ===
func _spawn_shape(type: String, pos: Vector3, col: Color, size_vec: Vector3):
var body = StaticBody3D.new()
body.position = pos
body.name = type.capitalize() + "_" + str(randi() % 1000)

var mesh_inst = MeshInstance3D.new()
var col_shape = CollisionShape3D.new()

if type == "сфера":
var sph = SphereMesh.new()
sph.radius = size_vec.x * 0.5
sph.height = size_vec.x
mesh_inst.mesh = sph
var s_col = SphereShape3D.new()
s_col.radius = sph.radius
col_shape.shape = s_col
elif type == "цилиндър":
var cyl = CylinderMesh.new()
cyl.top_radius = size_vec.x * 0.5
cyl.bottom_radius = size_vec.x * 0.5
cyl.height = size_vec.y
mesh_inst.mesh = cyl
var c_col = CylinderShape3D.new()
c_col.radius = cyl.top_radius
c_col.height = cyl.height
col_shape.shape = c_col
else:
var box = BoxMesh.new()
box.size = size_vec
mesh_inst.mesh = box
var b_col = BoxShape3D.new()
b_col.size = size_vec
col_shape.shape = b_col

var mat = StandardMaterial3D.new()
mat.albedo_color = col
mat.roughness = 0.3
mat.metallic = 0.2
mesh_inst.material_override = mat

body.add_child(mesh_inst)
body.add_child(col_shape)
world_spawn.add_child(body)
_select_object(body)

func _spawn_human(pos: Vector3):
var body = StaticBody3D.new()
body.name = "Humanoid_Model"
body.position = pos

var col = CollisionShape3D.new()
var cap = CapsuleShape3D.new()
cap.radius = 0.5; cap.height = 1.9
col.shape = cap
col.position.y = 0.95
body.add_child(col)

var torso = MeshInstance3D.new()
var t_box = BoxMesh.new()
t_box.size = Vector3(0.8, 0.9, 0.4)
torso.mesh = t_box
torso.position.y = 1.15
var mat_t = StandardMaterial3D.new()
mat_t.albedo_color = Color(0.0, 0.6, 1.0)
torso.material_override = mat_t
body.add_child(torso)

var head = MeshInstance3D.new()
var h_sph = SphereMesh.new()
h_sph.radius = 0.28; h_sph.height = 0.56
head.mesh = h_sph
head.position.y = 1.85
var mat_h = StandardMaterial3D.new()
mat_h.albedo_color = Color(1.0, 0.85, 0.65)
head.material_override = mat_h
body.add_child(head)

world_spawn.add_child(body)
_select_object(body)

# === 30% ДОЛЕН AI ЧАТ ===
func _add_user_message(msg: String):
chat_history.append_text("[color=#00f2fe][b]Ти:[/b][/color] " + msg + "\n")

func _add_ai_message(msg: String):
chat_history.append_text("[color=#00ff88][b]TipTop AI:[/b][/color] " + msg + "\n")

func _on_send_chat():
var text = chat_input.text.strip_edges()
if text.is_empty(): return
chat_input.text = ""
_add_user_message(text)
_process_prompt(text)

func _on_chip_pressed(prompt_text: String):
chat_input.text = ""
_add_user_message(prompt_text)
_process_prompt(prompt_text)

func _process_prompt(p: String):
var p_low = p.to_lower()
var spawn_pos = cam_target + Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))

if "замък" in p_low or "кула" in p_low:
_spawn_shape("куб", spawn_pos + Vector3(0, 3, 0), Color(0.3, 0.35, 0.45), Vector3(3, 6, 3))
_spawn_shape("цилиндър", spawn_pos + Vector3(0, 6.5, 0), Color(0.8, 0.2, 0.2), Vector3(2.5, 2, 2.5))
_add_ai_message("Създадох замъчна кула с покрив.")
elif "кола" in p_low:
_spawn_shape("куб", spawn_pos + Vector3(0, 0.6, 0), Color(1.0, 0.05, 0.2), Vector3(2.2, 0.8, 4.4))
_spawn_shape("куб", spawn_pos + Vector3(0, 1.2, -0.2), Color(0.1, 0.15, 0.25), Vector3(1.7, 0.7, 2.2))
_add_ai_message("Генерирах спортно купе. Можеш да го местиш със стрелките.")
elif "дърво" in p_low or "гора" in p_low:
_spawn_shape("цилиндър", spawn_pos + Vector3(0, 1.5, 0), Color(0.35, 0.2, 0.1), Vector3(0.5, 3.0, 0.5))
_spawn_shape("сфера", spawn_pos + Vector3(0, 3.8, 0), Color(0.1, 0.7, 0.2), Vector3(3.2, 3.2, 3.2))
_add_ai_message("Поставих процедурно дърво.")
elif "робот" in p_low or "човек" in p_low:
_spawn_human(spawn_pos)
_add_ai_message("Спаунах нов хуманоиден герой.")
else:
_spawn_shape("куб", spawn_pos + Vector3(0, 1, 0), Color(randf(), randf(), randf()), Vector3(2, 2, 2))
_add_ai_message("Генерирах физичен блок според заявката ти.")

func _on_settings_btn_pressed():
api_modal.visible = !api_modal.visible

func _on_save_key_pressed():
api_key = api_input.text.strip_edges()
api_modal.visible = false
_add_ai_message("API ключът е запазен успешно!")
