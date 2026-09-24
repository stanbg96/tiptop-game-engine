class_name WorldBuilder

static func build_world(recipe: Dictionary, target_node: Node3D, env: WorldEnvironment, sun: DirectionalLight3D):
for child in target_node.get_children():
child.queue_free()

# Осветление и Небе
if recipe.has("environment"):
var e = recipe["environment"]
if env and env.environment and env.environment.sky:
var sky_mat = env.environment.sky.sky_material
if sky_mat is ProceduralSkyMaterial:
sky_mat.sky_top_color = Color(e.get("sky_top", "#0d1b2a"))
sky_mat.sky_horizon_color = Color(e.get("sky_horizon", "#1b263b"))

if sun:
sun.light_color = Color(e.get("sun_color", "#fff2cc"))
sun.light_energy = float(e.get("sun_energy", 1.5))
var rot = e.get("sun_rot", [-45, 30])
sun.rotation_degrees = Vector3(rot[0], rot[1], 0)

# Терен / Земна основа с процедурен асфалтов/бетонен шейдър
if recipe.has("terrain"):
var t = recipe["terrain"]
var t_type = t.get("type", "flat")
var t_size = float(t.get("size", 120.0))
var t_color = Color(t.get("color", "#151c28"))

var terrain_mesh: Mesh
if t_type == "flat":
var plane = PlaneMesh.new()
plane.size = Vector2(t_size, t_size)
terrain_mesh = plane
else:
terrain_mesh = ProceduralCore.generate_terrain(36, t_size, float(t.get("height", 14.0)), t_type)

var terrain_inst = MeshInstance3D.new()
terrain_inst.mesh = terrain_mesh

# Прилагане на Шейдър Режим 1 (Процедурен асфалт с шумов микрорелеф)
terrain_inst.material_override = ProceduralCore.get_procedural_material(1, t_color, 0.05, 0.85)

var body = StaticBody3D.new()
var col = CollisionShape3D.new()
col.shape = terrain_mesh.create_trimesh_shape()
body.add_child(col)
body.add_child(terrain_inst)
target_node.add_child(body)

# Обекти
if recipe.has("entities") and recipe["entities"] is Array:
for e in recipe["entities"]:
_spawn_entity(e, target_node)

static func _spawn_entity(d: Dictionary, parent: Node3D):
var type = d.get("type", "prop")
var pos = d.get("pos", [0, 0, 0])
var rot = d.get("rot", [0, 0, 0])
var sca = d.get("scale", [1, 1, 1])

var node = Node3D.new()
node.position = Vector3(pos[0], pos[1], pos[2])
node.rotation_degrees = Vector3(rot[0], rot[1], rot[2])
node.scale = Vector3(sca[0], sca[1], sca[2])

match type:
"building":
_build_building(node, d)
"vehicle":
_build_vehicle(node, d)
"tree":
_build_tree(node, d)
"light":
_build_light(node, d)
_:
_build_prop(node, d)

parent.add_child(node)

static func _build_building(parent: Node3D, d: Dictionary):
var floors = int(d.get("floors", 8))
var floor_h = 2.4
var w = float(d.get("width", 7.0))
var col = Color(d.get("color", "#151b26"))
var neon = Color(d.get("neon", "#00f2fe"))

var b_mesh = BoxMesh.new()
b_mesh.size = Vector3(w, floors * floor_h, w)
var b_inst = MeshInstance3D.new()
b_inst.mesh = b_mesh
# Бетонна текстура през шейдъра
b_inst.material_override = ProceduralCore.get_procedural_material(1, col, 0.1, 0.9)
b_inst.position.y = (floors * floor_h) * 0.5
parent.add_child(b_inst)

# Процедурен светещ неон (Шейдър Режим 2)
for f in range(1, floors + 1):
var ring = BoxMesh.new()
ring.size = Vector3(w * 1.02, 0.15, w * 1.02)
var ring_inst = MeshInstance3D.new()
ring_inst.mesh = ring
ring_inst.material_override = ProceduralCore.get_procedural_material(2, Color.BLACK, 0.5, 0.2, 0.0, neon)
ring_inst.position.y = f * floor_h
parent.add_child(ring_inst)

