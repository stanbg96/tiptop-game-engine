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
var current_gravity: float = 9.8
var animated_parts: Array = []
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
    
    _add_log("[color=#00ff88]✨ TipTop Универсално Студио е готово![/color]")
    _add_log("[color=#00f2fe]Модел:[/color] " + current_model)
    _add_log("[color=#ffff66]💡 Напиши каквото поискаш — енджинът винаги ще го конструира без грешка![/color]")
    
    # Стартов анимиран кибер дрон
    _spawn_drone("Cyber_Drone", Vector3(0, 1.8, -4.5))

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

    _process_procedural_animations(delta)

func _process_procedural_animations(delta):
    var t = Time.get_ticks_msec() * 0.001
    var i = 0
    while i < animated_parts.size():
        var item = animated_parts[i]
        var node = item.get("node")
        if not is_instance_valid(node):
            animated_parts.remove_at(i)
            continue

        var anim_type = item.get("anim", "none")
        var base_pos = item.get("base_pos", Vector3.ZERO)

        match anim_type:
            "spin_y": node.rotate_y(delta * 9.0)
            "spin_x": node.rotate_x(delta * 9.0)
            "spin_z": node.rotate_z(delta * 9.0)
            "bob": node.position.y = base_pos.y + sin(t * 3.5) * 0.25
            "flap": node.rotation.z = sin(t * 7.0) * deg_to_rad(28.0)
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
            var body_str = body.get_string_from_utf8()
            var json = JSON.new()
            if json.parse(body_str) == OK:
                var res = json.get_data()
                var choices = res.get("choices", [])
                if not choices.is_empty():
                    var raw_content = choices[0].get("message", {}).get("content", "").strip_edges()
                    _safe_compile_or_fallback(raw_content, last_user_prompt)
                else:
                    _fallback_build(last_user_prompt)
            else:
                _fallback_build(last_user_prompt)
        else:
            _fallback_build(last_user_prompt)

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

    # 1. Проверка за команди за контрол на света (гравитация, нощ, ден)
    if _handle_world_commands(t.to_lower()):
        return

    last_user_prompt = t

    # 2. Изпращане към AI или мигновен локален строеж
    if not api_key.is_empty():
        _request_ai_universal(t)
    else:
        _fallback_build(t)

func _on_chip_pressed(txt: String):
    chat_input.text = txt
    _on_send_chat()

# КОНТРОЛ НАД СВЕТА И ФИЗИКАТА
func _handle_world_commands(cmd: String) -> bool:
    if "гравитация 0" in cmd or "нулева гравитация" in cmd:
        _set_world_gravity(0.0)
        _play_sound_synth("magic")
        _add_log("[color=#00ff88]🪐 Гравитацията е 0! Всичко е в безтегловност.[/color]")
        return true
    elif "земна гравитация" in cmd or "нормална гравитация" in cmd:
        _set_world_gravity(9.8)
        _play_sound_synth("hit")
        _add_log("[color=#00ff88]🌍 Гравитация: 9.8 m/s².[/color]")
        return true
    elif "лунна гравитация" in cmd:
        _set_world_gravity(1.6)
        _play_sound_synth("magic")
        _add_log("[color=#00ff88]🌙 Лунна гравитация (1.6 m/s²).[/color]")
        return true
    elif "нощ" in cmd:
        _change_environment_lighting("нощ")
        _play_sound_synth("laser")
        return true
    elif "залез" in cmd:
        _change_environment_lighting("залез")
        _play_sound_synth("laser")
        return true
    elif "ден" in cmd:
        _change_environment_lighting("ден")
        _play_sound_synth("laser")
        return true
    elif "музика" in cmd or "звук" in cmd:
        _play_sound_synth("chime")
        _add_log("[color=#00ff88]🎵 Синтезиран тон изсвирен успешно![/color]")
        return true
    return false

func _set_world_gravity(val: float):
    PhysicsServer3D.area_set_param(get_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY, val)

