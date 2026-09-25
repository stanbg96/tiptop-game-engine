extends Node3D

@onready var camera = $Camera3D
@onready var joy = $UI/VirtualJoystick
@onready var chat_log = $UI/ChatBG/VBox/Margin1/Log
@onready var chat_input = $UI/ChatBG/VBox/Margin2/InputRow/ChatInput
@onready var center_tools = $UI/CenterTools
@onready var lbl_selected = $UI/CenterTools/Panel/VBox/Header/LabelName
@onready var indicator = $Indicator
@onready var world = $World
@onready var http_request = $HTTPRequest
@onready var audio_player = $AudioPlayer
@onready var api_page = $UI/ApiPage

var selected_obj: Node3D = null
var is_dragging: bool = false
var api_key: String = ""
var current_model: String = "openrouter/free"

func _ready():
center_tools.visible = false; indicator.visible = false; api_page.visible = false
http_request.request_completed.connect(_on_http_response)
_add_log("[color=#00ff88]✨ МОДУЛЕН ЕНДЖИН: Зареден успешно![/color]")

# Извикваме модулите ГЛОБАЛНО без preload!
world.add_child(BuildMod.spawn_piano(Vector3(-4, 0, -6.0)))
world.add_child(BuildMod.spawn_car(Vector3(4, 0, -6.0)))

func _process(delta):
if joy.output.length() > 0.05:
var fwd = -camera.global_transform.basis.z; var rgt = camera.global_transform.basis.x
fwd.y = 0.0; rgt.y = 0.0; camera.global_position += (rgt.normalized() * joy.output.x + fwd.normalized() * -joy.output.y) * 15.0 * delta

if selected_obj and is_instance_valid(selected_obj):
indicator.visible = true; indicator.global_position = selected_obj.global_position + Vector3(0, 3.5 + sin(Time.get_ticks_msec() * 0.006) * 0.25, 0)
else: indicator.visible = false

func _unhandled_input(event):
if api_page.visible: return
var limit_h = get_viewport().size.y * 0.65
if event is InputEventScreenTouch:
if event.position.y > limit_h: return
if event.pressed:
var res = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(camera.project_ray_origin(event.position), camera.project_ray_origin(event.position) + camera.project_ray_normal(event.position) * 1000.0))
if res and res.collider.is_in_group("prop"):
selected_obj = res.collider.get_parent(); lbl_selected.text = "🎯 " + selected_obj.name; center_tools.visible = true; is_dragging = true
if "piano" in selected_obj.name.to_lower(): _play_piano()
else: selected_obj = null; center_tools.visible = false; is_dragging = false
else: is_dragging = false
elif event is InputEventScreenDrag and is_dragging and selected_obj:
var hit = Plane(Vector3.UP, selected_obj.global_position.y).intersects_ray(camera.project_ray_origin(event.position), camera.project_ray_normal(event.position))
if hit != null: selected_obj.global_position.x = hit.x; selected_obj.global_position.z = hit.z

func _on_act_up(): if selected_obj: selected_obj.global_position.y += 0.8
func _on_act_del(): if selected_obj: selected_obj.queue_free(); selected_obj = null; center_tools.visible = false

func _add_log(msg: String): chat_log.append_text(msg + "\n")

func _on_send_chat():
var t = chat_input.text.strip_edges(); if t.is_empty(): return
chat_input.text = ""; _add_log("[color=#00ff88]Ти:[/color] " + t)

if "нощ" in t.to_lower() or "ден" in t.to_lower() or "залез" in t.to_lower():
EnvMod.apply_time_of_day(t.to_lower(), $WorldEnvironment, $DirectionalLight3D); return
if "гравитация" in t.to_lower():
EnvMod.set_gravity(get_world_3d().space, 0.0 if "0" in t else 9.8); return

var arch = AIMod.detect_archetype(t)
if arch == "piano": world.add_child(BuildMod.spawn_piano(_spawn_pos()))
elif arch == "car": world.add_child(BuildMod.spawn_car(_spawn_pos()))
elif arch == "wall": world.add_child(BuildMod.spawn_wall(_spawn_pos()))
else: world.add_child(BuildMod.spawn_wall(_spawn_pos()))

func _on_http_response(result, code, headers, body): pass

func _play_piano():
var sr = 22050.0; var n = int(sr * 1.2); var pcm = PackedByteArray(); pcm.resize(n * 2)
for i in range(n):
var s = (sin((i/sr) * 261.63 * TAU) + sin((i/sr) * 329.63 * TAU) + sin((i/sr) * 392.0 * TAU)) * 0.33 * exp(-(i/sr) * 2.5)
pcm.encode_s16(i * 2, int(clamp(s, -1.0, 1.0) * 32767.0))
var st = AudioStreamWAV.new(); st.format = AudioStreamWAV.FORMAT_16_BITS; st.mix_rate = int(sr); st.data = pcm
$AudioPlayer.stream = st; $AudioPlayer.play(); _add_log("[color=#00ff88]🎵 Пианото свири![/color]")

func _spawn_pos() -> Vector3: var fwd = -camera.global_transform.basis.z; fwd.y = 0.0; return camera.global_position + fwd.normalized() * 6.5
