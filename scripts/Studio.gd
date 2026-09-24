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
var cam_pitch: float = -0.4
var animated_parts: Array = []

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
    
    _add_log("[color=#00ff88]✨ TipTop High-Definition 3D Studio е заредено![/color]")
    _add_log("[color=#00f2fe]Модел:[/color] " + current_model)
    _add_log("[color=#ffff66]💡 Напиши: 'червена кола кабрио', 'къща', 'бемве', 'замък'![/color]")
    
    # Стартираме веднага с високодетайлно червено спортно кабрио с волан и седалки
    _spawn_high_detail_car("Sports_Cabrio", "#e60026", true)

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
        indicator.global_position = selected_obj.global_position + Vector3(0, 3.2 + bounce, 0)
    else:
        indicator.visible = false

    _process_animations(delta)

func _process_animations(delta):
    var t = Time.get_ticks_msec() * 0.001
    var i = 0
    while i < animated_parts.size():
        var item = animated_parts[i]
        var node = item.get("node")
        if not is_instance_valid(node):
            animated_parts.remove_at(i)
            continue
        var anim_type = item.get("anim", "none")
        match anim_type:
            "spin_y": node.rotate_y(delta * 9.0)
            "spin_x": node.rotate_x(delta * 9.0)
            "bob": node.position.y = item.get("base_pos").y + sin(t * 3.5) * 0.2
            "flap": node.rotation.z = sin(t * 7.0) * deg_to_rad(25.0)
            "pulse":
                if node is MeshInstance3D and node.material_override is StandardMaterial3D:
                    node.material_override.emission_energy_multiplier = (sin(t * 6.0) * 0.5 + 0.5) * 4.0
        i += 1

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
    status_lbl.modulate = Color(0, 1, 0.6)

    var url = providers[current_provider_idx]["models_url"]
    var headers = ["Authorization: Bearer " + api_key, "Content-Type: application/json"]
    if current_provider_idx == 0:
        headers.append("HTTP-Referer: https://tiptop.engine")
        headers.append("X-Title: TipTop Studio")

    http_request.request(url, headers, HTTPClient.METHOD_GET)

func _on_http_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
    test_btn.disabled = false
    if is_testing_models:
        is_testing_models = false
        if response_code == 200:
            var json = JSON.new()
            if json.parse(body.get_string_from_utf8()) == OK:
                var res = json.get_data()
                var list = res.get("data", [])
                if list.is_empty(): list = res.get("models", [])
                raw_models_cache = list
                _render_models_list(raw_models_cache, "")
                status_lbl.text = "✅ Намерени " + str(raw_models_cache.size()) + " модела!"
                status_lbl.modulate = Color(0, 1, 0.5)
                _save_config()
            else:
                status_lbl.text = "❌ Грешка при четене."
                status_lbl.modulate = Color(1, 0.3, 0.3)
        else:
            status_lbl.text = "❌ Невалиден ключ! (Код " + str(response_code) + ")"
            status_lbl.modulate = Color(1, 0.3, 0.3)
    else:
        if response_code == 200:
            var json = JSON.new()
            if json.parse(body.get_string_from_utf8()) == OK:
                var res = json.get_data()
                var choices = res.get("choices", [])
                if not choices.is_empty():
                    var content = choices[0].get("message", {}).get("content", "").strip_edges()
                    _interpret_ai_and_construct(content)
                else:
                    _add_log("[color=#ff4444]AI не върна съдържание.[/color]")
            else:
                _add_log("[color=#ff4444]Грешка в отговора.[/color]")
        else:
            _add_log("[color=#ff4444]AI грешка (" + str(response_code) + ").[/color]")

