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

# UI елементи за облачния AI
@onready var api_page = $UI/ApiPage
@onready var provider_select = $UI/ApiPage/Card/Margin/VBox/ProviderSelect
@onready var key_input = $UI/ApiPage/Card/Margin/VBox/KeyInput
@onready var test_btn = $UI/ApiPage/Card/Margin/VBox/TestBtn
@onready var status_lbl = $UI/ApiPage/Card/Margin/VBox/StatusLbl
@onready var model_select = $UI/ApiPage/Card/Margin/VBox/ModelSelect
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
var fetched_models: Array = []
var model_ids_map: Array = []
var is_testing_models: bool = false

func _ready():
    center_tools.visible = false
    indicator.visible = false
    api_page.visible = false
    
    http_request.request_completed.connect(_on_http_response)
    _setup_provider_dropdown()
    _setup_popup_scrolling()
    _load_saved_config()
    
    _add_log("[color=#00ff88]✨ TipTop Генеративен 3D Енджин е активен![/color]")
    _add_log("[color=#00f2fe]Модел:[/color] " + current_model)
    _add_log("[color=#ffff66]💡 Напиши произволен обект (тоалетна, замък, робот, самолет) и AI ще го построи геометрично![/color]")

func _setup_provider_dropdown():
    provider_select.clear()
    provider_select.add_item("🌐 OpenRouter (300+ модела)")
    provider_select.add_item("⚡ Groq (Супер бърз)")
    provider_select.add_item("🤖 OpenAI (ChatGPT)")
    provider_select.add_item("🧠 DeepSeek (V3 / R1)")

func _setup_popup_scrolling():
    var popup = model_select.get_popup()
    if popup:
        popup.max_size = Vector2i(660, 560)
        popup.always_on_top = true
        popup.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS

        var vscroll_grabber = StyleBoxFlat.new()
        vscroll_grabber.bg_color = Color(0.0, 1.0, 0.55, 0.9)
        vscroll_grabber.corner_radius_top_left = 14
        vscroll_grabber.corner_radius_top_right = 14
        vscroll_grabber.corner_radius_bottom_right = 14
        vscroll_grabber.corner_radius_bottom_left = 14
        vscroll_grabber.content_margin_left = 14.0
        vscroll_grabber.content_margin_right = 14.0

        var vscroll_bg = StyleBoxFlat.new()
        vscroll_bg.bg_color = Color(0.06, 0.09, 0.1, 0.95)
        vscroll_bg.corner_radius_top_left = 14
        vscroll_bg.corner_radius_top_right = 14
        vscroll_bg.corner_radius_bottom_right = 14
        vscroll_bg.corner_radius_bottom_left = 14

        popup.add_theme_stylebox_override("scroll", vscroll_bg)
        popup.add_theme_stylebox_override("grabber", vscroll_grabber)
        popup.add_theme_constant_override("v_scroll_width", 28)

func _process(delta):
    if joy.output.length() > 0.05:
        var fwd = -camera.global_transform.basis.z
        var rgt = camera.global_transform.basis.x
        fwd.y = 0.0
        rgt.y = 0.0
        fwd = fwd.normalized()
        rgt = rgt.normalized()
        camera.global_position += (rgt * joy.output.x + fwd * -joy.output.y) * 14.0 * delta

    if selected_obj and is_instance_valid(selected_obj):
        indicator.visible = true
        var bounce = sin(Time.get_ticks_msec() * 0.006) * 0.25
        indicator.global_position = selected_obj.global_position + Vector3(0, 3.2 + bounce, 0)
    else:
        indicator.visible = false

func _unhandled_input(event):
    if api_page.visible:
        return
        
    var screen_h = get_viewport().size.y
    var limit_h = screen_h * 0.65

    if event is InputEventScreenTouch:
        if event.position.y > limit_h:
            return
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
        if event.position.y > limit_h:
            return
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
    if hit != null:
        return hit
    return Vector3.INF

func _select(obj):
    selected_obj = obj
    lbl_selected.text = "🎯 " + obj.name
    center_tools.visible = true

func _deselect():
    selected_obj = null
    center_tools.visible = false

func _on_act_up():
    if selected_obj and is_instance_valid(selected_obj):
        selected_obj.global_position.y += 0.8

