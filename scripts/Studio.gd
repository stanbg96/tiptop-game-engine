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
@onready var audio_player = $AudioPlayer

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
var last_user_prompt: String = ""

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

func _ready():
center_tools.visible = false
indicator.visible = false
api_page.visible = false

http_request.request_completed.connect(_on_http_response)
_setup_provider_dropdown()
_load_saved_config()

_add_log("[color=#00ff88]✨ TipTop Studio е онлайн![/color]")
_add_log("[color=#00f2fe]Модел:[/color] " + current_model)
_add_log("[color=#ffff66]💡 Опитай: 'замък', 'тухлена стена', 'бемве', 'пиано', 'каща'![/color]")

_spawn_detailed_piano("Grand_Piano", Vector3(0, 0, -5.0))

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
fwd.y = 0.0
rgt.y = 0.0
fwd = fwd.normalized()
rgt = rgt.normalized()
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
if "piano" in hit.name.to_lower():
_play_piano_chord()
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

func _on_act_up():
if selected_obj and is_instance_valid(selected_obj): selected_obj.global_position.y += 0.8

func _on_act_down():
if selected_obj and is_instance_valid(selected_obj): selected_obj.global_position.y = max(0.0, selected_obj.global_position.y - 0.8)

func _on_act_rot():
if selected_obj and is_instance_valid(selected_obj): selected_obj.rotate_y(deg_to_rad(45.0))

func _on_act_del():
if selected_obj and is_instance_valid(selected_obj):
selected_obj.queue_free()
_deselect()

func _on_open_settings(): api_page.visible = true
func _on_close_settings(): api_page.visible = false; _save_config()
func _on_confirm_and_enter(): _save_config(); api_page.visible = false; _add_log("[color=#00ff88]✓ Модел:[/color] " + current_model)
func _on_key_submitted(_new_text: String): _on_fetch_models_pressed()

func _on_provider_selected(idx: int):
current_provider_idx = idx
status_lbl.text = "Доставчик: " + providers[idx]["name"]
models_list_ui.clear()

func _on_fetch_models_pressed():
api_key = key_input.text.strip_edges()
if api_key.is_empty():
status_lbl.text = "❌ Въведи първо API ключ!"
status_lbl.modulate = Color(1, 0.3, 0.3)
return