func _render_models_list(source_list: Array, filter_query: String):
    models_list_ui.clear()
    model_ids_map.clear()
    var q = filter_query.strip_edges().to_lower()
    
    if q.is_empty() or "free" in q or "auto" in q:
        models_list_ui.add_item("⚡ АВТОМАТИЧЕН (OpenRouter Free Router)")
        model_ids_map.append("openrouter/free")
        
    var free_list = []
    var paid_list = []
    for item in source_list:
        var m_id = str(item.get("id", "")) if item is Dictionary else str(item)
        if m_id.is_empty() or m_id == "openrouter/free": continue
        if not q.is_empty() and not q in m_id.to_lower(): continue
        if ":free" in m_id.to_lower() or "free" in m_id.to_lower():
            free_list.append(m_id)
        else:
            paid_list.append(m_id)
            
    free_list.sort()
    paid_list.sort()
    for m in free_list:
        models_list_ui.add_item("🎁 [FREE] " + m)
        model_ids_map.append(m)
    for m in paid_list:
        models_list_ui.add_item("⭐ " + m)
        model_ids_map.append(m)
        
    var sel_idx = model_ids_map.find(current_model)
    if sel_idx != -1 and sel_idx < models_list_ui.item_count:
        models_list_ui.select(sel_idx)

func _on_search_changed(new_text: String): _render_models_list(raw_models_cache, new_text)

func _on_model_item_selected(index: int):
    if index >= 0 and index < model_ids_map.size():
        current_model = model_ids_map[index]
        current_model_chip.text = "🤖 " + current_model
        _save_config()

func _save_config():
    var cfg = {
        "provider": current_provider_idx,
        "api_key": key_input.text.strip_edges(),
        "model": current_model,
        "raw_models": raw_models_cache
    }
    var f = FileAccess.open("user://api_config.json", FileAccess.WRITE)
    if f: f.store_string(JSON.stringify(cfg))

func _load_saved_config():
    if not FileAccess.file_exists("user://api_config.json"): return
    var f = FileAccess.open("user://api_config.json", FileAccess.READ)
    if not f: return
    var json = JSON.new()
    if json.parse(f.get_as_text()) != OK: return
    var cfg = json.get_data()
    if not cfg is Dictionary: return
        
    current_provider_idx = int(cfg.get("provider", 0))
    if current_provider_idx < provider_select.item_count:
        provider_select.selected = current_provider_idx
        
    api_key = str(cfg.get("api_key", ""))
    key_input.text = api_key
    current_model = str(cfg.get("model", "openrouter/free"))
    current_model_chip.text = "🤖 " + current_model
    
    var saved_list = cfg.get("raw_models", [])
    if saved_list is Array and not saved_list.is_empty():
        raw_models_cache = saved_list
        _render_models_list(raw_models_cache, "")

func _add_log(msg: String): chat_log.append_text(msg + "\n")

func _on_send_chat():
    var t = chat_input.text.strip_edges()
    if t.is_empty(): return
    chat_input.text = ""
    _add_log("[color=#00ff88]Ти:[/color] " + t)

    var low = t.to_lower()
    # Локално разпознаване с мигновена висока детайлност
    if "кола" in low or "бемве" in low or "bmw" in low or "автомобил" in low:
        var is_cab = "кабрио" in low or "открит" in low
        var col = "#0066ff" if "бемве" in low or "bmw" in low else ("#e60026" if "червен" in low else "#ffd000")
        var name_car = "BMW_Cabrio" if "бемве" in low else "Sports_Car"
        _spawn_high_detail_car(name_car, col, is_cab)
    elif "къща" in low or "дом" in low or "вила" in low:
        var col = "#e76f51" if "тухл" in low or "червен" in low else "#2a9d8f"
        _spawn_high_detail_house("Cozy_House", col)
    elif "сграда" in low or "небостъргач" in low or "блок" in low:
        _spawn_high_detail_skyscraper("Skyscraper")
    elif "дърво" in low or "гора" in low:
        _spawn_high_detail_tree("Tree")
    elif not api_key.is_empty():
        _request_ai_parameters(t)
    else:
        _add_log("[color=#ffff66]Въведи ключ от '⚙️ AI Облак' за свободни команди.[/color]")

