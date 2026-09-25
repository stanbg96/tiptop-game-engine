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
    
    _add_log("[color=#00ff88]✨ Холивудско Студийно Осветление & PBR са активни![/color]")
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
                    var raw_content = choices[0].get("message", {}).get("content", "").strip_edges()
                    _interpret_and_build(raw_content, last_user_prompt)
                else:
                    _fuzzy_semantic_engine(last_user_prompt)
            else:
                _fuzzy_semantic_engine(last_user_prompt)
        else:
            _fuzzy_semantic_engine(last_user_prompt)

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
    last_user_prompt = t

    if _fuzzy_stem_match(t.to_lower()):
        return

    if not api_key.is_empty():
        _request_ai_universal_recipe(t)
    else:
        _fuzzy_semantic_engine(t)

func _on_chip_pressed(txt: String):
    chat_input.text = txt
    _on_send_chat()

func _get_spawn_pos() -> Vector3:
    var fwd = -camera.global_transform.basis.z; fwd.y = 0.0
    var p = camera.global_position + fwd.normalized() * 7.5; p.y = 0.0
    return p

func _fuzzy_stem_match(low: String) -> bool:
    var pos = _get_spawn_pos()
    
    if "стен" in low or "тухл" in low or "зид" in low or "оград" in low:
        _spawn_detailed_brick_wall("Brick_Wall", pos)
        return true
    elif "пиан" in low or "роял" in low or "клавиш" in low:
        _spawn_detailed_piano("Grand_Piano", pos)
        return true
    elif "замък" in low or "замк" in low or "крепос" in low or "цитадел" in low:
        _spawn_detailed_castle("Medieval_Castle", pos)
        return true
    elif "къщ" in low or "кащ" in low or "дом" in low or "вил" in low:
        _spawn_detailed_house("Cozy_House", "#e76f51", pos)
        return true
    elif "кол" in low or "бемв" in low or "bmw" in low or "кабри" in low:
        var is_cab = "кабри" in low or "бемв" in low or "bmw" in low
        var col = "#0066ff" if "бемв" in low else "#e60026"
        _spawn_detailed_car("Sports_Car", col, is_cab, pos)
        return true

    return false

func _request_ai_universal_recipe(prompt: String):
    _add_log("[color=#00f2fe]⏳ " + current_model + " проектира детайлен 3D CAD модел в RAM...[/color]")
    var url = providers[current_provider_idx]["chat"]
    var headers = ["Authorization: Bearer " + api_key, "Content-Type: application/json"]
    if current_provider_idx == 0:
        headers.append("HTTP-Referer: https://tiptop.engine")
        headers.append("X-Title: TipTop Studio")

    var system_prompt = """You are an expert 3D Procedural CAD Modeler. 
Understand user intent even with spelling typos (e.g. 'каща' -> house, 'тухлена стена' -> brick wall).
Output ONLY raw JSON (no markdown, no explanations):
{
  "name": "BulgarianName",
  "parts": [
    {
      "shape": "box" | "sphere" | "cylinder" | "torus" | "prism",
      "pos": [x, y, z],
      "size": [w, h, d],
      "rot": [pitch_deg, yaw_deg, roll_deg],
      "color": "#HEX",
      "metallic": 0.0-1.0,
      "roughness": 0.0-1.0,
      "clearcoat": 0.0-1.0
    }
  ]
}
Y=0 is ground level (Y>=0). Use 6 to 18 detailed parts."""

    var body = JSON.stringify({
        "model": current_model,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": "3D CAD model for: " + prompt}
        ],
        "max_tokens": 1400,
        "temperature": 0.2
    })
    http_request.request(url, headers, HTTPClient.METHOD_POST, body)

func _interpret_and_build(raw_text: String, original_prompt: String):
    var clean = raw_text.strip_edges()
    if clean.contains("```"):
        var parts = clean.split("```")
        for p in parts:
            var t = p.strip_edges()
            if t.begins_with("json"): t = t.substr(4).strip_edges()
            if t.contains("{"): clean = t; break

    var s_idx = clean.find("{"); var e_idx = clean.rfind("}")
    if s_idx != -1 and e_idx != -1 and e_idx > s_idx:
        clean = clean.substr(s_idx, e_idx - s_idx + 1)

    var j = JSON.new()
    if j.parse(clean) == OK and j.get_data() is Dictionary and j.get_data().has("parts"):
        _build_raw_recipe(j.get_data())
    else:
        _fuzzy_semantic_engine(original_prompt)