func _on_act_down():
    if selected_obj and is_instance_valid(selected_obj):
        selected_obj.global_position.y = max(0.0, selected_obj.global_position.y - 0.8)

func _on_act_rot():
    if selected_obj and is_instance_valid(selected_obj):
        selected_obj.rotate_y(deg_to_rad(45.0))

func _on_act_del():
    if selected_obj and is_instance_valid(selected_obj):
        selected_obj.queue_free()
        _deselect()

func _on_open_settings():
    api_page.visible = true

func _on_close_settings():
    api_page.visible = false
    _save_config()

func _on_confirm_and_enter():
    _save_config()
    api_page.visible = false
    _add_log("[color=#00ff88]✓ Готово! Активен модел:[/color] " + current_model)

func _on_key_submitted(_new_text: String):
    _on_fetch_models_pressed()

func _on_provider_selected(idx: int):
    current_provider_idx = idx
    status_lbl.text = "Доставчик: " + providers[idx]["name"]
    model_select.clear()
    model_select.add_item("Натисни бутона за сваляне на модели...")

func _on_fetch_models_pressed():
    api_key = key_input.text.strip_edges()
    if api_key.is_empty():
        status_lbl.text = "❌ Въведи първо API ключ!"
        status_lbl.modulate = Color(1, 0.3, 0.3)
        return

    is_testing_models = true
    test_btn.disabled = true
    status_lbl.text = "⏳ Сваляне и проверка на моделите..."
    status_lbl.modulate = Color(0, 1, 0.6)

    var url = providers[current_provider_idx]["models_url"]
    var headers = [
        "Authorization: Bearer " + api_key,
        "Content-Type: application/json"
    ]
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
                _populate_models_list(res)
            else:
                status_lbl.text = "❌ Грешка при четене на отговора."
                status_lbl.modulate = Color(1, 0.3, 0.3)
        else:
            status_lbl.text = "❌ Невалиден ключ! (HTTP " + str(response_code) + ")"
            status_lbl.modulate = Color(1, 0.3, 0.3)
    else:
        # Получен отговор за генериране на 3D модел от AI
        if response_code == 200:
            var json = JSON.new()
            if json.parse(body.get_string_from_utf8()) == OK:
                var res = json.get_data()
                var raw_content = res["choices"][0]["message"]["content"].strip_edges()
                _compile_procedural_recipe(raw_content)
            else:
                _add_log("[color=#ff4444]Невалиден JSON отговор от модела.[/color]")
        else:
            _add_log("[color=#ff4444]AI грешка (" + str(response_code) + "). Провери баланса/ключа.[/color]")

func _populate_models_list(data: Dictionary):
    model_select.clear()
    fetched_models.clear()
    model_ids_map.clear()
    
    var list = data.get("data", [])
    if list.is_empty():
        list = data.get("models", [])

    var free_models = []
    var paid_models = []

    for item in list:
        var m_id = ""
        if item is Dictionary:
            m_id = item.get("id", "")
        elif item is String:
            m_id = item
            
        if not m_id.is_empty():
            if ":free" in m_id.to_lower() or "free" in m_id.to_lower():
                free_models.append(m_id)
            else:
                paid_models.append(m_id)

    free_models.sort()
    paid_models.sort()

    model_select.add_item("⚡ АВТОМАТИЧЕН (OpenRouter Free Router)")
    model_ids_map.append("openrouter/free")

    for m in free_models:
        model_select.add_item("🎁 [FREE] " + m)
        model_ids_map.append(m)

    for m in paid_models:
        model_select.add_item("⭐ " + m)
        model_ids_map.append(m)

    fetched_models = model_ids_map

    if fetched_models.size() > 1:
        status_lbl.text = "✅ Намерени " + str(free_models.size()) + " безплатни от " + str(list.size()) + " модела."
        status_lbl.modulate = Color(0, 1, 0.5)
        model_select.selected = 0
        current_model = "openrouter/free"
        current_model_chip.text = "🤖 " + current_model
        _save_config()
    else:
        status_lbl.text = "⚠️ Ключът е валиден, но няма открити модели."
        status_lbl.modulate = Color(1, 0.8, 0.2)

func _on_model_selected(idx: int):
    if idx >= 0 and idx < model_ids_map.size():
        current_model = model_ids_map[idx]
        current_model_chip.text = "🤖 " + current_model
        _save_config()