func _on_chip_pressed(txt: String):
    chat_input.text = txt
    _on_send_chat()

# ИЗПРАЩАНЕ НА СЕМАНТИЧНА ЗАЯВКА КЪМ AI ЗА ПАРАМЕТРИ
func _request_ai_parameters(prompt: String):
    _add_log("[color=#00f2fe]⏳ " + current_model + " проектира детайлен 3D дизайн...[/color]")
    var url = providers[current_provider_idx]["chat"]
    var headers = ["Authorization: Bearer " + api_key, "Content-Type: application/json"]
    if current_provider_idx == 0:
        headers.append("HTTP-Referer: https://tiptop.engine")
        headers.append("X-Title: TipTop Studio")

    var system_prompt = """Extract 3D construction parameters from the user's Bulgarian request.
Output ONLY raw JSON:
{
  "category": "car" | "house" | "skyscraper" | "tree" | "prop",
  "name": "BulgarianName",
  "color": "#HEX",
  "cabrio": true | false,
  "style": "sport" | "classic" | "cyber"
}"""

    var body = JSON.stringify({
        "model": current_model,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt}
        ],
        "temperature": 0.2
    })
    http_request.request(url, headers, HTTPClient.METHOD_POST, body)

func _interpret_ai_and_construct(raw_json: String):
    var clean = raw_json.strip_edges()
    var s_idx = clean.find("{"); var e_idx = clean.rfind("}")
    if s_idx != -1 and e_idx != -1 and e_idx > s_idx:
        clean = clean.substr(s_idx, e_idx - s_idx + 1)

    var j = JSON.new()
    if j.parse(clean) == OK and j.get_data() is Dictionary:
        var d = j.get_data()
        var cat = str(d.get("category", "car")).to_lower()
        var col = str(d.get("color", "#e60026"))
        var name_obj = str(d.get("name", "Custom_Object"))
        var is_cab = bool(d.get("cabrio", false))

        if cat == "car":
            _spawn_high_detail_car(name_obj, col, is_cab)
        elif cat == "house":
            _spawn_high_detail_house(name_obj, col)
        elif cat == "skyscraper":
            _spawn_high_detail_skyscraper(name_obj)
        elif cat == "tree":
            _spawn_high_detail_tree(name_obj)
        else:
            _spawn_high_detail_car(name_obj, col, is_cab)
    else:
        _spawn_high_detail_car("Sports_Car", "#e60026", true)

