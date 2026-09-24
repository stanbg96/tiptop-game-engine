extends CharacterBody3D

@export var move_speed: float = 9.0
@export var gravity: float = 24.0

var walk_cycle: float = 0.0
var left_leg: Node3D
var right_leg: Node3D
var left_arm: Node3D
var right_arm: Node3D
var visuals: Node3D

func _ready():
_build_human_body()

func _physics_process(delta):
if not is_on_floor():
velocity.y -= gravity * delta
else:
velocity.y = 0.0

# Вземане на посоката от Джойстика
var input_vec = Vector2.ZERO
var main = get_parent()
if main and main.has_node("UI/Joystick"):
input_vec = main.get_node("UI/Joystick").output

if input_vec.length() > 0.1:
# Изчисляване на движение спрямо завъртането на камерата
var cam_rot = 0.0
if main and main.has_node("Camera3D"):
cam_rot = main.get_node("Camera3D").rotation.y

var move_dir = Vector3(input_vec.x, 0, input_vec.y).rotated(Vector3.UP, cam_rot)
velocity.x = move_dir.x * move_speed
velocity.z = move_dir.z * move_speed

# Завъртане на човека по посоката на ходене
var target_angle = atan2(move_dir.x, move_dir.z)
visuals.rotation.y = lerp_angle(visuals.rotation.y, target_angle, 12.0 * delta)

# Анимация на ходене (размахване на крака и ръце)
walk_cycle += delta * move_speed * 1.5
var swing = sin(walk_cycle) * 0.65
if left_leg: left_leg.rotation.x = swing
if right_leg: right_leg.rotation.x = -swing
if left_arm: left_arm.rotation.x = -swing
if right_arm: right_arm.rotation.x = swing
else:
velocity.x = move_toward(velocity.x, 0.0, 15.0 * delta)
velocity.z = move_toward(velocity.z, 0.0, 15.0 * delta)
# Връщане в изправено състояние
if left_leg: left_leg.rotation.x = lerp(left_leg.rotation.x, 0.0, 10.0 * delta)
if right_leg: right_leg.rotation.x = lerp(right_leg.rotation.x, 0.0, 10.0 * delta)
if left_arm: left_arm.rotation.x = lerp(left_arm.rotation.x, 0.0, 10.0 * delta)
if right_arm: right_arm.rotation.x = lerp(right_arm.rotation.x, 0.0, 10.0 * delta)

move_and_slide()

# Генериране на 3D тялото на човека
func _build_human_body():
# Физичен колидер
var col = CollisionShape3D.new()
var cap = CapsuleShape3D.new()
cap.radius = 0.4
cap.height = 1.9
col.shape = cap
col.position.y = 0.95
add_child(col)

visuals = Node3D.new()
add_child(visuals)

# 1. Тяло / Яке (Светло син неонов пуловер)
var body_mesh = MeshInstance3D.new()
var b_box = BoxMesh.new()
b_box.size = Vector3(0.65, 0.8, 0.35)
body_mesh.mesh = b_box
var mat_body = StandardMaterial3D.new()
mat_body.albedo_color = Color(0.0, 0.55, 1.0)
mat_body.roughness = 0.4
body_mesh.material_override = mat_body
body_mesh.position.y = 1.15
visuals.add_child(body_mesh)

# 2. Глава (Сфера с очи/визьор)
var head_mesh = MeshInstance3D.new()
var h_sph = SphereMesh.new()
h_sph.radius = 0.24
h_sph.height = 0.48
head_mesh.mesh = h_sph
var mat_head = StandardMaterial3D.new()
mat_head.albedo_color = Color(1.0, 0.82, 0.65)
head_mesh.material_override = mat_head
head_mesh.position.y = 1.8
visuals.add_child(head_mesh)

# Светещ кибер визьор на главата
var visor = MeshInstance3D.new()
var v_box = BoxMesh.new()
v_box.size = Vector3(0.3, 0.09, 0.12)
visor.mesh = v_box
var mat_v = StandardMaterial3D.new()
mat_v.albedo_color = Color(0.0, 0.95, 1.0)
mat_v.emission_enabled = true
mat_v.emission = Color(0.0, 0.95, 1.0)
visor.material_override = mat_v
visor.position = Vector3(0, 1.8, 0.2)
visuals.add_child(visor)

# 3. Крака (Тъмни панталони)
var leg_mat = StandardMaterial3D.new()
leg_mat.albedo_color = Color(0.12, 0.14, 0.18)
var l_mesh = CapsuleMesh.new()
l_mesh.radius = 0.11
l_mesh.height = 0.75

left_leg = Node3D.new()
left_leg.position = Vector3(-0.2, 0.75, 0)
var ll_inst = MeshInstance3D.new()
ll_inst.mesh = l_mesh
ll_inst.material_override = leg_mat
ll_inst.position.y = -0.35
left_leg.add_child(ll_inst)
visuals.add_child(left_leg)

right_leg = Node3D.new()
right_leg.position = Vector3(0.2, 0.75, 0)
var rl_inst = MeshInstance3D.new()
rl_inst.mesh = l_mesh
rl_inst.material_override = leg_mat
rl_inst.position.y = -0.35
right_leg.add_child(rl_inst)
visuals.add_child(right_leg)

# 4. Ръце
var arm_mat = StandardMaterial3D.new()
arm_mat.albedo_color = Color(0.0, 0.45, 0.85)
var a_mesh = CapsuleMesh.new()
a_mesh.radius = 0.09
a_mesh.height = 0.65

left_arm = Node3D.new()
left_arm.position = Vector3(-0.42, 1.45, 0)
var la_inst = MeshInstance3D.new()
la_inst.mesh = a_mesh
la_inst.material_override = arm_mat
la_inst.position.y = -0.28
left_arm.add_child(la_inst)
visuals.add_child(left_arm)

right_arm = Node3D.new()
right_arm.position = Vector3(0.42, 1.45, 0)
var ra_inst = MeshInstance3D.new()
ra_inst.mesh = a_mesh
ra_inst.material_override = arm_mat
ra_inst.position.y = -0.28
right_arm.add_child(ra_inst)
visuals.add_child(right_arm)
