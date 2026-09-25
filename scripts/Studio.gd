extends Node3D

@onready var camera = $Camera3D
@onready var joy = $UI/VirtualJoystick
@onready var chat_log = $UI/ChatBG/VBox/Margin1/Log
@onready var chat_input = $UI/ChatBG/VBox/Margin2/InputRow/ChatInput
@onready var center_tools = $UI/CenterTools
@onready var lbl_selected = $UI/CenterTools/Panel/VBox/Header/LabelName
@onready var drive_btn = $UI/CenterTools/Panel/VBox/Buttons/BtnDrive
@onready var indicator = $Indicator
@onready var world = $World
@onready var api_page = $UI/ApiPage
@onready var http_request = $HTTPRequest

@onready var provider_select = $UI/ApiPage/Card/Margin/VBox/ProviderSelect
@onready var key_input = $UI/ApiPage/Card/Margin/VBox/KeyInput
@onready var test_btn = $UI/ApiPage/Card/Margin/VBox/TestBtn
@onready var status_lbl = $UI/ApiPage/Card/Margin/VBox/StatusLbl
@onready var models_list_ui = $UI/ApiPage/Card/Margin/VBox/ModelsList

var audio_player: AudioStreamPlayer
var selected_obj: Node3D = null
var is_dragging: bool = false
var is_driving: bool = false
var car_speed: float = 0.0
var cam_yaw: float = 0.0
var cam_pitch: float = -0.4

var providers = {
0: {"name": "OpenRouter", "chat": "https://openrouter.ai/api/v1/chat/completions", "models_url": "https://openrouter.ai/api/v1/models"},
1: {"name": "Groq", "chat": "https://api.groq.com/openai/v1/chat/completions", "models_url": "https://api.groq.com/openai/v1/models"}
}
var current_provider_idx: int = 0
var api_key: String = ""
var current_model: String = "openrouter/free"
var raw_models_cache: Array = []
var model_ids_map: Array = []

func _ready():
audio_player = AudioStreamPlayer.new()
add_child(audio_player)

center_tools.visible = false
indicator.visible = false
api_page.visible = false

http_request.request_completed.connect(_on_http_response)
provider_select.clear()
provider_select.add_item("🌐 OpenRouter (300+ модела)")
provider_select.add_item("⚡ Groq (Супер бърз)")

_add_log("[color=#00ff88]✨ TipTop High-Fidelity Studio е възстановено![/color]")
_add_log("[color=#ffff66]💡 Опитай: 'замък', 'бемве', 'пиано', 'тухлена стена'![/color]")

_spawn_piano("Grand_Piano", Vector3(-4, 0, -5.0))
_spawn_car("BMW_Cabrio", "#0066ff", true, Vector3(4, 0, -5.0))

func _process(delta):
if is_driving and selected_obj:
var steer = -joy.output.x; var throttle = -joy.output.y
if abs(steer) > 0.05: selected_obj.rotate_y(steer * 2.8 * delta)
if abs(throttle) > 0.05:
car_speed = move_toward(car_speed, throttle * 28.0, 18.0 * delta)
if randf() < 0.2: _play_engine_sound(abs(car_speed))
else: car_speed = move_toward(car_speed, 0.0, 12.0 * delta)
selected_obj.global_position += -selected_obj.global_transform.basis.z * car_speed * delta
var cam_t = selected_obj.global_position + selected_obj.global_transform.basis.z * 8.0 + Vector3(0, 3.4, 0)
camera.global_position = camera.global_position.lerp(cam_t, 9.0 * delta)
camera.look_at(selected_obj.global_position + Vector3(0, 1.0, 0), Vector3.UP)
return

if joy.output.length() > 0.05:
var fwd = -camera.global_transform.basis.z; var rgt = camera.global_transform.basis.x
fwd.y = 0.0; rgt.y = 0.0; camera.global_position += (rgt.normalized() * joy.output.x + fwd.normalized() * -joy.output.y) * 15.0 * delta

if selected_obj and is_instance_valid(selected_obj):
indicator.visible = true; indicator.global_position = selected_obj.global_position + Vector3(0, 3.5 + sin(Time.get_ticks_msec() * 0.006) * 0.25, 0)
else: indicator.visible = false