# ==============================================================================
# 1. АВТОМОБИЛЕН АРХИТЕКТ (28 ДЕТАЙЛА: КАПАК, КАБРИО САЛОН, ВОЛАН, ФАРОВЕ, ДЖАНТИ)
# ==============================================================================
func _spawn_high_detail_car(car_name: String, color_hex: String, is_cabrio: bool):
    var fwd = -camera.global_transform.basis.z; fwd.y = 0.0
    var spawn_pos = camera.global_position + fwd.normalized() * 6.5; spawn_pos.y = 0.0

    var root = Node3D.new(); root.name = car_name; root.position = spawn_pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

    # Автомобилен двоен лак (PBR)
    var p_mat = StandardMaterial3D.new()
    p_mat.albedo_color = Color.from_string(color_hex, Color.RED)
    p_mat.metallic = 0.92; p_mat.roughness = 0.14; p_mat.clearcoat_enabled = true; p_mat.clearcoat = 1.0

    var black_mat = StandardMaterial3D.new(); black_mat.albedo_color = Color(0.1, 0.1, 0.12); black_mat.roughness = 0.5
    var chrome_mat = StandardMaterial3D.new(); chrome_mat.albedo_color = Color(0.9, 0.9, 0.95); chrome_mat.metallic = 0.98; chrome_mat.roughness = 0.15
    var tire_mat = StandardMaterial3D.new(); tire_mat.albedo_color = Color(0.12, 0.12, 0.14); tire_mat.roughness = 0.85

    # 1. Шаси (Долна платформа и сплитер)
    _box(rb, Vector3(2.1, 0.35, 4.5), p_mat, Vector3(0, 0.45, 0))
    _box(rb, Vector3(2.15, 0.12, 0.4), black_mat, Vector3(0, 0.32, -2.15)) # Преден сплитер
    _box(rb, Vector3(1.2, 0.22, 0.06), black_mat, Vector3(0, 0.48, -2.26)) # Радиаторна решетка

    # 2. Скосен преден капак
    _box(rb, Vector3(1.95, 0.24, 1.6), p_mat, Vector3(0, 0.65, -1.25))

    # 3. Кабина (Кабриолет или Спортно Купе)
    if is_cabrio:
        # Скосено челно стъкло
        var g_mat = StandardMaterial3D.new(); g_mat.albedo_color = Color(0.1, 0.25, 0.4, 0.4); g_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS; g_mat.roughness = 0.05
        _box(rb, Vector3(1.85, 0.48, 0.06), g_mat, Vector3(0, 0.92, -0.45), Vector3(deg_to_rad(-24), 0, 0))
        
        # Салон с 2 спортни седалки с подглавници
        var seat_col = Color(0.15, 0.15, 0.18)
        var s_mat = StandardMaterial3D.new(); s_mat.albedo_color = seat_col; s_mat.roughness = 0.6
        _box(rb, Vector3(0.65, 0.5, 0.6), s_mat, Vector3(-0.45, 0.72, 0.2)) # Лява седалка
        _box(rb, Vector3(0.35, 0.22, 0.15), s_mat, Vector3(-0.45, 1.05, 0.45)) # Ляв подглавник
        _box(rb, Vector3(0.65, 0.5, 0.6), s_mat, Vector3(0.45, 0.72, 0.2)) # Дясна седалка
        _box(rb, Vector3(0.35, 0.22, 0.15), s_mat, Vector3(0.45, 1.05, 0.45)) # Десен подглавник

        # Табло и Истински 3D волан (Torus)
        _box(rb, Vector3(1.6, 0.22, 0.4), black_mat, Vector3(0, 0.78, -0.28))
        _torus(rb, 0.18, 0.03, chrome_mat, Vector3(-0.45, 0.88, -0.15), Vector3(deg_to_rad(25), 0, 0))
    else:
        var cm = StandardMaterial3D.new(); cm.albedo_color = Color(0.08, 0.1, 0.15); cm.roughness = 0.1
        _box(rb, Vector3(1.65, 0.55, 2.1), cm, Vector3(0, 0.85, 0.1))

    # 4. Странични огледала (Ляво и Дясно)
    _box(rb, Vector3(0.22, 0.12, 0.14), p_mat, Vector3(-1.16, 0.92, -0.4))
    _box(rb, Vector3(0.22, 0.12, 0.14), p_mat, Vector3(1.16, 0.92, -0.4))

    # 5. Заден капак и спортно антикрило (Спойлер)
    _box(rb, Vector3(1.9, 0.28, 1.15), p_mat, Vector3(0, 0.65, 1.45))
    _box(rb, Vector3(2.0, 0.06, 0.35), black_mat, Vector3(0, 0.96, 1.85)) # Крило
    _box(rb, Vector3(0.06, 0.2, 0.15), black_mat, Vector3(-0.7, 0.82, 1.85)) # Стойка 1
    _box(rb, Vector3(0.06, 0.2, 0.15), black_mat, Vector3(0.7, 0.82, 1.85)) # Стойка 2

    # 6. Ксенонови фарове отпред (Светещи)
    var hl_mat = StandardMaterial3D.new(); hl_mat.albedo_color = Color(1, 1, 1); hl_mat.emission_enabled = true; hl_mat.emission = Color(0.85, 0.95, 1.0); hl_mat.emission_energy_multiplier = 4.0
    _box(rb, Vector3(0.42, 0.14, 0.05), hl_mat, Vector3(-0.7, 0.56, -2.26))
    _box(rb, Vector3(0.42, 0.14, 0.05), hl_mat, Vector3(0.7, 0.56, -2.26))

    # 7. Червени LED стопове отзад (Светещи)
    var tl_mat = StandardMaterial3D.new(); tl_mat.albedo_color = Color(1, 0, 0); tl_mat.emission_enabled = true; tl_mat.emission = Color(1.0, 0.05, 0.05); tl_mat.emission_energy_multiplier = 4.0
    _box(rb, Vector3(0.55, 0.12, 0.05), tl_mat, Vector3(-0.65, 0.6, 2.26))
    _box(rb, Vector3(0.55, 0.12, 0.05), tl_mat, Vector3(0.65, 0.6, 2.26))

    # 8. Двойни хромирани ауспуси отзад
    _cyl(rb, 0.08, 0.25, chrome_mat, Vector3(-0.5, 0.35, 2.3), Vector3(deg_to_rad(90), 0, 0))
    _cyl(rb, 0.08, 0.25, chrome_mat, Vector3(0.5, 0.35, 2.3), Vector3(deg_to_rad(90), 0, 0))

    # 9. ЧЕТИРИТЕ КОЛЕЛА (Гума + Хромирана титаниева джанта)
    var wheel_coords = [
        Vector3(-1.05, 0.38, -1.35), Vector3(1.05, 0.38, -1.35),
        Vector3(-1.05, 0.38, 1.35), Vector3(1.05, 0.38, 1.35)
    ]
    for w_pos in wheel_coords:
        _cyl(rb, 0.38, 0.28, tire_mat, w_pos, Vector3(0, 0, deg_to_rad(90))) # Гума
        _cyl(rb, 0.24, 0.29, chrome_mat, w_pos, Vector3(0, 0, deg_to_rad(90))) # Джанта
        _cyl(rb, 0.08, 0.30, black_mat, w_pos, Vector3(0, 0, deg_to_rad(90))) # Централна капачка

    var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(2.4, 1.3, 4.6); cs.shape = bs; cs.position.y = 0.65; rb.add_child(cs)
    world.add_child(root); _select(root)
    _add_log("[color=#00ff88]✓ " + car_name + " е конструиран анатомично с 28 детайла![/color]")

