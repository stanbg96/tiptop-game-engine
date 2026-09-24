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
    
    _add_log("[color=#00ff88]🌌 Universal TipTop Game Engine е онлайн![/color]")
    _add_log("[color=#00f2fe]Модел:[/color] " + current_model)
    _add_log("[color=#ffff66]💡 Можеш да строиш ВСИЧКО с анимации или да управляваш гравитацията и небето![/color]")
    
    # Стартов демонстрационен дрон с въртящи се перки
    _compile_procedural_recipe(JSON.stringify({
        "name": "Cyber_Drone",
        "parts": [
            {"shape": "sphere", "pos": [0, 2.0, 0], "size": [1.4, 0.6, 1.4], "color": "#00f2fe", "metallic": 0.9, "roughness": 0.1, "emission": "#002233", "anim": "bob"},
            {"shape": "cylinder", "pos": [-1.2, 2.4, 0], "size": [1.1, 0.05, 1.1], "color": "#ff0055", "metallic": 0.5, "anim": "spin_y"},
            {"shape": "cylinder", "pos": [1.2, 2.4, 0], "size": [1.1, 0.05, 1.1], "color": "#ff0055", "metallic": 0.5, "anim": "spin_y"},
            {"shape": "sphere", "pos": [0, 1.8, 0.6], "size": [0.4, 0.4, 0.4], "color": "#ffffff", "emission": "#00ffff", "anim": "pulse"}
        ]
    }))

func _setup_provider_dropdown():
    provider_select.clear()
    provider_select.add_item("🌐 OpenRouter (300+ модела)")
    provider_select.add_item("⚡ Groq (Супер бърз)")
    provider_select.add_item("🤖 OpenAI (ChatGPT)")
    provider_select.add_item("🧠 DeepSeek (V3 / R1)")

func _process(delta):
    # 1. ДРОН ЛЕТЕНЕ ЧРЕЗ ДЖОЙСТИК
    if joy.output.length() > 0.05:
        var fwd = -camera.global_transform.basis.z
        var rgt = camera.global_transform.basis.x
        fwd.y = 0.0; rgt.y = 0.0
        fwd = fwd.normalized(); rgt = rgt.normalized()
        camera.global_position += (rgt * joy.output.x + fwd * -joy.output.y) * 15.0 * delta

    # 2. МАРКЕР НАД ИЗБРАНИЯ ОБЕКТ
    if selected_obj and is_instance_valid(selected_obj):
        indicator.visible = true
        var bounce = sin(Time.get_ticks_msec() * 0.006) * 0.25
        indicator.global_position = selected_obj.global_position + Vector3(0, 3.2 + bounce, 0)
    else:
        indicator.visible = false

    # 3. ПРОЦЕДУРЕН АНИМАЦИОНЕН ЕНДЖИН В РЕАЛНО ВРЕМЕ
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
            "spin_y":
                node.rotate_y(delta * 8.0)
            "spin_x":
                node.rotate_x(delta * 8.0)
            "spin_z":
                node.rotate_z(delta * 8.0)
            "bob":
                node.position.y = base_pos.y + sin(t * 3.5) * 0.25
            "flap":
                node.rotation.z = sin(t * 7.0) * deg_to_rad(28.0)
            "pulse":
                if node is MeshInstance3D and node.material_override is StandardMaterial3D:
                    var pulse_val = (sin(t * 6.0) * 0.5 + 0.5) * 4.0
                    node.material_override.emission_energy_multiplier = pulse_val

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
func _on_confirm_and_enter(): _save_config(); api_page.visible = false; _add_log("[color=#00ff88]✓ Активен модел:[/color] " + current_model)
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
                    _compile_procedural_recipe(raw_content)
                else:
                    _add_log("[color=#ff4444]AI не върна съдържание.[/color]")
            else:
                _add_log("[color=#ff4444]Невалиден JSON отговор.[/color]")
        else:
            _add_log("[color=#ff4444]Грешка при заявка (" + str(response_code) + ").[/color]")

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

    # Проверка за команди за директен контрол на света и физиката
    if _handle_world_commands(t.to_lower()):
        return

    if not api_key.is_empty():
        _request_ai_universal_recipe(t)
    else:
        _add_log("[color=#ffff66]Въведи първо ключ от '⚙️ AI Облак'.[/color]")