func _save_config():
    var cfg = {
        "provider": current_provider_idx,
        "api_key": key_input.text.strip_edges(),
        "model": current_model,
        "models": model_ids_map
    }
    var f = FileAccess.open("user://api_config.json", FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify(cfg))

func _load_saved_config():
    if FileAccess.file_exists("user://api_config.json"):
        var f = FileAccess.open("user://api_config.json", FileAccess.READ)
        var json = JSON.new()
        if json.parse(f.get_as_text()) == OK:
            var cfg = json.get_data()
            current_provider_idx = cfg.get("provider", 0)
            provider_select.selected = current_provider_idx
            api_key = cfg.get("api_key", "")
            key_input.text = api_key
            current_model = cfg.get("model", "openrouter/free")
            current_model_chip.text = "🤖 " + current_model
            model_ids_map = cfg.get("models", [])
            if not model_ids_map.is_empty():
                model_select.clear()
                model_select.add_item("⚡ АВТОМАТИЧЕН (OpenRouter Free Router)")
                for idx in range(1, model_ids_map.size()):
                    var m = model_ids_map[idx]
                    if ":free" in m.to_lower():
                        model_select.add_item("🎁 [FREE] " + m)
                    else:
                        model_select.add_item("⭐ " + m)
                var saved_idx = model_ids_map.find(current_model)
                if saved_idx != -1:
                    model_select.selected = saved_idx

func _add_log(msg: String):
    chat_log.append_text(msg + "\n")

func _on_send_chat():
    var t = chat_input.text.strip_edges()
    if t.is_empty():
        return
    chat_input.text = ""
    _add_log("[color=#00ff88]Ти:[/color] " + t)

    if not api_key.is_empty():
        _request_ai_procedural_recipe(t)
    else:
        _add_log("[color=#ffff66]Нямаш въведен API ключ! Натисни '⚙️ AI Облак'.[/color]")

func _on_chip_pressed(txt: String):
    _add_log("[color=#00ff88]Ти:[/color] " + txt)
    if not api_key.is_empty():
        _request_ai_procedural_recipe(txt)
    else:
        _add_log("[color=#ffff66]Нямаш въведен API ключ! Натисни '⚙️ AI Облак'.[/color]")