# ==============================================================================
# 2. АРХИТЕКТУРЕН АРХИТЕКТ (24 ДЕТАЙЛА: ФУНДАМЕНТ, ПОКРИВ, КОМИН, ВРАТА, ПРОЗОРЦИ)
# ==============================================================================
func _spawn_high_detail_house(house_name: String, wall_color_hex: String):
    var fwd = -camera.global_transform.basis.z; fwd.y = 0.0
    var spawn_pos = camera.global_position + fwd.normalized() * 7.5; spawn_pos.y = 0.0

    var root = Node3D.new(); root.name = house_name; root.position = spawn_pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

    var wall_mat = StandardMaterial3D.new(); wall_mat.albedo_color = Color.from_string(wall_color_hex, Color(0.9, 0.85, 0.75)); wall_mat.roughness = 0.9
    var stone_mat = StandardMaterial3D.new(); stone_mat.albedo_color = Color(0.3, 0.32, 0.36); stone_mat.roughness = 0.95
    var roof_mat = StandardMaterial3D.new(); roof_mat.albedo_color = Color(0.48, 0.15, 0.12); roof_mat.roughness = 0.8
    var wood_mat = StandardMaterial3D.new(); wood_mat.albedo_color = Color(0.28, 0.16, 0.08); wood_mat.roughness = 0.7
    var white_frame_mat = StandardMaterial3D.new(); white_frame_mat.albedo_color = Color(0.95, 0.95, 0.95)
    var glass_mat = StandardMaterial3D.new(); glass_mat.albedo_color = Color(0.2, 0.4, 0.6, 0.5); glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS; glass_mat.roughness = 0.05
    var lantern_mat = StandardMaterial3D.new(); lantern_mat.albedo_color = Color(1, 0.8, 0.2); lantern_mat.emission_enabled = true; lantern_mat.emission = Color(1.0, 0.85, 0.2); lantern_mat.emission_energy_multiplier = 3.0

    # 1. Каменен фундамент и веранда
    _box(rb, Vector3(5.4, 0.35, 4.8), stone_mat, Vector3(0, 0.17, 0))
    _box(rb, Vector3(1.8, 0.18, 0.8), stone_mat, Vector3(0, 0.09, -2.6)) # Входно стъпало

    # 2. Основен етаж (Стени)
    _box(rb, Vector3(5.0, 3.0, 4.4), wall_mat, Vector3(0, 1.85, 0))

    # 3. Двускатен покрив с керемиди
    _prism(rb, Vector3(4.8, 1.8, 5.4), roof_mat, Vector3(0, 4.2, 0), Vector3(0, deg_to_rad(90), 0))

    # 4. Тухлен комин
    _box(rb, Vector3(0.65, 1.6, 0.65), stone_mat, Vector3(1.5, 4.4, 0.6))

    # 5. Входна врата с дървена каса и златна дръжка
    _box(rb, Vector3(1.2, 2.1, 0.08), wood_mat, Vector3(0, 1.4, -2.25))
    _sph(rb, 0.06, chrome_mat(), Vector3(0.4, 1.35, -2.32)) # Дръжка

    # Светещ фенер до вратата
    _box(rb, Vector3(0.18, 0.25, 0.18), lantern_mat, Vector3(0.85, 1.8, -2.3))

    # 6. Прозорци с бели рамки и стъкла
    var win_coords = [
        Vector3(-1.5, 1.8, -2.24), Vector3(1.5, 1.8, -2.24), # Предни
        Vector3(-2.54, 1.8, 0), Vector3(2.54, 1.8, 0)         # Странични
    ]
    for w_idx in range(win_coords.size()):
        var w_pos = win_coords[w_idx]
        var is_side = w_idx >= 2
        var frame_sz = Vector3(0.06, 1.2, 1.2) if is_side else Vector3(1.2, 1.2, 0.06)
        var glass_sz = Vector3(0.08, 1.0, 1.0) if is_side else Vector3(1.0, 1.0, 0.08)
        _box(rb, frame_sz, white_frame_mat, w_pos)
        _box(rb, glass_sz, glass_mat, w_pos)

    var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(5.6, 5.0, 5.0); cs.shape = bs; cs.position.y = 2.5; rb.add_child(cs)
    world.add_child(root); _select(root)
    _add_log("[color=#00ff88]✓ " + house_name + " е построена с покрив, комин, врата и прозорци![/color]")

