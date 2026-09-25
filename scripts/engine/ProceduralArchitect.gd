extends RefCounted

# КОНЦЕРТНО ПИАНО С PBR ОТРАЖЕНИЯ И ЗЛАТНИ ПАНТИ
static func spawn_piano(pos: Vector3, world: Node3D) -> Node3D:
var root = Node3D.new(); root.name = "Grand_Piano"; root.position = pos
var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

var lacquer = StandardMaterial3D.new()
lacquer.albedo_color = Color(0.08, 0.08, 0.1); lacquer.metallic = 0.4; lacquer.roughness = 0.06; lacquer.clearcoat_enabled = true; lacquer.clearcoat = 1.0
var gold = StandardMaterial3D.new(); gold.albedo_color = Color(0.96, 0.82, 0.28); gold.metallic = 0.96; gold.roughness = 0.12
var red_felt = _mat(Color(0.8, 0.05, 0.12)); var wk = _mat(Color(0.96, 0.96, 0.98)); var bk = _mat(Color(0.06, 0.06, 0.08))

_box(rb, Vector3(2.2, 0.45, 2.6), lacquer, Vector3(0, 1.15, 0))
_box(rb, Vector3(1.6, 0.44, 1.4), lacquer, Vector3(-0.25, 1.15, 1.2))
_box(rb, Vector3(2.24, 0.04, 2.64), gold, Vector3(0, 1.38, 0))

for lp in [Vector3(-0.9, 0.55, -1.0), Vector3(0.9, 0.55, -1.0), Vector3(-0.2, 0.55, 1.6)]:
_cyl(rb, 0.09, 1.1, lacquer, lp); _cyl(rb, 0.11, 0.06, gold, lp + Vector3(0, 0.48, 0)); _sph(rb, 0.07, gold, lp - Vector3(0, 0.52, 0))

_box(rb, Vector3(2.3, 0.06, 2.7), lacquer, Vector3(0.3, 1.8, 0.1), Vector3(0, 0, deg_to_rad(32)))
_cyl(rb, 0.03, 0.9, gold, Vector3(0.7, 1.6, 0.2), Vector3(0, 0, deg_to_rad(15)))
_box(rb, Vector3(0.12, 0.05, 0.2), gold, Vector3(-0.8, 1.4, 0.1))
_box(rb, Vector3(0.12, 0.05, 0.2), gold, Vector3(-0.8, 1.4, 1.0))

_box(rb, Vector3(1.92, 0.02, 0.06), red_felt, Vector3(0, 1.04, -1.32))
_box(rb, Vector3(1.9, 0.08, 0.35), wk, Vector3(0, 0.98, -1.45))
_box(rb, Vector3(1.7, 0.12, 0.2), bk, Vector3(0, 1.02, -1.5))

_box(rb, Vector3(0.35, 0.25, 0.1), lacquer, Vector3(0, 0.3, -0.6))
_box(rb, Vector3(0.06, 0.04, 0.2), gold, Vector3(-0.08, 0.18, -0.68))
_box(rb, Vector3(0.06, 0.04, 0.2), gold, Vector3(0.0, 0.18, -0.68))
_box(rb, Vector3(0.06, 0.04, 0.2), gold, Vector3(0.08, 0.18, -0.68))

_col(rb, Vector3(2.6, 2.2, 3.2), Vector3(0, 1.1, 0))
world.add_child(root); return root

# СРЕДНОВЕКОВЕН ЗАМЪК
static func spawn_castle(pos: Vector3, world: Node3D) -> Node3D:
var root = Node3D.new(); root.name = "Medieval_Castle"; root.position = pos
var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

var stone = _mat(Color(0.48, 0.5, 0.55), 0.95); var blue_roof = _mat(Color(0.12, 0.3, 0.75), 0.75)
var wood = _mat(Color(0.28, 0.15, 0.08)); var flag = _mat(Color(1.0, 0.15, 0.15))

_box(rb, Vector3(7.0, 3.5, 7.0), stone, Vector3(0, 1.75, 0))

for tp in [Vector3(-3.8, 0, -3.8), Vector3(3.8, 0, -3.8), Vector3(-3.8, 0, 3.8), Vector3(3.8, 0, 3.8)]:
_cyl(rb, 1.1, 5.5, stone, tp + Vector3(0, 2.75, 0))
var cone = CylinderMesh.new(); cone.top_radius = 0.02; cone.bottom_radius = 1.35; cone.height = 2.2
_add_mesh(rb, cone, blue_roof, tp + Vector3(0, 6.6, 0), Vector3.ZERO)

