extends Node3D

@onready var camera = $Camera3D
@onready var joy = $UI/JoystickArea/VirtualJoystick
@onready var chat_log = $UI/ChatBG/VBox/Margin1/Log
@onready var chat_input = $UI/ChatBG/VBox/Margin2/InputRow/ChatInput
@onready var center_tools = $UI/CenterTools
@onready var lbl_selected = $UI/CenterTools/Panel/VBox/Header/LabelName
@onready var indicator = $Indicator
@onready var world = $World
@onready var http_request = $HTTPRequest
@onready var env_node = $WorldEnvironment
@onready var sun_light = $DirectionalLight3D
@onready var rim_light = $RimLight

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
var cam_pitch: float = -0.4

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
center_tools.visible = false
indicator.visible = false
api_page.visible = false

http_request.request_completed.connect(_on_http_response)
_setup_provider_dropdown()
_load_saved_config()

_add_log("[color=#00ff88]✨ Модулен TipTop Studio Енджин v2.0 е активен![/color]")
_add_log("[color=#00f2fe]Модел:[/color] " + current_model)
_add_log("[color=#ffff66]💡 Опитай: 'пиано', 'замък', 'тухлена стена', 'каща'![/color]")

_spawn_by_name("piano", Vector3(0, 0, -5.0))

func _setup_provider_dropdown():
provider_select.clear()
provider_select.add_item("🌐 OpenRouter (300+ модела)")
provider_select.add_item("⚡ Groq (Супер бърз)")
provider_select.add_item("🤖 OpenAI (ChatGPT)")
provider_select.add_item("🧠 DeepSeek (V3 / R1)")

func _process(delta):
if joy.output.length() > 0.05:
var fwd = -camera.global_transform.basis.z
var rgt = camera.global_transform.basis.x
fwd.y = 0.0; rgt.y = 0.0
fwd = fwd.normalized(); rgt = rgt.normalized()
camera.global_position += (rgt * joy.output.x + fwd * -joy.output.y) * 15.0 * delta

if selected_obj and is_instance_valid(selected_obj):
indicator.visible = true
var bounce = sin(Time.get_ticks_msec() * 0.006) * 0.25
indicator.global_position = selected_obj.global_position + Vector3(0, 3.5 + bounce, 0)
else:
indicator.visible = false

func _unhandled_input(event):
if api_page.visible: return
var limit_h = get_viewport().size.y * 0.65

if event is InputEventScreenTouch:
if event.position.y > limit_h: return
if event.pressed:
var hit = _raycast(event.position)
if hit:
_select(hit)
is_dragging = true
else:
_deselect()
is_dragging = false
else:
is_dragging = false

elif event is InputEventScreenDrag:
if event.position.y > limit_h: return
if is_dragging and selected_obj and is_instance_valid(selected_obj):
var drop = _get_floor(event.position)
if drop != Vector3.INF:
selected_obj.global_position.x = drop.x
selected_obj.global_position.z = drop.z
else:
cam_yaw -= event.relative.x * 0.005
cam_pitch = clamp(cam_pitch - event.relative.y * 0.005, -1.4, 1.4)
camera.rotation.y = cam_yaw
camera.rotation.x = cam_pitch

func _raycast(pos: Vector2):
var from = camera.project_ray_origin(pos)
var to = from + camera.project_ray_normal(pos) * 1000.0
var q = PhysicsRayQueryParameters3D.create(from, to)
var res = get_world_3d().direct_space_state.intersect_ray(q)
if res and res.collider.is_in_group("prop"):
return res.collider.get_parent()
return null

func _get_floor(pos: Vector2):
var from = camera.project_ray_origin(pos)
var dir = camera.project_ray_normal(pos)
var h = selected_obj.global_position.y if selected_obj else 0.0
var plane = Plane(Vector3.UP, h)
var hit = plane.intersects_ray(from, dir)
if hit != null: return hit
return Vector3.INF

func _select(obj):
selected_obj = obj
lbl_selected.text = "🎯 " + obj.name
center_tools.visible = true

func _deselect():
selected_obj = null
center_tools.visible = false