func _on_chip_pressed(txt: String):
    _add_log("[color=#00ff88]Ти:[/color] " + txt)
    if not api_key.is_empty(): _request_ai_universal_recipe(txt)
    else: _add_log("[color=#ffff66]Въведи първо ключ от '⚙️ AI Облак'.[/color]")

# КОМАНДИ ЗА ДИРЕКТЕН КОНТРОЛ НАД СВЕТА, ФИЗИКАТА И ЗВУКА
func _handle_world_commands(cmd: String) -> bool:
    if "гравитация 0" in cmd or "нулева гравитация" in cmd:
        current_gravity = 0.0
        _set_world_gravity(0.0)
        _play_sound_synth("magic")
        _add_log("[color=#00ff88]🪐 Гравитацията е нулева! Обектите плуват безтегловно.[/color]")
        return true
    elif "земна гравитация" in cmd or "нормална гравитация" in cmd:
        current_gravity = 9.8
        _set_world_gravity(9.8)
        _play_sound_synth("hit")
        _add_log("[color=#00ff88]🌍 Гравитацията е възстановена (9.8 m/s²).[/color]")
        return true
    elif "лунна гравитация" in cmd:
        current_gravity = 1.6
        _set_world_gravity(1.6)
        _play_sound_synth("magic")
        _add_log("[color=#00ff88]🌙 Лунна гравитация активирана (1.6 m/s²).[/color]")
        return true
    elif "нощ" in cmd or "залез" in cmd or "ден" in cmd:
        _change_environment_lighting(cmd)
        _play_sound_synth("laser")
        return true
    elif "музика" in cmd or "звук" in cmd:
        _play_sound_synth("chime")
        _add_log("[color=#00ff88]🎵 Изсвирен синтезиран PBR аудио тон![/color]")
        return true
    return false

func _set_world_gravity(val: float):
    PhysicsServer3D.area_set_param(get_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY, val)

func _change_environment_lighting(type: String):
    if not env_node or not env_node.environment: return
    if "нощ" in type:
        env_node.environment.background_color = Color(0.02, 0.03, 0.06)
        sun_light.light_energy = 0.2
        sun_light.light_color = Color(0.4, 0.6, 1.0)
        _add_log("[color=#00f2fe]🌙 Активирана е нощна кибер атмосфера.[/color]")
    elif "залез" in type:
        env_node.environment.background_color = Color(0.4, 0.15, 0.1)
        sun_light.light_energy = 1.2
        sun_light.light_color = Color(1.0, 0.45, 0.2)
        _add_log("[color=#ff9900]🌅 Залез с топло оранжево осветление.[/color]")
    else:
        env_node.environment.background_color = Color(0.4, 0.6, 0.8)
        sun_light.light_energy = 1.2
        sun_light.light_color = Color(1.0, 0.98, 0.92)
        _add_log("[color=#00ff88]☀️ Дневно слънчево осветление.[/color]")

# СОФТУЕРЕН СИНТЕЗАТОР НА ЗВУК В RAM (0 MB аудио файлове)
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
        var val16 = int(clamp(sample, -1.0, 1.0) * 32767.0)
        pcm.encode_s16(idx * 2, val16)

    var stream = AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = int(sample_rate)
    stream.data = pcm
    audio_player.stream = stream
    audio_player.play()

# УНИВЕРСАЛЕН AI ПРОМПТ ЗА ВСЕКИ ОБЕКТ В СВЕТА С АНИМАЦИИ
func _request_ai_universal_recipe(prompt: String):
    _add_log("[color=#00f2fe]⏳ " + current_model + " проектира универсален модел с физика и анимации...[/color]")
    var url = providers[current_provider_idx]["chat"]
    var headers = ["Authorization: Bearer " + api_key, "Content-Type: application/json"]
    if current_provider_idx == 0:
        headers.append("HTTP-Referer: https://tiptop.engine")
        headers.append("X-Title: TipTop Studio")

    var system_prompt = """You are a Universal 3D Procedural Engine compiler.
Construct ANY object described by the user using 3D geometric primitives.
You can animate parts using the "anim" property.

OUTPUT ONLY RAW VALID JSON (no markdown, no explanations):
{
  "name": "BulgarianName",
  "physics": "static" | "rigid",
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
      "anim": "none" | "spin_y" | "spin_x" | "spin_z" | "bob" | "flap" | "pulse"
    }
  ]
}

RULES:
- Y=0 is ground level. Parts must have Y >= 0.
- For rotating parts (propellers, wheels, clock hands, turbines) use "anim": "spin_y" or "spin_x".
- For hovering crafts/drones/magic use "anim": "bob".
- For wings use "anim": "flap".
- For glowing lights/cores use "anim": "pulse".
- Use between 5 and 14 well-placed parts to make the object unmistakable and detailed."""

    var body = JSON.stringify({
        "model": current_model,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": "Build 3D object: " + prompt}
        ],
        "max_tokens": 1400,
        "temperature": 0.2
    })
    http_request.request(url, headers, HTTPClient.METHOD_POST, body)

