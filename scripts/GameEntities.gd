extends RefCounted

static func spawn_player(world: Node3D, pos: Vector3) -> CharacterBody3D:
var p = CharacterBody3D.new(); p.name = "PlayerAvatar"; p.position = pos
var cs = CollisionShape3D.new()
var cap = CapsuleShape3D.new(); cap.radius = 0.45; cap.height = 1.85
cs.shape = cap; cs.position.y = 0.95; p.add_child(cs)

var vis = Node3D.new(); vis.name = "Visuals"; p.add_child(vis)
var b_mat = _mat(Color(0, 0.55, 1)); var h_mat = _mat(Color(1, 0.85, 0.68)); var l_mat = _mat(Color(0.12, 0.14, 0.18))
_box(vis, Vector3(0.75, 0.85, 0.4), b_mat, Vector3(0, 1.15, 0))
_sph(vis, 0.26, h_mat, Vector3(0, 1.82, 0))

var ll = Node3D.new(); ll.name = "LeftLeg"; ll.position = Vector3(-0.22, 0.72, 0); _cyl(ll, 0.12, 0.75, l_mat, Vector3(0, -0.36, 0)); vis.add_child(ll)
var rl = Node3D.new(); rl.name = "RightLeg"; rl.position = Vector3(0.22, 0.72, 0); _cyl(rl, 0.12, 0.75, l_mat, Vector3(0, -0.36, 0)); vis.add_child(rl)
var la = Node3D.new(); la.name = "LeftArm"; la.position = Vector3(-0.46, 1.45, 0); _cyl(la, 0.1, 0.65, b_mat, Vector3(0, -0.28, 0)); vis.add_child(la)
var ra = Node3D.new(); ra.name = "RightArm"; ra.position = Vector3(0.46, 1.45, 0); _cyl(ra, 0.1, 0.65, b_mat, Vector3(0, -0.28, 0)); vis.add_child(ra)
world.add_child(p); return p

static func spawn_car(world: Node3D, name_str: String, col_hex: String, is_cab: bool, pos: Vector3) -> Node3D:
var root = Node3D.new(); root.name = name_str; root.position = pos
var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

var p_mat = StandardMaterial3D.new(); p_mat.albedo_color = Color.from_string(col_hex, Color.RED); p_mat.metallic = 0.92; p_mat.roughness = 0.14; p_mat.clearcoat_enabled = true; p_mat.clearcoat = 1.0
var blk = _mat(Color(0.1, 0.1, 0.12)); var chrm = StandardMaterial3D.new(); chrm.albedo_color = Color(0.9, 0.9, 0.95); chrm.metallic = 0.98; chrm.roughness = 0.15
var tire = StandardMaterial3D.new(); tire.albedo_color = Color(0.12, 0.12, 0.14); tire.roughness = 0.85

_box(rb, Vector3(2.1, 0.35, 4.5), p_mat, Vector3(0, 0.45, 0))
_box(rb, Vector3(2.15, 0.12, 0.4), blk, Vector3(0, 0.32, -2.15))
_box(rb, Vector3(1.95, 0.24, 1.6), p_mat, Vector3(0, 0.65, -1.25))

if is_cab:
var gm = StandardMaterial3D.new(); gm.albedo_color = Color(0.1, 0.25, 0.4, 0.4); gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
_box(rb, Vector3(1.85, 0.48, 0.06), gm, Vector3(0, 0.92, -0.45), Vector3(deg_to_rad(-24), 0, 0))
var sm = _mat(Color(0.15, 0.15, 0.18))
_box(rb, Vector3(0.65, 0.5, 0.6), sm, Vector3(-0.45, 0.72, 0.2)); _box(rb, Vector3(0.65, 0.5, 0.6), sm, Vector3(0.45, 0.72, 0.2))
_box(rb, Vector3(1.6, 0.22, 0.4), blk, Vector3(0, 0.78, -0.28))
_torus(rb, 0.18, 0.03, chrm, Vector3(-0.45, 0.88, -0.15), Vector3(deg_to_rad(25), 0, 0))
else:
_box(rb, Vector3(1.65, 0.55, 2.1), _mat(Color(0.08, 0.1, 0.15)), Vector3(0, 0.85, 0.1))

