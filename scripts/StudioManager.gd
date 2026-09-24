extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var joy: Control = $UI/ToolsOverlay/VirtualJoystick
@onready var indicator: MeshInstance3D = $SelectionIndicator
@onready var tools_bar: PanelContainer = $UI/ToolsOverlay/SelectedTools
@onready var selected_lbl: Label = $UI/ToolsOverlay/SelectedTools/HBox/Label
@onready var chat_log: RichTextLabel = $UI/ChatPanel/VBox/Margin1/Log
@onready var chat_input: TextEdit = $UI/ChatPanel/VBox/Margin2/InputRow/ChatInput
@onready var world_spawn: Node3D = $WorldObjects

var selected_node: Node3D = null
var is_dragging_obj: bool = false
var cam_yaw: float = 0.0
var cam_pitch: float = -0.3

func _ready():
indicator.visible = false
tools_bar.visible = false
_add_log("[color=#00f2fe]✨ TipTop 3D PRO е зареден![/color]")
_add_log("🕹️ Ползвай джойстика вляво, за да летиш в света.")
_add_log("👆 Докосни обект за опции или го влачи с пръст.")

_build_procedural_object("кола")
_build_procedural_object("дърво")

func _process(delta):
# ДРОН КАМЕРА: Летене чрез джойстика
if joy.output.length() > 0:
var move_dir = (camera.transform.basis.x * joy.output.x + camera.transform.basis.z * joy.output.y)
camera.position += move_dir * 8.0 * delta

# МАРКЕР над избрания обект
if selected_node and is_instance_valid(selected_node):
indicator.visible = true
indicator.global_position = selected_node.global_position + Vector3(0, 2.5 + sin(Time.get_ticks_msec()*0.005)*0.2, 0)
else:
indicator.visible = false

func _unhandled_input(event):
var zone_h = get_viewport().size.y * 0.7

if event is InputEventScreenTouch:
if event.position.y < zone_h:
if event.pressed:
var obj = _raycast_obj(event.position)
if obj:
_select(obj)
is_dragging_obj = true
else:
is_dragging_obj = false
_deselect()
else:
is_dragging_obj = false

elif event is InputEventScreenDrag:
if event.position.y < zone_h:
if is_dragging_obj and selected_node and is_instance_valid(selected_node):
# ВЛАЧЕНЕ НА ОБЕКТА (Drag)
var drop = _get_drag_pos(event.position)
if drop != Vector3.INF:
selected_node.global_position.x = drop.x
selected_node.global_position.z = drop.z
else:
# ВЪРТЕНЕ НА КАМЕРАТА (Look around)
cam_yaw -= event.relative.x * 0.005
cam_pitch = clamp(cam_pitch - event.relative.y * 0.005, -1.5, 1.5)
camera.rotation.y = cam_yaw
camera.rotation.x = cam_pitch

func _raycast_obj(pos: Vector2):
var from = camera.project_ray_origin(pos)
var to = from + camera.project_ray_normal(pos) * 100.0
var space = get_world_3d().direct_space_state
var q = PhysicsRayQueryParameters3D.create(from, to)
var res = space.intersect_ray(q)
if res and res.collider.is_in_group("selectable"):
return res.collider.get_parent() if res.collider is CollisionShape3D else res.collider
return null

func _get_drag_pos(pos: Vector2) -> Vector3:
var from = camera.project_ray_origin(pos)
var dir = camera.project_ray_normal(pos)
var obj_y = selected_node.global_position.y if selected_node else 0.0
var plane = Plane(Vector3.UP, obj_y)
var hit = plane.intersects_ray(from, dir)
return hit if hit != null else Vector3.INF

func _select(node):
selected_node = node
selected_lbl.text = node.name
tools_bar.visible = true

func _deselect():
selected_node = null
tools_bar.visible = false