is_testing_models = true
test_btn.disabled = true
status_lbl.text = "⏳ Сваляне на модели..."
status_lbl.modulate = Color(0,

cat << 'EOF' > scripts/Studio.gd
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
var last_user_prompt: String = ""
var audio_player: AudioStreamPlayer

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

func _ready():
# Динамично създаване на AudioPlayer, за да избегнем липсващ възел в сцената
audio_player = AudioStreamPlayer.new()
add_child(audio_player)

center_tools.visible = false
indicator.visible = false
api_page.visible = false

http_request.request_completed.connect(_on_http_response)
_setup_provider_dropdown()
_load_saved_config()

_add_log("[color=#00ff88]✨ TipTop Studio е онлайн и напълно активно![/color]")
_add_log("[color=#00f2fe]Модел:[/color] " + current_model)
_add_log("[color=#ffff66]💡 Опитай: 'замък', 'тухлена стена', 'бемве', 'пиано', 'каща'![/color]")

_spawn_detailed_piano("Grand_Piano", Vector3(0, 0, -5.0))

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
fwd.y = 0.0
rgt.y = 0.0
fwd = fwd.normalized()
rgt = rgt.normalized()
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
if "piano" in hit.name.to_lower() or "роял" in hit.name.to_lower():
_play_piano_chord()
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

func _on_act_up():
if selected_obj and is_instance_valid(selected_obj): selected_obj.global_position.y += 0.8

func _on_act_down():
if selected_obj and is_instance_valid(selected_obj): selected_obj.global_position.y = max(0.0, selected_obj.global_position.y - 0.8)

func _on_act_rot():
if selected_obj and is_instance_valid(selected_obj): selected_obj.rotate_y(deg_to_rad(45.0))

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
status_lbl.text = "❌ Въведи първо API ключ!"
status_lbl.modulate = Color(1, 0.3, 0.3)
return

is_testing_models = true
test_btn.disabled = true
status_lbl.text = "⏳ Сваляне на модели..."
status_lbl.modulate = Color(0, 1, 0.6)

var url = providers[current_provider

cat << 'EOF' > scripts/Studio.gd
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

@onready var api_page = $UI/ApiPage
@onready var provider_select = $UI/ApiPage/Card/Margin/VBox/ProviderSelect
@onready var key_input = $UI/ApiPage/Card/Margin/VBox/KeyInput
@onready var test_btn = $UI/ApiPage/Card/Margin/VBox/TestBtn
@onready var status_lbl = $UI/ApiPage/Card/Margin/VBox/StatusLbl
@onready var search_input = $UI/ApiPage/Card/Margin/VBox/SearchInput
@onready var models_list_ui = $UI/ApiPage/Card/Margin/VBox/ModelsList
@onready var current_model_chip = $UI/ChatBG/VBox/TopRow/CurrentModelLbl

var audio_player: AudioStreamPlayer
var selected_obj: Node3D = null
var is_dragging: bool = false
var cam_yaw: float = 0.0
var cam_pitch: float = -0.4

var providers = {
    0: {"name": "OpenRouter", "chat": "https://openrouter.ai/api/v1/chat/completions", "models_url": "https://openrouter.ai/api/v1/models"},
    1: {"name": "Groq", "chat": "https://api.groq.com/openai/v1/chat/completions", "models_url": "https://api.groq.com/openai/v1/models"},
    2: {"name": "OpenAI", "chat": "https://api.openai.com/v1/chat/completions", "models_url": "https://api.openai.com/v1/models"}
}

var current_provider_idx: int = 0
var api_key: String = ""
var current_model: String = "openrouter/free"
var raw_models_cache: Array = []
var model_ids_map: Array = []
var is_testing_models: bool = false

func _ready():
    # ДИНАМИЧЕН АУДИО ПЛЕЙЪР (За да не крашва ако липсва в сцената)
    audio_player = AudioStreamPlayer.new()
    add_child(audio_player)

    center_tools.visible = false
    indicator.visible = false
    api_page.visible = false
    
    http_request.request_completed.connect(_on_http_response)
    provider_select.clear()
    provider_select.add_item("🌐 OpenRouter (300+ модела)")
    provider_select.add_item("⚡ Groq (Супер бърз)")
    provider_select.add_item("🤖 OpenAI (ChatGPT)")
    
    _load_saved_config()
    
    _add_log("[color=#00ff88]✨ TipTop Studio е онлайн![/color]")
    _add_log("[color=#00f2fe]Модел:[/color] " + current_model)
    _add_log("[color=#ffff66]💡 Опитай: 'замък', 'тухлена стена', 'бемве', 'пиано', 'каща'![/color]")
    
    _spawn_piano("Grand_Piano", Vector3(0, 0, -5.0))
    _spawn_castle("Medieval_Castle", Vector3(-6, 0, -10.0))

func _process(delta):
    if joy.output.length() > 0.05:
        var fwd = -camera.global_transform.basis.z; var rgt = camera.global_transform.basis.x
        fwd.y = 0.0; rgt.y = 0.0; fwd = fwd.normalized(); rgt = rgt.normalized()
        camera.global_position += (rgt * joy.output.x + fwd * -joy.output.y) * 15.0 * delta

    if selected_obj and is_instance_valid(selected_obj):
        indicator.visible = true
        indicator.global_position = selected_obj.global_position + Vector3(0, 3.5 + sin(Time.get_ticks_msec() * 0.006) * 0.25, 0)
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
                _select(hit); is_dragging = true
                # СВИРЕНЕ НА ПИАНО
                if "piano" in hit.name.to_lower(): _play_piano_chord()
            else:
                _deselect(); is_dragging = false
        else:
            is_dragging = false

    elif event is InputEventScreenDrag:
        if event.position.y > limit_h: return
        if is_dragging and selected_obj and is_instance_valid(selected_obj):
            var drop = _get_floor(event.position)
            if drop != Vector3.INF:
                selected_obj.global_position.x = drop.x; selected_obj.global_position.z = drop.z
        else:
            cam_yaw -= event.relative.x * 0.005; cam_pitch = clamp(cam_pitch - event.relative.y * 0.005, -1.4, 1.4)
            camera.rotation.y = cam_yaw; camera.rotation.x = cam_pitch

func _raycast(pos: Vector2):
    var from = camera.project_ray_origin(pos); var to = from + camera.project_ray_normal(pos) * 1000.0
    var res = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
    if res and res.collider.is_in_group("prop"): return res.collider.get_parent()
    return null

func _get_floor(pos: Vector2):
    var from = camera.project_ray_origin(pos); var dir = camera.project_ray_normal(pos)
    var h = selected_obj.global_position.y if selected_obj else 0.0
    var hit = Plane(Vector3.UP, h).intersects_ray(from, dir)
    if hit != null: return hit
    return Vector3.INF

func _select(obj): selected_obj = obj; lbl_selected.text = "🎯 " + obj.name; center_tools.visible = true
func _deselect(): selected_obj = null; center_tools.visible = false

func _on_act_up(): if selected_obj and is_instance_valid(selected_obj): selected_obj.global_position.y += 0.8
func _on_act_down(): if selected_obj and is_instance_valid(selected_obj): selected_obj.global_position.y = max(0.0, selected_obj.global_position.y - 0.8)
func _on_act_rot(): if selected_obj and is_instance_valid(selected_obj): selected_obj.rotate_y(deg_to_rad(45.0))
func _on_act_del(): if selected_obj and is_instance_valid(selected_obj): selected_obj.queue_free(); _deselect()

func _on_open_settings(): api_page.visible = true
func _on_close_settings(): api_page.visible = false; _save_config()
func _on_confirm_and_enter(): _save_config(); api_page.visible = false; _add_log("[color=#00ff88]✓ Модел:[/color] " + current_model)
func _on_key_submitted(_new_text: String): _on_fetch_models_pressed()
func _on_provider_selected(idx: int): current_provider_idx = idx; status_lbl.text = "Доставчик: " + providers[idx]["name"]; models_list_ui.clear()

func _on_fetch_models_pressed():
    api_key = key_input.text.strip_edges()
    if api_key.is_empty():
        status_lbl.text = "❌ Въведи първо API ключ!"; status_lbl.modulate = Color(1, 0.3, 0.3); return

    is_testing_models = true; test_btn.disabled = true
    status_lbl.text = "⏳ Сваляне на модели..."; status_lbl.modulate = Color(0, 1, 0.6)
    var url = providers[current_provider_idx]["models_url"]
    var headers = ["Authorization: Bearer " + api_key, "Content-Type: application/json"]
    if current_provider_idx == 0: headers.append("HTTP-Referer: https://tiptop.engine")
    http_request.request(url, headers, HTTPClient.METHOD_GET)

func _on_http_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
    test_btn.disabled = false
    if is_testing_models:
        is_testing_models = false
        if response_code == 200:
            var json = JSON.new()
            if json.parse(body.get_string_from_utf8()) == OK:
                var res = json.get_data(); var list = res.get("data", []); if list.is_empty(): list = res.get("models", [])
                raw_models_cache = list; _render_models_list(raw_models_cache, ""); _save_config()
                status_lbl.text = "✅ Намерени " + str(raw_models_cache.size()) + " модела!"; status_lbl.modulate = Color(0, 1, 0.5)
        else:
            status_lbl.text = "❌ Невалиден ключ! (Код " + str(response_code) + ")"; status_lbl.modulate = Color(1, 0.3, 0.3)

func _render_models_list(source_list: Array, filter_query: String):
    models_list_ui.clear(); model_ids_map.clear(); var q = filter_query.strip_edges().to_lower()
    if q.is_empty() or "free" in q: models_list_ui.add_item("⚡ АВТОМАТИЧЕН (OpenRouter Free Router)"); model_ids_map.append("openrouter/free")
    var free_list = []; var paid_list = []
    for item in source_list:
        var m_id = str(item.get("id", "")) if item is Dictionary else str(item)
        if m_id.is_empty() or m_id == "openrouter/free": continue
        if not q.is_empty() and not q in m_id.to_lower(): continue
        if ":free" in m_id.to_lower(): free_list.append(m_id)
        else: paid_list.append(m_id)
    free_list.sort(); paid_list.sort()
    for m in free_list: models_list_ui.add_item("🎁 [FREE] " + m); model_ids_map.append(m)
    for m in paid_list: models_list_ui.add_item("⭐ " + m); model_ids_map.append(m)

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
    raw_models_cache = cfg.get("raw_models", []); if not raw_models_cache.is_empty(): _render_models_list(raw_models_cache, "")

func _add_log(msg: String): chat_log.append_text(msg + "\n")

func _on_send_chat():
    var t = chat_input.text.strip_edges(); if t.is_empty(): return
    chat_input.text = ""; _add_log("[color=#00ff88]Ти:[/color] " + t)
    var low = t.to_lower()
    
    var fwd = -camera.global_transform.basis.z; fwd.y = 0.0
    var pos = camera.global_position + fwd.normalized() * 6.5; pos.y = 0.0
    
    if "пиан" in low or "роял" in low: _spawn_piano("Grand_Piano", pos)
    elif "замък" in low or "крепост" in low: _spawn_castle("Medieval_Castle", pos)
    elif "кол" in low or "бемв" in low or "bmw" in low: _spawn_car("BMW_Cabrio", "#0066ff", true, pos)
    elif "къщ" in low or "кащ" in low: _spawn_house("House", "#e76f51", pos)
    elif "стен" in low or "тухл" in low or "зид" in low: _spawn_wall("Brick_Wall", pos)
    else: _spawn_house("House", "#e76f51", pos) # Fallback

func _on_chip_pressed(txt: String): chat_input.text = txt; _on_send_chat()

# ================== СИНТЕЗАТОР НА ПИАНО АКОРД ==================
func _play_piano_chord():
    var sample_rate = 22050.0
    var duration = 1.2
    var num_samples = int(sample_rate * duration)
    var pcm = PackedByteArray()
    pcm.resize(num_samples * 2)
    var freqs = [261.63, 329.63, 392.00] # Мажорен акорд C-E-G

    for idx in range(num_samples):
        var t = float(idx) / sample_rate
        var envelope = exp(-t * 2.5)
        var sample = 0.0
        for f in freqs: sample += sin(t * f * TAU) * 0.33
        sample *= envelope
        pcm.encode_s16(idx * 2, int(clamp(sample, -1.0, 1.0) * 32767.0))

    var stream = AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = int(sample_rate)
    stream.data = pcm
    audio_player.stream = stream
    audio_player.play()
    _add_log("[color=#00ff88]🎵 Пианото изсвири хармоничен акорд C-E-G![/color]")

# ================== CAD МОДЕЛИ ==================
func _spawn_piano(piano_name: String, pos: Vector3):
    var root = Node3D.new(); root.name = piano_name; root.position = pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)
    var lacquer = StandardMaterial3D.new(); lacquer.albedo_color = Color(0.08, 0.08, 0.1); lacquer.metallic = 0.4; lacquer.roughness = 0.06; lacquer.clearcoat_enabled = true; lacquer.clearcoat = 1.0
    var gold = StandardMaterial3D.new(); gold.albedo_color = Color(0.96, 0.82, 0.28); gold.metallic = 0.96; gold.roughness = 0.12
    var red_felt = _mat(Color(0.8, 0.05, 0.12)); var wk = _mat(Color(0.96, 0.96, 0.98)); var bk = _mat(Color(0.06, 0.06, 0.08))

    _box(rb, Vector3(2.2, 0.45, 2.6), lacquer, Vector3(0, 1.15, 0))
    _box(rb, Vector3(1.6, 0.44, 1.4), lacquer, Vector3(-0.25, 1.15, 1.2))
    _box(rb, Vector3(2.24, 0.04, 2.64), gold, Vector3(0, 1.38, 0))

    for lp in [Vector3(-0.9, 0.55, -1.0), Vector3(0.9, 0.55, -1.0), Vector3(-0.2, 0.55, 1.6)]:
        _cyl(rb, 0.09, 1.1, lacquer, lp); _cyl(rb, 0.11, 0.06, gold, lp + Vector3(0, 0.48, 0)); _sph(rb, 0.07, gold, lp - Vector3(0, 0.52, 0))

    _box(rb, Vector3(2.3, 0.06, 2.7), lacquer, Vector3(0.3, 1.8, 0.1), Vector3(0, 0, deg_to_rad(32)))
    _cyl(rb, 0.03, 0.9, gold, Vector3(0.7, 1.6, 0.2), Vector3(0, 0, deg_to_rad(15)))
    _box(rb, Vector3(0.12, 0.05, 0.2), gold, Vector3(-0.8, 1.4, 0.1)); _box(rb, Vector3(0.12, 0.05, 0.2), gold, Vector3(-0.8, 1.4, 1.0))
    _box(rb, Vector3(1.92, 0.02, 0.06), red_felt, Vector3(0, 1.04, -1.32))
    _box(rb, Vector3(1.9, 0.08, 0.35), wk, Vector3(0, 0.98, -1.45)); _box(rb, Vector3(1.7, 0.12, 0.2), bk, Vector3(0, 1.02, -1.5))
    _box(rb, Vector3(0.35, 0.25, 0.1), lacquer, Vector3(0, 0.3, -0.6)); _box(rb, Vector3(0.06, 0.04, 0.2), gold, Vector3(-0.08, 0.18, -0.68))
    _box(rb, Vector3(0.06, 0.04, 0.2), gold, Vector3(0.0, 0.18, -0.68)); _box(rb, Vector3(0.06, 0.04, 0.2), gold, Vector3(0.08, 0.18, -0.68))

    _col(rb, Vector3(2.6, 2.2, 3.2), Vector3(0, 1.1, 0))
    world.add_child(root); _select(root); _add_log("[color=#00ff88]✓ Концертно пиано създадено![/color]")

func _spawn_castle(castle_name: String, pos: Vector3):
    var root = Node3D.new(); root.name = castle_name; root.position = pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

    var stone = _mat(Color(0.48, 0.5, 0.55), 0.95); var blue_roof = _mat(Color(0.12, 0.3, 0.75), 0.75); var flag = _mat(Color(1.0, 0.15, 0.15))
    _box(rb, Vector3(7.0, 3.5, 7.0), stone, Vector3(0, 1.75, 0))

    for tp in [Vector3(-3.8, 0, -3.8), Vector3(3.8, 0, -3.8), Vector3(-3.8, 0, 3.8), Vector3(3.8, 0, 3.8)]:
        _cyl(rb, 1.1, 5.5, stone, tp + Vector3(0, 2.75, 0))
        var cone = CylinderMesh.new(); cone.top_radius = 0.02; cone.bottom_radius = 1.35; cone.height = 2.2; _add_m(rb, cone, blue_roof, tp + Vector3(0, 6.6, 0))

    _cyl(rb, 1.8, 7.5, stone, Vector3(0, 3.75, 0))
    var mcone = CylinderMesh.new(); mcone.top_radius = 0.02; mcone.bottom_radius = 2.1; mcone.height = 2.8; _add_m(rb, mcone, blue_roof, Vector3(0, 8.9, 0))
    _cyl(rb, 0.04, 1.2, stone, Vector3(0, 10.8, 0)); _box(rb, Vector3(0.6, 0.35, 0.04), flag, Vector3(0.32, 11.1, 0))
    for bx in [-2.5, 0.0, 2.5]: _box(rb, Vector3(0.7, 0.45, 0.3), stone, Vector3(bx, 3.75, -3.6)); _box(rb, Vector3(0.7, 0.45, 0.3), stone, Vector3(bx, 3.75, 3.6))

    _col(rb, Vector3(10.0, 11.5, 10.0), Vector3(0, 5.0, 0))
    world.add_child(root); _select(root); _add_log("[color=#00ff88]✓ Средновековен замък издигнат![/color]")

func _spawn_car(car_name: String, color_hex: String, is_cabrio: bool, pos: Vector3):
    var root = Node3D.new(); root.name = car_name; root.position = pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

    var p_mat = StandardMaterial3D.new(); p_mat.albedo_color = Color.from_string(color_hex, Color.RED); p_mat.metallic = 0.92; p_mat.roughness = 0.14; p_mat.clearcoat_enabled = true; p_mat.clearcoat = 1.0
    var blk = _mat(Color(0.1, 0.1, 0.12)); var chrm = StandardMaterial3D.new(); chrm.albedo_color = Color(0.9, 0.9, 0.95); chrm.metallic = 0.98; chrm.roughness = 0.15
    var tire = _mat(Color(0.12, 0.12, 0.14), 0.85)

    _box(rb, Vector3(2.1, 0.35, 4.5), p_mat, Vector3(0, 0.45, 0))
    _box(rb, Vector3(2.15, 0.12, 0.4), blk, Vector3(0, 0.32, -2.15))
    _box(rb, Vector3(1.2, 0.22, 0.06), blk, Vector3(0, 0.48, -2.26))
    _box(rb, Vector3(1.95, 0.24, 1.6), p_mat, Vector3(0, 0.65, -1.25))

    if is_cabrio:
        var gm = StandardMaterial3D.new(); gm.albedo_color = Color(0.1, 0.25, 0.4, 0.4); gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
        _box(rb, Vector3(1.85, 0.48, 0.06), gm, Vector3(0, 0.92, -0.45), Vector3(deg_to_rad(-24), 0, 0))
        var sm = _mat(Color(0.15, 0.15, 0.18), 0.6)
        _box(rb, Vector3(0.65, 0.5, 0.6), sm, Vector3(-0.45, 0.72, 0.2)); _box(rb, Vector3(0.65, 0.5, 0.6), sm, Vector3(0.45, 0.72, 0.2))
        _box(rb, Vector3(1.6, 0.22, 0.4), blk, Vector3(0, 0.78, -0.28))
        var tor = TorusMesh.new(); tor.inner_radius = 0.03; tor.outer_radius = 0.18; _add_m(rb, tor, chrm, Vector3(-0.45, 0.88, -0.15), Vector3(deg_to_rad(25), 0, 0))
    else:
        _box(rb, Vector3(1.65, 0.55, 2.1), _mat(Color(0.08, 0.1, 0.15)), Vector3(0, 0.85, 0.1))

    for wp in [Vector3(-1.05, 0.38, -1.35), Vector3(1.05, 0.38, -1.35), Vector3(-1.05, 0.38, 1.35), Vector3(1.05, 0.38, 1.35)]:
        _cyl(rb, 0.38, 0.28, tire, wp, Vector3(0, 0, deg_to_rad(90)))
        _cyl(rb, 0.24, 0.29, chrm, wp, Vector3(0, 0, deg_to_rad(90)))

    _col(rb, Vector3(2.4, 1.3, 4.6), Vector3(0, 0.65, 0))
    world.add_child(root); _select(root); _add_log("[color=#00ff88]✓ Спортна кола создадена![/color]")

func _spawn_wall(wall_name: String, pos: Vector3):
    var root = Node3D.new(); root.name = wall_name; root.position = pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)
    var r = _mat(Color(0.72, 0.25, 0.16), 0.92); var d = _mat(Color(0.58, 0.18, 0.12), 0.95); var sc = _mat(Color(0.85, 0.85, 0.88), 0.85)

    _box(rb, Vector3(6.0, 3.2, 0.55), _mat(Color(0.7, 0.7, 0.72)), Vector3(0, 1.6, 0))
    for row in range(7):
        var yp = 0.25 + row * 0.45; var ox = 0.3 if row % 2 == 1 else 0.0
        for col in range(-4, 5):
            var xp = col * 0.7 + ox
            if abs(xp) < 2.8: _box(rb, Vector3(0.62, 0.38, 0.62), r if (row + col) % 2 == 0 else d, Vector3(xp, yp, 0))

    _box(rb, Vector3(6.3, 0.18, 0.75), sc, Vector3(0, 3.3, 0))
    _col(rb, Vector3(6.3, 3.4, 0.75), Vector3(0, 1.7, 0))
    world.add_child(root); _select(root); _add_log("[color=#00ff88]✓ Тухлена стена иззидана![/color]")