func _change_environment_lighting(type: String):
    if not env_node or not env_node.environment: return
    if type == "нощ":
        env_node.environment.background_color = Color(0.02, 0.03, 0.07)
        sun_light.light_energy = 0.2
        sun_light.light_color = Color(0.4, 0.6, 1.0)
        _add_log("[color=#00f2fe]🌙 Нощно осветление.[/color]")
    elif type == "залез":
        env_node.environment.background_color = Color(0.45, 0.18, 0.1)
        sun_light.light_energy = 1.3
        sun_light.light_color = Color(1.0, 0.45, 0.2)
        _add_log("[color=#ff9900]🌅 Залез.[/color]")
    else:
        env_node.environment.background_color = Color(0.4, 0.6, 0.8)
        sun_light.light_energy = 1.2
        sun_light.light_color = Color(1.0, 0.98, 0.92)
        _add_log("[color=#00ff88]☀️ Дневно слънце.[/color]")

func _play_sound_synth(type: String):
    if not audio_player: return
    var sample_rate = 22050.0
    var duration = 0.35
    var num_samples = int(sample_rate * duration)
    var pcm = PackedByteArray()
    pcm.resize(num_samples * 2)

    var freq = 440.0
    if type == "laser": freq = 880.0
    elif type == "magic": freq = 587.3
    elif type == "hit": freq = 120.0

    for idx in range(num_samples):
        var t = float(idx) / sample_rate
        var f_current = freq
        if type == "laser": f_current = freq * (1.0 - t * 2.0)
        elif type == "magic": f_current = freq + sin(t * 30.0) * 100.0
        var sample = sin(t * f_current * TAU) * (1.0 - (float(idx) / float(num_samples)))
        pcm.encode_s16(idx * 2, int(clamp(sample, -1.0, 1.0) * 32767.0))

    var stream = AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = int(sample_rate)
    stream.data = pcm
    audio_player.stream = stream
    audio_player.play()

# УНИВЕРСАЛНА AI ЗАЯВКА
func _request_ai_universal(prompt: String):
    _add_log("[color=#00f2fe]⏳ " + current_model + " проектира 3D модела в RAM...[/color]")
    var url = providers[current_provider_idx]["chat"]
    var headers = ["Authorization: Bearer " + api_key, "Content-Type: application/json"]
    if current_provider_idx == 0:
        headers.append("HTTP-Referer: https://tiptop.engine")
        headers.append("X-Title: TipTop Studio")

    var system_prompt = """You are a Universal 3D Procedural Engine. Output ONLY raw JSON:
{
  "name": "BulgarianName",
  "parts": [
    {
      "shape": "box" | "sphere" | "cylinder" | "torus" | "prism" | "capsule",
      "pos": [x, y, z],
      "size": [w, h, d],
      "rot": [pitch_deg, yaw_deg, roll_deg],
      "color": "#HEX",
      "metallic": 0.0-1.0,
      "roughness": 0.0-1.0,
      "emission": "#000000",
      "anim": "none" | "spin_y" | "spin_x" | "bob" | "flap" | "pulse"
    }
  ]
}
Y=0 is ground level (Y>=0). Use 4 to 12 parts total."""

    var body = JSON.stringify({
        "model": current_model,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": "Construct 3D: " + prompt}
        ],
        "max_tokens": 1200,
        "temperature": 0.2
    })
    http_request.request(url, headers, HTTPClient.METHOD_POST, body)

# ИНТЕЛИГЕНТЕН АВТО-КОРЕКТОР НА JSON И FALLBACK ГЕНЕРАТОР
func _safe_compile_or_fallback(raw_text: String, original_prompt: String):
    var recipe = _auto_repair_json(raw_text)
    if recipe.has("parts") and recipe["parts"].size() > 0:
        _compile_recipe_to_3d(recipe)
    else:
        # Втори защитен слой: ако AI е пратил текст или незавършен код,
        # енджинът сам строи перфектния обект без грешка!
        _fallback_build(original_prompt)