func _unhandled_input(event):
if api_page.visible or is_driving: return
var limit_h = get_viewport().size.y * 0.65
if event is InputEventScreenTouch:
if event.position.y > limit_h: return
if event.pressed:
var res = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(camera.project_ray_origin(event.position), camera.project_ray_origin(event.position) + camera.project_ray_normal(event.position) * 1000.0))
if res and res.collider.is_in_group("prop"):
_select(res.collider.get_parent()); is_dragging = true
if "piano" in selected_obj.name.to_lower(): _play_piano_chord()
else: _deselect(); is_dragging = false
else: is_dragging = false
elif event is InputEventScreenDrag and is_dragging and selected_obj:
var hit = Plane(Vector3.UP, selected_obj.global_position.y).intersects_ray(camera.project_ray_origin(event.position), camera.project_ray_normal(event.position))
if hit != null: selected_obj.global_position.x = hit.x; selected_obj.global_position.z = hit.z
elif event is InputEventScreenDrag and not is_dragging:
cam_yaw -= event.relative.x * 0.005; cam_pitch = clamp(cam_pitch - event.relative.y * 0.005, -1.4, 1.4)
camera.rotation.y = cam_yaw; camera.rotation.x = cam_pitch

func _select(obj): 
selected_obj = obj; lbl_selected.text = "🎯 " + obj.name; center_tools.visible = true
drive_btn.visible = ("car" in obj.name.to_lower() or "bmw" in obj.name.to_lower())

func _deselect(): selected_obj = null; center_tools.visible = false; drive_btn.visible = false
func _on_act_up(): if selected_obj: selected_obj.global_position.y += 0.8
func _on_act_del(): if selected_obj: selected_obj.queue_free(); _deselect()
func _on_toggle_drive():
is_driving = !is_driving; drive_btn.text = "🛑 СПРИ" if is_driving else "🏎️ КАРАЙ"
if not is_driving: car_speed = 0.0

func _add_log(msg: String): chat_log.append_text(msg + "\n")
func _on_open_settings(): api_page.visible = true
func _on_close_settings(): api_page.visible = false

func _on_send_chat():
var t = chat_input.text.strip_edges(); if t.is_empty(): return
chat_input.text = ""; _add_log("[color=#00ff88]Ти:[/color] " + t)
var low = t.to_lower(); var p = _spawn_pos()
if "пиан" in low or "роял" in low: _spawn_piano("Grand_Piano", p)
elif "замък" in low or "крепост" in low: _spawn_castle("Medieval_Castle", p)
elif "кол" in low or "бемв" in low or "bmw" in low: _spawn_car("BMW_Cabrio", "#0066ff", true, p)
elif "къщ" in low or "кащ" in low: _spawn_house("Cozy_House", "#e76f51", p)
elif "стен" in low or "тухл" in low: _spawn_wall("Brick_Wall", p)
elif not api_key.is_empty(): _request_ai(t)
else: _spawn_house("House", "#e76f51", p)

func _on_chip_pressed(txt: String): chat_input.text = txt; _on_send_chat()

func _spawn_pos() -> Vector3:
var fwd = -camera.global_transform.basis.z; fwd.y = 0.0
return camera.global_position + fwd.normalized() * 6.5

func _play_piano_chord():
var sr = 22050.0; var n = int(sr * 1.2); var pcm = PackedByteArray(); pcm.resize(n * 2)
for i in range(n):
var s = (sin((i/sr) * 261.63 * TAU) + sin((i/sr) * 329.63 * TAU) + sin((i/sr) * 392.0 * TAU)) * 0.33 * exp(-(i/sr) * 2.5)
pcm.encode_s16(i * 2, int(clamp(s, -1.0, 1.0) * 32767.0))
var st = AudioStreamWAV.new(); st.format = AudioStreamWAV.FORMAT_16_BITS; st.mix_rate = int(sr); st.data = pcm
audio_player.stream = st; audio_player.play(); _add_log("[color=#00ff88]🎵 Пианото изсвири акорд![/color]")

func _play_engine_sound(spd: float):
var sr = 22050.0; var n = int(sr * 0.1); var pcm = PackedByteArray(); pcm.resize(n * 2)
var freq = 60.0 + (spd * 8.0)
for i in range(n):
var s = (fmod((float(i)/sr) * freq, 1.0) - 0.5) * 0.8
pcm.encode_s16(i * 2, int(clamp(s, -1.0, 1.0) * 32767.0))
var st = AudioStreamWAV.new(); st.format = AudioStreamWAV.FORMAT_16_BITS; st.mix_rate = int(sr); st.data = pcm
audio_player.stream = st; audio_player.play()