var hl = StandardMaterial3D.new(); hl.albedo_color = Color(1, 1, 1); hl.emission_enabled = true; hl.emission = Color(0.9, 0.95, 1); hl.emission_energy_multiplier = 4.0
_box(rb, Vector3(0.42, 0.14, 0.05), hl, Vector3(-0.7, 0.56, -2.26)); _box(rb, Vector3(0.42, 0.14, 0.05), hl, Vector3(0.7, 0.56, -2.26))
var tl = StandardMaterial3D.new(); tl.albedo_color = Color(1, 0, 0); tl.emission_enabled = true; tl.emission = Color(1, 0, 0); tl.emission_energy_multiplier = 4.0
_box(rb, Vector3(0.55, 0.12, 0.05), tl, Vector3(-0.65, 0.6, 2.26)); _box(rb, Vector3(0.55, 0.12, 0.05), tl, Vector3(0.65, 0.6, 2.26))

for wp in [Vector3(-1.05, 0.38, -1.35), Vector3(1.05, 0.38, -1.35), Vector3(-1.05, 0.38, 1.35), Vector3(1.05, 0.38, 1.35)]:
_cyl(rb, 0.38, 0.28, tire, wp, Vector3(0, 0, deg_to_rad(90)))
_cyl(rb, 0.24, 0.29, chrm, wp, Vector3(0, 0, deg_to_rad(90)))

var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(2.4, 1.3, 4.6); cs.shape = bs; cs.position.y = 0.65; rb.add_child(cs)
world.add_child(root); return root

static func spawn_piano(world: Node3D, pos: Vector3) -> Node3D:
var root = Node3D.new(); root.name = "Grand_Piano"; root.position = pos
var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)
var lq = StandardMaterial3D.new(); lq.albedo_color = Color(0.08, 0.08, 0.1); lq.metallic = 0.4; lq.roughness = 0.06; lq.clearcoat_enabled = true; lq.clearcoat = 1.0
var gd = StandardMaterial3D.new(); gd.albedo_color = Color(0.96, 0.82, 0.28); gd.metallic = 0.96; gd.roughness = 0.12
var wk = _mat(Color(0.96, 0.96, 0.98)); var bk = _mat(Color(0.06, 0.06, 0.08)); var rf = _mat(Color(0.8, 0.05, 0.12))

_box(rb, Vector3(2.2, 0.45, 2.6), lq, Vector3(0, 1.15, 0))
_box(rb, Vector3(1.6, 0.44, 1.4), lq, Vector3(-0.25, 1.15, 1.2))
_box(rb, Vector3(2.24, 0.04, 2.64), gd, Vector3(0, 1.38, 0))
for lp in [Vector3(-0.9, 0.55, -1.0), Vector3(0.9, 0.55, -1.0), Vector3(-0.2, 0.55, 1.6)]:
_cyl(rb, 0.09, 1.1, lq, lp); _sph(rb, 0.07, gd, lp - Vector3(0, 0.52, 0))
_box(rb, Vector3(2.3, 0.06, 2.7), lq, Vector3(0.3, 1.8, 0.1), Vector3(0, 0, deg_to_rad(32)))
_cyl(rb, 0.03, 0.9, gd, Vector3(0.7, 1.6, 0.2), Vector3(0, 0, deg_to_rad(15)))
_box(rb, Vector3(1.92, 0.02, 0.06), rf, Vector3(0, 1.04, -1.32))
_box(rb, Vector3(1.9, 0.08, 0.35), wk, Vector3(0, 0.98, -1.45))
_box(rb, Vector3(1.7, 0.12, 0.2), bk, Vector3(0, 1.02, -1.5))
_box(rb, Vector3(0.35, 0.25, 0.1), lq, Vector3(0, 0.3, -0.6))

var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(2.6, 2.2, 3.2); cs.shape = bs; cs.position.y = 1.1; rb.add_child(cs)
world.add_child(root); return root