func _build_raw_recipe(recipe: Dictionary):
    var root = Node3D.new()
    root.name = str(recipe.get("name", "Custom_Object"))
    root.position = _get_spawn_pos()

    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

    for part in recipe.get("parts", []):
        var shape = str(part.get("shape", "box")).to_lower()
        var pos = part.get("pos", [0, 0, 0])
        var sz = part.get("size", [1, 1, 1])
        var rot = part.get("rot", [0, 0, 0])
        var col = str(part.get("color", "#00f2fe"))
        var met = float(part.get("metallic", 0.2))
        var rough = float(part.get("roughness", 0.4))
        var clr = float(part.get("clearcoat", 0.0))

        var p_pos = Vector3(float(pos[0]), max(0.0, float(pos[1])), float(pos[2]))
        var p_sz = Vector3(max(0.05, float(sz[0])), max(0.05, float(sz[1])), max(0.05, float(sz[2])))
        var p_rot = Vector3(deg_to_rad(float(rot[0])), deg_to_rad(float(rot[1])), deg_to_rad(float(rot[2])))

        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color.from_string(col, Color.CYAN)
        mat.metallic = met; mat.roughness = rough
        if clr > 0.0:
            mat.clearcoat_enabled = true; mat.clearcoat = clr; mat.clearcoat_roughness = 0.04

        if shape == "cylinder":
            _cyl(rb, p_sz.x * 0.5, p_sz.y, mat, p_pos, p_rot)
        elif shape == "sphere":
            _sph(rb, p_sz.x * 0.5, mat, p_pos, p_rot)
        elif shape == "torus":
            _torus(rb, p_sz.x * 0.5, max(0.02, p_sz.x * 0.15), mat, p_pos, p_rot)
        elif shape == "prism":
            _prism(rb, p_sz, mat, p_pos, p_rot)
        else:
            _box(rb, p_sz, mat, p_pos, p_rot)

    var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(4, 4, 4); cs.shape = bs; cs.position.y = 2.0; rb.add_child(cs)
    world.add_child(root); _select(root)
    _add_log("[color=#00ff88]✓ " + root.name + " е компилиран в 3D света![/color]")

func _fuzzy_semantic_engine(prompt: String):
    var low = prompt.to_lower()
    var pos = _get_spawn_pos()
    if not _fuzzy_stem_match(low):
        _spawn_detailed_brick_wall("Custom_Structure", pos)