_cyl(rb, 1.8, 7.5, stone, Vector3(0, 3.75, 0))
var mcone = CylinderMesh.new(); mcone.top_radius = 0.02; mcone.bottom_radius = 2.1; mcone.height = 2.8
_add_mesh(rb, mcone, blue_roof, Vector3(0, 8.9, 0), Vector3.ZERO)
_cyl(rb, 0.04, 1.2, stone, Vector3(0, 10.8, 0))
_box(rb, Vector3(0.6, 0.35, 0.04), flag, Vector3(0.32, 11.1, 0))

for bx in [-2.5, 0.0, 2.5]:
_box(rb, Vector3(0.7, 0.45, 0.3), stone, Vector3(bx, 3.75, -3.6))
_box(rb, Vector3(0.7, 0.45, 0.3), stone, Vector3(bx, 3.75, 3.6))

_box(rb, Vector3(2.2, 2.6, 0.2), wood, Vector3(0, 1.3, -3.6))
_torus(rb, 1.1, 0.15, stone, Vector3(0, 2.6, -3.62), Vector3(deg_to_rad(90), 0, 0))

_col(rb, Vector3(10.0, 11.5, 10.0), Vector3(0, 5.0, 0))
world.add_child(root); return root

# СПОРТЕН АВТОМОБИЛ / БЕМВЕ КАБРИО
static func spawn_car(pos: Vector3, world: Node3D, car_name: String, color_hex: String, is_cabrio: bool) -> Node3D:
var root = Node3D.new(); root.name = car_name; root.position = pos
var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

var p_mat = StandardMaterial3D.new()
p_mat.albedo_color = Color.from_string(color_hex, Color.RED); p_mat.metallic = 0.92; p_mat.roughness = 0.14; p_mat.clearcoat_enabled = true; p_mat.clearcoat = 1.0

var blk = _mat(Color(0.1, 0.1, 0.12)); var chrm = StandardMaterial3D.new(); chrm.albedo_color = Color(0.9, 0.9, 0.95); chrm.metallic = 0.98; chrm.roughness = 0.15
var tire = _mat(Color(0.12, 0.12, 0.14), 0.85)

_box(rb, Vector3(2.1, 0.35, 4.5), p_mat, Vector3(0, 0.45, 0))
_box(rb, Vector3(2.15, 0.12, 0.4), blk, Vector3(0, 0.32, -2.15))
_box(rb, Vector3(1.2, 0.22, 0.06), blk, Vector3(0, 0.48, -2.26))
_box(rb, Vector3(1.95, 0.24, 1.6), p_mat, Vector3(0, 0.65, -1.25))

if is_cabrio:
var gm = StandardMaterial3D.new(); gm.albedo_color = Color(0.1, 0.25, 0.4, 0.4); gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS; gm.roughness = 0.05
_box(rb, Vector3(1.85, 0.48, 0.06), gm, Vector3(0, 0.92, -0.45), Vector3(deg_to_rad(-24), 0, 0))
var sm = _mat(Color(0.15, 0.15, 0.18), 0.6)
_box(rb, Vector3(0.65, 0.5, 0.6), sm, Vector3(-0.45, 0.72, 0.2)); _box(rb, Vector3(0.65, 0.5, 0.6), sm, Vector3(0.45, 0.72, 0.2))
_box(rb, Vector3(1.6, 0.22, 0.4), blk, Vector3(0, 0.78, -0.28))
_torus(rb, 0.18, 0.03, chrm, Vector3(-0.45, 0.88, -0.15), Vector3(deg_to_rad(25), 0, 0))
else:
_box(rb, Vector3(1.65, 0.55, 2.1), _mat(Color(0.08, 0.1, 0.15)), Vector3(0, 0.85, 0.1))

_box(rb, Vector3(0.22, 0.12, 0.14), p_mat, Vector3(-1.16, 0.92, -0.4)); _box(rb, Vector3(0.22, 0.12, 0.14), p_mat, Vector3(1.16, 0.92, -0.4))
_box(rb, Vector3(1.9, 0.28, 1.15), p_mat, Vector3(0, 0.65, 1.45)); _box(rb, Vector3(2.0, 0.06, 0.35), blk, Vector3(0, 0.96, 1.85))

