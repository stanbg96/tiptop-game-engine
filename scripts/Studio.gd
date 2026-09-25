extends Node3D

const Entities = preload("res://scripts/GameEntities.gd")

@onready var camera = $Camera3D
@onready var joy = $UI/JoystickArea/VirtualJoystick
@onready var chat_log = $UI/ChatBG/VBox/Margin1/Log
@onready var chat_input = $UI/ChatBG/VBox/Margin2/InputRow/ChatInput
@onready var center_tools = $UI/CenterTools
@onready var lbl_selected = $UI/CenterTools/Panel/VBox/Header/LabelName
@onready var indicator = $Indicator
@onready var world = $World
@onready var http_request = $HTTPRequest
@onready var audio_player = $AudioPlayer
@onready var env_node = $WorldEnvironment
@onready var sun_light = $DirectionalLight3D

@onready var api_page = $UI/ApiPage
@onready var provider_select = $UI/ApiPage/Card/Margin/VBox/ProviderSelect
@onready var key_input = $UI/ApiPage/Card/Margin/VBox/KeyInput
@onready var test_btn = $UI/ApiPage/Card/Margin/VBox/TestBtn
@onready var status_lbl = $UI/ApiPage/Card/Margin/VBox/StatusLbl
@onready var search_input = $UI/ApiPage/Card/Margin/VBox/SearchInput
@onready var models_list_ui = $UI/ApiPage/Card/Margin/VBox/ModelsList
@onready var current_model_chip = $UI/ChatBG/VBox/TopRow/CurrentModelLbl

var selected_obj: Node3D = null
var is_dragging: bool = false
var cam_yaw: float = 0.0
var cam_pitch: float = -0.35

var player_avatar: CharacterBody3D = null
var is_driving: bool = false
var car_speed: float = 0.0
var active_vehicle: Node3D = null
var walk_cycle: float = 0.0
var drive_btn: Button = null
var speedo_lbl: Label = null
var engine_audio_timer: float = 0.0

var providers = {
0: {"name": "OpenRouter", "chat": "https://openrouter.ai/api/v1/chat/completions", "models_url": "https://openrouter.ai/api/v1/models"},
1: {"name": "Groq", "chat": "https://api.groq.com/openai/v1/chat/completions", "models_url": "https://api.groq.com/openai/v1/models"},
2: {"name": "OpenAI", "chat": "https://api.openai.com/v1/chat/completions", "models_url": "https://api.openai.com/v1/models"},
3: {"name": "DeepSeek", "chat": "https://api.deepseek.com/v1/chat/completions", "models_url": "https://api.deepseek.com/v1/models"}
}

var current_provider_idx: int = 0
var api_key: String = ""
var current_model: String = "openrouter/free"
var raw_models_cache: Array = []
var model_ids_map: Array = []
var is_testing_models: bool = false
var last_user_prompt: String = ""

func _ready():
center_tools.visible = false; indicator.visible = false; api_page.visible = false
http_request.request_completed.connect(_on_http_response)
_setup_provider_dropdown(); _load_saved_config(); _setup_hud()

_add_log("[color=#00ff88]🎮 TipTop World Engine v4.0 е активен![/color]")
_add_log("[color=#00f2fe]• Ходи пеша с аватара или влез в БМВ-то.[/color]")
_add_log("[color=#ffff66]• Докосни пианото за музикален акорд.[/color]")

player_avatar = Entities.spawn_player(world, Vector3(0, 0, 0))
Entities.spawn_car(world, "BMW_Cabrio", "#0066ff", true, Vector3(4.0, 0, -3.0))
Entities.spawn_piano(world, Vector3(-6.0, 0, -5.0))
Entities.spawn_brick_wall(world, Vector3(4.0, 0, -18.0))

func _setup_provider_dropdown():
provider_select.clear()
provider_select.add_item("🌐 OpenRouter (300+ модела)")
provider_select.add_item("⚡ Groq (Супер бърз)")
provider_select.add_item("🤖 OpenAI (ChatGPT)")
provider_select.add_item("🧠 DeepSeek (V3 / R1)")

func _setup_hud():
speedo_lbl = Label.new(); speedo_lbl.text = "0 km/h"; speedo_lbl.position = Vector2(24, 70)
speedo_lbl.add_theme_font_size_override("font_size", 22); speedo_lbl.add_theme_color_override("font_color", Color(0, 1, 0.7))
speedo_lbl.visible = false; $UI.add_child(speedo_lbl)

drive_btn = Button.new(); drive_btn.text = "🏎️ ВЛЕЗ В КОЛАТА"; drive_btn.custom_minimum_size = Vector2(140, 48)
drive_btn.position = Vector2(get_viewport().size.x - 160, 70); drive_btn.modulate = Color(0, 1, 0.6)
drive_btn.visible = false; drive_btn.pressed.connect(_on_toggle_drive_mode); $UI.add_child(drive_btn)