func _spawn_detailed_piano(piano_name: String, pos: Vector3):
    var root = Node3D.new(); root.name = piano_name; root.position = pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

    var lacquer = StandardMaterial3D.new()
    lacquer.albedo_color = Color(0.08, 0.08, 0.1)
    lacquer.metallic = 0.4; lacquer.roughness = 0.06
    lacquer.clearcoat_enabled = true; lacquer.clearcoat = 1.0; lacquer.clearcoat_roughness = 0.03

    var gold = StandardMaterial3D.new(); gold.albedo_color = Color(0.96, 0.82, 0.28); gold.metallic = 0.96; gold.roughness = 0.12
    var red_felt = StandardMaterial3D.new(); red_felt.albedo_color = Color(0.8, 0.05, 0.12); red_felt.roughness = 0.95
    var white_keys = StandardMaterial3D.new(); white_keys.albedo_color = Color(0.96, 0.96, 0.98); white_keys.roughness = 0.15
    var black_keys = StandardMaterial3D.new(); black_keys.albedo_color = Color(0.06, 0.06, 0.08); black_keys.roughness = 0.08

    _box(rb, Vector3(2.2, 0.45, 2.6), lacquer, Vector3(0, 1.15, 0))
    _box(rb, Vector3(1.6, 0.44, 1.4), lacquer, Vector3(-0.25, 1.15, 1.2))
    _box(rb, Vector3(2.24, 0.04, 2.64), gold, Vector3(0, 1.38, 0))

    for lp in [Vector3(-0.9, 0.55, -1.0), Vector3(0.9, 0.55, -1.0), Vector3(-0.2, 0.55, 1.6)]:
        _cyl(rb, 0.09, 1.1, lacquer, lp)
        _cyl(rb, 0.11, 0.06, gold, lp + Vector3(0, 0.48, 0))
        _sph(rb, 0.07, gold, lp - Vector3(0, 0.52, 0))

    _box(rb, Vector3(2.3, 0.06, 2.7), lacquer, Vector3(0.3, 1.8, 0.1), Vector3(0, 0, deg_to_rad(32)))
    _cyl(rb, 0.03, 0.9, gold, Vector3(0.7, 1.6, 0.2), Vector3(0, 0, deg_to_rad(15)))
    _box(rb, Vector3(0.12, 0.05, 0.2), gold, Vector3(-0.8, 1.4, 0.1))
    _box(rb, Vector3(0.12, 0.05, 0.2), gold, Vector3(-0.8, 1.4, 1.0))

    _box(rb, Vector3(1.92, 0.02, 0.06), red_felt, Vector3(0, 1.04, -1.32))
    _box(rb, Vector3(1.9, 0.08, 0.35), white_keys, Vector3(0, 0.98, -1.45))
    _box(rb, Vector3(1.7, 0.12, 0.2), black_keys, Vector3(0, 1.02, -1.5))

    _box(rb, Vector3(0.35, 0.25, 0.1), lacquer, Vector3(0, 0.3, -0.6))
    _box(rb, Vector3(0.06, 0.04, 0.2), gold, Vector3(-0.08, 0.18, -0.68))
    _box(rb, Vector3(0.06, 0.04, 0.2), gold, Vector3(0.0, 0.18, -0.68))
    _box(rb, Vector3(0.06, 0.04, 0.2), gold, Vector3(0.08, 0.18, -0.68))

    var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(2.6, 2.2, 3.2); cs.shape = bs; cs.position.y = 1.1; rb.add_child(cs)
    world.add_child(root); _select(root)
    _add_log("[color=#00ff88]✓ Концертно пиано с PBR отражения, златни панти и червен филц е готово![/color]")

func _spawn_detailed_brick_wall(wall_name: String, pos: Vector3):
    var root = Node3D.new(); root.name = wall_name; root.position = pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

    var brick_red = StandardMaterial3D.new(); brick_red.albedo_color = Color(0.72, 0.25, 0.16); brick_red.roughness = 0.92
    var brick_dark = StandardMaterial3D.new(); brick_dark.albedo_color = Color(0.58, 0.18, 0.12); brick_dark.roughness = 0.95
    var mortar = StandardMaterial3D.new(); mortar.albedo_color = Color(0.7, 0.7, 0.72); mortar.roughness = 0.9
    var stone_cap = StandardMaterial3D.new(); stone_cap.albedo_color = Color(0.85, 0.85, 0.88); stone_cap.roughness = 0.85

    _box(rb, Vector3(6.0, 3.2, 0.55), mortar, Vector3(0, 1.6, 0))

    for row in range(7):
        var y_p = 0.25 + row * 0.45
        var offset_x = 0.3 if row % 2 == 1 else 0.0
        for col_idx in range(-4, 5):
            var x_p = col_idx * 0.7 + offset_x
            if abs(x_p) < 2.8:
                var mat = brick_red if (row + col_idx) % 2 == 0 else brick_dark
                _box(rb, Vector3(0.62, 0.38, 0.62), mat, Vector3(x_p, y_p, 0))

    _box(rb, Vector3(6.3, 0.18, 0.75), stone_cap, Vector3(0, 3.3, 0))
    var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(6.3, 3.4, 0.75); cs.shape = bs; cs.position.y = 1.7; rb.add_child(cs)
    world.add_child(root); _select(root)
    _add_log("[color=#00ff88]✓ Масивна тухлена стена с релефни тухли и каменна шапка е иззидана![/color]")