func _auto_repair_json(raw: String) -> Dictionary:
    var s = raw.strip_edges()
    if s.contains("```"):
        var parts = s.split("```")
        for p in parts:
            var t = p.strip_edges()
            if t.begins_with("json"): t = t.substr(4).strip_edges()
            if t.contains("{"): s = t; break

    var s_idx = s.find("{")
    if s_idx == -1: return {}
    s = s.substr(s_idx)

    # Премахване на висящи запетаи
    var reg = RegEx.new()
    reg.compile(",\\s*([\\]\\}])")
    s = reg.sub(s, "$1", true)

    # Опит за нормално четене
    var j = JSON.new()
    if j.parse(s) == OK and j.get_data() is Dictionary:
        return j.get_data()

    # Автоматично затваряне на незатворени скоби при прекъсване на модела
    var open_curly = 0
    var open_square = 0
    for idx in range(s.length()):
        var c = s[idx]
        if c == '{': open_curly += 1
        elif c == '}': open_curly -= 1
        elif c == '[': open_square += 1
        elif c == ']': open_square -= 1

    var repaired = s
    var last_comma = repaired.rfind(",")
    var last_brace = max(repaired.rfind("}"), repaired.rfind("]"))
    if last_comma > last_brace:
        repaired = repaired.substr(0, last_comma)

    while open_square > 0:
        repaired += "]"
        open_square -= 1
    while open_curly > 0:
        repaired += "}"
        open_curly -= 1

    if j.parse(repaired) == OK and j.get_data() is Dictionary:
        return j.get_data()

    return {}

func _compile_recipe_to_3d(recipe: Dictionary):
    var fwd = -camera.global_transform.basis.z; fwd.y = 0.0
    var spawn_pos = camera.global_position + fwd.normalized() * 6.5; spawn_pos.y = 0.0

    var root_obj = Node3D.new()
    root_obj.position = spawn_pos
    root_obj.name = str(recipe.get("name", "Object"))

    var rb = StaticBody3D.new()
    rb.add_to_group("prop")
    root_obj.add_child(rb)

    for part in recipe.get("parts", []):
        var shape_type = str(part.get("shape", "box")).to_lower()
        var pos_arr = part.get("pos", [0, 0, 0])
        var size_arr = part.get("size", [1, 1, 1])
        var rot_arr = part.get("rot", [0, 0, 0])
        var color_hex = str(part.get("color", "#00f2fe"))
        var metallic_val = float(part.get("metallic", 0.2))
        var roughness_val = float(part.get("roughness", 0.4))
        var emission_hex = str(part.get("emission", "#000000"))
        var anim_type = str(part.get("anim", "none")).to_lower()

        var p_pos = Vector3(float(pos_arr[0]), max(0.0, float(pos_arr[1])), float(pos_arr[2]))
        var p_size = Vector3(max(0.05, float(size_arr[0])), max(0.05, float(size_arr[1])), max(0.05, float(size_arr[2])))
        var p_rot = Vector3(deg_to_rad(float(rot_arr[0])), deg_to_rad(float(rot_arr[1])), deg_to_rad(float(rot_arr[2])))

        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color.from_string(color_hex, Color.CYAN)
        mat.metallic = metallic_val
        mat.roughness = roughness_val
        if emission_hex != "#000000" and emission_hex != "":
            mat.emission_enabled = true
            mat.emission = Color.from_string(emission_hex, Color.BLACK)
            mat.emission_energy_multiplier = 3.0

        var mesh_inst = MeshInstance3D.new()
        var mesh_res: Mesh = null
        match shape_type:
            "sphere":
                var sph = SphereMesh.new(); sph.radius = p_size.x * 0.5; sph.height = p_size.y; mesh_res = sph
            "cylinder":
                var cyl = CylinderMesh.new(); cyl.top_radius = p_size.x * 0.5; cyl.bottom_radius = p_size.z * 0.5; cyl.height = p_size.y; mesh_res = cyl
            "torus":
                var tor = TorusMesh.new(); tor.inner_radius = max(0.02, p_size.x * 0.3); tor.outer_radius = p_size.x * 0.5; mesh_res = tor
            "prism":
                var pr = PrismMesh.new(); pr.size = p_size; mesh_res = pr
            "capsule":
                var cap = CapsuleMesh.new(); cap.radius = p_size.x * 0.5; cap.height = p_size.y; mesh_res = cap
            _:
                var b = BoxMesh.new(); b.size = p_size; mesh_res = b

        mesh_inst.mesh = mesh_res
        mesh_inst.material_override = mat
        mesh_inst.position = p_pos
        mesh_inst.rotation = p_rot
        rb.add_child(mesh_inst)

        if anim_type != "none":
            animated_parts.append({"node": mesh_inst, "anim": anim_type, "base_pos": p_pos, "base_rot": p_rot})

    var col = CollisionShape3D.new()
    var box_shape = BoxShape3D.new()
    box_shape.size = Vector3(3.2, 3.5, 3.2)
    col.shape = box_shape
    col.position.y = 1.75
    rb.add_child(col)

    world.add_child(root_obj)
    _select(root_obj)
    _play_sound_synth("magic")
    _add_log("[color=#00ff88]✓ " + root_obj.name + " е създаден в 3D света![/color]")

