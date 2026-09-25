class_name ProceduralArchitect

# КОНЦЕРТНО ПИАНО С PBR ОТРАЖЕНИЯ, ЗЛАТНИ ПАНТИ И ЧЕРВЕН ФИЛЦ
static func build_piano(piano_name: String, pos: Vector3) -> Node3D:
var root = Node3D.new(); root.name = piano_name; root.position = pos
var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

var lacquer = StandardMaterial3D.new()
lacquer.albedo_color = Color(0.08, 0.08, 0.1)
lacquer.metallic = 0.4; lacquer.roughness = 0.06; lacquer.clearcoat_enabled = true; lacquer.clearcoat = 1.0; lacquer.clearcoat_roughness = 0.03

var gold = StandardMaterial3D.new(); gold.albedo_color = Color(0.96, 0.82, 0.28); gold.metallic = 0.96; gold.roughness = 0.12
var red_felt = StandardMaterial3D.new(); red_felt.albedo_color = Color(0.8, 0.05, 0.12); red_felt.roughness = 0.95
var white_keys = StandardMaterial3D.new(); white_keys.albedo_color = Color(0.96, 0.96, 0.98); white_keys.roughness = 0.15
var black_keys = StandardMaterial3D.new(); black_keys.albedo_color = Color(0.06, 0.06, 0.08); black_keys.roughness = 0.08

_box(rb, Vector3(2.2, 0.45, 2.6), lacquer, Vector3(0, 1.15, 0))
_box(rb, Vector3(1.6, 0.44, 1.4), lacquer, Vector3(-0.25, 1.15, 1.2))
_box(rb, Vector3(2.24, 0.04, 2.64), gold, Vector3(0, 1.38, 0))

for lp in [Vector3(-0.9, 0.55, -1.0), Vector3(0.9, 0.55, -1.0), Vector3(-0.2, 0.55, 1.6)]:
_cyl(rb, 0.09, 1.1, lacquer, lp)
_cyl(rb, 0.11, 0.06, gold, lp + Vector3(0, 0.48, 0))
_sph(rb, 0.07, gold, lp - Vector3(0, 0.52, 0))

_box(rb, Vector3(2.3, 0.06, 2.7), lacquer, Vector3(0.3, 1.8, 0.1), Vector3(0, 0, deg_to_rad(32)))
_cyl(rb, 0.03, 0.9, gold, Vector3(0.7, 1.6, 0.2), Vector3(0, 0, deg_to_rad(15)))
_box(rb, Vector3(0.12, 0.05, 0.2), gold, Vector3(-0.8, 1.4, 0.1))
_box(rb, Vector3(0.12, 0.05, 0.2), gold, Vector3(-0.8, 1.4, 1.0))

_box(rb, Vector3(1.92, 0.02, 0.06), red_felt, Vector3(0, 1.04, -1.32))
_box(rb, Vector3(1.9, 0.08, 0.35), white_keys, Vector3(0, 0.98, -1.45))
_box(rb, Vector3(1.7, 0.12, 0.2), black_keys, Vector3(0, 1.02, -1.5))

_box(rb, Vector3(0.35, 0.25, 0.1), lacquer, Vector3(0, 0.3, -0.6))
_box(rb, Vector3(0.06, 0.04, 0.2), gold, Vector3(-0.08, 0.18, -0.68))
_box(rb, Vector3(0.06, 0.04, 0.2), gold, Vector3(0.0, 0.18, -0.68))
_box(rb, Vector3(0.06, 0.04, 0.2), gold, Vector3(0.08, 0.18, -0.68))

var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(2.6, 2.2, 3.2); cs.shape = bs; cs.position.y = 1.1; rb.add_child(cs)
return root

# ДЕТАЙЛЕН СРЕДНОВЕКОВЕН ЗАМЪК
static func build_castle(castle_name: String, pos: Vector3) -> Node3D:
var root = Node3D.new(); root.name = castle_name; root.position = pos
var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