func _on_act_up(): if selected_obj and is_instance_valid(selected_obj): selected_obj.global_position.y += 0.8
func _on_act_down(): if selected_obj and is_instance_valid(selected_obj): selected_obj.global_position.y = max(0.0, selected_obj.global_position.y - 0.8)
func _on_act_rot(): if selected_obj and is_instance_valid(selected_obj): selected_obj.rotate_y(deg_to_rad(45.0))
func _on_act_del():
if selected_obj and is_instance_valid(selected_obj):
selected_obj.queue_free()
_deselect()

func _on_open_settings(): api_page.visible = true
func _on_close_settings(): api_page.visible = false; _save_config()
func _on_confirm_and_enter(): _save_config(); api_page.visible = false; _add_log("[color=#00ff88]✓ Модел:[/color] " + current_model)
func _on_key_submitted(_new_text: String): _on_fetch_models_pressed()
func _on_provider_selected(idx: int): current_provider_idx = idx; status_lbl.text = "Доставчик: " + providers[idx]["name"]; models_list_ui.clear()

func _on_fetch_models_pressed():
api_key = key_input.text.strip_edges()
if api_key.is_empty():
status_lbl.text = "❌ Въведи първо API ключ!"; status_lbl.modulate = Color(1, 0.3, 0.3); return
is_testing_models = true; test_btn.disabled = true; status_lbl.text = "⏳ Сваляне на модели..."; status_lbl.modulate = Color(0, 1, 0.6)
var url = providers[current_provider_idx]["models_url"]
var headers = ["Authorization: Bearer " + api_key, "Content-Type: application/json"]
if current_provider_idx == 0:
headers.append("HTTP-Referer: https://tiptop.engine"); headers.append("X-Title: TipTop Studio")
http_request.request(url, headers, HTTPClient.METHOD_GET)

func _on_http_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
test_btn.disabled = false
if is_testing_models:
is_testing_models = false
if response_code == 200:
var json = JSON.new()
if json.parse(body.get_string_from_utf8()) == OK:
var res = json.get_data(); var list = res.get("data", []); if list.is_empty(): list = res.get("models", [])
raw_models_cache = list; _render_models_list(raw_models_cache, "")
status_lbl.text = "✅ Намерени " + str(raw_models_cache.size()) + " модела!"; status_lbl.modulate = Color(0, 1, 0.5); _save_config()
else:
status_lbl.text = "❌ Невалиден ключ! (" + str(response_code) + ")"; status_lbl.modulate = Color(1, 0.3, 0.3)
else:
if response_code == 200:
var json = JSON.new()
if json.parse(body.get_string_from_utf8()) == OK:
var res = json.get_data(); var choices = res.get("choices", [])
if not choices.is_empty():
var raw_content = choices[0].get("message", {}).get("content", "").strip_edges()
_interpret_and_build(raw_content)
else: _fallback(last_user_prompt)
else: _fallback(last_user_prompt)
else: _fallback(last_user_prompt)

func _render_models_list(source_list: Array, filter_query: String):
models_list_ui.clear(); model_ids_map.clear()
var q = filter_query.strip_edges().to_lower()
if q.is_empty() or "free" in q:
models_list_ui.add_item("⚡ АВТОМАТИЧЕН (OpenRouter Free Router)")
model_ids_map.append("openrouter/free")
var free_list = []; var paid_list = []
for item in source_list:
var m_id = str(item.get("id", "")) if item is Dictionary else str(item)
if m_id.is_empty() or m_id == "openrouter/free": continue
if not q.is_empty() and not q in m_id.to_lower(): continue
if ":free" in m_id.to_lower() or "free" in m_id.to_lower(): free_list.append(m_id)
else: paid_list.append(m_id)
free_list.sort(); paid_list.sort()
for m in free_list: models_list_ui.add_item("🎁 [FREE] " + m); model_ids_map.append(m)
for m in paid_list: models_list_ui.add_item("⭐ " + m); model_ids_map.append(m)
var sel_idx = model_ids_map.find(current_model)
if sel_idx != -1 and sel_idx < models_list_ui.item_count: models_list_ui.select(sel_idx)

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
current_provider_idx = int(cfg.get("provider", 0))
if current_provider_idx < provider_select.item_count: provider_select.selected = current_provider_idx
api_key = str(cfg.get("api_key", "")); key_input.text = api_key
current_model = str(cfg.get("model", "openrouter/free")); current_model_chip.text = "🤖 " + current_model
raw_models_cache = cfg.get("raw_models", [])
if not raw_models_cache.is_empty(): _render_models_list(raw_models_cache, "")