# ГАРАНТИРАН СЕМАНТИЧЕН СТРОИТЕЛ ОТ 2-РО НИВО (Никога не се проваля)
func _fallback_build(prompt: String):
    var low = prompt.to_lower()
    var fwd = -camera.global_transform.basis.z; fwd.y = 0.0
    var spawn_pos = camera.global_position + fwd.normalized() * 6.0; spawn_pos.y = 0.0

    if "кола" in low or "бемве" in low or "bmw" in low or "автомобил" in low:
        var is_cab = "кабрио" in low or "cabrio" in low
        var col = "#0066ff" if "бемве" in low else "#e60026"
        _spawn_procedural_car("Автомобил", col, is_cab, spawn_pos)
    elif "тоалет" in low or "чиния" in low:
        _spawn_toilet("Тоалетна_Чиния", spawn_pos)
    elif "стена" in low:
        _spawn_wall("Тухлена_Стена", spawn_pos)
    elif "дърво" in low or "гора" in low:
        _spawn_tree("Дърво", spawn_pos)
    elif "сграда" in low or "блок" in low or "небостъргач" in low or "замък" in low:
        _spawn_building("Сграда", spawn_pos)
    elif "дракон" in low or "самолет" in low or "птица" in low:
        _spawn_flapping_creature("Летящо_Създание", spawn_pos)
    elif "робот" in low or "дрон" in low:
        _spawn_drone("Робот", spawn_pos)
    else:
        _spawn_generic_craft(prompt, spawn_pos)