var stone = StandardMaterial3D.new(); stone.albedo_color = Color(0.48, 0.5, 0.55); stone.roughness = 0.95
var blue_roof = StandardMaterial3D.new(); blue_roof.albedo_color = Color(0.12, 0.3, 0.75); blue_roof.roughness = 0.75
var wood_gate = StandardMaterial3D.new(); wood_gate.albedo_color = Color(0.28, 0.15, 0.08); wood_gate.roughness = 0.85
var flag_mat = StandardMaterial3D.new(); flag_mat.albedo_color = Color(1.0, 0.15, 0.15)

_box(rb, Vector3(7.0, 3.5, 7.0), stone, Vector3(0, 1.75, 0))

for tp in [Vector3(-3.8, 0, -3.8), Vector3(3.8, 0, -3.8), Vector3(-3.8, 0, 3.8), Vector3(3.8, 0, 3.8)]:
_cyl(rb, 1.1, 5.5, stone, tp + Vector3(0, 2.75, 0))
var cone = CylinderMesh.new(); cone.top_radius = 0.02; cone.bottom_radius = 1.35; cone.height = 2.2
_add_mesh(rb, cone, blue_roof, tp + Vector3(0, 6.6, 0))

_cyl(rb, 1.8, 7.5, stone, Vector3(0, 3.75, 0))
var main_cone = CylinderMesh.new(); main_cone.top_radius = 0.02; main_cone.bottom_radius = 2.1; main_cone.height = 2.8
_add_mesh(rb, main_cone, blue_roof, Vector3(0, 8.9, 0))
_cyl(rb, 0.04, 1.2, stone, Vector3(0, 10.8, 0))
_box(rb, Vector3(0.6, 0.35, 0.04), flag_mat, Vector3(0.32, 11.1, 0))

for bx in [-2.5, 0.0, 2.5]:
_box(rb, Vector3(0.7, 0.45, 0.3), stone, Vector3(bx, 3.75, -3.6))
_box(rb, Vector3(0.7, 0.45, 0.3), stone, Vector3(bx, 3.75, 3.6))

_box(rb, Vector3(2.2, 2.6, 0.2), wood_gate, Vector3(0, 1.3, -3.6))
_torus(rb, 1.1, 0.15, stone, Vector3(0, 2.6, -3.62), Vector3(deg_to_rad(90), 0, 0))

var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(10.0, 11.5, 10.0); cs.shape = bs; cs.position.y = 5.0; rb.add_child(cs)
return root

# СПОРТНО БЕМВЕ КАБРИО СЪС САЛОН И ВОЛАН
static func build_car(car_name: String, color_hex: String, is_cabrio: bool, pos: Vector3) -> Node3D:
var root = Node3D.new(); root.name = car_name; root.position = pos
var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

var p_mat = StandardMaterial3D.new()
p_mat.albedo_color = Color.from_string(color_hex, Color.RED)
p_mat.metallic = 0.92; p_mat.roughness = 0.14; p_mat.clearcoat_enabled = true; p_mat.clearcoat = 1.0

var black_mat = StandardMaterial3D.new(); black_mat.albedo_color = Color(0.1, 0.1, 0.12); black_mat.roughness = 0.5
var chrome_mat = StandardMaterial3D.new(); chrome_mat.albedo_color = Color(0.9, 0.9, 0.95); chrome_mat.metallic = 0.98; chrome_mat.roughness = 0.15
var tire_mat = StandardMaterial3D.new(); tire_mat.albedo_color = Color(0.12, 0.12, 0.14); tire_mat.roughness = 0.85

_box(rb, Vector3(2.1, 0.35, 4.5), p_mat, Vector3(0, 0.45, 0))
_box(rb, Vector3(2.15, 0.12, 0.4), black_mat, Vector3(0, 0.32, -2.15))
_box(rb, Vector3(1.2, 0.22, 0.06), black_mat, Vector3(0, 0.48, -2.26))
_box(rb, Vector3(1.95, 0.24, 1.6), p_mat, Vector3(0, 0.65, -1.25))