var hl = StandardMaterial3D.new(); hl.albedo_color = Color(1, 1, 1); hl.emission_enabled = true; hl.emission = Color(0.85, 0.95, 1); hl.emission_energy_multiplier = 4.0
_box(rb, Vector3(0.42, 0.14, 0.05), hl, Vector3(-0.7, 0.56, -2.26)); _box(rb, Vector3(0.42, 0.14, 0.05), hl, Vector3(0.7, 0.56, -2.26))
var tl = StandardMaterial3D.new(); tl.albedo_color = Color(1, 0, 0); tl.emission_enabled = true; tl.emission = Color(1, 0, 0); tl.emission_energy_multiplier = 4.0
_box(rb, Vector3(0.55, 0.12, 0.05), tl, Vector3(-0.65, 0.6, 2.26)); _box(rb, Vector3(0.55, 0.12, 0.05), tl, Vector3(0.65, 0.6, 2.26))

for wp in [Vector3(-1.05, 0.38, -1.35), Vector3(1.05, 0.38, -1.35), Vector3(-1.05, 0.38, 1.35), Vector3(1.05, 0.38, 1.35)]:
_cyl(rb, 0.38, 0.28, tire, wp, Vector3(0, 0, deg_to_rad(90)))
_cyl(rb, 0.24, 0.29, chrm, wp, Vector3(0, 0, deg_to_rad(90)))

_col(rb, Vector3(2.4, 1.3, 4.6), Vector3(0, 0.65, 0))
world.add_child(root); return root

# РЕЛЕФНА ТУХЛЕНА СТЕНА
static func spawn_brick_wall(pos: Vector3, world: Node3D) -> Node3D:
var root = Node3D.new(); root.name = "Brick_Wall"; root.position = pos
var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)
var br = _mat(Color(0.72, 0.25, 0.16), 0.92); var bd = _mat(Color(0.58, 0.18, 0.12), 0.95)
var mt = _mat(Color(0.7, 0.7, 0.72)); var sc = _mat(Color(0.85, 0.85, 0.88), 0.85)

_box(rb, Vector3(6.0, 3.2, 0.55), mt, Vector3(0, 1.6, 0))
for r in range(7):
var yp = 0.25 + r * 0.45; var ox = 0.3 if r % 2 == 1 else 0.0
for c in range(-4, 5):
var xp = c * 0.7 + ox
if abs(xp) < 2.8: _box(rb, Vector3(0.62, 0.38, 0.62), br if (r + c) % 2 == 0 else bd, Vector3(xp, yp, 0))

_box(rb, Vector3(6.3, 0.18, 0.75), sc, Vector3(0, 3.3, 0))
_col(rb, Vector3(6.3, 3.4, 0.75), Vector3(0, 1.7, 0))
world.add_child(root); return root

# АРХИТЕКТУРНА КЪЩА
static func spawn_house(pos: Vector3, world: Node3D, house_name: String, wall_col: String) -> Node3D:
var root = Node3D.new(); root.name = house_name; root.position = pos
var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

var wm = _mat(Color.from_string(wall_col, Color(0.9, 0.85, 0.75)), 0.9)
var sm = _mat(Color(0.3, 0.32, 0.36), 0.95); var rm = _mat(Color(0.48, 0.15, 0.12), 0.8)
var wdm = _mat(Color(0.28, 0.16, 0.08), 0.7); var wfm = _mat(Color(0.95, 0.95, 0.95))
var gm = StandardMaterial3D.new(); gm.albedo_color = Color(0.2, 0.4, 0.6, 0.5); gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS

_box(rb, Vector3(5.4, 0.35, 4.8), sm, Vector3(0, 0.17, 0))
_box(rb, Vector3(1.8, 0.18, 0.8), sm, Vector3(0, 0.09, -2.6))
_box(rb, Vector3(5.0, 3.0, 4.4), wm, Vector3(0, 1.85, 0))
_prism(rb, Vector3(4.8, 1.8, 5.4), rm, Vector3(0, 4.2, 0), Vector3(0, deg_to_rad(90), 0))
_box(rb, Vector3(0.65, 1.6, 0.65), sm, Vector3(1.5, 4.4, 0.6))
_box(rb, Vector3(1.2, 2.1, 0.08), wdm, Vector3(0, 1.4, -2.25))
_sph(rb, 0.06, wfm, Vector3(0.4, 1.35, -2.32))