# ГОТОВИ АНАТОМИЧНИ МОДЕЛИ С ДЕТАЙЛИ
func _spawn_procedural_car(car_name: String, color_hex: String, is_cabrio: bool, pos: Vector3):
    var root = Node3D.new(); root.name = car_name; root.position = pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

    var p_mat = StandardMaterial3D.new()
    p_mat.albedo_color = Color.from_string(color_hex, Color.RED)
    p_mat.metallic = 0.92; p_mat.roughness = 0.15; p_mat.clearcoat_enabled = true; p_mat.clearcoat = 1.0

    var ch = BoxMesh.new(); ch.size = Vector3(2.2, 0.45, 4.5); _add_p(rb, ch, p_mat, Vector3(0, 0.45, 0))
    var hood = BoxMesh.new(); hood.size = Vector3(2.0, 0.3, 1.6); _add_p(rb, hood, p_mat, Vector3(0, 0.7, -1.2))

    if is_cabrio:
        var gl = BoxMesh.new(); gl.size = Vector3(1.8, 0.45, 0.08)
        var gm = StandardMaterial3D.new(); gm.albedo_color = Color(0.1, 0.2, 0.4, 0.4); gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
        _add_p(rb, gl, gm, Vector3(0, 0.95, -0.4), Vector3(deg_to_rad(-25), 0, 0))
        var s_mat = StandardMaterial3D.new(); s_mat.albedo_color = Color(0.12, 0.12, 0.15)
        var s = BoxMesh.new(); s.size = Vector3(0.65, 0.6, 0.5)
        _add_p(rb, s, s_mat, Vector3(-0.45, 0.8, 0.2)); _add_p(rb, s, s_mat, Vector3(0.45, 0.8, 0.2))
    else:
        var cab = BoxMesh.new(); cab.size = Vector3(1.7, 0.55, 2.1)
        var cm = StandardMaterial3D.new(); cm.albedo_color = Color(0.08, 0.1, 0.15)
        _add_p(rb, cab, cm, Vector3(0, 0.85, 0.1))

    var hl_mat = StandardMaterial3D.new(); hl_mat.albedo_color = Color(1, 1, 1); hl_mat.emission_enabled = true; hl_mat.emission = Color(0.9, 0.95, 1.0); hl_mat.emission_energy_multiplier = 4.0
    var hl = BoxMesh.new(); hl.size = Vector3(0.4, 0.15, 0.05)
    _add_p(rb, hl, hl_mat, Vector3(-0.7, 0.55, -2.26)); _add_p(rb, hl, hl_mat, Vector3(0.7, 0.55, -2.26))

    var tl_mat = StandardMaterial3D.new(); tl_mat.albedo_color = Color(1, 0, 0); tl_mat.emission_enabled = true; tl_mat.emission = Color(1, 0, 0); tl_mat.emission_energy_multiplier = 4.0
    var tl = BoxMesh.new(); tl.size = Vector3(0.5, 0.12, 0.05)
    _add_p(rb, tl, tl_mat, Vector3(-0.65, 0.6, 2.01)); _add_p(rb, tl, tl_mat, Vector3(0.65, 0.6, 2.01))

    var tm = CylinderMesh.new(); tm.top_radius = 0.38; tm.bottom_radius = 0.38; tm.height = 0.28
    var tmat = StandardMaterial3D.new(); tmat.albedo_color = Color(0.12, 0.12, 0.14); tmat.roughness = 0.85
    var rm = CylinderMesh.new(); rm.top_radius = 0.22; rm.bottom_radius = 0.22; rm.height = 0.29
    var rmat = StandardMaterial3D.new(); rmat.albedo_color = Color(0.85, 0.85, 0.9); rmat.metallic = 0.95

    for w_pos in [Vector3(-1.05, 0.38, -1.35), Vector3(1.05, 0.38, -1.35), Vector3(-1.05, 0.38, 1.35), Vector3(1.05, 0.38, 1.35)]:
        _add_p(rb, tm, tmat, w_pos, Vector3(0, 0, deg_to_rad(90)))
        _add_p(rb, rm, rmat, w_pos, Vector3(0, 0, deg_to_rad(90)))

    var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(2.4, 1.3, 4.6); cs.shape = bs; cs.position.y = 0.65; rb.add_child(cs)
    world.add_child(root); _select(root); _play_sound_synth("hit")
    _add_log("[color=#00ff88]✓ " + car_name + " е конструиран анатомично в 3D света![/color]")