func _spawn_house(house_name: String, wall_col: String, pos: Vector3):
    var root = Node3D.new(); root.name = house_name; root.position = pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

    var wm = _mat(Color.from_string(wall_col, Color(0.9, 0.85, 0.75)), 0.9); var sm = _mat(Color(0.3, 0.32, 0.36), 0.95)
    var rm = _mat(Color(0.48, 0.15, 0.12), 0.8); var wfm = _mat(Color(0.95, 0.95, 0.95))

    _box(rb, Vector3(5.4, 0.35, 4.8), sm, Vector3(0, 0.17, 0))
    _box(rb, Vector3(5.0, 3.0, 4.4), wm, Vector3(0, 1.85, 0))
    var prism = PrismMesh.new(); prism.size = Vector3(4.8, 1.8, 5.4); _add_m(rb, prism, rm, Vector3(0, 4.2, 0), Vector3(0, deg_to_rad(90), 0))
    _box(rb, Vector3(0.65, 1.6, 0.65), sm, Vector3(1.5, 4.4, 0.6))
    _box(rb, Vector3(1.2, 2.1, 0.08), _mat(Color(0.28, 0.16, 0.08), 0.7), Vector3(0, 1.4, -2.25))

    for wp in [Vector3(-1.5, 1.8, -2.24), Vector3(1.5, 1.8, -2.24), Vector3(-2.54, 1.8, 0), Vector3(2.54, 1.8, 0)]:
        _box(rb, Vector3(1.2, 1.2, 0.06), wfm, wp)

    _col(rb, Vector3(5.6, 5.0, 5.0), Vector3(0, 2.5, 0))
    world.add_child(root); _select(root); _add_log("[color=#00ff88]✓ Къща построена![/color]")

func _mat(col: Color, rough: float = 0.4) -> StandardMaterial3D:
    var m = StandardMaterial3D.new(); m.albedo_color = col; m.roughness = rough; return m

func _box(p: Node3D, sz: Vector3, mat: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO):
    var m = BoxMesh.new(); m.size = sz; _add_m(p, m, mat, pos, rot)

func _cyl(p: Node3D, r: float, h: float, mat: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO):
    var m = CylinderMesh.new(); m.top_radius = r; m.bottom_radius = r; m.height = h; _add_m(p, m, mat, pos, rot)

func _sph(p: Node3D, r: float, mat: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO):
    var m = SphereMesh.new(); m.radius = r; m.height = r * 2.0; _add_m(p, m, mat, pos, rot)

func _col(p: Node3D, sz: Vector3, pos: Vector3):
    var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = sz; cs.shape = bs; cs.position = pos; p.add_child(cs)

func _add_m(p: Node3D, msh: Mesh, mat: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO):
    var mi = MeshInstance3D.new(); mi.mesh = msh; mi.material_override = mat; mi.position = pos; mi.rotation = rot; p.add_child(mi)
