extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var world_objects: Node3D = $WorldObjects
@onready var chat_input: LineEdit = $UI/ChatBar/Input
@onready var status_lbl: Label = $UI/TopBar/Label

# Тъч контроли за движение
func _on_fwd_down(): player.move_forward = true
func _on_fwd_up(): player.move_forward = false

func _on_back_down(): player.move_backward = true
func _on_back_up(): player.move_backward = false

func _on_left_down(): player.turn_left = true
func _on_left_up(): player.turn_left = false

func _on_right_down(): player.turn_right = true
func _on_right_up(): player.turn_right = false

func _on_jump_pressed(): player.jump()

# Чат строител: пуска 3D обекти пред играча
func _on_spawn_pressed():
var text = chat_input.text.strip_edges()
if text.is_empty(): return
chat_input.text = ""

status_lbl.text = "✓ Създадено: " + text

var spawn_pos = player.global_position - player.transform.basis.z * 3.5 + Vector3(0, 2.0, 0)
var rb = RigidBody3D.new()
rb.position = spawn_pos
rb.mass = 3.0

var mesh_inst = MeshInstance3D.new()
var col_shape = CollisionShape3D.new()
var mat = StandardMaterial3D.new()
mat.roughness = 0.3

var t_low = text.to_lower()
if "сфера" in t_low or "топка" in t_low:
var sph = SphereMesh.new()
sph.radius = 0.9
sph.height = 1.8
mesh_inst.mesh = sph
var s_col = SphereShape3D.new()
s_col.radius = 0.9
col_shape.shape = s_col
mat.albedo_color = Color(1.0, 0.2, 0.0)
elif "кола" in t_low:
var box = BoxMesh.new()
box.size = Vector3(2.2, 0.9, 4.2)
mesh_inst.mesh = box
var b_col = BoxShape3D.new()
b_col.size = box.size
col_shape.shape = b_col
mat.albedo_color = Color(0.9, 0.05, 0.2)
mat.metallic = 0.8
else:
var box = BoxMesh.new()
box.size = Vector3(2.0, 2.0, 2.0)
mesh_inst.mesh = box
var b_col = BoxShape3D.new()
b_col.size = box.size
col_shape.shape = b_col
mat.albedo_color = Color(randf(), randf(), randf())

mesh_inst.material_override = mat
rb.add_child(mesh_inst)
rb.add_child(col_shape)
world_objects.add_child(rb)