for wp in [Vector3(-1.5, 1.8, -2.24), Vector3(1.5, 1.8, -2.24), Vector3(-2.54, 1.8, 0), Vector3(2.54, 1.8, 0)]:
_box(rb, Vector3(1.2, 1.2, 0.06), wfm, wp); _box(rb, Vector3(1.0, 1.0, 0.08), gm, wp)

_col(rb, Vector3(5.6, 5.0, 5.0), Vector3(0, 2.5, 0))
world.add_child(root); return root

# КОМПИЛАТОР НА СВОБОДЕН JSON ОТ AI
static func compile_recipe(recipe: Dictionary, pos: Vector3, world: Node3D) -> Node3D:
var root = Node3D.new(); root.name = str(recipe.get("name", "Object")); root.position = pos
var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

for p in recipe.get("parts", []):
var sh = str(p.get("shape", "box")).to_lower()
var p_pos = Vector3(float(p.get("pos", [0,0,0])[0]), max(0.0, float(p.get("pos", [0,0,0])[1])), float(p.get("pos", [0,0,0])[2]))
var p_sz = Vector3(max(0.05, float(p.get("size", [1,1,1])[0])), max(0.05, float(p.get("size", [1,1,1])[1])), max(0.05, float(p.get("size", [1,1,1])[2])))
var p_rot = Vector3(deg_to_rad(float(p.get("rot", [0,0,0])[0])), deg_to_rad(float(p.get("rot", [0,0,0])[1])), deg_to_rad(float(p.get("rot", [0,0,0])[2])))

var m = StandardMaterial3D.new()
m.albedo_color = Color.from_string(str(p.get("color", "#00f2fe")), Color.CYAN)
m.metallic = float(p.get("metallic", 0.2)); m.roughness = float(p.get("roughness", 0.4))
var clr = float(p.get("clearcoat", 0.0))
if clr > 0.0: m.clearcoat_enabled = true; m.clearcoat = clr; m.clearcoat_roughness = 0.04

if sh == "cylinder": _cyl(rb, p_sz.x * 0.5, p_sz.y, m, p_pos, p_rot)
elif sh == "sphere": _sph(rb, p_sz.x * 0.5, m, p_pos, p_rot)
elif sh == "torus": _torus(rb, p_sz.x * 0.5, max(0.02, p_sz.x * 0.15), m, p_pos, p_rot)
elif sh == "prism": _prism(rb, p_sz, m, p_pos, p_rot)
else: _box(rb, p_sz, m, p_pos, p_rot)

_col(rb, Vector3(4, 4, 4), Vector3(0, 2.0, 0))
world.add_child(root); return root

static func _mat(col: Color, rough: float = 0.4) -> StandardMaterial3D:
var m = StandardMaterial3D.new(); m.albedo_color = col; m.roughness = rough; return m
static func _box(p, sz, mat, pos, rot: Vector3 = Vector3.ZERO):
var m = BoxMesh.new(); m.size = sz; _add_mesh(p, m, mat, pos, rot)
static func _cyl(p, r, h, mat, pos, rot: Vector3 = Vector3.ZERO):
var m = CylinderMesh.new(); m.top_radius = r; m.bottom_radius = r; m.height = h; _add_mesh(p, m, mat, pos, rot)
static func _sph(p, r, mat, pos, rot: Vector3 = Vector3.ZERO):
var m = SphereMesh.new(); m.radius = r; m.height = r * 2.0; _add_mesh(p, m, mat, pos, rot)
static func _torus(p, orad, irad, mat, pos, rot: Vector3 = Vector3.ZERO):
var m = TorusMesh.new(); m.outer_radius = orad; m.inner_radius = irad; _add_mesh(p, m, mat, pos, rot)
static func _prism(p, sz, mat, pos, rot: Vector3 = Vector3.ZERO):
var m = PrismMesh.new(); m.size = sz; _add_mesh(p, m, mat, pos, rot)
static func _col(p, sz, pos):
var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = sz; cs.shape = bs; cs.position = pos; p.add_child(cs)
static func _add_mesh(p: Node3D, msh: Mesh, mat: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO):
var mi = MeshInstance3D.new(); mi.mesh = msh; mi.material_override = mat; mi.position = pos; mi.rotation = rot; p.add_child(mi)