if is_cabrio:
var g_mat = StandardMaterial3D.new(); g_mat.albedo_color = Color(0.1, 0.25, 0.4, 0.4); g_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS; g_mat.roughness = 0.05
_box(rb, Vector3(1.85, 0.48, 0.06), g_mat, Vector3(0, 0.92, -0.45), Vector3(deg_to_rad(-24), 0, 0))
var s_mat = StandardMaterial3D.new(); s_mat.albedo_color = Color(0.15, 0.15, 0.18); s_mat.roughness = 0.6
_box(rb, Vector3(0.65, 0.5, 0.6), s_mat, Vector3(-0.45, 0.72, 0.2))
_box(rb, Vector3(0.35, 0.22, 0.15), s_mat, Vector3(-0.45, 1.05, 0.45))
_box(rb, Vector3(0.65, 0.5, 0.6), s_mat, Vector3(0.45, 0.72, 0.2))
_box(rb, Vector3(0.35, 0.22, 0.15), s_mat, Vector3(0.45, 1.05, 0.45))
_box(rb, Vector3(1.6, 0.22, 0.4), black_mat, Vector3(0, 0.78, -0.28))
_torus(rb, 0.18, 0.03, chrome_mat, Vector3(-0.45, 0.88, -0.15), Vector3(deg_to_rad(25), 0, 0))
else:
var cm = StandardMaterial3D.new(); cm.albedo_color = Color(0.08, 0.1, 0.15); cm.roughness = 0.1
_box(rb, Vector3(1.65, 0.55, 2.1), cm, Vector3(0, 0.85, 0.1))

_box(rb, Vector3(0.22, 0.12, 0.14), p_mat, Vector3(-1.16, 0.92, -0.4))
_box(rb, Vector3(0.22, 0.12, 0.14), p_mat, Vector3(1.16, 0.92, -0.4))
_box(rb, Vector3(1.9, 0.28, 1.15), p_mat, Vector3(0, 0.65, 1.45))
_box(rb, Vector3(2.0, 0.06, 0.35), black_mat, Vector3(0, 0.96, 1.85))

var hl_mat = StandardMaterial3D.new(); hl_mat.albedo_color = Color(1, 1, 1); hl_mat.emission_enabled = true; hl_mat.emission = Color(0.85, 0.95, 1.0); hl_mat.emission_energy_multiplier = 4.0
_box(rb, Vector3(0.42, 0.14, 0.05), hl_mat, Vector3(-0.7, 0.56, -2.26))
_box(rb, Vector3(0.42, 0.14, 0.05), hl_mat, Vector3(0.7, 0.56, -2.26))

var tl_mat = StandardMaterial3D.new(); tl_mat.albedo_color = Color(1, 0, 0); tl_mat.emission_enabled = true; tl_mat.emission = Color(1.0, 0.05, 0.05); tl_mat.emission_energy_multiplier = 4.0
_box(rb, Vector3(0.55, 0.12, 0.05), tl_mat, Vector3(-0.65, 0.6, 2.26))
_box(rb, Vector3(0.55, 0.12, 0.05), tl_mat, Vector3(0.65, 0.6, 2.26))

for w_pos in [Vector3(-1.05, 0.38, -1.35), Vector3(1.05, 0.38, -1.35), Vector3(-1.05, 0.38, 1.35), Vector3(1.05, 0.38, 1.35)]:
_cyl(rb, 0.38, 0.28, tire_mat, w_pos, Vector3(0, 0, deg_to_rad(90)))
_cyl(rb, 0.24, 0.29, chrome_mat, w_pos, Vector3(0, 0, deg_to_rad(90)))

var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(2.4, 1.3, 4.6); cs.shape = bs; cs.position.y = 0.65; rb.add_child(cs)
return root

# РЕЛЕФНА ТУХЛЕНА СТЕНА
static func build_brick_wall(wall_name: String, pos: Vector3) -> Node3D:
var root = Node3D.new(); root.name = wall_name; root.position = pos
var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