func _process(delta):
if is_driving and active_vehicle and is_instance_valid(active_vehicle):
_handle_car_driving(delta); return

if player_avatar and is_instance_valid(player_avatar):
_handle_player_walking(delta); _check_vehicle_proximity()

if selected_obj and is_instance_valid(selected_obj):
indicator.visible = true
indicator.global_position = selected_obj.global_position + Vector3(0, 3.5 + sin(Time.get_ticks_msec() * 0.006) * 0.25, 0)
else: indicator.visible = false

func _handle_player_walking(delta: float):
if joy.output.length() > 0.05:
var fwd = -camera.global_transform.basis.z; var rgt = camera.global_transform.basis.x
fwd.y = 0; rgt.y = 0; fwd = fwd.normalized(); rgt = rgt.normalized()
var move = (rgt * joy.output.x + fwd * -joy.output.y).normalized()
player_avatar.velocity.x = move.x * 8.5; player_avatar.velocity.z = move.z * 8.5
player_avatar.rotation.y = lerp_angle(player_avatar.rotation.y, atan2(move.x, move.z), 12.0 * delta)

walk_cycle += delta * 12.0; var sw = sin(walk_cycle) * 0.6
var ll = player_avatar.get_node_or_null("Visuals/LeftLeg"); var rl = player_avatar.get_node_or_null("Visuals/RightLeg")
var la = player_avatar.get_node_or_null("Visuals/LeftArm"); var ra = player_avatar.get_node_or_null("Visuals/RightArm")
if ll: ll.rotation.x = sw; if rl: rl.rotation.x = -sw; if la: la.rotation.x = -sw; if ra: ra.rotation.x = sw
else:
player_avatar.velocity.x = move_toward(player_avatar.velocity.x, 0.0, 15.0 * delta)
player_avatar.velocity.z = move_toward(player_avatar.velocity.z, 0.0, 15.0 * delta)

player_avatar.move_and_slide()
var t_cam = player_avatar.global_position + Vector3(0, 3.2, 5.8)
camera.global_position = camera.global_position.lerp(t_cam, 8.0 * delta)
camera.look_at(player_avatar.global_position + Vector3(0, 1.2, 0), Vector3.UP)

func _check_vehicle_proximity():
var nearest: Node3D = null; var min_d = 4.5
for c in world.get_children():
if "car" in c.name.to_lower() or "бемве" in c.name.to_lower():
var d = player_avatar.global_position.distance_to(c.global_position)
if d < min_d: min_d = d; nearest = c
if nearest:
active_vehicle = nearest; drive_btn.text = "🏎️ ВЛЕЗ В КОЛАТА"; drive_btn.visible = true
elif not is_driving: drive_btn.visible = false

func _handle_car_driving(delta: float):
var steer = -joy.output.x; var throttle = -joy.output.y
if abs(steer) > 0.05: active_vehicle.rotate_y(steer * 2.8 * delta)
if abs(throttle) > 0.05:
car_speed = move_toward(car_speed, throttle * 28.0, 18.0 * delta)
engine_audio_timer += delta
if engine_audio_timer > 0.12: engine_audio_timer = 0.0; _play_engine_sound(abs(car_speed))
else: car_speed = move_toward(car_speed, 0.0, 12.0 * delta)

active_vehicle.global_position += -active_vehicle.global_transform.basis.z * car_speed * delta
speedo_lbl.text = str(int(abs(car_speed) * 3.6)) + " km/h"

var cam_t = active_vehicle.global_position + active_vehicle.global_transform.basis.z * 8.0 + Vector3(0, 3.4, 0)
camera.global_position = camera.global_position.lerp(cam_t, 9.0 * delta)
camera.look_at(active_vehicle.global_position + Vector3(0, 1.0, 0), Vector3.UP)

func _on_toggle_drive_mode():
if not is_driving and active_vehicle:
is_driving = true; player_avatar.visible = false; drive_btn.text = "🧍 СЛЕЗ"; speedo_lbl.visible = true
_add_log("[color=#00ff88]🏎️ Влезе в колата! Дай газ с джойстика.[/color]")
elif is_driving and active_vehicle:
is_driving = false; car_speed = 0.0
player_avatar.global_position = active_vehicle.global_position + active_vehicle.global_transform.basis.x * 2.0
player_avatar.visible = true; drive_btn.text = "🏎️ ВЛЕЗ В КОЛАТА"; speedo_lbl.visible = false
_add_log("[color=#00f2fe]🧍 Слезе от колата.[/color]")

