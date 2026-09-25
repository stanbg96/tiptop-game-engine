extends RefCounted

static func spawn_piano(pos: Vector3) -> Node3D:
var root = Node3D.new(); root.name = "Grand_Piano"; root.position = pos
var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)
var lq = _mat(Color(0.08,0.08,0.1), 0.06, 0.4); lq.clearcoat_enabled=true; lq.clearcoat=1.0
var gd = _mat(Color(0.96,0.82,0.28), 0.12, 0.96)
_box(rb, Vector3(2.2,0.45,2.6), lq, Vector3(0,1.15,0))
_box(rb, Vector3(1.6,0.44,1.4), lq, Vector3(-0.25,1.15,1.2))
_box(rb, Vector3(2.3,0.06,2.7), lq, Vector3(0.3,1.8,0.1), Vector3(0,0,deg_to_rad(32)))
for lp in [Vector3(-0.9,0.55,-1.0), Vector3(0.9,0.55,-1.0), Vector3(-0.2,0.55,1.6)]:
_cyl(rb, 0.09, 1.1, lq, lp); _sph(rb, 0.07, gd, lp-Vector3(0,0.52,0))
_box(rb, Vector3(1.9,0.08,0.35), _mat(Color(0.96,0.96,0.98)), Vector3(0,0.98,-1.45))
_col(rb, Vector3(2.6, 2.2, 3.2), Vector3(0, 1.1, 0)); return root

static func spawn_car(pos: Vector3) -> Node3D:
var root = Node3D.new(); root.name = "BMW_Cabrio"; root.position = pos
var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)
var p_mat = _mat(Color(0, 0.4, 1.0), 0.14, 0.92); p_mat.clearcoat_enabled=true; p_mat.clearcoat=1.0
var blk = _mat(Color(0.1,0.1,0.12)); var chrm = _mat(Color(0.9,0.9,0.95), 0.15, 0.98)
_box(rb, Vector3(2.1,0.35,4.5), p_mat, Vector3(0,0.45,0))
_box(rb, Vector3(1.95,0.24,1.6), p_mat, Vector3(0,0.65,-1.25))
var gm = StandardMaterial3D.new(); gm.albedo_color=Color(0.1,0.25,0.4,0.4); gm.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
_box(rb, Vector3(1.85,0.48,0.06), gm, Vector3(0,0.92,-0.45), Vector3(deg_to_rad(-24),0,0))
_box(rb, Vector3(0.65,0.5,0.6), blk, Vector3(-0.45,0.72,0.2)); _box(rb, Vector3(0.65,0.5,0.6), blk, Vector3(0.45,0.72,0.2))
for wp in [Vector3(-1.05,0.38,-1.35), Vector3(1.05,0.38,-1.35), Vector3(-1.05,0.38,1.35), Vector3(1.05,0.38,1.35)]:
_cyl(rb, 0.38, 0.28, _mat(Color(0.12,0.12,0.14)), wp, Vector3(0,0,deg_to_rad(90)))
_col(rb, Vector3(2.4, 1.3, 4.6), Vector3(0, 0.65, 0)); return root

static func spawn_wall(pos: Vector3) -> Node3D:
var root = Node3D.new(); root.name = "Brick_Wall"; root.position = pos
var rb = RigidBody3D.new(); rb.mass = 1.5; rb.add_to_group("prop"); root.add_child(rb)
_box(rb, Vector3(6.0,3.2,0.55), _mat(Color(0.7,0.7,0.72)), Vector3(0,1.6,0))
for row in range(6):
var yp = 0.25+row*0.45; var ox = 0.3 if row%2==1 else 0.0
for col in range(-3,4):
var xp = col*0.68+ox; if abs(xp)<2.8: _box(rb, Vector3(0.62,0.38,0.55), _mat(Color(0.72,0.25,0.16)), Vector3(xp,yp,0))
_col(rb, Vector3(6.3,3.4,0.75), Vector3(0,1.7,0)); return root

static func spawn_from_json(recipe: Dictionary, pos: Vector3) -> Node3D:
var root = Node3D.new(); root.name = str(recipe.get("name", "Object")); root.position = pos
var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)
for p in recipe.get("parts", []):
var sh = str(p.get("shape", "box")).to_lower()
var p_pos = Vector3(float(p.get("pos",[0,0,0])[0]), max(0.0, float(p.get("pos",[0,0,0])[1])), float(p.get("pos",[0,0,0])[2]))
var p_sz = Vector3(max(0.05, float(p.get("size",[1,1,1])[0])), max(0.05, float(p.get("size",[1,1,1])[1])), max(0.05, float(p.get("size",[1,1,1])[2])))
var p_rot = Vector3(deg_to_rad(float(p.get("rot",[0,0,0])[0])), deg_to_rad(float(p.get("rot",[0,0,0])[1])), deg_to_rad(float(p.get("rot",[0,0,0])[2])))
var m = _mat(Color.from_string(str(p.get("color", "#00f2fe")), Color.CYAN), float(p.get("roughness", 0.4)), float(p.get("metallic", 0.2)))
if sh == "cylinder": _cyl(rb, p_sz.x * 0.5, p_sz.y, m, p_pos, p_rot)
elif sh == "sphere": _sph(rb, p_sz.x * 0.5, m, p_pos, p_rot)
elif sh == "torus": _torus(rb, p_sz.x * 0.5, 0.1, m, p_pos, p_rot)
elif sh == "prism": _prism(rb, p_sz, m, p_pos, p_rot)
else: _box(rb, p_sz, m, p_pos, p_rot)
_col(rb, Vector3(4, 4, 4), Vector3(0, 2.0, 0)); return root

static func _mat(c: Color, r: float=0.4, m: float=0.0) -> StandardMaterial3D: var mat=StandardMaterial3D.new(); mat.albedo_color=c; mat.roughness=r; mat.metallic=m; return mat
static func _box(p, sz, mat, pos, rot=Vector3.ZERO): var m=BoxMesh.new(); m.size=sz; _add_m(p, m, mat, pos, rot)
func _cyl(p, r, h, mat, pos, rot=Vector3.ZERO): var m=CylinderMesh.new(); m.top_radius=r; m.bottom_radius=r; m.height=h; _add_m(p, m, mat, pos, rot)
static func _sph(p, r, mat, pos, rot=Vector3.ZERO): var m=SphereMesh.new(); m.radius=r; m.height=r*2.0; _add_m(p, m, mat, pos, rot)
static func _torus(p, orad, irad, mat, pos, rot=Vector3.ZERO): var m=TorusMesh.new(); m.outer_radius=orad; m.inner_radius=irad; _add_m(p, m, mat, pos, rot)
static func _prism(p, sz, mat, pos, rot=Vector3.ZERO): var m=PrismMesh.new(); m.size=sz; _add_m(p, m, mat, pos, rot)
static func _col(p, sz, pos): var cs=CollisionShape3D.new(); var bs=BoxShape3D.new(); bs.size=sz; cs.shape=bs; cs.position=pos; p.add_child(cs)
static func _add_m(p, msh, mat, pos, rot): var mi=MeshInstance3D.new(); mi.mesh=msh; mi.material_override=mat; mi.position=pos; mi.rotation=rot; p.add_child(mi)