# СИСТЕМЕН ПРОМПТ ЗА 100% ВАЛИДНА ПРОЦЕДУРНА JSON РЕЦЕПТА
func _request_ai_procedural_recipe(prompt: String):
    _add_log("[color=#00f2fe]⏳ " + current_model + " проектира 3D модела в RAM...[/color]")
    var url = providers[current_provider_idx]["chat"]
    var headers = [
        "Authorization: Bearer " + api_key,
        "Content-Type: application/json"
    ]
    if current_provider_idx == 0:
        headers.append("HTTP-Referer: https://tiptop.engine")
        headers.append("X-Title: TipTop Studio")

    var system_prompt = """Ти си процедурен 3D CAD графичен компилатор.

{
  "name": "ИмеНаОбекта",
  "parts": [
    {
      "shape": "box" | "sphere" | "cylinder" | "torus" | "prism" | "capsule",
      "pos": [x, y, z],
      "size": [width, height, depth],
      "rot": [pitch_deg, yaw_deg, roll_deg],
      "color": "#RRGGBB",
      "metallic": 0.0-1.0,
      "roughness": 0.0-1.0,
      "emission": "#000000"
    }
  ]
}

- За тоалетна чиния: комбинирай цилиндър за основа, кутия за казанче, тор/кутия със заобляне за седалка.
- За кола: правоъгълна кутия за шаси, скосена кутия за кабина, 4 цилиндъра за гуми.
- За замък: цилиндрични кули с конусовидни призми и стени.

    var body = JSON.stringify({
        "model": current_model,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": "Конструирай 3D рецепта за: " + prompt}
        ],
        "temperature": 0.2
    })
    http_request.request(url, headers, HTTPClient.METHOD_POST, body)

# КОМПИЛАТОР НА JSON РЕЦЕПТАТА В РЕАЛНИ 3D MESHES И PBR МАТЕРИАЛИ
func _compile_procedural_recipe(raw_json: String):
    var clean_text = raw_json.strip_edges()
    if clean_text.begins_with("```"):
        clean_text = clean_text.trim_prefix("```json").trim_prefix("```").trim_suffix("```").strip_edges()

    # Търсене на JSON блок ако моделът е написал текст наоколо
    var start_idx = clean_text.find("{")
    var end_idx = clean_text.rfind("}")
    if start_idx != -1 and end_idx != -1 and end_idx > start_idx:
        clean_text = clean_text.substr(start_idx, end_idx - start_idx + 1)

    var json = JSON.new()
    if json.parse(clean_text) != OK:
        _add_log("[color=#ff4444]AI върна невалиден JSON код. Опитай пак.[/color]")
        return

    var recipe = json.get_data()
    if not recipe is Dictionary or not recipe.has("parts"):
        _add_log("[color=#ff4444]Липсват геометрични части в рецептата.[/color]")
        return

    # Спаун позиция пред погледа на камерата
    var fwd = -camera.global_transform.basis.z
    fwd.y = 0.0
    var spawn_pos = camera.global_position + fwd.normalized() * 6.0
    spawn_pos.y = 0.0

    var root_obj = Node3D.new()
    root_obj.position = spawn_pos
    root_obj.name = str(recipe.get("name", "AI_Object"))

    var rb = StaticBody3D.new()
    rb.add_to_group("prop")
    root_obj.add_child(rb)

    var parts = recipe.get("parts", [])
    for part in parts:
        var shape_type = str(part.get("shape", "box")).to_lower()
        var pos_arr = part.get("pos", [0, 0, 0])
        var size_arr = part.get("size", [1, 1, 1])
        var rot_arr = part.get("rot", [0, 0, 0])
        var color_hex = str(part.get("color", "#aaaaaa"))
        var metallic_val = float(part.get("metallic", 0.1))
        var roughness_val = float(part.get("roughness", 0.5))
        var emission_hex = str(part.get("emission", "#000000"))

        var p_pos = Vector3(pos_arr[0], pos_arr[1], pos_arr[2])
        var p_size = Vector3(max(0.05, size_arr[0]), max(0.05, size_arr[1]), max(0.05, size_arr[2]))
        var p_rot = Vector3(deg_to_rad(rot_arr[0]), deg_to_rad(rot_arr[1]), deg_to_rad(rot_arr[2]))

        # PBR Материал с физически свойства
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color.from_string(color_hex, Color.GRAY)
        mat.metallic = metallic_val
        mat.roughness = roughness_val
        if emission_hex != "#000000" and emission_hex != "":
            mat.emission_enabled = true
            mat.emission = Color.from_string(emission_hex, Color.BLACK)
            mat.emission_energy_multiplier = 2.0

        var mesh_inst = MeshInstance3D.new()
        var mesh_res: Mesh = null

        match shape_type:
            "sphere":
                var sph = SphereMesh.new()
                sph.radius = p_size.x * 0.5
                sph.height = p_size.y
                mesh_res = sph
            "cylinder":
                var cyl = CylinderMesh.new()
                cyl.top_radius = p_size.x * 0.5
                cyl.bottom_radius = p_size.z * 0.5
                cyl.height = p_size.y
                mesh_res = cyl
            "torus":
                var tor = TorusMesh.new()
                tor.inner_radius = max(0.02, p_size.x * 0.3)
                tor.outer_radius = p_size.x * 0.5
                mesh_res = tor
            "prism":
                var pr = PrismMesh.new()
                pr.size = p_size
                mesh_res = pr
            "capsule":
                var cap = CapsuleMesh.new()
                cap.radius = p_size.x * 0.5
                cap.height = p_size.y
                mesh_res = cap
            _:
                var b = BoxMesh.new()
                b.size = p_size
                mesh_res = b

        mesh_inst.mesh = mesh_res
        mesh_inst.material_override = mat
        mesh_inst.position = p_pos
        mesh_inst.rotation = p_rot
        rb.add_child(mesh_inst)

    # Общ колидър за целия сглобен обект
    var col = CollisionShape3D.new()
    var box_shape = BoxShape3D.new()
    box_shape.size = Vector3(3.0, 3.0, 3.0)
    col.shape = box_shape
    col.position.y = 1.5
    rb.add_child(col)

    world.add_child(root_obj)
    _select(root_obj)
    _add_log("[color=#00ff88]✓ " + root_obj.name + " е построен успешно в RAM![/color]")