var brick_red = StandardMaterial3D.new(); brick_red.albedo_color = Color(0.72, 0.25, 0.16); brick_red.roughness = 0.92
var brick_dark = StandardMaterial3D.new(); brick_dark.albedo_color = Color(0.58, 0.18, 0.12); brick_dark.roughness = 0.95
var mortar = StandardMaterial3D.new(); mortar.albedo_color = Color(0.7, 0.7, 0.72); mortar.roughness = 0.9
var stone_cap = StandardMaterial3D.new(); stone_cap.albedo_color = Color(0.85, 0.85, 0.88); stone_cap.roughness = 0.85

_box(rb, Vector3(6.0, 3.2, 0.55), mortar, Vector3(0, 1.6, 0))

for row in range(7):
var y_p = 0.25 + row * 0.45
var offset_x = 0.3 if row % 2 == 1 else 0.0
for col_idx in range(-4, 5):
var x_p = col_idx * 0.7 + offset_x
if abs(x_p) < 2.8:
var mat = brick_red if (row + col_idx) % 2 == 0 else brick_dark
_box(rb, Vector3(0.62, 0.38, 0.62), mat, Vector3(x_p, y_p, 0))

_box(rb, Vector3(6.3, 0.18, 0.75), stone_cap, Vector3(0, 3.3, 0))
var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(6.3, 3.4, 0.75); cs.shape = bs; cs.position.y = 1.7; rb.add_child(cs)
return root

# АРХИТЕКТУРНА КЪЩА
static func build_house(house_name: String, wall_color_hex: String, pos: Vector3) -> Node3D:
var root = Node3D.new(); root.name = house_name; root.position = pos
var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

var wall_mat = StandardMaterial3D.new(); wall_mat.albedo_color = Color.from_string(wall_color_hex, Color(0.9, 0.85, 0.75)); wall_mat.roughness = 0.9
var stone_mat = StandardMaterial3D.new(); stone_mat.albedo_color = Color(0.3, 0.32, 0.36); stone_mat.roughness = 0.95
var roof_mat = StandardMaterial3D.new(); roof_mat.albedo_color = Color(0.48, 0.15, 0.12); roof_mat.roughness = 0.8
var wood_mat = StandardMaterial3D.new(); wood_mat.albedo_color = Color(0.28, 0.16, 0.08); wood_mat.roughness = 0.7
var white_frame = StandardMaterial3D.new(); white_frame.albedo_color = Color(0.95, 0.95, 0.95)
var glass = StandardMaterial3D.new(); glass.albedo_color = Color(0.2, 0.4, 0.6, 0.5); glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS; glass.roughness = 0.05
var lantern = StandardMaterial3D.new(); lantern.albedo_color = Color(1, 0.8, 0.2); lantern.emission_enabled = true; lantern.emission = Color(1.0, 0.85, 0.2); lantern.emission_energy_multiplier = 3.0

_box(rb, Vector3(5.4, 0.35, 4.8), stone_mat, Vector3(0, 0.17, 0))
_box(rb, Vector3(1.8, 0.18, 0.8), stone_mat, Vector3(0, 0.09, -2.6))
_box(rb, Vector3(5.0, 3.0, 4.4), wall_mat, Vector3(0, 1.85, 0))
_prism(rb, Vector3(4.8, 1.8, 5.4), roof_mat, Vector3(0, 4.2, 0), Vector3(0, deg_to_rad(90), 0))
_box(rb, Vector3(0.65, 1.6, 0.65), stone_mat, Vector3(1.5, 4.4, 0.6))
_box(rb, Vector3(1.2, 2.1, 0.08), wood_mat, Vector3(0, 1.4, -2.25))
_sph(rb, 0.06, white_frame, Vector3(0.4, 1.35, -2.32))
_box(rb, Vector3(0.18, 0.25, 0.18), lantern, Vector3(0.85, 1.8, -2.3))