# ====== АРХИТЕКТ ======
func _spawn_piano(n: String, pos: Vector3):
var r = Node3D.new(); r.name = n; r.position = pos; var rb = StaticBody3D.new(); rb.add_to_group("prop"); r.add_child(rb)
var lq = _mat(Color(0.08,0.08,0.1), 0.06, 0.4); lq.clearcoat_enabled=true; lq.clearcoat=1.0
var gd = _mat(Color(0.96,0.82,0.28), 0.12, 0.96); var wk = _mat(Color(0.96,0.96,0.98), 0.15)
var bk = _mat(Color(0.06,0.06,0.08), 0.08); var rf = _mat(Color(0.8,0.05,0.12), 0.95)
_box(rb, Vector3(2.2,0.45,2.6), lq, Vector3(0,1.15,0)); _box(rb, Vector3(1.6,0.44,1.4), lq, Vector3(-0.25,1.15,1.2)); _box(rb, Vector3(2.24,0.04,2.64), gd, Vector3(0,1.38,0))
for lp in [Vector3(-0.9,0.55,-1.0), Vector3(0.9,0.55,-1.0), Vector3(-0.2,0.55,1.6)]:
_cyl(rb, 0.09, 1.1, lq, lp); _cyl(rb, 0.11, 0.06, gd, lp+Vector3(0,0.48,0)); _sph(rb, 0.07, gd, lp-Vector3(0,0.52,0))
_box(rb, Vector3(2.3,0.06,2.7), lq, Vector3(0.3,1.8,0.1), Vector3(0,0,deg_to_rad(32))); _cyl(rb, 0.03, 0.9, gd, Vector3(0.7,1.6,0.2), Vector3(0,0,deg_to_rad(15)))
_box(rb, Vector3(1.92,0.02,0.06), rf, Vector3(0,1.04,-1.32)); _box(rb, Vector3(1.9,0.08,0.35), wk, Vector3(0,0.98,-1.45)); _box(rb, Vector3(1.7,0.12,0.2), bk, Vector3(0,1.02,-1.5))
_box(rb, Vector3(0.35,0.25,0.1), lq, Vector3(0,0.3,-0.6)); _box(rb, Vector3(0.06,0.04,0.2), gd, Vector3(-0.08,0.18,-0.68)); _box(rb, Vector3(0.06,0.04,0.2), gd, Vector3(0.0,0.18,-0.68)); _box(rb, Vector3(0.06,0.04,0.2), gd, Vector3(0.08,0.18,-0.68))
_col(rb, Vector3(2.6,2.2,3.2), Vector3(0,1.1,0)); world.add_child(r); _select(r); _add_log("[color=#00ff88]✓ Пиано създадено![/color]")