static func spawn_brick_wall(world: Node3D, pos: Vector3) -> Node3D:
var root = Node3D.new(); root.name = "Brick_Wall"; root.position = pos
var r_mat = _mat(Color(0.75, 0.25, 0.16)); var d_mat = _mat(Color(0.58, 0.18, 0.12))
for row in range(6):
var yp = 0.25 + row * 0.45; var ox = 0.32 if row % 2 == 1 else 0.0
for col in range(-3, 4):
var rb = RigidBody3D.new(); rb.mass = 1.5; rb.position = Vector3(col * 0.68 + ox, yp, 0)
var bm = BoxMesh.new(); bm.size = Vector3(0.62, 0.38, 0.55)
var mi = MeshInstance3D.new(); mi.mesh = bm; mi.material_override = (r_mat if (row + col) % 2 == 0 else d_mat); rb.add_child(mi)
var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = bm.size; cs.shape = bs; rb.add_child(cs)
root.add_child(rb)
world.add_child(root); return root

static func spawn_castle(world: Node3D, pos: Vector3) -> Node3D:
var root = Node3D.new(); root.name = "Medieval_Castle"; root.position = pos
var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)
var st = _mat(Color(0.48, 0.5, 0.55)); var rf = _mat(Color(0.12, 0.3, 0.75))
_box(rb, Vector3(7.0, 3.5, 7.0), st, Vector3(0, 1.75, 0))
for tp in [Vector3(-3.8, 0, -3.8), Vector3(3.8, 0, -3.8), Vector3(-3.8, 0, 3.8), Vector3(3.8, 0, 3.8)]:
_cyl(rb, 1.1, 5.5, st, tp + Vector3(0, 2.75, 0))
var cone = CylinderMesh.new(); cone.top_radius = 0.02; cone.bottom_radius = 1.35; cone.height = 2.2
_add_m(rb, cone, rf, tp + Vector3(0, 6.6, 0))
_cyl(rb, 1.8, 7.5, st, Vector3(0, 3.75, 0))
var mc = CylinderMesh.new(); mc.top_radius = 0.02; mc.bottom_radius = 2.1; mc.height = 2.8
_add_m(rb, mc, rf, Vector3(0, 8.9, 0))
var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(10.0, 11.5, 10.0); cs.shape = bs; cs.position.y = 5.0; rb.add_child(cs)
world.add_child(root); return root

static func spawn_bot(world: Node3D, pos: Vector3) -> Node3D:
var root = Node3D.new(); root.name = "NPC_Bot"; root.position = pos
var rb = RigidBody3D.new(); rb.mass = 2.0; rb.add_to_group("prop"); root.add_child(rb)
var zm = _mat(Color(0.2, 0.75, 0.3))
_box(rb, Vector3(0.8, 1.2, 0.5), zm, Vector3(0, 1.0, 0)); _sph(rb, 0.28, zm, Vector3(0, 1.8, 0))
var hpm = StandardMaterial3D.new(); hpm.albedo_color = Color(0, 1, 0); hpm.emission_enabled = true; hpm.emission = Color(0, 1, 0)
_box(rb, Vector3(0.8, 0.08, 0.08), hpm, Vector3(0, 2.3, 0))
var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(1.2, 2.2, 1.0); cs.shape = bs; cs.position.y = 1.1; rb.add_child(cs)
world.add_child(root); return root

static func _mat(col: Color) -> StandardMaterial3D:
var m = StandardMaterial3D.new(); m.albedo_color = col; m.roughness = 0.4; return m
static func _box(p, sz, mat, pos, rot = Vector3.ZERO):
var m = BoxMesh.new(); m.size = sz; _add_m(p, m, mat, pos, rot)
static func _cyl(p, r, h, mat, pos, rot = Vector3.ZERO):
var m = CylinderMesh.new(); m.top_radius = r; m.bottom_radius = r; m.height = h; _add_m(p, m, mat, pos, rot)
static func _sph(p, r, mat, pos, rot = Vector3.ZERO):
var m = SphereMesh.new(); m.radius = r; m.height = r * 2.0; _add_m(p, m, mat, pos, rot)
static func _torus(p, orad, irad, mat, pos, rot = Vector3.ZERO):
var m = TorusMesh.new(); m.outer_radius = orad; m.inner_radius = irad; _add_m(p, m, mat, pos, rot)
static func _add_m(parent, msh, mat, pos, rot = Vector3.ZERO):
var mi = MeshInstance3D.new(); mi.mesh = msh; mi.material_override = mat; mi.position = pos; mi.rotation = rot; parent.add_child(mi)