func _add_log(msg: String): chat_log.append_text(msg + "\n")

func _on_send_chat():
var t = chat_input.text.strip_edges(); if t.is_empty(): return
chat_input.text = ""; _add_log("[color=#00ff88]Ти:[/color] " + t)
last_user_prompt = t

var low = t.to_lower()
# Контрол на света
if "нощ" in low or "залез" in low or "ден" in low:
EnvironmentStudio.set_time_of_day(low, env_node, sun_light, rim_light)
_add_log("[color=#00f2fe]Атмосферата е сменена.[/color]")
return
elif "гравитация" in low:
var g_val = 0.0 if " 0" in low or "нул" in low else (1.6 if "лун" in low else 9.8)
EnvironmentStudio.set_gravity(get_world_3d().space, g_val)
_add_log("[color=#00f2fe]Гравитация: " + str(g_val) + " m/s².[/color]")
return

# Проверка за архитип чрез AIBridge
var arch = AIBridge.detect_archetype(low)
if not arch.is_empty():
_spawn_by_name(arch, _get_spawn_pos())
return

if not api_key.is_empty(): _request_ai(t)
else: _fallback(t)

func _on_chip_pressed(txt: String): chat_input.text = txt; _on_send_chat()

func _get_spawn_pos() -> Vector3:
var fwd = -camera.global_transform.basis.z; fwd.y = 0.0
var p = camera.global_position + fwd.normalized() * 7.5; p.y = 0.0
return p

func _spawn_by_name(arch: String, pos: Vector3):
var node: Node3D = null
match arch:
"piano": node = ProceduralArchitect.build_piano("Grand_Piano", pos)
"castle": node = ProceduralArchitect.build_castle("Medieval_Castle", pos)
"car": node = ProceduralArchitect.build_car("BMW_Cabrio", "#0066ff", true, pos)
"wall": node = ProceduralArchitect.build_brick_wall("Brick_Wall", pos)
"house": node = ProceduralArchitect.build_house("Cozy_House", "#e76f51", pos)
if node:
world.add_child(node)
_select(node)
_add_log("[color=#00ff88]✓ " + node.name + " е компилиран на сцената![/color]")

func _request_ai(prompt: String):
_add_log("[color=#00f2fe]⏳ " + current_model + " проектира детайлен 3D CAD модел в RAM...[/color]")
var url = providers[current_provider_idx]["chat"]
var headers = ["Authorization: Bearer " + api_key, "Content-Type: application/json"]
if current_provider_idx == 0:
headers.append("HTTP-Referer: https://tiptop.engine"); headers.append("X-Title: TipTop Studio")
var body = JSON.stringify({
"model": current_model,
"messages": [{"role": "system", "content": AIBridge.get_system_prompt()}, {"role": "user", "content": "3D CAD for: " + prompt}],
"max_tokens": 1400, "temperature": 0.2
})
http_request.request(url, headers, HTTPClient.METHOD_POST, body)

func _interpret_and_build(raw_text: String):
var recipe = AIBridge.auto_repair_json(raw_text)
if recipe.has("parts") and recipe["parts"].size() > 0:
var node = ProceduralArchitect.compile_json_recipe(recipe, _get_spawn_pos())
world.add_child(node); _select(node)
_add_log("[color=#00ff88]✓ " + node.name + " е генериран успешно от AI![/color]")
else:
_fallback(last_user_prompt)

func _fallback(prompt: String):
var arch = AIBridge.detect_archetype(prompt.to_lower())
if arch.is_empty(): arch = "wall"
_spawn_by_name(arch, _get_spawn_pos())
