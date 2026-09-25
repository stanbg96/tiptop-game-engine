extends Node3D

const EnvMod = preload("res://scripts/modules/Environment.gd")
const AIMod = preload("res://scripts/modules/AIBridge.gd")
const BuildMod = preload("res://scripts/modules/Builder.gd")

@onready var camera = $Camera3D
@onready var joy = $UI/VirtualJoystick
@onready var chat_log = $UI/ChatBG/VBox/Margin1/Log
@onready var chat_input = $UI/ChatBG/VBox/Margin2/InputRow/ChatInput
@onready var center_tools = $UI/CenterTools
@onready var lbl_selected = $UI/CenterTools/Panel/VBox/Header/LabelName
@onready var drive_btn = $UI/CenterTools/Panel/VBox/Buttons/BtnDrive
@onready var indicator = $Indicator
@onready var world = $World
@onready var http_request = $HTTPRequest
@onready var audio_player = $AudioPlayer

@onready var api_page = $UI/ApiPage
@onready var provider_select = $UI/ApiPage/Card/Margin/VBox/ProviderSelect
@onready var key_input = $UI/ApiPage/Card/Margin/VBox/KeyInput
@onready var test_btn = $UI/ApiPage/Card/Margin/VBox/TestBtn
@onready var status_lbl = $UI/ApiPage/Card/Margin/VBox/StatusLbl
@onready var models_list_ui = $UI/ApiPage/Card/Margin/VBox/ModelsList

var selected_obj: Node3D = null
var is_dragging: bool = false
var is_driving: bool = false
var car_speed: float = 0.0
var api_key: String = ""
var current_model: String = "openrouter/free"

func _ready():
center_tools.visible = false; indicator.visible = false; api_page.visible = false
http_request.request_completed.connect(_on_http_response)
_add_log("[color=#00ff88]✨ МОДУЛЕН ЕНДЖИН: Успешно зареден![/color]")
world.add_child(BuildMod.spawn_piano(Vector3(-4, 0, -6.0)))
world.add_child(BuildMod.spawn_car(Vector3(4, 0, -6.0)))

func _process(delta):
if is_driving and selected_obj:
var steer = -joy.output.x; var throttle = -joy.output.y
if abs(steer) > 0.05: selected_obj.rotate_y(steer * 2.8 * delta)
if abs(throttle) > 0.05: car_speed = move_toward(car_speed, throttle * 28.0, 18.0 * delta)
else: car_speed = move_toward(car_speed, 0.0, 12.0 * delta)
selected_obj.global_position += -selected_obj.global_transform.basis.z * car_speed * delta
camera.global_position = camera.global_position.lerp(selected_obj.global_position + selected_obj.global_transform.basis.z * 8.0 + Vector3(0, 3.4, 0), 9.0 * delta)
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
selected_obj = res.collider.get_parent(); lbl_selected.text = "🎯 " + selected_obj.name; center_tools.visible = true; is_dragging = true
drive_btn.visible = ("car" in selected_obj.name.to_lower() or "bmw" in selected_obj.name.to_lower())
if "piano" in selected_obj.name.to_lower(): _play_piano()
else: selected_obj = null; center_tools.visible = false; is_dragging = false
else: is_dragging = false
elif event is InputEventScreenDrag and is_dragging and selected_obj:
var hit = Plane(Vector3.UP, selected_obj.global_position.y).intersects_ray(camera.project_ray_origin(event.position), camera.project_ray_normal(event.position))
if hit != null: selected_obj.global_position.x = hit.x; selected_obj.global_position.z = hit.z

func _on_act_up(): if selected_obj: selected_obj.global_position.y += 0.8
func _on_act_del(): if selected_obj: selected_obj.queue_free(); selected_obj = null; center_tools.visible = false
func _on_toggle_drive():
is_driving = !is_driving
drive_btn.text = "🛑 СПРИ" if is_driving else "🏎️ КАРАЙ"
if not is_driving: car_speed = 0.0

func _add_log(msg: String): chat_log.append_text(msg + "\n")
func _on_open_settings(): api_page.visible = true
func _on_close_settings(): api_page.visible = false
func _on_fetch_models_pressed():
api_key = key_input.text.strip_edges()
test_btn.disabled = true; status_lbl.text = "⏳ Сваляне..."
http_request.request("https://openrouter.ai/api/v1/models", ["Authorization: Bearer " + api_key], HTTPClient.METHOD_GET)

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
elif not api_key.is_empty():
http_request.request("https://openrouter.ai/api/v1/chat/completions", ["Authorization: Bearer " + api_key, "Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify({"model": current_model, "messages": [{"role": "system", "content": AIMod.get_prompt()}, {"role": "user", "content": t}]}))
else: world.add_child(BuildMod.spawn_wall(_spawn_pos()))

func _on_http_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
if api_page.visible:
test_btn.disabled = false; status_lbl.text = "✅ Намерени модели!"
elif response_code == 200:
var json = JSON.new(); if json.parse(body.get_string_from_utf8()) == OK:
var res = json.get_data(); var ch = res.get("choices", [])
if not ch.is_empty():
var recipe = AIMod.clean_json(ch[0].get("message", {}).get("content", ""))
if recipe.has("parts"): world.add_child(BuildMod.spawn_from_json(recipe, _spawn_pos()))

func _play_piano():
var sr = 22050.0; var n = int(sr * 1.2); var pcm = PackedByteArray(); pcm.resize(n * 2)
for i in range(n):
var s = (sin((i/sr) * 261.63 * TAU) + sin((i/sr) * 329.63 * TAU) + sin((i/sr) * 392.0 * TAU)) * 0.33 * exp(-(i/sr) * 2.5)
pcm.encode_s16(i * 2, int(clamp(s, -1.0, 1.0) * 32767.0))
var st = AudioStreamWAV.new(); st.format = AudioStreamWAV.FORMAT_16_BITS; st.mix_rate = int(sr); st.data = pcm
$AudioPlayer.stream = st; $AudioPlayer.play(); _add_log("🎵 Акорд!")

func _spawn_pos() -> Vector3: var fwd = -camera.global_transform.basis.z; fwd.y = 0.0; return camera.global_position + fwd.normalized() * 6.5