# КОМПИЛИРАНЕ НА УНИВЕРСАЛНИЯ МОДЕЛ С PBR И АНИМАЦИОННИ НИШКИ
func _compile_procedural_recipe(raw_json: String):
    var clean_text = raw_json.strip_edges()
    if clean_text.contains("```"):
        var parts = clean_text.split("```")
        for p in parts:
            var trimmed = p.strip_edges()
            if trimmed.begins_with("json"): trimmed = trimmed.substr(4).strip_edges()
            if trimmed.begins_with("{") and trimmed.ends_with("}"):
                clean_text = trimmed
                break

    var s_idx = clean_text.find("{"); var e_idx = clean_text.rfind("}")
    if s_idx != -1 and e_idx != -1 and e_idx > s_idx:
        clean_text = clean_text.substr(s_idx, e_idx - s_idx + 1)

    var regex = RegEx.new()
    regex.compile(",\\s*([\\]\\}])")
    clean_text = regex.sub(clean_text, "$1", true)

    var json = JSON.new()
    if json.parse(clean_text) != OK:
        _add_log("[color=#ff4444]AI върна непълен JSON. Опитай пак с кратка заявка.[/color]")
        return

    var recipe = json.get_data()
    if not recipe is Dictionary or not recipe.has("parts"):
        _add_log("[color=#ff4444]Липсват геометрични части в отговора.[/color]")
        return

    var fwd = -camera.global_transform.basis.z; fwd.y = 0.0
    var spawn_pos = camera.global_position + fwd.normalized() * 6.5; spawn_pos.y = 0.0

    var root_obj = Node3D.new()
    root_obj.position = spawn_pos
    root_obj.name = str(recipe.get("name", "Object"))

    var is_rigid = str(recipe.get("physics", "static")).to_lower() == "rigid"
    var body_node = RigidBody3D.new() if is_rigid else StaticBody3D.new()
    body_node.add_to_group("prop")
    root_obj.add_child(body_node)

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
                var sph = SphereMesh.new(); sph.radius = p_size.x * 0.5; sph.height = p_size.y
                mesh_res = sph
            "cylinder":
                var cyl = CylinderMesh.new(); cyl.top_radius = p_size.x * 0.5; cyl.bottom_radius = p_size.z * 0.5; cyl.height = p_size.y
                mesh_res = cyl
            "torus":
                var tor = TorusMesh.new(); tor.inner_radius = max(0.02, p_size.x * 0.3); tor.outer_radius = p_size.x * 0.5
                mesh_res = tor
            "prism":
                var pr = PrismMesh.new(); pr.size = p_size
                mesh_res = pr
            "capsule":
                var cap = CapsuleMesh.new(); cap.radius = p_size.x * 0.5; cap.height = p_size.y
                mesh_res = cap
            _:
                var b = BoxMesh.new(); b.size = p_size
                mesh_res = b

        mesh_inst.mesh = mesh_res
        mesh_inst.material_override = mat
        mesh_inst.position = p_pos
        mesh_inst.rotation = p_rot
        body_node.add_child(mesh_inst)

        # Регистриране в анимационния конвейер
        if anim_type != "none":
            animated_parts.append({
                "node": mesh_inst,
                "anim": anim_type,
                "base_pos": p_pos,
                "base_rot": p_rot
            })

    # Автоматичен колидър
    var col = CollisionShape3D.new()
    var box_shape = BoxShape3D.new()
    box_shape.size = Vector3(3.2, 3.5, 3.2)
    col.shape = box_shape
    col.position.y = 1.75
    body_node.add_child(col)

    world.add_child(root_obj)
    _select(root_obj)
    _play_sound_synth("magic")
    _add_log("[color=#00ff88]✓ " + root_obj.name + " е създаден с анимации и физика![/color]")