func _spawn_detailed_castle(castle_name: String, pos: Vector3):
    var root = Node3D.new(); root.name = castle_name; root.position = pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

    var stone = StandardMaterial3D.new(); stone.albedo_color = Color(0.48, 0.5, 0.55); stone.roughness = 0.95
    var blue_roof = StandardMaterial3D.new(); blue_roof.albedo_color = Color(0.12, 0.3, 0.75); blue_roof.roughness = 0.75
    var wood_gate = StandardMaterial3D.new(); wood_gate.albedo_color = Color(0.28, 0.15, 0.08); wood_gate.roughness = 0.85
    var flag_mat = StandardMaterial3D.new(); flag_mat.albedo_color = Color(1.0, 0.15, 0.15)

    _box(rb, Vector3(7.0, 3.5, 7.0), stone, Vector3(0, 1.75, 0))

    for tp in [Vector3(-3.8, 0, -3.8), Vector3(3.8, 0, -3.8), Vector3(-3.8, 0, 3.8), Vector3(3.8, 0, 3.8)]:
        _cyl(rb, 1.1, 5.5, stone, tp + Vector3(0, 2.75, 0))
        var cone = CylinderMesh.new(); cone.top_radius = 0.02; cone.bottom_radius = 1.35; cone.height = 2.2
        _add_mesh(rb, cone, blue_roof, tp + Vector3(0, 6.6, 0), Vector3.ZERO)

    _cyl(rb, 1.8, 7.5, stone, Vector3(0, 3.75, 0))
    var main_cone = CylinderMesh.new(); main_cone.top_radius = 0.02; main_cone.bottom_radius = 2.1; main_cone.height = 2.8
    _add_mesh(rb, main_cone, blue_roof, Vector3(0, 8.9, 0), Vector3.ZERO)

    _cyl(rb, 0.04, 1.2, stone, Vector3(0, 10.8, 0))
    _box(rb, Vector3(0.6, 0.35, 0.04), flag_mat, Vector3(0.32, 11.1, 0))

    for bx in [-2.5, 0.0, 2.5]:
        _box(rb, Vector3(0.7, 0.45, 0.3), stone, Vector3(bx, 3.75, -3.6))
        _box(rb, Vector3(0.7, 0.45, 0.3), stone, Vector3(bx, 3.75, 3.6))

    _box(rb, Vector3(2.2, 2.6, 0.2), wood_gate, Vector3(0, 1.3, -3.6))
    _torus(rb, 1.1, 0.15, stone, Vector3(0, 2.6, -3.62), Vector3(deg_to_rad(90), 0, 0))

    var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(10.0, 11.5, 10.0); cs.shape = bs; cs.position.y = 5.0; rb.add_child(cs)
    world.add_child(root); _select(root)
    _add_log("[color=#00ff88]✓ Средновековен замък с 4 кули и бойници е издигнат![/color]")