func _spawn_car(n: String, col: String, is_cab: bool, pos: Vector3):
var r = Node3D.new(); r.name = n; r.position = pos; var rb = StaticBody3D.new(); rb.add_to_group("prop"); r.add_child(rb)
var p_mat = _mat(Color.from_string(col, Color.RED), 0.14, 0.92); p_mat.clearcoat_enabled=true; p_mat.clearcoat=1.0
var blk = _mat(Color(0.1,0.1,0.12)); var chrm = _mat(Color(0.9,0.9,0.95), 0.15, 0.98); var tire = _mat(Color(0.12,0.12,0.14), 0.85)
_box(rb, Vector3(2.1,0.35,4.5), p_mat, Vector3(0,0.45,0)); _box(rb, Vector3(2.15,0.12,0.4), blk, Vector3(0,0.32,-2.15)); _box(rb, Vector3(1.2,0.22,0.06), blk, Vector3(0,0.48,-2.26)); _box(rb, Vector3(1.95,0.24,1.6), p_mat, Vector3(0,0.65,-1.25))
if is_cab:
var gm = StandardMaterial3D.new(); gm.albedo_color=Color(0.1,0.25,0.4,0.4); gm.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
_box(rb, Vector3(1.85,0.48,0.06), gm, Vector3(0,0.92,-0.45), Vector3(deg_to_rad(-24),0,0))
var sm = _mat(Color(0.15,0.15,0.18), 0.6)
_box(rb, Vector3(0.65,0.5,0.6), sm, Vector3(-0.45,0.72,0.2)); _box(rb, Vector3(0.65,0.5,0.6), sm, Vector3(0.45,0.72,0.2))
_box(rb, Vector3(1.6,0.22,0.4), blk, Vector3(0,0.78,-0.28)); _torus(rb, 0.18, 0.03, chrm, Vector3(-0.45,0.88,-0.15), Vector3(deg_to_rad(25),0,0))
else: _box(rb, Vector3(1.65,0.55,2.1), _mat(Color(0.08,0.1,0.15)), Vector3(0,0.85,0.1))
var hl = _mat(Color(1,1,1)); hl.emission_enabled=true; hl.emission=Color(0.85,0.95,1); hl.emission_energy_multiplier=4.0
_box(rb, Vector3(0.42,0.14,0.05), hl, Vector3(-0.7,0.56,-2.26)); _box(rb, Vector3(0.42,0.14,0.05), hl, Vector3(0.7,0.56,-2.26))
var tl = _mat(Color(1,0,0)); tl.emission_enabled=true; tl.emission=Color(1,0,0); tl.emission_energy_multiplier=4.0
_box(rb, Vector3(0.55,0.12,0.05), tl, Vector3(-0.65,0.6,2.26)); _box(rb, Vector3(0.55,0.12,0.05), tl, Vector3(0.65,0.6,2.26))
for wp in [Vector3(-1.05,0.38,-1.35), Vector3(1.05,0.38,-1.35), Vector3(-1.05,0.38,1.35), Vector3(1.05,0.38,1.35)]:
_cyl(rb, 0.38, 0.28, tire, wp, Vector3(0,0,deg_to_rad(90))); _cyl(rb, 0.24, 0.29, chrm, wp, Vector3(0,0,deg_to_rad(90)))
_col(rb, Vector3(2.4,1.3,4.6), Vector3(0,0.65,0)); world.add_child(r); _select(r); _add_log("[color=#00ff88]✓ Автомобил създаден![/color]")

func _spawn_castle(n: String, pos: Vector3):
var r = Node3D.new(); r.name = n; r.position = pos; var rb = StaticBody3D.new(); rb.add_to_group("prop"); r.add_child(rb)
var st = _mat(Color(0.48,0.5,0.55), 0.95); var rf = _mat(Color(0.12,0.3,0.75), 0.75); var flg = _mat(Color(1,0.15,0.15))
_box(rb, Vector3(7.0,3.5,7.0), st, Vector3(0,1.75,0)); _cyl(rb, 1.8, 7.5, st, Vector3(0,3.75,0)); _cyl(rb, 0.04, 1.2, st, Vector3(0,10.8,0)); _box(rb, Vector3(0.6,0.35,0.04), flg, Vector3(0.32,11.1,0))
var mcone = CylinderMesh.new(); mcone.top_radius=0.02; mcone.bottom_radius=2.1; mcone.height=2.8; _add_m(rb, mcone, rf, Vector3(0,8.9,0))
for tp in [Vector3(-3.8,0,-3.8), Vector3(3.8,0,-3.8), Vector3(-3.8,0,3.8), Vector3(3.8,0,3.8)]:
_cyl(rb, 1.1, 5.5, st, tp+Vector3(0,2.75,0)); var cone = CylinderMesh.new(); cone.top_radius=0.02; cone.bottom_radius=1.35; cone.height=2.2; _add_m(rb, cone, rf, tp+Vector3(0,6.6,0))
for bx in [-2.5, 0.0, 2.5]: _box(rb, Vector3(0.7,0.45,0.3), st, Vector3(bx,3.75,-3.6)); _box(rb, Vector3(0.7,0.45,0.3), st, Vector3(bx,3.75,3.6))
_box(rb, Vector3(2.2,2.6,0.2), _mat(Color(0.28,0.15,0.08)), Vector3(0,1.3,-3.6)); _torus(rb, 1.1, 0.15, st, Vector3(0,2.6,-3.62), Vector3(deg_to_rad(90),0,0))
_col(rb, Vector3(10.0,11.5,10.0), Vector3(0,5.0,0)); world.add_child(r); _select(r); _add_log("[color=#00ff88]✓ Замък създаден![/color]")