static func _build_vehicle(parent: Node3D, d: Dictionary):
var col = Color(d.get("color", "#ff0037"))

# Шейдър Режим 0: Истинска автомобилна боя с Clearcoat и металикови микрочастици
var paint_mat = ProceduralCore.get_procedural_material(0, col, 0.96, 0.12, 1.0)
# Шейдър Режим 3: Автомобилно стъкло
var glass_mat = ProceduralCore.get_procedural_material(3, Color(0.05, 0.08, 0.12, 0.35), 0.1, 0.05)

var chassis = BoxMesh.new()
chassis.size = Vector3(2.0, 0.6, 4.5)
var ch_inst = MeshInstance3D.new()
ch_inst.mesh = chassis
ch_inst.material_override = paint_mat
ch_inst.position.y = 0.5
parent.add_child(ch_inst)

var cabin = BoxMesh.new()
cabin.size = Vector3(1.5, 0.6, 2.2)
var cab_inst = MeshInstance3D.new()
cab_inst.mesh = cabin
cab_inst.material_override = glass_mat
cab_inst.position = Vector3(0, 1.0, -0.2)
parent.add_child(cab_inst)

var wheel_mesh = CylinderMesh.new()
wheel_mesh.top_radius = 0.38
wheel_mesh.bottom_radius = 0.38
wheel_mesh.height = 0.28
var wheel_mat = ProceduralCore.get_procedural_material(1, Color(0.08, 0.08, 0.09), 0.0, 0.9)

var offsets = [
Vector3(-1.05, 0.38, 1.4), Vector3(1.05, 0.38, 1.4),
Vector3(-1.05, 0.38, -1.4), Vector3(1.05, 0.38, -1.4)
]
for off in offsets:
var w_inst = MeshInstance3D.new()
w_inst.mesh = wheel_mesh
w_inst.material_override = wheel_mat
w_inst.rotation.z = deg_to_rad(90)
w_inst.position = off
parent.add_child(w_inst)

static func _build_tree(parent: Node3D, d: Dictionary):
var h = float(d.get("height", 5.0))
var trunk = CylinderMesh.new()
trunk.bottom_radius = 0.35
trunk.top_radius = 0.18
trunk.height = h * 0.5
var tr_inst = MeshInstance3D.new()
tr_inst.mesh = trunk
tr_inst.material_override = ProceduralCore.get_procedural_material(1, Color(d.get("trunk_color", "#2d1b00")), 0.0, 0.95)
tr_inst.position.y = (h * 0.5) * 0.5
parent.add_child(tr_inst)

for i in range(3):
var foliage = CylinderMesh.new()
foliage.bottom_radius = 1.8 - (i * 0.4)
foliage.top_radius = 0.0
foliage.height = h * 0.35
var fol_inst = MeshInstance3D.new()
fol_inst.mesh = foliage
fol_inst.material_override = ProceduralCore.get_procedural_material(1, Color(d.get("leaf_color", "#1b5e20")), 0.05, 0.8)
fol_inst.position.y = (h * 0.35) + (i * (h * 0.22))
parent.add_child(fol_inst)

static func _build_light(parent: Node3D, d: Dictionary):
var light = OmniLight3D.new()
light.light_color = Color(d.get("color", "#00f2fe"))
light.light_energy = float(d.get("energy", 4.0))
light.omni_range = float(d.get("range", 20.0))
parent.add_child(light)

static func _build_prop(parent: Node3D, d: Dictionary):
var box = BoxMesh.new()
var inst = MeshInstance3D.new()
inst.mesh = box
inst.material_override = ProceduralCore.get_procedural_material(0, Color(d.get("color", "#00f2fe")), 0.5, 0.4)
parent.add_child(inst)