func _spawn_detailed_car(car_name: String, color_hex: String, is_cabrio: bool, pos: Vector3):
    var root = Node3D.new(); root.name = car_name; root.position = pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

    var p_mat = StandardMaterial3D.new()
    p_mat.albedo_color = Color.from_string(color_hex, Color.RED)
    p_mat.metallic = 0.92; p_mat.roughness = 0.14; p_mat.clearcoat_enabled = true; p_mat.clearcoat = 1.0

    var black_mat = StandardMaterial3D.new(); black_mat.albedo_color = Color(0.1, 0.1, 0.12); black_mat.roughness = 0.5
    var chrome_mat = StandardMaterial3D.new(); chrome_mat.albedo_color = Color(0.9, 0.9, 0.95); chrome_mat.metallic = 0.98; chrome_mat.roughness = 0.15
    var tire_mat = StandardMaterial3D.new(); tire_mat.albedo_color = Color(0.12, 0.12, 0.14); tire_mat.roughness = 0.85

    _box(rb, Vector3(2.1, 0.35, 4.5), p_mat, Vector3(0, 0.45, 0))
    _box(rb, Vector3(2.15, 0.12, 0.4), black_mat, Vector3(0, 0.32, -2.15))
    _box(rb, Vector3(1.2, 0.22, 0.06), black_mat, Vector3(0, 0.48, -2.26))
    _box(rb, Vector3(1.95, 0.24, 1.6), p_mat, Vector3(0, 0.65, -1.25))

    if is_cabrio:
        var g_mat = StandardMaterial3D.new(); g_mat.albedo_color = Color(0.1, 0.25, 0.4, 0.4); g_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS; g_mat.roughness = 0.05
        _box(rb, Vector3(1.85, 0.48, 0.06), g_mat, Vector3(0, 0.92, -0.45), Vector3(deg_to_rad(-24), 0, 0))
        var s_mat = StandardMaterial3D.new(); s_mat.albedo_color = Color(0.15, 0.15, 0.18); s_mat.roughness = 0.6
        _box(rb, Vector3(0.65, 0.5, 0.6), s_mat, Vector3(-0.45, 0.72, 0.2))
        _box(rb, Vector3(0.35, 0.22, 0.15), s_mat, Vector3(-0.45, 1.05, 0.45))
        _box(rb, Vector3(0.65, 0.5, 0.6), s_mat, Vector3(0.45, 0.72, 0.2))
        _box(rb, Vector3(0.35, 0.22, 0.15), s_mat, Vector3(0.45, 1.05, 0.45))
        _box(rb, Vector3(1.6, 0.22, 0.4), black_mat, Vector3(0, 0.78, -0.28))
        _torus(rb, 0.18, 0.03, chrome_mat, Vector3(-0.45, 0.88, -0.15), Vector3(deg_to_rad(25), 0, 0))
    else:
        var cm = StandardMaterial3D.new(); cm.albedo_color = Color(0.08, 0.1, 0.15); cm.roughness = 0.1
        _box(rb, Vector3(1.65, 0.55, 2.1), cm, Vector3(0, 0.85, 0.1))

    _box(rb, Vector3(0.22, 0.12, 0.14), p_mat, Vector3(-1.16, 0.92, -0.4))
    _box(rb, Vector3(0.22, 0.12, 0.14), p_mat, Vector3(1.16, 0.92, -0.4))
    _box(rb, Vector3(1.9, 0.28, 1.15), p_mat, Vector3(0, 0.65, 1.45))
    _box(rb, Vector3(2.0, 0.06, 0.35), black_mat, Vector3(0, 0.96, 1.85))

    var hl_mat = StandardMaterial3D.new(); hl_mat.albedo_color = Color(1, 1, 1); hl_mat.emission_enabled = true; hl_mat.emission = Color(0.85, 0.95, 1.0); hl_mat.emission_energy_multiplier = 4.0
    _box(rb, Vector3(0.42, 0.14, 0.05), hl_mat, Vector3(-0.7, 0.56, -2.26))
    _box(rb, Vector3(0.42, 0.14, 0.05), hl_mat, Vector3(0.7, 0.56, -2.26))

    var tl_mat = StandardMaterial3D.new(); tl_mat.albedo_color = Color(1, 0, 0); tl_mat.emission_enabled = true; tl_mat.emission = Color(1.0, 0.05, 0.05); tl_mat.emission_energy_multiplier = 4.0
    _box(rb, Vector3(0.55, 0.12, 0.05), tl_mat, Vector3(-0.65, 0.6, 2.26))
    _box(rb, Vector3(0.55, 0.12, 0.05), tl_mat, Vector3(0.65, 0.6, 2.26))

    for w_pos in [Vector3(-1.05, 0.38, -1.35), Vector3(1.05, 0.38, -1.35), Vector3(-1.05, 0.38, 1.35), Vector3(1.05, 0.38, 1.35)]:
        _cyl(rb, 0.38, 0.28, tire_mat, w_pos, Vector3(0, 0, deg_to_rad(90)))
        _cyl(rb, 0.24, 0.29, chrome_mat, w_pos, Vector3(0, 0, deg_to_rad(90)))

    var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(2.4, 1.3, 4.6); cs.shape = bs; cs.position.y = 0.65; rb.add_child(cs)
    world.add_child(root); _select(root)
    _add_log("[color=#00ff88]✓ " + car_name + " е конструиран анатомично![/color]")