func _spawn_house(n: String, col: String, pos: Vector3):
var r = Node3D.new(); r.name = n; r.position = pos; var rb = StaticBody3D.new(); rb.add_to_group("prop"); r.add_child(rb)
var wm = _mat(Color.from_string(col, Color(0.9,0.85,0.75)), 0.9); var sm = _mat(Color(0.3,0.32,0.36), 0.95); var rm = _mat(Color(0.48,0.15,0.12), 0.8)
_box(rb, Vector3(5.4,0.35,4.8), sm, Vector3(0,0.17,0)); _box(rb, Vector3(1.8,0.18,0.8), sm, Vector3(0,0.09,-2.6))
_box(rb, Vector3(5.0,3.0,4.4), wm, Vector3(0,1.85,0)); var prism = PrismMesh.new(); prism.size = Vector3(4.8, 1.8, 5.4); _add_m(rb, prism, rm, Vector3(0,4.2,0), Vector3(0,deg_to_rad(90),0))
_box(rb, Vector3(0.65,1.6,0.65), sm, Vector3(1.5,4.4,0.6)); _box(rb, Vector3(1.2,2.1,0.08), _mat(Color(0.28,0.16,0.08),0.7), Vector3(0,1.4,-2.25))
_col(rb, Vector3(5.6,5.0,5.0), Vector3(0,2.5,0)); world.add_child(r); _select(r); _add_log("[color=#00ff88]✓ Къща създадена![/color]")

func _spawn_wall(n: String, pos: Vector3):
var r = Node3D.new(); r.name = n; r.position = pos; var rb = RigidBody3D.new(); rb.mass = 1.5; rb.add_to_group("prop"); r.add_child(rb)
var c1 = _mat(Color(0.72,0.25,0.16), 0.92); var c2 = _mat(Color(0.58,0.18,0.12), 0.95); _box(rb, Vector3(6.0,3.2,0.55), _mat(Color(0.7,0.7,0.72)), Vector3(0,1.6,0))
for row in range(6):
var yp = 0.25+row*0.45; var ox = 0.3 if row%2==1 else 0.0
for col in range(-3,4):
var xp = col*0.68+ox; if abs(xp)<2.8: _box(rb, Vector3(0.62,0.38,0.55), c1 if (row+col)%2==0 else c2, Vector3(xp,yp,0))
_col(rb, Vector3(6.3,3.4,0.75), Vector3(0,1.7,0)); world.add_child(r); _select(r); _add_log("[color=#00ff88]✓ Стена създадена![/color]")

func _mat(c: Color, r: float=0.4, m: float=0.0) -> StandardMaterial3D: var mat=StandardMaterial3D.new(); mat.albedo_color=c; mat.roughness=r; mat.metallic=m; return mat
func _box(p, sz, mat, pos, rot=Vector3.ZERO): var m=BoxMesh.new(); m.size=sz; _add_m(p, m, mat, pos, rot)
func _cyl(p, r, h, mat, pos, rot=Vector3.ZERO): var m=CylinderMesh.new(); m.top_radius=r; m.bottom_radius=r; m.height=h; _add_m(p, m, mat, pos, rot)
func _sph(p, r, mat, pos, rot=Vector3.ZERO): var m=SphereMesh.new(); m.radius=r; m.height=r*2.0; _add_m(p, m, mat, pos, rot)
func _torus(p, orad, irad, mat, pos, rot=Vector3.ZERO): var m=TorusMesh.new(); m.outer_radius=orad; m.inner_radius=irad; _add_m(p, m, mat, pos, rot)
func _col(p, sz, pos): var cs=CollisionShape3D.new(); var bs=BoxShape3D.new(); bs.size=sz; cs.shape=bs; cs.position=pos; p.add_child(cs)
func _add_m(p, msh, mat, pos, rot): var mi=MeshInstance3D.new(); mi.mesh=msh; mi.material_override=mat; mi.position=pos; mi.rotation=rot; p.add_child(mi)

# ====== AI CLOUD ======
func _on_fetch_models_pressed(): pass
func _on_http_response(r, c, h, b): pass
func _request_ai(prompt: String): pass