# === МЕНЮ С ОПЦИИ ЗА ОБЕКТА ===
func _on_act_up(): if selected_node: selected_node.position.y += 0.5
func _on_act_down(): if selected_node: selected_node.position.y -= 0.5
func _on_act_rot(): if selected_node: selected_node.rotate_y(deg_to_rad(45))
func _on_act_color():
if selected_node:
var c = Color(randf(), randf(), randf())
for child in selected_node.get_children():
if child is MeshInstance3D:
var m = StandardMaterial3D.new()
m.albedo_color = c
child.material_override = m
func _on_act_dup():
if selected_node:
var copy = selected_node.duplicate()
copy.position += Vector3(1.5, 0, 1.5)
world_spawn.add_child(copy)
_select(copy)
func _on_act_del():
if selected_node:
selected_node.queue_free()
_deselect()

# === ЧАТ ===
func _add_log(msg: String): chat_log.append_text(msg + "\n")
func _on_send_chat():
var t = chat_input.text.strip_edges()
if t.is_empty(): return
chat_input.text = ""
_add_log("[color=#00ff88]Ти:[/color] " + t)
_build_procedural_object(t.to_lower())

func _on_chip_pressed(txt: String):
chat_input.text = ""
_add_log("[color=#00ff88]Ти:[/color] " + txt)
_build_procedural_object(txt.to_lower())

func _build_procedural_object(prompt: String):
# Пада точно пред камерата
var pos = camera.global_position - camera.transform.basis.z * 5.0
pos.y = 0.0

var obj = StaticBody3D.new()
obj.position = pos
obj.add_to_group("selectable")

if "дърво" in prompt:
obj.name = "Tree_" + str(randi()%100)
_add_m(obj, CylinderMesh.new(), Vector3(0.5, 1.5, 0.5), Vector3(0, 0.75, 0), Color(0.35, 0.2, 0.1))
_add_m(obj, SphereMesh.new(), Vector3(3, 3, 3), Vector3(0, 2.5, 0), Color(0.1, 0.65, 0.2))
_add_c(obj, Vector3(2, 4, 2), Vector3(0, 2, 0))
elif "сграда" in prompt or "блок" in prompt:
obj.name = "Building_" + str(randi()%100)
var h = randi_range(3, 6) * 1.5
_add_m(obj, BoxMesh.new(), Vector3(3, h, 3), Vector3(0, h/2, 0), Color(0.2, 0.25, 0.35))
_add_c(obj, Vector3(3, h, 3), Vector3(0, h/2, 0))
elif "кола" in prompt:
obj.name = "Car_" + str(randi()%100)
_add_m(obj, BoxMesh.new(), Vector3(2.2, 0.6, 4.4), Vector3(0, 0.5, 0), Color(0.9, 0.1, 0.2))
_add_m(obj, BoxMesh.new(), Vector3(1.6, 0.5, 2.0), Vector3(0, 1.05, -0.2), Color(0.05, 0.05, 0.1)) 
_add_c(obj, Vector3(2.2, 1.2, 4.4), Vector3(0, 0.6, 0))
else:
obj.name = "Block_" + str(randi()%100)
_add_m(obj, BoxMesh.new(), Vector3(1.5, 1.5, 1.5), Vector3(0, 0.75, 0), Color(randf(), randf(), randf()))
_add_c(obj, Vector3(1.5, 1.5, 1.5), Vector3(0, 0.75, 0))

world_spawn.add_child(obj)
_select(obj)

func _add_m(p: Node3D, msh: Mesh, sz: Vector3, pos: Vector3, col: Color):
var m = MeshInstance3D.new()
if msh is BoxMesh: msh.size = sz
elif msh is CylinderMesh: msh.top_radius=sz.x/2; msh.bottom_radius=sz.x/2; msh.height=sz.y
elif msh is SphereMesh: msh.radius=sz.x/2; msh.height=sz.y
m.mesh = msh; m.position = pos
var mat = StandardMaterial3D.new(); mat.albedo_color = col; mat.roughness = 0.3
m.material_override = mat; p.add_child(m)

func _add_c(p: Node3D, sz: Vector3, pos: Vector3):
var c = CollisionShape3D.new(); var s = BoxShape3D.new(); s.size = sz
c.shape = s; c.position = pos; p.add_child(c)