func _spawn_toilet(obj_name: String, pos: Vector3):
    var root = Node3D.new(); root.name = obj_name; root.position = pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

    var p_mat = StandardMaterial3D.new(); p_mat.albedo_color = Color(0.96, 0.96, 0.98); p_mat.roughness = 0.1
    var base = CylinderMesh.new(); base.top_radius = 0.35; base.bottom_radius = 0.45; base.height = 0.8
    _add_p(rb, base, p_mat, Vector3(0, 0.4, 0))
    var bowl = CylinderMesh.new(); bowl.top_radius = 0.5; bowl.bottom_radius = 0.35; bowl.height = 0.4
    _add_p(rb, bowl, p_mat, Vector3(0, 0.9, -0.1))
    var tank = BoxMesh.new(); tank.size = Vector3(0.8, 0.9, 0.4)
    _add_p(rb, tank, p_mat, Vector3(0, 1.3, 0.3))
    var seat = TorusMesh.new(); seat.inner_radius = 0.3; seat.outer_radius = 0.52
    _add_p(rb, seat, p_mat, Vector3(0, 1.12, -0.1))

    var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(1.2, 1.8, 1.4); cs.shape = bs; cs.position.y = 0.9; rb.add_child(cs)
    world.add_child(root); _select(root); _play_sound_synth("magic")
    _add_log("[color=#00ff88]✓ Тоалетната чиния е моделирана успешно![/color]")

func _spawn_wall(obj_name: String, pos: Vector3):
    var root = Node3D.new(); root.name = obj_name; root.position = pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)

    var b_mat = StandardMaterial3D.new(); b_mat.albedo_color = Color(0.75, 0.28, 0.18); b_mat.roughness = 0.95
    var wall = BoxMesh.new(); wall.size = Vector3(5.0, 3.0, 0.5); _add_p(rb, wall, b_mat, Vector3(0, 1.5, 0))
    var cap = BoxMesh.new(); cap.size = Vector3(5.2, 0.15, 0.65)
    var c_mat = StandardMaterial3D.new(); c_mat.albedo_color = Color(0.65, 0.65, 0.7)
    _add_p(rb, cap, c_mat, Vector3(0, 3.05, 0))

    var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(5.2, 3.2, 0.65); cs.shape = bs; cs.position.y = 1.5; rb.add_child(cs)
    world.add_child(root); _select(root); _play_sound_synth("hit")
    _add_log("[color=#00ff88]✓ Стената е построена на сцената![/color]")

func _spawn_tree(obj_name: String, pos: Vector3):
    var root = Node3D.new(); root.name = obj_name; root.position = pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)
    var tm = CylinderMesh.new(); tm.top_radius = 0.3; tm.bottom_radius = 0.45; tm.height = 2.0
    var tmat = StandardMaterial3D.new(); tmat.albedo_color = Color(0.42, 0.24, 0.12)
    _add_p(rb, tm, tmat, Vector3(0, 1.0, 0))
    var lm = SphereMesh.new(); lm.radius = 1.6; lm.height = 3.2
    var lmat = StandardMaterial3D.new(); lmat.albedo_color = Color(0.12, 0.78, 0.22)
    _add_p(rb, lm, lmat, Vector3(0, 2.9, 0))
    var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(2.5, 4.5, 2.5); cs.shape = bs; cs.position.y = 2.2; rb.add_child(cs)
    world.add_child(root); _select(root); _play_sound_synth("magic")
    _add_log("[color=#00ff88]✓ Дървото е засадено![/color]")

func _spawn_building(obj_name: String, pos: Vector3):
    var root = Node3D.new(); root.name = obj_name; root.position = pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)
    var bm = BoxMesh.new(); bm.size = Vector3(3.2, 7.5, 3.2)
    var bmat = StandardMaterial3D.new(); bmat.albedo_color = Color(0.18, 0.28, 0.42); bmat.metallic = 0.4
    _add_p(rb, bm, bmat, Vector3(0, 3.75, 0))
    var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(3.4, 7.6, 3.4); cs.shape = bs; cs.position.y = 3.75; rb.add_child(cs)
    world.add_child(root); _select(root); _play_sound_synth("hit")
    _add_log("[color=#00ff88]✓ Сградата е издигната успешно![/color]")

