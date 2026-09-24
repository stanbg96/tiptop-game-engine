extends Node3D

@onready var camera = $Camera3D
@onready var joy = $UI/VirtualJoystick
@onready var indicator = $SelectionIndicator
@onready var tools_bar = $UI/ToolsBar
@onready var lbl_selected = $UI/ToolsBar/HBox/LabelName
@onready var chat_log = $UI/ChatPanel/VBox/Margin1/Log
@onready var chat_input = $UI/ChatPanel/VBox/Margin2/InputRow/ChatInput
@onready var world_spawn = $WorldObjects

var selected_obj: Node3D = null
var is_dragging: bool = false
var cam_rot_y: float = 0.0
var cam_rot_x: float = -0.2

func _ready():
tools_bar.visible = false
indicator.visible = false
_add_log("[color=#00f2fe]✅ Системата е възстановена успешно![/color]")
_add_log("🕹️ Ползвай джойстика вляво, за да летиш.")
_add_log("👆 Плъзгай по празния екран, за да се оглеждаш.")
_add_log("📦 Напиши обект долу или ползвай бутоните.")

# Създаваме първоначални обекти
_build("дърво", Vector3(-4, 0, -6))
_build("кола", Vector3(4, 0, -6))

func _process(delta):
# 1. ДРОН КАМЕРА (Движение чрез Джойстика)
if joy.output.length() > 0.05:
var forward = -camera.global_transform.basis.z
var right = camera.global_transform.basis.x
forward.y = 0; right.y = 0 # Заключваме височината
forward = forward.normalized(); right = right.normalized()

# output.y е отрицателен, когато буташ джойстика НАГОРЕ
var move_dir = right * joy.output.x + forward * (-joy.output.y)
camera.global_position += move_dir * 12.0 * delta

# 2. МАРКЕР НАД ОБЕКТА
if selected_obj and is_instance_valid(selected_obj):
indicator.visible = true
indicator.global_position = selected_obj.global_position + Vector3(0, 3.0 + sin(Time.get_ticks_msec()*0.005)*0.2, 0)
else:
indicator.visible = false

func _unhandled_input(event):
var screen_h = get_viewport().size.y
var chat_limit = screen_h * 0.65 # Чатът заема долните 35%

if event is InputEventScreenTouch:
if event.position.y > chat_limit: return # Игнорираме, ако цъкаме по чата

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
if event.position.y > chat_limit: return

if is_dragging and selected_obj and is_instance_valid(selected_obj):
# ВЛАЧЕНЕ НА ОБЕКТА ПО ЗЕМЯТА
var drop = _get_floor_hit(event.position)
if drop != Vector3.INF:
selected_obj.global_position.x = drop.x
selected_obj.global_position.z = drop.z
else:
# ОГЛЕЖДАНЕ С КАМЕРАТА (Въртене)
cam_rot_y -= event.relative.x * 0.005
cam_rot_x = clamp(cam_rot_x - event.relative.y * 0.005, -1.5, 1.5)
camera.rotation.y = cam_rot_y
camera.rotation.x = cam_rot_x

func _raycast(pos: Vector2):
var from = camera.project_ray_origin(pos)
var to = from + camera.project_ray_normal(pos) * 1000.0
var q = PhysicsRayQueryParameters3D.create(from, to)
var res = get_world_3d().direct_space_state.intersect_ray(q)
if res and res.collider.is_in_group("obj"):
return res.collider.get_parent() if res.collider is CollisionShape3D else res.collider
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

# --- ИНСТРУМЕНТИ ЗА ОБЕКТА ---
func _on_act_up(): if selected_obj: selected_obj.global_position.y += 0.5
func _on_act_down(): if selected_obj: selected_obj.global_position.y -= 0.5
func _on_act_rot(): if selected_obj: selected_obj.rotate_y(deg_to_rad(45))
func _on_act_col():
if selected_obj:
var c = Color(randf(), randf(), randf())
for child in selected_obj.get_children():
if child is MeshInstance3D:
var m = StandardMaterial3D.new()
m.albedo_color = c
child.material_override = m
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
_build(t.to_lower())

func _on_chip_pressed(txt: String):
_add_log("[color=#00ff88]Ти:[/color] " + txt)
_build(txt.to_lower())

func _build(prompt: String, forced_pos: Vector3 = Vector3.INF):
# Спаунва точно пред камерата на земята
var pos = forced_pos
if pos == Vector3.INF:
var forward = -camera.global_transform.basis.z
forward.y = 0
pos = camera.global_position + forward.normalized() * 6.0
pos.y = 0.0

var obj = StaticBody3D.new()
obj.position = pos
obj.add_to_group("obj")

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
obj.name = "Shape_" + str(randi()%100)
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