for w_pos in [Vector3(-1.5, 1.8, -2.24), Vector3(1.5, 1.8, -2.24), Vector3(-2.54, 1.8, 0), Vector3(2.54, 1.8, 0)]:
_box(rb, Vector3(1.2, 1.2, 0.06), white_frame, w_pos)
_box(rb, Vector3(1.0, 1.0, 0.08), glass, w_pos)

var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(5.6, 5.0, 5.0); cs.shape = bs; cs.position.y = 2.5; rb.add_child(cs)
return root

# КОМПИЛАТОР НА СВОБОДНА JSON РЕЦЕПТА ОТ OPENROUTER
static func compile_json_recipe(recipe: Dictionary, spawn_pos: Vector3) -> Node3D:
var root = Node3D.new()
root.name = str(recipe.get("name", "Custom_Object"))
root.position = spawn_pos
var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

for part in recipe.get("parts", []):
var shape = str(part.get("shape", "box")).to_lower()
var pos = part.get("pos", [0, 0, 0])
var sz = part.get("size", [1, 1, 1])
var rot = part.get("rot", [0, 0, 0])
var col = str(part.get("color", "#00f2fe"))
var met = float(part.get("metallic", 0.2))
var rough = float(part.get("roughness", 0.4))
var clr = float(part.get("clearcoat", 0.0))

var p_pos = Vector3(float(pos[0]), max(0.0, float(pos[1])), float(pos[2]))
var p_sz = Vector3(max(0.05, float(sz[0])), max(0.05, float(sz[1])), max(0.05, float(sz[2])))
var p_rot = Vector3(deg_to_rad(float(rot[0])), deg_to_rad(float(rot[1])), deg_to_rad(float(rot[2])))

var mat = StandardMaterial3D.new()
mat.albedo_color = Color.from_string(col, Color.CYAN)
mat.metallic = met; mat.roughness = rough
if clr > 0.0:
mat.clearcoat_enabled = true; mat.clearcoat = clr; mat.clearcoat_roughness = 0.04

if shape == "cylinder": _cyl(rb, p_sz.x * 0.5, p_sz.y, mat, p_pos, p_rot)
elif shape == "sphere": _sph(rb, p_sz.x * 0.5, mat, p_pos, p_rot)
elif shape == "torus": _torus(rb, p_sz.x * 0.5, max(0.02, p_sz.x * 0.15), mat, p_pos, p_rot)
elif shape == "prism": _prism(rb, p_sz, mat, p_pos, p_rot)
else: _box(rb, p_sz, mat, p_pos, p_rot)

var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(4, 4, 4); cs.shape = bs; cs.position.y = 2.0; rb.add_child(cs)
return root

# ХЕЛПЪРИ
static func _box(p, sz, mat, pos, rot = Vector3.ZERO):
var m = BoxMesh.new(); m.size = sz; _add_mesh(p, m, mat, pos, rot)

static func _cyl(p, r, h, mat, pos, rot = Vector3.ZERO):
var m = CylinderMesh.new(); m.top_radius = r; m.bottom_radius = r; m.height = h; _add_mesh(p, m, mat, pos, rot)

static func _sph(p, r, mat, pos, rot = Vector3.ZERO):
var m = SphereMesh.new(); m.radius = r; m.height = r * 2.0; _add_mesh(p, m, mat, pos, rot)

static func _torus(p, outer_r, inner_r, mat, pos, rot = Vector3.ZERO):
var m = TorusMesh.new(); m.outer_radius = outer_r; m.inner_radius = inner_r; _add_mesh(p, m, mat, pos, rot)

static func _prism(p, sz, mat, pos, rot = Vector3.ZERO):
var m = PrismMesh.new(); m.size = sz; _add_mesh(p, m, mat, pos, rot)

static func _add_mesh(parent, mesh_res, mat, pos, rot = Vector3.ZERO):
var mi = MeshInstance3D.new()
mi.mesh = mesh_res; mi.material_override = mat
mi.position = pos; mi.rotation = rot
parent.add_child(mi)