func _play_engine_sound(spd: float):
if not audio_player: return
var sr = 22050.0; var dur = 0.1; var n = int(sr * dur); var pcm = PackedByteArray(); pcm.resize(n * 2)
var freq = 60.0 + (spd * 8.0)
for i in range(n):
var t = float(i) / sr; var sample = (fmod(t * freq, 1.0) - 0.5) * 0.8
pcm.encode_s16(i * 2, int(clamp(sample, -1.0, 1.0) * 32767.0))
var st = AudioStreamWAV.new(); st.format = AudioStreamWAV.FORMAT_16_BITS; st.mix_rate = int(sr); st.data = pcm
audio_player.stream = st; audio_player.play()

func _play_piano_chord():
if not audio_player: return
var sr = 22050.0; var dur = 1.2; var n = int(sr * dur); var pcm = PackedByteArray(); pcm.resize(n * 2)
var freqs = [261.63, 329.63, 392.00]
for i in range(n):
var t = float(i) / sr; var env = exp(-t * 2.5); var s = 0.0
for f in freqs: s += sin(t * f * TAU) * 0.33
pcm.encode_s16(i * 2, int(clamp(s * env, -1.0, 1.0) * 32767.0))
var st = AudioStreamWAV.new(); st.format = AudioStreamWAV.FORMAT_16_BITS; st.mix_rate = int(sr); st.data = pcm
audio_player.stream = st; audio_player.play()
_add_log("[color=#00ff88]🎵 Пианото свири акорд C-E-G![/color]")

func _unhandled_input(event):
if api_page.visible or is_driving: return
if event is InputEventScreenTouch:
if event.position.y > get_viewport().size.y * 0.65: return
if event.pressed:
var hit = _raycast(event.position)
if hit:
_select(hit); is_dragging = true
if "piano" in hit.name.to_lower(): _play_piano_chord()
else: _deselect(); is_dragging = false
else: is_dragging = false
elif event is InputEventScreenDrag:
if event.position.y > get_viewport().size.y * 0.65: return
if is_dragging and selected_obj and is_instance_valid(selected_obj):
var drop = _get_floor(event.position)
if drop != Vector3.INF: selected_obj.global_position.x = drop.x; selected_obj.global_position.z = drop.z

func _raycast(pos: Vector2):
var from = camera.project_ray_origin(pos); var to = from + camera.project_ray_normal(pos) * 1000.0
var res = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
if res and res.collider.is_in_group("prop"): return res.collider.get_parent()
return null

func _get_floor(pos: Vector2):
var from = camera.project_ray_origin(pos); var dir = camera.project_ray_normal(pos)
var plane = Plane(Vector3.UP, selected_obj.global_position.y if selected_obj else 0.0)
var hit = plane.intersects_ray(from, dir); return hit if hit != null else Vector3.INF

func _select(obj): selected_obj = obj; lbl_selected.text = "🎯 " + obj.name; center_tools.visible = true
func _deselect(): if not is_driving: selected_obj = null; center_tools.visible = false

func _on_act_up(): if selected_obj: selected_obj.global_position.y += 0.8
func _on_act_down(): if selected_obj: selected_obj.global_position.y = max(0.0, selected_obj.global_position.y - 0.8)
func _on_act_rot(): if selected_obj: selected_obj.rotate_y(deg_to_rad(45.0))
func _on_act_del(): if selected_obj: selected_obj.queue_free(); _deselect()

func _on_open_settings(): api_page.visible = true
func _on_close_settings(): api_page.visible = false; _save_config()
func _on_confirm_and_enter(): _save_config(); api_page.visible = false
func _on_key_submitted(_new_text: String): _on_fetch_models_pressed()
func _on_provider_selected(idx: int): current_provider_idx = idx; models_list_ui.clear()

func _on_fetch_models_pressed():
api_key = key_input.text.strip_edges()
if api_key.is_empty(): return
is_testing_models = true; test_btn.disabled = true
var headers = ["Authorization: Bearer " + api_key, "Content-Type: application/json"]
if current_provider_idx == 0: headers.append("HTTP-Referer: https://tiptop.engine")
http_request.request(providers[current_provider_idx]["models_url"], headers, HTTPClient.METHOD_GET)

func _on_http_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
test_btn.disabled = false
if is_testing_models:
is_testing_models = false
if response_code == 200:
var json = JSON.new()
if json.parse(body.get_string_from_utf8()) == OK:
var res = json.get_data(); var list = res.get("data", []); if list.is_empty(): list = res.get("models", [])
raw_models_cache = list; _render_models_list(raw_models_cache, ""); _save_config()
else:
if response_code == 200:
var json = JSON.new()
if json.parse(body.get_string_from_utf8()) == OK:
var res = json.get_data(); var ch = res.get("choices", [])
if not ch.is_empty(): _spawn_by_keyword(last_user_prompt)
else: _spawn_by_keyword(last_user_prompt)