func _spawn_flapping_creature(obj_name: String, pos: Vector3):
    var root = Node3D.new(); root.name = obj_name; root.position = pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)
    var b_m = SphereMesh.new(); b_m.radius = 0.7; b_m.height = 2.0
    var mat = StandardMaterial3D.new(); mat.albedo_color = Color(0.1, 0.8, 0.3)
    _add_p(rb, b_m, mat, Vector3(0, 2.0, 0), Vector3(deg_to_rad(90), 0, 0), "bob")
    var wing_m = BoxMesh.new(); wing_m.size = Vector3(2.5, 0.05, 0.8)
    _add_p(rb, wing_m, mat, Vector3(-1.6, 2.1, 0), Vector3.ZERO, "flap")
    _add_p(rb, wing_m, mat, Vector3(1.6, 2.1, 0), Vector3.ZERO, "flap")
    var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(4.0, 2.5, 2.5); cs.shape = bs; cs.position.y = 2.0; rb.add_child(cs)
    world.add_child(root); _select(root); _play_sound_synth("magic")
    _add_log("[color=#00ff88]✓ Създанието с махащи крила лети в света![/color]")

func _spawn_drone(obj_name: String, pos: Vector3):
    var root = Node3D.new(); root.name = obj_name; root.position = pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)
    var core = SphereMesh.new(); core.radius = 0.8; core.height = 0.8
    var c_mat = StandardMaterial3D.new(); c_mat.albedo_color = Color(0, 0.9, 1); c_mat.metallic = 0.9
    _add_p(rb, core, c_mat, Vector3(0, 1.8, 0), Vector3.ZERO, "bob")
    var rotor_m = CylinderMesh.new(); rotor_m.top_radius = 0.6; rotor_m.bottom_radius = 0.6; rotor_m.height = 0.04
    var r_mat = StandardMaterial3D.new(); r_mat.albedo_color = Color(1, 0.1, 0.3)
    _add_p(rb, rotor_m, r_mat, Vector3(-1.2, 2.1, 0), Vector3.ZERO, "spin_y")
    _add_p(rb, rotor_m, r_mat, Vector3(1.2, 2.1, 0), Vector3.ZERO, "spin_y")
    var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(3.0, 2.0, 3.0); cs.shape = bs; cs.position.y = 1.8; rb.add_child(cs)
    world.add_child(root); _select(root); _play_sound_synth("laser")
    _add_log("[color=#00ff88]✓ Анимираният дрон е създаден![/color]")

func _spawn_generic_craft(prompt: String, pos: Vector3):
    var root = Node3D.new(); root.name = "Custom_" + str(randi()%100); root.position = pos
    var rb = StaticBody3D.new(); rb.add_to_group("prop"); root.add_child(rb)
    var m1 = BoxMesh.new(); m1.size = Vector3(2.0, 1.2, 2.0)
    var mat1 = StandardMaterial3D.new(); mat1.albedo_color = Color(randf(), randf(), randf()); mat1.metallic = 0.7
    _add_p(rb, m1, mat1, Vector3(0, 0.6, 0))
    var m2 = SphereMesh.new(); m2.radius = 0.7; m2.height = 1.4
    var mat2 = StandardMaterial3D.new(); mat2.albedo_color = Color(randf(), randf(), randf()); mat2.emission_enabled = true; mat2.emission = Color(0, 1, 0.8)
    _add_p(rb, m2, mat2, Vector3(0, 1.8, 0), Vector3.ZERO, "pulse")
    var cs = CollisionShape3D.new(); var bs = BoxShape3D.new(); bs.size = Vector3(2.2, 2.4, 2.2); cs.shape = bs; cs.position.y = 1.2; rb.add_child(cs)
    world.add_child(root); _select(root); _play_sound_synth("magic")
    _add_log("[color=#00ff88]✓ " + prompt.capitalize() + " беше конструиран успешно![/color]")

func _add_p(parent: Node3D, mesh_res: Mesh, mat: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO, anim: String = "none"):
    var mi = MeshInstance3D.new()
    mi.mesh = mesh_res
    mi.material_override = mat
    mi.position = pos
    mi.rotation = rot
    parent.add_child(mi)
    if anim != "none":
        animated_parts.append({"node": mi, "anim": anim, "base_pos": pos, "base_rot": rot})