# 3. НЕБОСТЪРГАЧ
func _spawn_high_detail_skyscraper(bld_name: String):
    var fwd = -camera.global_transform.basis.z; fwd.y = 0.0
    var spawn_pos = camera.global_position + fwd.normalized() * 8.5; spawn_pos.y = 0.0

    var root = Node3D.new(); root.name = bld_name; root.position = spawn_pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

    var facade_mat = StandardMaterial3D.new(); facade_mat.albedo_color = Color(0.15, 0.22, 0.35); facade_mat.metallic = 0.8; facade_mat.roughness = 0.15
    var neon_mat = StandardMaterial3D.new(); neon_mat.albedo_color = Color(0, 0.9, 1); neon_mat.emission_enabled = true; neon_mat.emission = Color(0, 0.9, 1); neon_mat.emission_energy_multiplier = 3.0

    _box(rb, Vector3(3.6, 10.0, 3.6), facade_mat, Vector3(0, 5.0, 0))
    for f in range(1, 6):
        _box(rb, Vector3(3.7, 0.12, 3.7), neon_mat, Vector3(0, f * 1.8, 0))
    _cyl(rb, 0.08, 2.5, neon_mat, Vector3(0, 11.2, 0)) # Антена на покрива

    var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(3.8, 10.5, 3.8); cs.shape = bs; cs.position.y = 5.0; rb.add_child(cs)
    world.add_child(root); _select(root)
    _add_log("[color=#00ff88]✓ Небостъргач със стъклена фасада и антена е издигнат![/color]")