func _render_models_list(source_list: Array, filter_query: String):
models_list_ui.clear(); model_ids_map.clear()
models_list_ui.add_item("⚡ АВТОМАТИЧЕН (OpenRouter Free Router)"); model_ids_map.append("openrouter/free")
for item in source_list:
var m_id = str(item.get("id", "")) if item is Dictionary else str(item)
if m_id.is_empty() or m_id == "openrouter/free": continue
if ":free" in m_id.to_lower(): models_list_ui.add_item("🎁 [FREE] " + m_id); model_ids_map.append(m_id)
else: models_list_ui.add_item("⭐ " + m_id); model_ids_map.append(m_id)

func _on_search_changed(new_text: String): _render_models_list(raw_models_cache, new_text)
func _on_model_item_selected(index: int):
if index >= 0 and index < model_ids_map.size():
current_model = model_ids_map[index]; current_model_chip.text = "🤖 " + current_model; _save_config()

func _save_config():
var cfg = {"provider": current_provider_idx, "api_key": key_input.text.strip_edges(), "model": current_model, "raw_models": raw_models_cache}
var f = FileAccess.open("user://api_config.json", FileAccess.WRITE)
if f: f.store_string(JSON.stringify(cfg))

func _load_saved_config():
if not FileAccess.file_exists("user://api_config.json"): return
var f = FileAccess.open("user://api_config.json", FileAccess.READ)
if not f: return
var json = JSON.new()
if json.parse(f.get_as_text()) != OK: return
var cfg = json.get_data(); if not cfg is Dictionary: return
current_provider_idx = int(cfg.get("provider", 0)); api_key = str(cfg.get("api_key", "")); key_input.text = api_key
current_model = str(cfg.get("model", "openrouter/free")); current_model_chip.text = "🤖 " + current_model
raw_models_cache = cfg.get("raw_models", []); if not raw_models_cache.is_empty(): _render_models_list(raw_models_cache, "")

func _add_log(msg: String): chat_log.append_text(msg + "\n")

func _on_send_chat():
var t = chat_input.text.strip_edges(); if t.is_empty(): return
chat_input.text = ""; _add_log("[color=#00ff88]Ти:[/color] " + t)
last_user_prompt = t

var low = t.to_lower()
if "нощ" in low or "залез" in low or "ден" in low:
_change_env(low); return
elif "гравитация" in low:
var g = 0.0 if " 0" in low or "нул" in low else (1.6 if "лун" in low else 9.8)
PhysicsServer3D.area_set_param(get_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY, g)
_add_log("[color=#00f2fe]Гравитация: " + str(g) + " m/s².[/color]"); return

_spawn_by_keyword(t)

func _on_chip_pressed(txt: String): chat_input.text = txt; _on_send_chat()

func _change_env(type: String):
if "нощ" in type:
env_node.environment.background_color = Color(0.04, 0.05, 0.09)
sun_light.light_energy = 0.2; sun_light.light_color = Color(0.4, 0.6, 1.0)
elif "залез" in type:
env_node.environment.background_color = Color(0.45, 0.18, 0.1)
sun_light.light_energy = 1.3; sun_light.light_color = Color(1.0, 0.45, 0.2)
else:
env_node.environment.background_color = Color(0.18, 0.22, 0.28)
sun_light.light_energy = 1.35; sun_light.light_color = Color(1.0, 0.98, 0.92)

func _get_spawn_pos() -> Vector3:
var fwd = -camera.global_transform.basis.z; fwd.y = 0.0
var p = camera.global_position + fwd.normalized() * 7.5; p.y = 0.0
return p

func _spawn_by_keyword(prompt: String):
var low = prompt.to_lower(); var pos = _get_spawn_pos()
var node: Node3D = null
if "стен" in low or "тухл" in low or "зид" in low or "оград" in low:
node = Entities.spawn_brick_wall(world, pos)
elif "пиан" in low or "роял" in low or "клавиш" in low:
node = Entities.spawn_piano(world, pos)
elif "замък" in low or "замк" in low or "крепос" in low:
node = Entities.spawn_castle(world, pos)
elif "кол" in low or "бемв" in low or "bmw" in low or "кабри" in low:
var is_cab = "кабри" in low or "бемв" in low or "bmw" in low
node = Entities.spawn_car(world, "BMW_Cabrio" if is_cab else "Sports_Car", "#0066ff" if "бемв" in low else "#e60026", is_cab, pos)
elif "зомби" in low or "бот" in low or "враг" in low or "робот" in low:
node = Entities.spawn_bot(world, pos)
else:
node = Entities.spawn_brick_wall(world, pos)
if node: _select(node); _add_log("[color=#00ff88]✓ " + node.name + " е създаден в света![/color]")
