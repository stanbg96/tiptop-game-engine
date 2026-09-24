extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var camera: Camera3D = $Camera3D
@onready var chat_input: LineEdit = $UI/ChatBar/Input
@onready var status_lbl: Label = $UI/StatusBar/Label
@onready var world_spawn: Node3D = $WorldObjects
@onready var http_request: HTTPRequest = $HTTPRequest

# Камера зад играча
var cam_yaw: float = 0.0
var cam_pitch: float = -0.3
var cam_distance: float = 5.5
var api_key: String = ""

func _ready():
http_request.request_completed.connect(_on_ai_response)
status_lbl.text = "Движи човека с джойстика долу вляво!"
_spawn_initial_props()

func _spawn_initial_props():
# Добавяне на няколко 3D обекта за ориентир в пространството
for i in range(4):
var box = CSGBox3D.new()
box.size = Vector3(2.5, 3.5, 2.5)
box.position = Vector3(-8 + i * 5, 1.75, -10)
var mat = StandardMaterial3D.new()
mat.albedo_color = Color(1.0, 0.3, 0.0) if i % 2 == 0 else Color(0.0, 0.8, 0.9)
mat.metallic = 0.3
box.material = mat
world_spawn.add_child(box)

func _process(delta):
if not player: return

# Камерата стои плътно зад човека и го следва плавно
var target_look = player.global_position + Vector3(0, 1.4, 0)
var offset = Vector3(
sin(cam_yaw) * cos(cam_pitch) * cam_distance,
-sin(cam_pitch) * cam_distance,
cos(cam_yaw) * cos(cam_pitch) * cam_distance
)
var target_cam_pos = target_look + offset
camera.global_position = camera.global_position.lerp(target_cam_pos, 10.0 * delta)
camera.look_at(target_look, Vector3.UP)

func _input(event):
# Плъзгане по дясната половина на екрана върти камерата около човека
if event is InputEventScreenDrag:
if event.position.x > get_viewport().size.x * 0.4:
cam_yaw += event.relative.x * 0.007
cam_pitch = clamp(cam_pitch + event.relative.y * 0.007, -0.85, 0.1)

# === ЧАТ СТРОИТЕЛ ОТДОЛУ ===
func _on_send_chat():
var prompt = chat_input.text.strip_edges()
if prompt.is_empty(): return
chat_input.text = ""

status_lbl.text = "Строене: " + prompt

# Изчисляване на позиция пред човека
var spawn_pos = player.global_position - player.transform.basis.z * 3.5
spawn_pos.y = 1.5

# Разпознаване на бързи команди или извикване на AI
var p_low = prompt.to_lower()
if "кола" in p_low:
_spawn_prop_box(spawn_pos, Vector3(2.0, 0.8, 4.0), Color(1.0, 0.0, 0.3))
elif "сграда" in p_low or "блок" in p_low:
_spawn_prop_box(spawn_pos, Vector3(4.0, 8.0, 4.0), Color(0.15, 0.25, 0.4))
elif "дърво" in p_low:
_spawn_prop_cylinder(spawn_pos, 0.3, 4.0, Color(0.35, 0.2, 0.1))
else:
_spawn_prop_box(spawn_pos, Vector3(2.0, 2.0, 2.0), Color(randf(), randf(), randf()))

func _spawn_prop_box(pos: Vector3, sz: Vector3, col: Color):
var box = RigidBody3D.new()
box.position = pos
var mesh = MeshInstance3D.new()
var b = BoxMesh.new()
b.size = sz
mesh.mesh = b
var mat = StandardMaterial3D.new()
mat.albedo_color = col
mat.metallic = 0.5
mat.roughness = 0.2
mesh.material_override = mat
var col_shape = CollisionShape3D.new()
var bs = BoxShape3D.new()
bs.size = sz
col_shape.shape = bs
box.add_child(mesh)
box.add_child(col_shape)
world_spawn.add_child(box)
status_lbl.text = "✓ Обектът е създаден в света!"

func _spawn_prop_cylinder(pos: Vector3, r: float, h: float, col: Color):
var body = StaticBody3D.new()
body.position = pos
var mesh = MeshInstance3D.new()
var c = CylinderMesh.new()
c.top_radius = r; c.bottom_radius = r; c.height = h
mesh.mesh = c
var mat = StandardMaterial3D.new()
mat.albedo_color = col
mesh.material_override = mat
var col_s = CollisionShape3D.new()
var cs = CylinderShape3D.new()
cs.radius = r; cs.height = h
col_s.shape = cs
body.add_child(mesh)
body.add_child(col_s)
world_spawn.add_child(body)
status_lbl.text = "✓ Обектът е създаден в света!"

func _on_ai_response(res, code, headers, body: PackedByteArray):
pass