# 4. ДЪРВО С КЛОНИ И КОРОНА
func _spawn_high_detail_tree(tree_name: String):
    var fwd = -camera.global_transform.basis.z; fwd.y = 0.0
    var spawn_pos = camera.global_position + fwd.normalized() * 6.5; spawn_pos.y = 0.0

    var root = Node3D.new(); root.name = tree_name; root.position = spawn_pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

    var bark_mat = StandardMaterial3D.new(); bark_mat.albedo_color = Color(0.38, 0.22, 0.12); bark_mat.roughness = 0.95
    var leaf_mat = StandardMaterial3D.new(); leaf_mat.albedo_color = Color(0.12, 0.72, 0.22); leaf_mat.roughness = 0.8

    _cyl(rb, 0.32, 2.4, bark_mat, Vector3(0, 1.2, 0))
    _cyl(rb, 0.15, 1.1, bark_mat, Vector3(-0.4, 2.0, 0), Vector3(0, 0, deg_to_rad(30))) # Клон 1
    _cyl(rb, 0.15, 1.1, bark_mat, Vector3(0.4, 2.2, 0), Vector3(0, 0, deg_to_rad(-30))) # Клон 2

    # Многопластова корона
    _sph(rb, 1.5, leaf_mat, Vector3(0, 3.0, 0))
    _sph(rb, 1.2, leaf_mat, Vector3(-0.8, 3.2, 0.2))
    _sph(rb, 1.2, leaf_mat, Vector3(0.8, 3.4, -0.2))
    _sph(rb, 0.9, leaf_mat, Vector3(0, 4.2, 0))

    var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(3.0, 5.0, 3.0); cs.shape = bs; cs.position.y = 2.5; rb.add_child(cs)
    world.add_child(root); _select(root)
    _add_log("[color=#00ff88]✓ Дърво с клони и многопластова корона е засадено![/color]")

# ПОМОЩНИ ФУНКЦИИ ЗА ГЕОМЕТРИЯ
func _box(p: Node3D, sz: Vector3, mat: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO):
    var m = BoxMesh.new(); m.size = sz
    _add_mi(p, m, mat, pos, rot)

func _cyl(p: Node3D, r: float, h: float, mat: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO):
    var m = CylinderMesh.new(); m.top_radius = r; m.bottom_radius = r; m.height = h
    _add_mi(p, m, mat, pos, rot)

func _sph(p: Node3D, r: float, mat: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO):
    var m = SphereMesh.new(); m.radius = r; m.height = r * 2.0
    _add_mi(p, m, mat, pos, rot)

func _torus(p: Node3D, outer_r: float, inner_r: float, mat: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO):
    var m = TorusMesh.new(); m.outer_radius = outer_r; m.inner_radius = inner_r
    _add_mi(p, m, mat, pos, rot)

func _prism(p: Node3D, sz: Vector3, mat: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO):
    var m = PrismMesh.new(); m.size = sz
    _add_mi(p, m, mat, pos, rot)

func _add_mi(parent: Node3D, mesh_res: Mesh, mat: Material, pos: Vector3, rot: Vector3):
    var mi = MeshInstance3D.new()
    mi.mesh = mesh_res
    mi.material_override = mat
    mi.position = pos
    mi.rotation = rot
    parent.add_child(mi)

func chrome_mat() -> StandardMaterial3D:
    var m = StandardMaterial3D.new()
    m.albedo_color = Color(0.95, 0.95, 0.98); m.metallic = 0.98; m.roughness = 0.1
    return m