func _spawn_detailed_house(house_name: String, wall_color_hex: String, pos: Vector3):
    var root = Node3D.new(); root.name = house_name; root.position = pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

    var wall_mat = StandardMaterial3D.new(); wall_mat.albedo_color = Color.from_string(wall_color_hex, Color(0.9, 0.85, 0.75)); wall_mat.roughness = 0.9
    var stone_mat = StandardMaterial3D.new(); stone_mat.albedo_color = Color(0.3, 0.32, 0.36); stone_mat.roughness = 0.95
    var roof_mat = StandardMaterial3D.new(); roof_mat.albedo_color = Color(0.48, 0.15, 0.12); roof_mat.roughness = 0.8
    var wood_mat = StandardMaterial3D.new(); wood_mat.albedo_color = Color(0.28, 0.16, 0.08); wood_mat.roughness = 0.7
    var white_frame_mat = StandardMaterial3D.new(); white_frame_mat.albedo_color = Color(0.95, 0.95, 0.95)
    var glass_mat = StandardMaterial3D.new(); glass_mat.albedo_color = Color(0.2, 0.4, 0.6, 0.5); glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS; glass_mat.roughness = 0.05
    var lantern_mat = StandardMaterial3D.new(); lantern_mat.albedo_color = Color(1, 0.8, 0.2); lantern_mat.emission_enabled = true; lantern_mat.emission = Color(1.0, 0.85, 0.2); lantern_mat.emission_energy_multiplier = 3.0

    _box(rb, Vector3(5.4, 0.35, 4.8), stone_mat, Vector3(0, 0.17, 0))
    _box(rb, Vector3(1.8, 0.18, 0.8), stone_mat, Vector3(0, 0.09, -2.6))
    _box(rb, Vector3(5.0, 3.0, 4.4), wall_mat, Vector3(0, 1.85, 0))
    _prism(rb, Vector3(4.8, 1.8, 5.4), roof_mat, Vector3(0, 4.2, 0), Vector3(0, deg_to_rad(90), 0))
    _box(rb, Vector3(0.65, 1.6, 0.65), stone_mat, Vector3(1.5, 4.4, 0.6))
    _box(rb, Vector3(1.2, 2.1, 0.08), wood_mat, Vector3(0, 1.4, -2.25))
    _sph(rb, 0.06, white_frame_mat, Vector3(0.4, 1.35, -2.32))
    _box(rb, Vector3(0.18, 0.25, 0.18), lantern_mat, Vector3(0.85, 1.8, -2.3))

    for w_pos in [Vector3(-1.5, 1.8, -2.24), Vector3(1.5, 1.8, -2.24), Vector3(-2.54, 1.8, 0), Vector3(2.54, 1.8, 0)]:
        _box(rb, Vector3(1.2, 1.2, 0.06), white_frame_mat, w_pos)
        _box(rb, Vector3(1.0, 1.0, 0.08), glass_mat, w_pos)

    var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(5.6, 5.0, 5.0); cs.shape = bs; cs.position.y = 2.5; rb.add_child(cs)
    world.add_child(root); _select(root)
    _add_log("[color=#00ff88]✓ " + house_name + " е построена с покрив, комин и прозорци![/color]")

func _box(p, sz, mat, pos, rot = Vector3.ZERO):
    var m = BoxMesh.new(); m.size = sz; _add_mesh(p, m, mat, pos, rot)

func _cyl(p, r, h, mat, pos, rot = Vector3.ZERO):
    var m = CylinderMesh.new(); m.top_radius = r; m.bottom_radius = r; m.height = h; _add_mesh(p, m, mat, pos, rot)

func _sph(p, r, mat, pos, rot = Vector3.ZERO):
    var m = SphereMesh.new(); m.radius = r; m.height = r * 2.0; _add_mesh(p, m, mat, pos, rot)

func _torus(p, outer_r, inner_r, mat, pos, rot = Vector3.ZERO):
    var m = TorusMesh.new(); m.outer_radius = outer_r; m.inner_radius = inner_r; _add_mesh(p, m, mat, pos, rot)

func _prism(p, sz, mat, pos, rot = Vector3.ZERO):
    var m = PrismMesh.new(); m.size = sz; _add_mesh(p, m, mat, pos, rot)

func _add_mesh(parent, mesh_res, mat, pos, rot = Vector3.ZERO):
    var mi = MeshInstance3D.new()
    mi.mesh = mesh_res; mi.material_override = mat
    mi.position = pos; mi.rotation = rot
    parent.add_child(mi)
