class_name ProceduralCore

static func compute_smooth_normals(verts: PackedVector3Array, indices: PackedInt32Array) -> PackedVector3Array:
var normals = PackedVector3Array()
normals.resize(verts.size())
normals.fill(Vector3.ZERO)

for i in range(0, indices.size(), 3):
var i0 = indices[i]
var i1 = indices[i + 1]
var i2 = indices[i + 2]
var fn = (verts[i1] - verts[i0]).cross(verts[i2] - verts[i0])
normals[i0] += fn
normals[i1] += fn
normals[i2] += fn

for i in range(normals.size()):
if normals[i].length_squared() > 0.00001:
normals[i] = normals[i].normalized()
else:
normals[i] = Vector3.UP
return normals

static func build_bezier_car(recipe: Dictionary) -> Node3D:
var root = Node3D.new()
var body_data = recipe.get("body", {})
var l = float(body_data.get("length", 4.6))
var w = float(body_data.get("width", 2.0))
var h = float(body_data.get("height", 1.25))
var paint_col = Color(body_data.get("paint_color", "#ff003b"))

# Генерация на повърхност в RAM
var u_segs = 16
var v_segs = 10
var verts = PackedVector3Array()
var indices = PackedInt32Array()

for i in range(u_segs + 1):
var tu = float(i) / float(u_segs)
var z = -l * 0.5 + tu * l
var width_factor = sin(tu * PI) * (w * 0.5)
var height_factor = (sin(tu * PI) * 0.4 + 0.6) * h

for j in range(v_segs + 1):
var tv = float(j) / float(v_segs)
var angle = (tv - 0.5) * PI
var x = sin(angle) * width_factor
var y = cos(angle) * (height_factor * 0.5) + (height_factor * 0.5)
verts.append(Vector3(x, y, z))

for i in range(u_segs):
for j in range(v_segs):
var cur = i * (v_segs + 1) + j
var nxt = cur + (v_segs + 1)
indices.append(cur)
indices.append(nxt)
indices.append(cur + 1)
indices.append(cur + 1)
indices.append(nxt)
indices.append(nxt + 1)

var normals = compute_smooth_normals(verts, indices)
var arr = []
arr.resize(Mesh.ARRAY_MAX)
arr[Mesh.ARRAY_VERTEX] = verts
arr[Mesh.ARRAY_NORMAL] = normals
arr[Mesh.ARRAY_INDEX] = indices

var mesh = ArrayMesh.new()
mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)

var car_body = MeshInstance3D.new()
car_body.mesh = mesh

var mat = StandardMaterial3D.new()
mat.albedo_color = paint_col
mat.metallic = 0.95
mat.roughness = 0.12
mat.clearcoat_enabled = true
mat.clearcoat = 1.0
mat.clearcoat_roughness = 0.04
car_body.material_override = mat
root.add_child(car_body)

# Добавяне на колела
var wheel_mesh = CylinderMesh.new()
wheel_mesh.top_radius = 0.36
wheel_mesh.bottom_radius = 0.36
wheel_mesh.height = 0.26
var wheel_mat = StandardMaterial3D.new()
wheel_mat.albedo_color = Color(0.1, 0.1, 0.12)
wheel_mat.roughness = 0.8

var offsets = [
Vector3(-w * 0.48, 0.36, -l * 0.3), Vector3(w * 0.48, 0.36, -l * 0.3),
Vector3(-w * 0.48, 0.36,  l * 0.3), Vector3(w * 0.48, 0.36,  l * 0.3)
]
for off in offsets:
var w_inst = MeshInstance3D.new()
w_inst.mesh = wheel_mesh
w_inst.material_override = wheel_mat
w_inst.rotation.z = deg_to_rad(90)
w_inst.position = off
root.add_child(w_inst)

return root
