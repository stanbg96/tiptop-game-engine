class_name ProceduralCore

static var pbr_shader: Shader = preload("res://shaders/procedural_pbr.gdshader")

# Изчисляване на Smooth Normals директно в RAM
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

# Създаване на шейдърен материал без картинки
static func get_procedural_material(mode: int, col: Color, met: float = 0.0, rough: float = 0.5, clearcoat: float = 0.0, emit: Color = Color.BLACK) -> ShaderMaterial:
var mat = ShaderMaterial.new()
mat.shader = pbr_shader
mat.set_shader_parameter("material_mode", mode)
mat.set_shader_parameter("albedo_color", col)
mat.set_shader_parameter("metallic_val", met)
mat.set_shader_parameter("roughness_val", rough)
mat.set_shader_parameter("clearcoat_val", clearcoat)
mat.set_shader_parameter("emission_color", emit)
return mat

# Генериране на процедурен 3D терен в RAM
static func generate_terrain(grid_size: int, world_scale: float, height_factor: float, terrain_type: String) -> ArrayMesh:
var verts = PackedVector3Array()
var indices = PackedInt32Array()
var uvs = PackedVector2Array()

var half = world_scale * 0.5
var step = world_scale / float(grid_size)

for z_idx in range(grid_size + 1):
var z = -half + z_idx * step
for x_idx in range(grid_size + 1):
var x = -half + x_idx * step
var y = 0.0

if terrain_type == "mountains":
y = (sin(x * 0.15) * cos(z * 0.15) * 0.6 + sin(x * 0.05 + z * 0.05) * 0.4) * height_factor
elif terrain_type == "islands":
var dist = Vector2(x, z).length()
var island_shape = clamp(1.0 - (dist / (half * 0.85)), 0.0, 1.0)
y = (sin(x * 0.2) * cos(z * 0.2) * 0.5 + 0.5) * height_factor * island_shape
elif terrain_type == "dunes":
y = sin(x * 0.1 + z * 0.05) * (height_factor * 0.35)

verts.append(Vector3(x, y, z))
uvs.append(Vector2(float(x_idx) / grid_size, float(z_idx) / grid_size))

for z_idx in range(grid_size):
for x_idx in range(grid_size):
var r1 = z_idx * (grid_size + 1)
var r2 = (z_idx + 1) * (grid_size + 1)

indices.append(r1 + x_idx)
indices.append(r2 + x_idx)
indices.append(r1 + x_idx + 1)

indices.append(r1 + x_idx + 1)
indices.append(r2 + x_idx)
indices.append(r2 + x_idx + 1)

var normals = compute_smooth_normals(verts, indices)
var arr = []
arr.resize(Mesh.ARRAY_MAX)
arr[Mesh.ARRAY_VERTEX] = verts
arr[Mesh.ARRAY_NORMAL] = normals
arr[Mesh.ARRAY_TEX_UV] = uvs
arr[Mesh.ARRAY_INDEX] = indices

var mesh = ArrayMesh.new()
mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
return mesh
